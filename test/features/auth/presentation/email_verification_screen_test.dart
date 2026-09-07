import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/error/failures.dart';
import 'package:smart_spend/core/state/app_states.dart';
import 'package:smart_spend/core/state/state_providers.dart';
import 'package:smart_spend/core/usecases/usecase.dart';
import 'package:smart_spend/features/auth/presentation/providers/auth_providers.dart';
import 'package:smart_spend/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:smart_spend/l10n/gen/app_localizations.dart';

import 'auth_presentation_mocks.dart';

void main() {
  late MockCheckEmailVerifiedUseCase checkVerified;
  late MockResendEmailVerificationUseCase resendVerification;
  late MockDeleteUserUseCase deleteUser;

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    checkVerified = MockCheckEmailVerifiedUseCase();
    resendVerification = MockResendEmailVerificationUseCase();
    deleteUser = MockDeleteUserUseCase();
  });

  Future<ProviderContainer> pumpScreen(
    WidgetTester tester, {
    String email = 'user@example.com',
  }) async {
    final container = ProviderContainer(
      overrides: [
        checkEmailVerifiedUseCaseProvider.overrideWithValue(checkVerified),
        resendEmailVerificationUseCaseProvider.overrideWithValue(
          resendVerification,
        ),
        deleteUserUseCaseProvider.overrideWithValue(deleteUser),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EmailVerificationScreen(email: email),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('renders the email, description, and the three actions',
      (tester) async {
    await pumpScreen(tester, email: 'alice@example.com');

    expect(find.text('Verify your email'), findsOneWidget);
    expect(find.textContaining('alice@example.com'), findsOneWidget);
    expect(find.text('Email verified'), findsOneWidget);
    expect(find.text('Resend email'), findsOneWidget);
    expect(find.text('Back to register'), findsOneWidget);
  });

  testWidgets(
    'tapping "Email verified" when verified advances AppState to authenticated',
    (tester) async {
      when(
        () => checkVerified.call(any()),
      ).thenAnswer((_) async => const Right(true));
      final container = await pumpScreen(tester);

      await tester.tap(find.text('Email verified'));
      await tester.pumpAndSettle();

      expect(
        container.read(appStateProvider),
        const AppState.authenticated(),
      );
    },
  );

  testWidgets(
    'tapping "Email verified" when not verified shows the error banner',
    (tester) async {
      when(
        () => checkVerified.call(any()),
      ).thenAnswer((_) async => const Right(false));
      final container = await pumpScreen(tester);

      await tester.tap(find.text('Email verified'));
      await tester.pumpAndSettle();

      expect(find.text("Your email isn't verified yet"), findsOneWidget);
      expect(
        container.read(appStateProvider),
        const AppState.unauthenticated(),
      );
    },
  );

  testWidgets('tapping "Resend email" calls the resend use case',
      (tester) async {
    when(
      () => resendVerification.call(any()),
    ).thenAnswer((_) async => const Right(unit));
    await pumpScreen(tester);

    await tester.tap(find.text('Resend email'));
    await tester.pumpAndSettle();

    verify(() => resendVerification.call(any())).called(1);
  });

  testWidgets('a resend failure shows the error banner', (tester) async {
    when(() => resendVerification.call(any())).thenAnswer(
      (_) async =>
          const Left(ServerFailure(code: 'x', message: 'Try again later')),
    );
    await pumpScreen(tester);

    await tester.tap(find.text('Resend email'));
    await tester.pumpAndSettle();

    expect(find.text('Try again later'), findsOneWidget);
  });

  Future<ProviderContainer> pumpBehindAPushedRoute(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        checkEmailVerifiedUseCaseProvider.overrideWithValue(checkVerified),
        resendEmailVerificationUseCaseProvider.overrideWithValue(
          resendVerification,
        ),
        deleteUserUseCaseProvider.overrideWithValue(deleteUser),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) =>
                          const EmailVerificationScreen(email: 'a@b.com'),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Back to register'), findsOneWidget);
    return container;
  }

  testWidgets(
    'tapping "Back to register" deletes the account and pops on success',
    (tester) async {
      when(
        () => deleteUser.call(any()),
      ).thenAnswer((_) async => const Right(unit));
      await pumpBehindAPushedRoute(tester);

      await tester.tap(find.text('Back to register'));
      await tester.pumpAndSettle();

      verify(() => deleteUser.call(any())).called(1);
      expect(find.text('open'), findsOneWidget);
      expect(find.text('Back to register'), findsNothing);
    },
  );

  testWidgets(
    'tapping "Back to register" stays on screen and shows the banner on '
    'failure',
    (tester) async {
      when(() => deleteUser.call(any())).thenAnswer(
        (_) async =>
            const Left(ServerFailure(code: 'x', message: 'Try again later')),
      );
      await pumpBehindAPushedRoute(tester);

      await tester.tap(find.text('Back to register'));
      await tester.pumpAndSettle();

      expect(find.text('open'), findsNothing);
      expect(find.text('Back to register'), findsOneWidget);
      expect(find.text('Try again later'), findsOneWidget);
    },
  );
}
