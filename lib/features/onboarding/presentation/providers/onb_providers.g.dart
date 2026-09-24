// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onb_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root for the `onboarding` feature.
///
/// `domain/` and `data/` stay free of Riverpod; this file assembles the
/// dependency graph (SDK singletons -> datasource -> repository -> use
/// cases) and is the only place presentation reaches into `data/`. Every
/// link is `keepAlive`: they're stateless and shared for the whole
/// session.

@ProviderFor(onbFirebaseAuth)
final onbFirebaseAuthProvider = OnbFirebaseAuthProvider._();

/// Composition root for the `onboarding` feature.
///
/// `domain/` and `data/` stay free of Riverpod; this file assembles the
/// dependency graph (SDK singletons -> datasource -> repository -> use
/// cases) and is the only place presentation reaches into `data/`. Every
/// link is `keepAlive`: they're stateless and shared for the whole
/// session.

final class OnbFirebaseAuthProvider
    extends $FunctionalProvider<FirebaseAuth, FirebaseAuth, FirebaseAuth>
    with $Provider<FirebaseAuth> {
  /// Composition root for the `onboarding` feature.
  ///
  /// `domain/` and `data/` stay free of Riverpod; this file assembles the
  /// dependency graph (SDK singletons -> datasource -> repository -> use
  /// cases) and is the only place presentation reaches into `data/`. Every
  /// link is `keepAlive`: they're stateless and shared for the whole
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

@ProviderFor(getCurrentUserUseCase)
final getCurrentUserUseCaseProvider = GetCurrentUserUseCaseProvider._();

final class GetCurrentUserUseCaseProvider
    extends
        $FunctionalProvider<
          GetCurrentUserUseCase,
          GetCurrentUserUseCase,
          GetCurrentUserUseCase
        >
    with $Provider<GetCurrentUserUseCase> {
  GetCurrentUserUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCurrentUserUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCurrentUserUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCurrentUserUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetCurrentUserUseCase create(Ref ref) {
    return getCurrentUserUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCurrentUserUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCurrentUserUseCase>(value),
    );
  }
}

String _$getCurrentUserUseCaseHash() =>
    r'6c9ec23c1f0304bfdadcc38d3f8009e26aab46a4';

@ProviderFor(getLocalDataUseCase)
final getLocalDataUseCaseProvider = GetLocalDataUseCaseProvider._();

final class GetLocalDataUseCaseProvider
    extends
        $FunctionalProvider<
          GetLocalDataUseCase,
          GetLocalDataUseCase,
          GetLocalDataUseCase
        >
    with $Provider<GetLocalDataUseCase> {
  GetLocalDataUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getLocalDataUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getLocalDataUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetLocalDataUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetLocalDataUseCase create(Ref ref) {
    return getLocalDataUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetLocalDataUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetLocalDataUseCase>(value),
    );
  }
}

String _$getLocalDataUseCaseHash() =>
    r'f6704958f7677004d9c635c06c8037f5bc55d2d0';
