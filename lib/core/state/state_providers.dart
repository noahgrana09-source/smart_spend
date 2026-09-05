import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_states.dart';

part 'state_providers.g.dart';

/// Starts unauthenticated; the `auth` feature updates this once login,
/// onboarding, or an error is resolved.
///
/// `keepAlive`: this is app-lifetime global state. It must never
/// auto-dispose — the session bootstrap in `main()` sets it during an
/// awaited step, before the widget tree exists to hold a listener, and
/// an auto-disposing provider would garbage-collect that value before
/// the first frame reads it (the app would then always open on login
/// despite a restored session).
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
