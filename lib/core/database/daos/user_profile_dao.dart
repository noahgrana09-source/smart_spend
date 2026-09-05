import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/user_profile_table.dart';

part 'user_profile_dao.g.dart';

@DriftAccessor(tables: [UserProfiles])
class UserProfileDao extends DatabaseAccessor<AppDatabase>
    with _$UserProfileDaoMixin {
  UserProfileDao(super.db);

  /// Reactive read — there's only ever one cached profile per device.
  Stream<UserProfile?> watchCurrentUser() =>
      select(userProfiles).watchSingleOrNull();

  /// One-shot read, used to check whether the cache is empty without
  /// subscribing to the stream (see `AuthRepositoryImpl._backfillIfEmpty`).
  Future<UserProfile?> getCurrentUser() =>
      select(userProfiles).getSingleOrNull();

  Future<void> saveUser(UserProfilesCompanion entry) =>
      into(userProfiles).insertOnConflictUpdate(entry);

  Future<void> clear() => delete(userProfiles).go();
}
