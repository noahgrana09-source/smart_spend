import '../../../../core/database/daos/user_profile_dao.dart';
import '../models/user_model.dart';

/// Local (Drift) cache of the signed-in user's profile — a best-effort
/// mirror of Firestore, written on every successful sign-in/up (see
/// `AuthRepositoryImpl`). Firebase Auth/Firestore stay the source of
/// truth for authentication; nothing reads this cache yet.
abstract class AuthLocalDataSource {
  /// Upserts [user] into the cache.
  Future<void> saveUser(UserModel user);

  /// Empties the cache (called on sign-out).
  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final UserProfileDao _dao;

  AuthLocalDataSourceImpl({required UserProfileDao dao}) : _dao = dao;

  @override
  Future<void> saveUser(UserModel user) => _dao.saveUser(user.toDriftCompanion());

  @override
  Future<void> clear() => _dao.clear();
}
