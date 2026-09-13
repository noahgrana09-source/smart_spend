import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/error/failures.dart';
import 'package:smart_spend/features/auth/domain/entities/user_entity.dart';
import 'package:smart_spend/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:smart_spend/features/auth/presentation/providers/auth_providers.dart';
import 'package:smart_spend/features/auth/presentation/providers/common_passwords_provider.dart';
import 'package:smart_spend/features/auth/presentation/screens/register_screen.dart';
import 'package:smart_spend/l10n/gen/app_localizations.dart';

import 'auth_presentation_mocks.dart';

void main() {
  late MockSignUpWithEmailUseCase signUp;

  final user = UserEntity(
    uid: 'u1',
    email: 'a@b.com',
    createdAt: DateTime(2024, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(
      const SignUpWithEmailParams(name: '', email: '', password: ''),
    );
  });

  setUp(() {
    signUp = MockSignUpWithEmailUseCase();
  });

  // RegisterScreen now pops itself (rather than pushing
  // EmailVerificationScreen) once sign-up succeeds — AuthWrapper reacts
  // to the same state change and shows the right thing underneath. So it
  // needs something to pop back to: pushed on top of a plain "open"
  // placeholder, same as `AuthWrapper` -> `LoginScreen` would provide it
  // for real.
  Future<void> pumpRegister(
    WidgetTester tester, {
    Set<String> common = const {'password123'},
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          signUpWithEmailUseCaseProvider.overrideWithValue(signUp),
          commonPasswordsProvider.overrideWith((ref) async => common),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> fill(
    WidgetTester tester, {
    String name = 'Alice',
    String email = 'user@example.com',
    String password = 'Str0ngPass!x',
    String? confirm,
  }) async {
    await tester.enterText(find.byType(TextFormField).at(0), name);
    await tester.enterText(find.byType(TextFormField).at(1), email);
    await tester.enterText(find.byType(TextFormField).at(2), password);
    await tester.enterText(find.byType(TextFormField).at(3), confirm ?? password);
  }

  testWidgets('renders the fields and actions', (tester) async {
    await pumpRegister(tester);

    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Create account'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Already have an account?'), findsOneWidget);
  });

  testWidgets('short password is rejected before the use case', (tester) async {
    await pumpRegister(tester);
    await fill(tester, password: 'aB3\$xy', confirm: 'aB3\$xy');

    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    verifyNever(() => signUp.call(any()));
  });

  testWidgets('common password is rejected before the use case',
      (tester) async {
    await pumpRegister(tester, common: {'password9x'});
    await fill(tester, password: 'password9x', confirm: 'password9x');

    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(
      find.text('That password is too common, pick another one'),
      findsOneWidget,
    );
    verifyNever(() => signUp.call(any()));
  });

  testWidgets('an acceptable password shows the strength hint', (tester) async {
    await pumpRegister(tester);
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Str0ngPass!x',
    );
    await tester.pumpAndSettle();

    expect(find.text('Strong password'), findsOneWidget);
  });

  testWidgets('mismatched confirmation is rejected', (tester) async {
    await pumpRegister(tester);
    await fill(tester, confirm: 'somethingElse1');

    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.text("Passwords don't match"), findsOneWidget);
    verifyNever(() => signUp.call(any()));
  });

  testWidgets('valid form calls the sign-up use case', (tester) async {
    when(() => signUp.call(any())).thenAnswer((_) async => Right(user));
    await pumpRegister(tester);
    await fill(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    verify(() => signUp.call(any())).called(1);
  });

  testWidgets('email-already-in-use surfaces under the email field',
      (tester) async {
    when(() => signUp.call(any())).thenAnswer(
      (_) async => const Left(AuthFailure(code: 'email-already-in-use')),
    );
    await pumpRegister(tester);
    await fill(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(
      find.text('An account with this email already exists'),
      findsOneWidget,
    );
  });

  testWidgets(
    'a successful sign-up pops back (AuthWrapper shows the email '
    'verification screen underneath, in the real app)',
    (tester) async {
      when(() => signUp.call(any())).thenAnswer((_) async => Right(user));
      await pumpRegister(tester);
      await fill(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pumpAndSettle();

      expect(find.text('open'), findsOneWidget);
      expect(find.byType(RegisterScreen), findsNothing);
    },
  );
}
