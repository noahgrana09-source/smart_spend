import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_database.dart';
import 'daos/user_profile_dao.dart';

part 'database_providers.g.dart';

/// The single app-wide Drift/SQLite connection.
///
/// Only other providers — the data-layer DI wiring — depend on this; no
/// widget or notifier reads it directly (the app reaches Drift only
/// through datasources). Kept alive for the whole session and closed
/// when the container is disposed. It lives in `core/` because every
/// feature's persistence shares this one connection: opening a second
/// [AppDatabase] against the same file corrupts Drift's state.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

/// DAO for the cached user profile, off [appDatabaseProvider]. Consumed
/// only by `features/auth`'s datasource wiring.
@Riverpod(keepAlive: true)
UserProfileDao userProfileDao(Ref ref) =>
    ref.watch(appDatabaseProvider).userProfileDao;
