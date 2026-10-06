import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/entities/app_user_entity.dart';
import 'package:smart_spend/core/router/app_router.dart';
import 'package:smart_spend/core/state/app_states.dart';
import 'package:smart_spend/core/state/state_providers.dart';
import 'package:smart_spend/core/usecases/usecase.dart';
import 'package:smart_spend/features/auth/domain/usecases/resolve_current_user_usecase.dart';
import 'package:smart_spend/features/auth/presentation/providers/auth_providers.dart'
    hide getCurrentUserUseCaseProvider;
import 'package:smart_spend/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_spend/features/onboarding/domain/usecases/get_current_user_usecase.dart';
import 'package:smart_spend/features/onboarding/domain/usecases/get_local_data_usecase.dart';
import 'package:smart_spend/features/onboarding/presentation/providers/onb_providers.dart';
import 'package:smart_spend/features/onboarding/presentation/screens/get_you_started_screen.dart';
import 'package:smart_spend/l10n/gen/app_localizations.dart';

class _FakeResolveCurrentUser extends Mock
    implements ResolveCurrentUserUseCase {}

class _FakeGetCurrentUser extends Mock implements GetCurrentUserUseCase {}

class _FakeGetLocalData extends Mock implements GetLocalDataUseCase {}

/// Bounded stand-in for `pumpAndSettle`: the login screen carries a
/// looping Lottie header, so the tree never truly settles.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  // Regression test for a real bug: AppStateListener used to navigate with
  // `context.go(...)`, but the context MaterialApp.router's `builder`
  // hands out sits *above* the Router it wraps, so `InheritedGoRouter`
  // (what context.go looks up) was never found. The lookup threw inside
  // the ref.listen callback — logged, not crashing — so AppState moved
  // but the screen never did. The fix calls `.go()` on the GoRouter
  // instance directly.
  testWidgets(
    'AppStateListener navigates when AppState changes, without a '
    'BuildContext-based GoRouter lookup',
    (tester) async {
      // `/login` renders `AuthWrapper`, which resolves a session through
      // this use case before deciding what to show — stub it so the test
      // never touches real Firebase.
      final resolveCurrentUser = _FakeResolveCurrentUser();
      when(() => resolveCurrentUser.call()).thenAnswer((_) async => null);

      // `/onboarding` renders `OnbWrapper`, which checks for a local
      // `UserProfiles` row through this use case in `initState` — stub
      // it (no row -> falls through to `GetYouStartedScreen`, which
      // resolves the current user through its own use case too).
      final getLocalData = _FakeGetLocalData();
      when(() => getLocalData.call(any())).thenAnswer((_) async => const Right(null));

      final getCurrentUser = _FakeGetCurrentUser();
      when(() => getCurrentUser.call(any())).thenAnswer(
        (_) async =>
            const Right(AppUserEntity(email: 'a@b.com', displayName: 'Noah')),
      );

      final container = ProviderContainer(
        overrides: [
          resolveCurrentUserUseCaseProvider.overrideWithValue(
            resolveCurrentUser,
          ),
          getLocalDataUseCaseProvider.overrideWithValue(getLocalData),
          getCurrentUserUseCaseProvider.overrideWithValue(getCurrentUser),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(appRouterProvider);
              return MaterialApp.router(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                routerConfig: router,
                builder: (context, child) => AppStateListener(child: child),
              );
            },
          ),
        ),
      );
      await _settle(tester);

      // Starts unauthenticated -> login, once AuthWrapper resolves "no
      // session".
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(GetYouStartedScreen), findsNothing);

      container
          .read(appStateProvider.notifier)
          .update(const AppState.authenticated());
      await _settle(tester);

      // authenticated -> onboarding, per `_pathFor`.
      expect(find.byType(GetYouStartedScreen), findsOneWidget);

      container.read(appStateProvider.notifier).update(const AppState.onboarded());
      await _settle(tester);

      // onboarded -> home. `HomeScreen` also reads `getLocalDataUseCaseProvider`
      // (same stub as `OnbWrapper` above, still no local row).
      expect(
        find.text('No local UserProfiles row for this user'),
        findsOneWidget,
      );
    },
  );

  // Investigating the "session restored but app opens on login anyway"
  // report: something updated appStateProvider before runApp() ever
  // built AppStateListener (main()'s own bootstrap used to do this;
  // today a feature wrapper could still race ahead of the widget tree
  // in principle). This simulates exactly that ordering: the state is
  // already `authenticated` on the container before the widget tree
  // (and therefore AppStateListener's ref.listen) exists at all.
  testWidgets(
    'a session already restored before the widget tree is built still '
    'lands on the right screen',
    (tester) async {
      final getLocalData = _FakeGetLocalData();
      when(() => getLocalData.call(any())).thenAnswer((_) async => const Right(null));

      final getCurrentUser = _FakeGetCurrentUser();
      when(() => getCurrentUser.call(any())).thenAnswer(
        (_) async =>
            const Right(AppUserEntity(email: 'a@b.com', displayName: 'Noah')),
      );

      final container = ProviderContainer(
        overrides: [
          getLocalDataUseCaseProvider.overrideWithValue(getLocalData),
          getCurrentUserUseCaseProvider.overrideWithValue(getCurrentUser),
        ],
      );
      addTearDown(container.dispose);

      // Simulates AppState having moved before the widget tree exists.
      container
          .read(appStateProvider.notifier)
          .update(const AppState.authenticated());

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(appRouterProvider);
              return MaterialApp.router(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                routerConfig: router,
                builder: (context, child) => AppStateListener(child: child),
              );
            },
          ),
        ),
      );
      await _settle(tester);

      expect(find.byType(GetYouStartedScreen), findsOneWidget);
    },
  );
}
