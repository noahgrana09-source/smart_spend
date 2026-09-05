// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Starts unauthenticated; the `auth` feature updates this once login,
/// onboarding, or an error is resolved.
///
/// `keepAlive`: this is app-lifetime global state. It must never
/// auto-dispose — the session bootstrap in `main()` sets it during an
/// awaited step, before the widget tree exists to hold a listener, and
/// an auto-disposing provider would garbage-collect that value before
/// the first frame reads it (the app would then always open on login
/// despite a restored session).

@ProviderFor(AppStateNotifier)
final appStateProvider = AppStateNotifierProvider._();

/// Starts unauthenticated; the `auth` feature updates this once login,
/// onboarding, or an error is resolved.
///
/// `keepAlive`: this is app-lifetime global state. It must never
/// auto-dispose — the session bootstrap in `main()` sets it during an
/// awaited step, before the widget tree exists to hold a listener, and
/// an auto-disposing provider would garbage-collect that value before
/// the first frame reads it (the app would then always open on login
/// despite a restored session).
final class AppStateNotifierProvider
    extends $NotifierProvider<AppStateNotifier, AppState> {
  /// Starts unauthenticated; the `auth` feature updates this once login,
  /// onboarding, or an error is resolved.
  ///
  /// `keepAlive`: this is app-lifetime global state. It must never
  /// auto-dispose — the session bootstrap in `main()` sets it during an
  /// awaited step, before the widget tree exists to hold a listener, and
  /// an auto-disposing provider would garbage-collect that value before
  /// the first frame reads it (the app would then always open on login
  /// despite a restored session).
  AppStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appStateNotifierHash();

  @$internal
  @override
  AppStateNotifier create() => AppStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppState>(value),
    );
  }
}

String _$appStateNotifierHash() => r'3171865ceb18c5172191109a188e209165917ad0';

/// Starts unauthenticated; the `auth` feature updates this once login,
/// onboarding, or an error is resolved.
///
/// `keepAlive`: this is app-lifetime global state. It must never
/// auto-dispose — the session bootstrap in `main()` sets it during an
/// awaited step, before the widget tree exists to hold a listener, and
/// an auto-disposing provider would garbage-collect that value before
/// the first frame reads it (the app would then always open on login
/// despite a restored session).

abstract class _$AppStateNotifier extends $Notifier<AppState> {
  AppState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppState, AppState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppState, AppState>,
              AppState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Starts standard; the `payment` feature updates this once Stripe's
/// webhook confirms the purchase (see `functions/src/index.ts`).
/// `keepAlive` for the same reason as [AppStateNotifier] — app-lifetime
/// global state.

@ProviderFor(PaymentStateNotifier)
final paymentStateProvider = PaymentStateNotifierProvider._();

/// Starts standard; the `payment` feature updates this once Stripe's
/// webhook confirms the purchase (see `functions/src/index.ts`).
/// `keepAlive` for the same reason as [AppStateNotifier] — app-lifetime
/// global state.
final class PaymentStateNotifierProvider
    extends $NotifierProvider<PaymentStateNotifier, PaymentState> {
  /// Starts standard; the `payment` feature updates this once Stripe's
  /// webhook confirms the purchase (see `functions/src/index.ts`).
  /// `keepAlive` for the same reason as [AppStateNotifier] — app-lifetime
  /// global state.
  PaymentStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentStateNotifierHash();

  @$internal
  @override
  PaymentStateNotifier create() => PaymentStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentState>(value),
    );
  }
}

String _$paymentStateNotifierHash() =>
    r'ec87ff663f1ff5acce724642afbb4bbed5c475f1';

/// Starts standard; the `payment` feature updates this once Stripe's
/// webhook confirms the purchase (see `functions/src/index.ts`).
/// `keepAlive` for the same reason as [AppStateNotifier] — app-lifetime
/// global state.

abstract class _$PaymentStateNotifier extends $Notifier<PaymentState> {
  PaymentState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PaymentState, PaymentState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PaymentState, PaymentState>,
              PaymentState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
