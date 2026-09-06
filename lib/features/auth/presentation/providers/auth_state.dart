import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

/// Which kind of failure the auth screens are showing, so each screen can
/// route the message to the right place: [invalidCredentials] and
/// [emailAlreadyInUse] go under a specific text field (via its
/// validator), [general] and [emailNotVerified] go to the error banner.
enum AuthErrorKind {
  invalidCredentials,
  emailAlreadyInUse,
  general,
  emailNotVerified,
}

/// Presentation state for the login, register, and email-verification
/// screens.
///
/// Not the source of truth for authentication — a successful sign-in
/// advances the global `appStateProvider` to `AppState.authenticated`;
/// see [AuthNotifier]. `AuthState` only covers what those screens render:
/// idle, an in-flight submit, a pending email verification, or the last
/// failure.
@freezed
sealed class AuthState with _$AuthState {
  /// Idle: nothing pending, nothing to show.
  const factory AuthState.normal() = AuthNormal;

  /// A submit is in flight; screens block input and show spinners.
  const factory AuthState.loading() = AuthLoading;

  /// A sign-up just succeeded but [email] isn't verified yet.
  /// `RegisterScreen` listens for this to push `EmailVerificationScreen`;
  /// the global `AppState` only advances to `authenticated` once
  /// verification is confirmed (manually, via the "email verified"
  /// button).
  const factory AuthState.verifying({required String email}) = AuthVerifying;

  /// The last submit failed. [message] is set only for
  /// [AuthErrorKind.general] — the raw failure text for the banner; the
  /// other kinds get a localized string chosen by the screen.
  const factory AuthState.error({
    required AuthErrorKind kind,
    String? message,
  }) = AuthError;
}
