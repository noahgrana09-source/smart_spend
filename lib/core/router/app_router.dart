import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/portfolio/presentation/screens/home.dart';
import '../state/app_states.dart';
import '../state/state_providers.dart';

part 'app_router.g.dart';

/// The app's [GoRouter]. Navigation between the three top-level screens
/// isn't driven by `GoRouter.redirect` — [AppStateListener] (wired as
/// `MaterialApp.router`'s `builder`) watches [appStateProvider] and calls
/// `.go(...)` on this router on every change. `go` always replaces the
/// stack, so e.g. an onboarded user can't hit "back" into login.
///
/// `initialLocation` reads the *current* [appStateProvider] value
/// (`ref.read`, not `ref.watch` — this provider is built once and
/// doesn't need to rebuild when the state changes later, that's what
/// [AppStateListener] is for) rather than assuming
/// [AppState.unauthenticated]. `main()` awaits its session-bootstrap
/// step before `runApp()`, so by the time this router is first built, a
/// restored session has already moved `appStateProvider` to
/// [AppState.authenticated] — hardcoding `unauthenticated` here would
/// always open on `/login` regardless.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: _pathFor(ref.read(appStateProvider)),
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
  );
}

String _pathFor(AppState state) => switch (state) {
  AppStateUnauthenticated() => '/login',
  AppStateAuthenticated() => '/onboarding',
  AppStateOnboarded() => '/home',
  AppStateError() => '/login',
};

/// Plug into `MaterialApp.router(builder: (context, child) =>
/// AppStateListener(child: child))`.
///
/// Navigates via the [GoRouter] instance itself
/// (`ref.read(appRouterProvider).go(...)`) rather than `context.go(...)`.
/// The `context` `MaterialApp.router`'s `builder` hands out sits *above*
/// the `Router`/`Navigator` it wraps (`child`) — `InheritedGoRouter`,
/// which `context.go` looks up, lives inside that subtree, so a
/// context-based lookup from here never finds it (it fails silently:
/// the exception is thrown inside this `ref.listen` callback, not
/// `build()`, so it's logged but doesn't crash the app — the screen
/// just never navigates).
///
/// Only reacts to *future* changes of [appStateProvider], not the value
/// already in place when this starts listening — that's exactly what let
/// a session restored before `runApp()` fall through silently (see
/// `appRouterProvider`'s doc comment). `WidgetRef.listen` has no
/// `fireImmediately` option to paper over that here (only
/// `listenManual`, which isn't safe to call from `build`), so the fix
/// for that case lives in `initialLocation` instead.
class AppStateListener extends ConsumerWidget {
  const AppStateListener({required this.child, super.key});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(appStateProvider, (previous, next) {
      ref.read(appRouterProvider).go(_pathFor(next));
    });

    return child ?? const SizedBox.shrink();
  }
}
