import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_states.dart';

part 'state_providers.g.dart';

/// Starts unauthenticated; the `auth` feature (`AuthWrapper`, at boot;
/// `AuthNotifier`, on sign-in/up/out) updates this once a session
/// resolves, onboarding finishes, or an error occurs.
///
/// `keepAlive`: this is app-lifetime global state, read and updated from
/// across the whole app for as long as it runs — auto-disposing it the
/// moment nothing happens to be watching it would lose that state
/// outright.
@Riverpod(keepAlive: true)
class AppStateNotifier extends _$AppStateNotifier {
  @override
  AppState build() => const AppState.unauthenticated();

  void update(AppState newState) => state = newState;
}

/// Starts standard; the `payment` feature updates this once Stripe's
/// webhook confirms the purchase (see `functions/src/index.ts`).
/// `keepAlive` for the same reason as [AppStateNotifier] — app-lifetime
/// global state.
@Riverpod(keepAlive: true)
class PaymentStateNotifier extends _$PaymentStateNotifier {
  @override
  PaymentState build() => const PaymentState.standard();

  void update(PaymentState newState) => state = newState;
}
