import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/error/failures.dart';
import 'package:smart_spend/core/usecases/usecase.dart';
import 'package:smart_spend/features/auth/domain/entities/user_entity.dart';
import 'package:smart_spend/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:smart_spend/features/auth/presentation/providers/auth_providers.dart';
import 'package:smart_spend/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_spend/l10n/gen/app_localizations.dart';

import 'auth_presentation_mocks.dart';

/// Like `pumpAndSettle`, but bounded: `AuthScaffold`'s Lottie header
/// loops (`repeat: true`), so the tree never truly settles.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

void main() {
  late MockSignInWithEmailUseCase signIn;
  late MockSignInWithGoogleUseCase google;

  final user = UserEntity(
    uid: 'u1',
    email: 'a@b.com',
    createdAt: DateTime(2024, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(
      const SignInWithEmailParams(email: '', password: ''),
    );
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    signIn = MockSignInWithEmailUseCase();
    google = MockSignInWithGoogleUseCase();
  });

  Future<void> pumpLogin(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          signInWithEmailUseCaseProvider.overrideWithValue(signIn),
          signInWithGoogleUseCaseProvider.overrideWithValue(google),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LoginScreen(),
        ),
      ),
    );
    await _settle(tester);
  }

  Future<void> fillValid(WidgetTester tester) async {
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password9');
  }

  testWidgets('renders the fields and actions', (tester) async {
    await pumpLogin(tester);

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text("Don't have an account?"), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
  });

  testWidgets('password field has a working visibility toggle', (tester) async {
    await pumpLogin(tester);

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    expect(find.byIcon(Icons.visibility_outlined), findsNothing);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
  });

  testWidgets('empty submit shows validation, use case not called',
      (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await _settle(tester);

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    verifyNever(() => signIn.call(any()));
  });

  testWidgets('valid submit calls the sign-in use case', (tester) async {
    when(() => signIn.call(any())).thenAnswer((_) async => Right(user));
    await pumpLogin(tester);

    await fillValid(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await _settle(tester);

    verify(() => signIn.call(any())).called(1);
  });

  testWidgets('generic failure shows the error banner', (tester) async {
    when(() => signIn.call(any())).thenAnswer(
      (_) async =>
          const Left(ServerFailure(code: 'x', message: 'Network down')),
    );
    await pumpLogin(tester);

    await fillValid(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await _settle(tester);

    expect(find.text('Network down'), findsOneWidget);
  });

  testWidgets(
    "a general error on login doesn't leak into a freshly opened register",
    (tester) async {
      when(() => signIn.call(any())).thenAnswer(
        (_) async =>
            const Left(ServerFailure(code: 'x', message: 'Network down')),
      );
      await pumpLogin(tester);
      await fillValid(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await _settle(tester);
      expect(find.text('Network down'), findsOneWidget);

      // login and register share one AuthNotifier: without resetting
      // before the push, Register's first build would read the same
      // leftover error and show this banner too.
      await tester.ensureVisible(find.text('Sign up'));
      await tester.tap(find.text('Sign up'));
      await _settle(tester);

      expect(find.text('Create account'), findsWidgets);
      expect(find.text('Network down'), findsNothing);
    },
  );

  testWidgets('invalid credentials surfaces under both fields', (tester) async {
    when(() => signIn.call(any())).thenAnswer(
      (_) async => const Left(AuthFailure(code: 'invalid-credential')),
    );
    await pumpLogin(tester);

    await fillValid(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await _settle(tester);

    // Shown under email and password: either could be the wrong one.
    expect(find.text('Wrong email or password'), findsNWidgets(2));
  });

  testWidgets(
    'a stale credential error clears when returning from register',
    (tester) async {
      when(() => signIn.call(any())).thenAnswer(
        (_) async => const Left(AuthFailure(code: 'invalid-credential')),
      );
      await pumpLogin(tester);
      await fillValid(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await _settle(tester);
      expect(find.text('Wrong email or password'), findsNWidgets(2));

      // Login -> Register.
      await tester.ensureVisible(find.text('Sign up'));
      await tester.tap(find.text('Sign up'));
      await _settle(tester);
      expect(find.text('Create account'), findsWidgets);

      // Register -> back to Login.
      await tester.ensureVisible(find.text('Sign in'));
      await tester.tap(find.text('Sign in'));
      await _settle(tester);

      // The TextFormField would otherwise keep showing the old error
      // text until the user typed again — it doesn't repaint just
      // because the parent rebuilt with a validator that now returns
      // null.
      expect(find.text('Wrong email or password'), findsNothing);
    },
  );

  testWidgets('shows a spinner while the sign-in is in flight', (tester) async {
    final completer = Completer<Either<Failure, UserEntity>>();
    when(() => signIn.call(any())).thenAnswer((_) => completer.future);
    await pumpLogin(tester);

    await fillValid(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);

    completer.complete(Right(user));
    await _settle(tester);
  });
}
