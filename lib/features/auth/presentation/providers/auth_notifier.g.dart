// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(AuthNotifier)
final authProvider = AuthNotifierProvider._();

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
final class AuthNotifierProvider
    extends $NotifierProvider<AuthNotifier, AuthState> {
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
  AuthNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authNotifierHash();

  @$internal
  @override
  AuthNotifier create() => AuthNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState>(value),
    );
  }
}

String _$authNotifierHash() => r'8af4a564ff0f14b5dee95741f7f906bd83dd111b';

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

abstract class _$AuthNotifier extends $Notifier<AuthState> {
  AuthState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthState, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthState, AuthState>,
              AuthState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
