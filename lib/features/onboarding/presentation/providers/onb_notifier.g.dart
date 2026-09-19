// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onb_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root for the `onboarding` feature, inlined here instead of
/// a separate `onb_providers.dart` — a single use case doesn't earn its
/// own file. Every link is `keepAlive`: stateless, shared for the whole
/// session.

@ProviderFor(onbFirebaseAuth)
final onbFirebaseAuthProvider = OnbFirebaseAuthProvider._();

/// Composition root for the `onboarding` feature, inlined here instead of
/// a separate `onb_providers.dart` — a single use case doesn't earn its
/// own file. Every link is `keepAlive`: stateless, shared for the whole
/// session.

final class OnbFirebaseAuthProvider
    extends $FunctionalProvider<FirebaseAuth, FirebaseAuth, FirebaseAuth>
    with $Provider<FirebaseAuth> {
  /// Composition root for the `onboarding` feature, inlined here instead of
  /// a separate `onb_providers.dart` — a single use case doesn't earn its
  /// own file. Every link is `keepAlive`: stateless, shared for the whole
  /// session.
  OnbFirebaseAuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onbFirebaseAuthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onbFirebaseAuthHash();

  @$internal
  @override
  $ProviderElement<FirebaseAuth> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FirebaseAuth create(Ref ref) {
    return onbFirebaseAuth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseAuth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseAuth>(value),
    );
  }
}

String _$onbFirebaseAuthHash() => r'448b7d134b9e84bc15124620e4be0df8c34d2baa';

@ProviderFor(onbLocalDataSource)
final onbLocalDataSourceProvider = OnbLocalDataSourceProvider._();

final class OnbLocalDataSourceProvider
    extends
        $FunctionalProvider<
          OnbLocalDataSource,
          OnbLocalDataSource,
          OnbLocalDataSource
        >
    with $Provider<OnbLocalDataSource> {
  OnbLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onbLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onbLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<OnbLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnbLocalDataSource create(Ref ref) {
    return onbLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnbLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnbLocalDataSource>(value),
    );
  }
}

String _$onbLocalDataSourceHash() =>
    r'48ca56ccd2a51c19adbc23ca150dc81dfabe754e';

@ProviderFor(onbRepository)
final onbRepositoryProvider = OnbRepositoryProvider._();

final class OnbRepositoryProvider
    extends $FunctionalProvider<OnbRepository, OnbRepository, OnbRepository>
    with $Provider<OnbRepository> {
  OnbRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onbRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onbRepositoryHash();

  @$internal
  @override
  $ProviderElement<OnbRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OnbRepository create(Ref ref) {
    return onbRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnbRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnbRepository>(value),
    );
  }
}

String _$onbRepositoryHash() => r'5828c6262cd5731555811f2ad903e3cd02637cb9';

@ProviderFor(saveDataUseCase)
final saveDataUseCaseProvider = SaveDataUseCaseProvider._();

final class SaveDataUseCaseProvider
    extends
        $FunctionalProvider<SaveDataUseCase, SaveDataUseCase, SaveDataUseCase>
    with $Provider<SaveDataUseCase> {
  SaveDataUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveDataUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveDataUseCaseHash();

  @$internal
  @override
  $ProviderElement<SaveDataUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SaveDataUseCase create(Ref ref) {
    return saveDataUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveDataUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveDataUseCase>(value),
    );
  }
}

String _$saveDataUseCaseHash() => r'07b05f95642789bfa38d26c1ff8c9911775010da';

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

String _$onbNotifierHash() => r'529f3f42ec0a053fad2370a17349b5bb899cb3ac';

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
