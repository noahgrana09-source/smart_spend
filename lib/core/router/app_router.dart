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
/// `context.go(...)` on every change. `go` always replaces the stack, so
/// e.g. an onboarded user can't hit "back" into login.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: _pathFor(const AppState.unauthenticated()),
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
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
/// AppStateListener(child: child))` so `context.go` runs on a
/// [BuildContext] that sits inside the router's [Navigator].
class AppStateListener extends ConsumerWidget {
  const AppStateListener({required this.child, super.key});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(appStateProvider, (previous, next) {
      context.go(_pathFor(next));
    });

    return child ?? const SizedBox.shrink();
  }
}
