import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/state/app_states.dart';
import 'package:smart_spend/core/state/state_providers.dart';
import 'package:smart_spend/core/widgets/adaptive_progress_indicator.dart';
import 'package:smart_spend/features/auth/domain/entities/user_entity.dart';
import 'package:smart_spend/features/auth/domain/usecases/resolve_current_user_usecase.dart';
import 'package:smart_spend/features/auth/presentation/providers/auth_notifier.dart';
import 'package:smart_spend/features/auth/presentation/providers/auth_providers.dart';
import 'package:smart_spend/features/auth/presentation/providers/auth_state.dart';
import 'package:smart_spend/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:smart_spend/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:smart_spend/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_spend/l10n/gen/app_localizations.dart';

class _FakeResolveCurrentUser extends Mock
    implements ResolveCurrentUserUseCase {}

void main() {
  late _FakeResolveCurrentUser resolveCurrentUser;

  setUp(() {
    resolveCurrentUser = _FakeResolveCurrentUser();
  });

  Future<ProviderContainer> pumpWrapper(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        resolveCurrentUserUseCaseProvider.overrideWithValue(
          resolveCurrentUser,
        ),
      ],
    );
    addTearDown(container.dispose);
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
    return container;
  }

  final verifiedUser = UserEntity(
    uid: 'u1',
    email: 'a@b.com',
    isEmailVerified: true,
    createdAt: DateTime(2024, 1, 1),
  );

  final unverifiedUser = UserEntity(
    uid: 'u1',
    email: 'a@b.com',
    isEmailVerified: false,
    createdAt: DateTime(2024, 1, 1),
  );

  testWidgets(
    'shows a bare loading spinner (not LoginScreen) before the boot '
    'resolve settles',
    (tester) async {
      // Never resolves during this test — asserts the default rendering
      // while unresolved is a neutral spinner, not either real screen (a
      // brief flash of LoginScreen for a returning, already-verified
      // user is exactly the bug this guards against).
      final neverCompletes = Completer<UserEntity?>();
      addTearDown(() {
        if (!neverCompletes.isCompleted) neverCompletes.complete(null);
      });
      when(
        () => resolveCurrentUser.call(),
      ).thenAnswer((_) => neverCompletes.future);

      await pumpWrapper(tester);
      await tester.pump();

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(EmailVerificationScreen), findsNothing);
      expect(find.byType(AdaptiveProgressIndicator), findsOneWidget);
    },
  );

  testWidgets(
    'a verified session never leaves the spinner (AppStateListener '
    'replaces the whole route before it would matter)',
    (tester) async {
      when(
        () => resolveCurrentUser.call(),
      ).thenAnswer((_) async => verifiedUser);

      final container = await pumpWrapper(tester);
      await tester.pump();
      await tester.pump();

      expect(
        container.read(appStateProvider),
        const AppState.authenticated(),
      );
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(AdaptiveProgressIndicator), findsOneWidget);
    },
  );

  testWidgets('no session -> stays on LoginScreen', (tester) async {
    when(() => resolveCurrentUser.call()).thenAnswer((_) async => null);

    await pumpWrapper(tester);
    await tester.pump();
    await tester.pump();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets(
    'a session with an unverified email -> switches to EmailVerificationScreen',
    (tester) async {
      when(
        () => resolveCurrentUser.call(),
      ).thenAnswer((_) async => unverifiedUser);

      await pumpWrapper(tester);
      await tester.pump();
      await tester.pump();

      expect(find.byType(EmailVerificationScreen), findsOneWidget);
      expect(find.textContaining('a@b.com'), findsOneWidget);
    },
  );

  testWidgets(
    "a loading blip on authProvider doesn't redirect away from "
    'EmailVerificationScreen (e.g. tapping one of its own buttons)',
    (tester) async {
      when(
        () => resolveCurrentUser.call(),
      ).thenAnswer((_) async => unverifiedUser);
      final container = await pumpWrapper(tester);
      await tester.pump();
      await tester.pump();
      expect(find.byType(EmailVerificationScreen), findsOneWidget);

      // Same transition checkEmailVerifiedNow/resendVerificationEmail/
      // deleteUser put the feature through while they run — AuthWrapper
      // must not treat it as "go back to login".
      container.read(authProvider.notifier).state = const AuthState.loading();
      await tester.pump();

      expect(find.byType(EmailVerificationScreen), findsOneWidget);
    },
  );

  testWidgets(
    "an error blip on authProvider doesn't redirect away from LoginScreen "
    '(e.g. a failed sign-in)',
    (tester) async {
      when(() => resolveCurrentUser.call()).thenAnswer((_) async => null);
      final container = await pumpWrapper(tester);
      await tester.pump();
      await tester.pump();
      expect(find.byType(LoginScreen), findsOneWidget);

      container.read(authProvider.notifier).state = const AuthState.error(
        kind: AuthErrorKind.invalidCredentials,
      );
      await tester.pump();

      expect(find.byType(LoginScreen), findsOneWidget);
    },
  );
}
