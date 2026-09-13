import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/features/auth/domain/entities/user_entity.dart';
import 'package:smart_spend/features/auth/domain/usecases/resolve_current_user_usecase.dart';
import 'package:smart_spend/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:smart_spend/features/auth/presentation/providers/auth_notifier.dart';
import 'package:smart_spend/features/auth/presentation/providers/auth_providers.dart';
import 'package:smart_spend/features/auth/presentation/providers/auth_state.dart';
import 'package:smart_spend/features/auth/presentation/providers/common_passwords_provider.dart';
import 'package:smart_spend/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:smart_spend/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:smart_spend/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_spend/features/auth/presentation/screens/register_screen.dart';
import 'package:smart_spend/l10n/gen/app_localizations.dart';

class _FakeResolveCurrentUser extends Mock
    implements ResolveCurrentUserUseCase {}

class _MockSignUp extends Mock implements SignUpWithEmailUseCase {}

void main() {
  testWidgets(
    'a real sign-up through LoginScreen -> RegisterScreen (both under '
    'AuthWrapper) reveals EmailVerificationScreen, not LoginScreen',
    (tester) async {
      final resolveCurrentUser = _FakeResolveCurrentUser();
      when(() => resolveCurrentUser.call()).thenAnswer((_) async => null);
      registerFallbackValue(
        const SignUpWithEmailParams(name: '', email: '', password: ''),
      );
      final signUp = _MockSignUp();
      final user = UserEntity(
        uid: 'u1',
        email: 'a@b.com',
        createdAt: DateTime(2024, 1, 1),
      );
      when(() => signUp.call(any())).thenAnswer((_) async => Right(user));

      final container = ProviderContainer(
        overrides: [
          resolveCurrentUserUseCaseProvider.overrideWithValue(
            resolveCurrentUser,
          ),
          signUpWithEmailUseCaseProvider.overrideWithValue(signUp),
          commonPasswordsProvider.overrideWith((ref) async => const {}),
        ],
      );
      addTearDown(container.dispose);
      container.listen(authProvider, (_, _) {}, fireImmediately: true);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AuthWrapper(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.ensureVisible(find.text('Sign up'));
      await tester.tap(find.text('Sign up'));
      await tester.pump();
      await tester.pump();
      expect(find.byType(RegisterScreen), findsOneWidget);

      // LoginScreen stays mounted (obscured, not disposed) underneath
      // the pushed RegisterScreen, so scope to Register's own fields —
      // `find.byType(TextFormField)` alone would also match Login's.
      final registerFields = find.descendant(
        of: find.byType(RegisterScreen),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(registerFields.at(0), 'Alice');
      await tester.enterText(registerFields.at(1), 'user@example.com');
      await tester.enterText(registerFields.at(2), 'Str0ngPass!x');
      await tester.enterText(registerFields.at(3), 'Str0ngPass!x');

      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(container.read(authProvider), isA<AuthVerifying>());
      expect(find.byType(EmailVerificationScreen), findsOneWidget);
      expect(find.byType(RegisterScreen), findsNothing);
      expect(find.byType(LoginScreen), findsNothing);
    },
  );
}
