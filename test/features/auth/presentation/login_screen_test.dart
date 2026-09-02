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
    await tester.pumpAndSettle();
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
    expect(find.text("Don't have an account? Sign up"), findsOneWidget);
  });

  testWidgets('empty submit shows validation, use case not called',
      (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    verifyNever(() => signIn.call(any()));
  });

  testWidgets('valid submit calls the sign-in use case', (tester) async {
    when(() => signIn.call(any())).thenAnswer((_) async => Right(user));
    await pumpLogin(tester);

    await fillValid(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();

    expect(find.text('Network down'), findsOneWidget);
  });

  testWidgets('invalid credentials surfaces under the field', (tester) async {
    when(() => signIn.call(any())).thenAnswer(
      (_) async => const Left(AuthFailure(code: 'invalid-credential')),
    );
    await pumpLogin(tester);

    await fillValid(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Wrong email or password'), findsOneWidget);
  });

  testWidgets('shows a spinner while the sign-in is in flight', (tester) async {
    final completer = Completer<Either<Failure, UserEntity>>();
    when(() => signIn.call(any())).thenAnswer((_) => completer.future);
    await pumpLogin(tester);

    await fillValid(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);

    completer.complete(Right(user));
    await tester.pumpAndSettle();
  });
}
