import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/state/app_states.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/sign_up_with_email_usecase.dart';
import 'auth_providers.dart';
import 'auth_state.dart';

part 'auth_notifier.g.dart';

/// Drives the login, register, and email-verification screens (they share
/// this one notifier) and owns every session transition — sign-in /
/// Google advance the global `appStateProvider` straight to
/// [AppState.authenticated]; sign-up advances it only once the email is
/// confirmed verified (see [submitSignUp], [checkEmailVerifiedNow]).
/// `submitSignOut` takes it back to [AppState.unauthenticated].
///
/// `AuthState` (normal / loading / verifying / error) is the local screen
/// state; a failed sign-in/up stays local, `AppState.error` is reserved
/// for session-level problems.
///
/// `keepAlive`: these methods touch `ref` *after* an `await`, and are
/// called fire-and-forget from screens that only `ref.read` this
/// notifier (the account screen's sign-out button, say — it doesn't
/// `ref.watch` it). An auto-disposing notifier would be collected
/// mid-await, its `ref` dead by the time the continuation runs — the
/// `appStateProvider` update would throw, the navigation would never
/// happen, and the screen would freeze. Screen-scoped resets are
/// explicit ([reset]), so there's nothing to lose by keeping it alive.
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() => const AuthState.normal();

  /// Back to [AuthState.normal]. `LoginScreen` calls this around the
  /// login<->register round trip so a leftover error from one screen
  /// doesn't leak onto the other — see `_openRegister`.
  void reset() => state = const AuthState.normal();

  Future<void> submitSignIn({
    required String email,
    required String password,
  }) {
    return _run(
      () => ref
          .read(signInWithEmailUseCaseProvider)
          .call(SignInWithEmailParams(email: email, password: password)),
    );
  }

  /// Unlike [submitSignIn]/[submitGoogle] (which run through [_run]), a
  /// successful sign-up doesn't advance the global `AppState` yet — it
  /// moves to [AuthState.verifying] instead, and `AppState` only becomes
  /// `authenticated` once the email is confirmed verified (see
  /// [checkEmailVerifiedNow]).
  Future<void> submitSignUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    final result = await ref
        .read(signUpWithEmailUseCaseProvider)
        .call(SignUpWithEmailParams(name: name, email: email, password: password));
    state = result.fold(
      _mapFailure,
      (user) => AuthState.verifying(email: user.email),
    );
  }

  /// Called from `EmailVerificationScreen`'s "email verified" button:
  /// checks the real Firebase Auth state once. If verified, advances
  /// `AppState` to `authenticated` and returns to [AuthState.normal];
  /// otherwise surfaces [AuthErrorKind.emailNotVerified] for the screen's
  /// error banner.
  Future<void> checkEmailVerifiedNow() async {
    state = const AuthState.loading();
    final result = await ref
        .read(checkEmailVerifiedUseCaseProvider)
        .call(const NoParams());
    state = result.fold(_mapFailure, (isVerified) {
      if (!isVerified) {
        return const AuthState.error(kind: AuthErrorKind.emailNotVerified);
      }
      ref.read(appStateProvider.notifier).update(const AppState.authenticated());
      return const AuthState.normal();
    });
  }

  /// Called from `EmailVerificationScreen`'s "resend email" button.
  Future<void> resendVerificationEmail() async {
    state = const AuthState.loading();
    final result = await ref
        .read(resendEmailVerificationUseCaseProvider)
        .call(const NoParams());
    state = result.fold(_mapFailure, (_) => const AuthState.normal());
  }

  /// Called from `EmailVerificationScreen`'s "back to register" button.
  /// Without this, backing out of that screen would leave the just-created
  /// account sitting unverified in Firebase Auth forever — unreachable
  /// (the user walked away from it) and unrecoverable (nothing ever
  /// deletes it), which defeats the point of requiring verification at
  /// all. A failure surfaces as a general error for the screen's banner;
  /// success returns to normal so the screen can pop.
  Future<void> deleteUser() async {
    state = const AuthState.loading();
    final result = await ref.read(deleteUserUseCaseProvider).call(const NoParams());
    state = result.fold(_mapFailure, (_) => const AuthState.normal());
  }

  Future<void> submitGoogle() {
    return _run(
      () => ref.read(signInWithGoogleUseCaseProvider).call(const NoParams()),
    );
  }

  /// Invoked from the account screen. Success returns the app to
  /// [AppState.unauthenticated]; a failure leaves the global state where
  /// it is (you stay signed in) and surfaces a general [AuthState.error]
  /// for the account screen to show. An *involuntary* sign-out (a token
  /// revoked mid-session) is a separate concern, handled elsewhere.
  Future<void> submitSignOut() async {
    state = const AuthState.loading();
    final result = await ref
        .read(signOutUseCaseProvider)
        .call(const NoParams());
    state = result.fold(
      (failure) => AuthState.error(
        kind: AuthErrorKind.general,
        message: failure.message.isEmpty ? null : failure.message,
      ),
      (_) {
        ref
            .read(appStateProvider.notifier)
            .update(const AppState.unauthenticated());
        return const AuthState.normal();
      },
    );
  }

  /// Flips to [AuthState.loading], awaits [action], then maps the result:
  /// success advances the global app state and returns to normal; a
  /// failure becomes an [AuthState.error] — except a user-cancelled
  /// Google prompt, which is a no-op (back to normal, app stays
  /// unauthenticated).
  Future<void> _run(
    Future<Either<Failure, UserEntity>> Function() action,
  ) async {
    state = const AuthState.loading();
    final result = await action();
    state = result.fold(_mapFailure, (_) {
      ref.read(appStateProvider.notifier).update(const AppState.authenticated());
      return const AuthState.normal();
    });
  }

  AuthState _mapFailure(Failure failure) {
    // Dismissing the native Google prompt isn't an error: stay on the
    // login screen with nothing flagged.
    if (failure.code == 'canceled') return const AuthState.normal();

    return switch (failure.code) {
      'wrong-password' ||
      'user-not-found' ||
      'invalid-credential' ||
      'invalid-login-credentials' => const AuthState.error(
        kind: AuthErrorKind.invalidCredentials,
      ),
      'email-already-in-use' => const AuthState.error(
        kind: AuthErrorKind.emailAlreadyInUse,
      ),
      _ => AuthState.error(
        kind: AuthErrorKind.general,
        message: failure.message.isEmpty ? null : failure.message,
      ),
    };
  }
}
