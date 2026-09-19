import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failures.dart';

part 'onb_state.freezed.dart';

/// Presentation state for the onboarding screens (nationality + investor
/// profile).
///
/// Not the source of truth for onboarding completion — a successful save
/// advances the global `appStateProvider` to `AppState.onboarded()`; see
/// `OnbNotifier`. `OnbState` only covers what the onboarding screens
/// render: idle, an in-flight submit, or the last failure.
@freezed
sealed class OnbState with _$OnbState {
  /// Idle: nothing pending, nothing to show.
  const factory OnbState.normal() = OnbNormal;

  /// A submit is in flight; screens block input and show spinners.
  const factory OnbState.loading() = OnbLoading;

  /// The last save failed.
  const factory OnbState.error(Failure failure) = OnbError;
}
