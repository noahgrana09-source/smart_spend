// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onb_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the onboarding screens and owns the transition to
/// `AppState.onboarded()` once the user's data is saved.
///
/// `keepAlive`: mirrors `AuthNotifier` — [submitSaveData] touches `ref`
/// after an `await`, and an auto-disposing notifier could be collected
/// mid-await if the calling screen only `ref.read`s it.

@ProviderFor(OnbNotifier)
final onbProvider = OnbNotifierProvider._();

/// Drives the onboarding screens and owns the transition to
/// `AppState.onboarded()` once the user's data is saved.
///
/// `keepAlive`: mirrors `AuthNotifier` — [submitSaveData] touches `ref`
/// after an `await`, and an auto-disposing notifier could be collected
/// mid-await if the calling screen only `ref.read`s it.
final class OnbNotifierProvider
    extends $NotifierProvider<OnbNotifier, OnbState> {
  /// Drives the onboarding screens and owns the transition to
  /// `AppState.onboarded()` once the user's data is saved.
  ///
  /// `keepAlive`: mirrors `AuthNotifier` — [submitSaveData] touches `ref`
  /// after an `await`, and an auto-disposing notifier could be collected
  /// mid-await if the calling screen only `ref.read`s it.
  OnbNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onbProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onbNotifierHash();

  @$internal
  @override
  OnbNotifier create() => OnbNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnbState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnbState>(value),
    );
  }
}

String _$onbNotifierHash() => r'2b1aefb7b70cfecbcf4fffbd99154fd3240ee761';

/// Drives the onboarding screens and owns the transition to
/// `AppState.onboarded()` once the user's data is saved.
///
/// `keepAlive`: mirrors `AuthNotifier` — [submitSaveData] touches `ref`
/// after an `await`, and an auto-disposing notifier could be collected
/// mid-await if the calling screen only `ref.read`s it.

abstract class _$OnbNotifier extends $Notifier<OnbState> {
  OnbState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<OnbState, OnbState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OnbState, OnbState>,
              OnbState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
