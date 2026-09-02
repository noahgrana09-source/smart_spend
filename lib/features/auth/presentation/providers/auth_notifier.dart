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

/// Drives the login and register screens (they share this one notifier).
///
/// Holds only presentation state ([AuthState]: normal / loading /
/// error). The source of truth for whether the user is authenticated is
/// the global `appStateProvider`, which this notifier advances to
/// [AppState.authenticated] on a successful sign-in or sign-up. A
/// failure never touches the global state — it stays local as an
/// [AuthState.error]; `AppState.error` is reserved for session-level
/// problems (an unexpected sign-out, a forced update).
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() => const AuthState.normal();

  /// Back to [AuthState.normal]. Each screen calls this in `initState`
  /// so a leftover error from the other screen doesn't show on entry.
  void reset() => state = const AuthState.normal();

  /// Feature bootstrap, called once from `main` before the first frame
  /// (not from [build], so it can safely advance `appStateProvider`). A
  /// live Firebase Auth session moves the app straight to
  /// [AppState.authenticated]; with no session nothing changes and the
  /// router shows login. Any failure is swallowed — treat it as "no
  /// session".
  void restoreSession() {
    try {
      final user = ref.read(getCurrentUserUseCaseProvider).call();
      if (user != null) {
        ref
            .read(appStateProvider.notifier)
            .update(const AppState.authenticated());
      }
    } catch (_) {
      // No session.
    }
  }

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

  Future<void> submitSignUp({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(
      () => ref
          .read(signUpWithEmailUseCaseProvider)
          .call(
            SignUpWithEmailParams(
              name: name,
              email: email,
              password: password,
            ),
          ),
    );
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
