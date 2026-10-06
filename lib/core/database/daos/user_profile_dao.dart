import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/user_profile_table.dart';

part 'user_profile_dao.g.dart';

@DriftAccessor(tables: [UserProfiles])
class UserProfileDao extends DatabaseAccessor<AppDatabase>
    with _$UserProfileDaoMixin {
  UserProfileDao(super.db);

  Future<void> saveProfile(UserProfilesCompanion entry) =>
      into(userProfiles).insertOnConflictUpdate(entry);

  Future<UserProfile?> getProfile(String uid) =>
      (select(userProfiles)..where((t) => t.uid.equals(uid))).getSingleOrNull();

  Future<void> clear() => delete(userProfiles).go();
}
