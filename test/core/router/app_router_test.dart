import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_spend/core/router/app_router.dart';
import 'package:smart_spend/core/state/app_states.dart';
import 'package:smart_spend/core/state/state_providers.dart';
import 'package:smart_spend/l10n/gen/app_localizations.dart';

/// Bounded stand-in for `pumpAndSettle`: the login screen carries a
/// looping Lottie header, so the tree never truly settles.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

void main() {
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
      final container = ProviderContainer();
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

      // Starts unauthenticated -> login.
      expect(find.text('Onboarding — pendiente'), findsNothing);

      container
          .read(appStateProvider.notifier)
          .update(const AppState.authenticated());
      await _settle(tester);

      // authenticated -> onboarding, per `_pathFor`.
      expect(find.text('Onboarding — pendiente'), findsOneWidget);

      container.read(appStateProvider.notifier).update(const AppState.onboarded());
      await _settle(tester);

      // onboarded -> home.
      expect(find.text('Home — pendiente'), findsOneWidget);
    },
  );

  // Investigating the "session restored but app opens on login anyway"
  // report: main() updates appStateProvider via restoreSession() BEFORE
  // runApp() ever builds AppStateListener. This simulates exactly that
  // ordering: the state is already `authenticated` on the container
  // before the widget tree (and therefore AppStateListener's
  // ref.listen) exists at all.
  testWidgets(
    'a session already restored before the widget tree is built still '
    'lands on the right screen',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // What restoreSession() does, before runApp().
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

      expect(find.text('Onboarding — pendiente'), findsOneWidget);
    },
  );
}
