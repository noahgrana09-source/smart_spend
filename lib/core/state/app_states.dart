import 'package:freezed_annotation/freezed_annotation.dart';

import '../error/failures.dart';

part 'app_states.freezed.dart';

/// High-level state of the app. `core/router` watches this to decide which
/// screen to show, mirroring the flow in `context/CLAUDE.md`: login ->
/// onboarding -> home.
@freezed
sealed class AppState with _$AppState {
  const factory AppState.unauthenticated() = AppStateUnauthenticated;
  const factory AppState.authenticated() = AppStateAuthenticated;
  const factory AppState.onboarded() = AppStateOnboarded;
  const factory AppState.error(Failure failure) = AppStateError;
}

/// Premium is a one-time purchase, not a subscription, so there's no
/// "expired" state to model.
@freezed
sealed class PaymentState with _$PaymentState {
  const factory PaymentState.standard() = PaymentStateStandard;
  const factory PaymentState.premium() = PaymentStatePremium;
}
