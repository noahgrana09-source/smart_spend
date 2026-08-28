import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_states.dart';

part 'state_providers.g.dart';

/// Starts unauthenticated; the `auth` feature updates this once login,
/// onboarding, or an error is resolved.
@riverpod
class AppStateNotifier extends _$AppStateNotifier {
  @override
  AppState build() => const AppState.unauthenticated();

  void update(AppState newState) => state = newState;
}

/// Starts standard; the `payment` feature updates this once Stripe's
/// webhook confirms the purchase (see `functions/src/index.ts`).
@riverpod
class PaymentStateNotifier extends _$PaymentStateNotifier {
  @override
  PaymentState build() => const PaymentState.standard();

  void update(PaymentState newState) => state = newState;
}
