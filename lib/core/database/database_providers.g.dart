// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The single app-wide Drift/SQLite connection.
///
/// Only other providers — the data-layer DI wiring — depend on this; no
/// widget or notifier reads it directly (the app reaches Drift only
/// through datasources). Kept alive for the whole session and closed
/// when the container is disposed. It lives in `core/` because every
/// feature's persistence shares this one connection: opening a second
/// [AppDatabase] against the same file corrupts Drift's state.

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// The single app-wide Drift/SQLite connection.
///
/// Only other providers — the data-layer DI wiring — depend on this; no
/// widget or notifier reads it directly (the app reaches Drift only
/// through datasources). Kept alive for the whole session and closed
/// when the container is disposed. It lives in `core/` because every
/// feature's persistence shares this one connection: opening a second
/// [AppDatabase] against the same file corrupts Drift's state.

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// The single app-wide Drift/SQLite connection.
  ///
  /// Only other providers — the data-layer DI wiring — depend on this; no
  /// widget or notifier reads it directly (the app reaches Drift only
  /// through datasources). Kept alive for the whole session and closed
  /// when the container is disposed. It lives in `core/` because every
  /// feature's persistence shares this one connection: opening a second
  /// [AppDatabase] against the same file corrupts Drift's state.
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';

/// DAO for the cached user profile, off [appDatabaseProvider]. Consumed
/// only by `features/auth`'s datasource wiring.

@ProviderFor(userProfileDao)
final userProfileDaoProvider = UserProfileDaoProvider._();

/// DAO for the cached user profile, off [appDatabaseProvider]. Consumed
/// only by `features/auth`'s datasource wiring.

final class UserProfileDaoProvider
    extends $FunctionalProvider<UserProfileDao, UserProfileDao, UserProfileDao>
    with $Provider<UserProfileDao> {
  /// DAO for the cached user profile, off [appDatabaseProvider]. Consumed
  /// only by `features/auth`'s datasource wiring.
  UserProfileDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileDaoHash();

  @$internal
  @override
  $ProviderElement<UserProfileDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserProfileDao create(Ref ref) {
    return userProfileDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserProfileDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserProfileDao>(value),
    );
  }
}

String _$userProfileDaoHash() => r'3ee9f13291e15e9568d22fab69f4477e60526e98';
