import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

/// Which kind of failure the auth screens are showing, so each screen can
/// route the message to the right place: [invalidCredentials] and
/// [emailAlreadyInUse] go under a specific text field (via its
/// validator), [general] goes to the error banner.
enum AuthErrorKind { invalidCredentials, emailAlreadyInUse, general }

/// Presentation state for the login and register screens.
///
/// Not the source of truth for authentication — a successful sign-in
/// advances the global `appStateProvider` to `AppState.authenticated`;
/// see [AuthNotifier]. `AuthState` only covers what the two screens
/// render: idle, an in-flight submit, or the last failure.
@freezed
sealed class AuthState with _$AuthState {
  /// Idle: nothing pending, nothing to show.
  const factory AuthState.normal() = AuthNormal;

  /// A submit is in flight; screens block input and show spinners.
  const factory AuthState.loading() = AuthLoading;

  /// The last submit failed. [message] is set only for
  /// [AuthErrorKind.general] — the raw failure text for the banner; the
  /// other kinds get a localized string chosen by the screen.
  const factory AuthState.error({
    required AuthErrorKind kind,
    String? message,
  }) = AuthError;
}
