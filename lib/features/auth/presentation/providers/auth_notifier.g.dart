// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the login and register screens (they share this one notifier).
///
/// Holds only presentation state ([AuthState]: normal / loading /
/// error). The source of truth for whether the user is authenticated is
/// the global `appStateProvider`, which this notifier advances to
/// [AppState.authenticated] on a successful sign-in or sign-up. A
/// failure never touches the global state — it stays local as an
/// [AuthState.error]; `AppState.error` is reserved for session-level
/// problems (an unexpected sign-out, a forced update).

@ProviderFor(AuthNotifier)
final authProvider = AuthNotifierProvider._();

/// Drives the login and register screens (they share this one notifier).
///
/// Holds only presentation state ([AuthState]: normal / loading /
/// error). The source of truth for whether the user is authenticated is
/// the global `appStateProvider`, which this notifier advances to
/// [AppState.authenticated] on a successful sign-in or sign-up. A
/// failure never touches the global state — it stays local as an
/// [AuthState.error]; `AppState.error` is reserved for session-level
/// problems (an unexpected sign-out, a forced update).
final class AuthNotifierProvider
    extends $NotifierProvider<AuthNotifier, AuthState> {
  /// Drives the login and register screens (they share this one notifier).
  ///
  /// Holds only presentation state ([AuthState]: normal / loading /
  /// error). The source of truth for whether the user is authenticated is
  /// the global `appStateProvider`, which this notifier advances to
  /// [AppState.authenticated] on a successful sign-in or sign-up. A
  /// failure never touches the global state — it stays local as an
  /// [AuthState.error]; `AppState.error` is reserved for session-level
  /// problems (an unexpected sign-out, a forced update).
  AuthNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: true,
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

String _$authNotifierHash() => r'f7282ab28dc8e30c2b59a2adc291b2a4fa9508e8';

/// Drives the login and register screens (they share this one notifier).
///
/// Holds only presentation state ([AuthState]: normal / loading /
/// error). The source of truth for whether the user is authenticated is
/// the global `appStateProvider`, which this notifier advances to
/// [AppState.authenticated] on a successful sign-in or sign-up. A
/// failure never touches the global state — it stays local as an
/// [AuthState.error]; `AppState.error` is reserved for session-level
/// problems (an unexpected sign-out, a forced update).

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
