// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Starts unauthenticated; the `auth` feature updates this once login,
/// onboarding, or an error is resolved.

@ProviderFor(AppStateNotifier)
final appStateProvider = AppStateNotifierProvider._();

/// Starts unauthenticated; the `auth` feature updates this once login,
/// onboarding, or an error is resolved.
final class AppStateNotifierProvider
    extends $NotifierProvider<AppStateNotifier, AppState> {
  /// Starts unauthenticated; the `auth` feature updates this once login,
  /// onboarding, or an error is resolved.
  AppStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appStateProvider',
        isAutoDispose: true,
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

String _$appStateNotifierHash() => r'731b404b2b8536e685ec5425d3cfe300582f9434';

/// Starts unauthenticated; the `auth` feature updates this once login,
/// onboarding, or an error is resolved.

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

@ProviderFor(PaymentStateNotifier)
final paymentStateProvider = PaymentStateNotifierProvider._();

/// Starts standard; the `payment` feature updates this once Stripe's
/// webhook confirms the purchase (see `functions/src/index.ts`).
final class PaymentStateNotifierProvider
    extends $NotifierProvider<PaymentStateNotifier, PaymentState> {
  /// Starts standard; the `payment` feature updates this once Stripe's
  /// webhook confirms the purchase (see `functions/src/index.ts`).
  PaymentStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentStateProvider',
        isAutoDispose: true,
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
    r'69930f07188fe0a1e760a23bf5fc6b3e04b3bb71';

/// Starts standard; the `payment` feature updates this once Stripe's
/// webhook confirms the purchase (see `functions/src/index.ts`).

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
