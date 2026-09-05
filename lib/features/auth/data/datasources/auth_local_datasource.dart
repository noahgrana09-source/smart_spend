import '../../../../core/database/daos/user_profile_dao.dart';
import '../models/user_model.dart';

/// Local (Drift) cache of the signed-in user's profile.
///
/// See `AuthRepository.watchCurrentUser` for why this exists alongside
/// the remote datasource — Firebase Auth/Firestore stay the source of
/// truth for authentication, this is just a read cache.
abstract class AuthLocalDataSource {
  /// Reactive read of the cached profile.
  Stream<UserModel?> watchCurrentUser();

  /// One-shot read, used to check whether the cache is empty.
  Future<UserModel?> getCurrentUser();

  /// Upserts [user] into the cache.
  Future<void> saveUser(UserModel user);

  /// Empties the cache (called on sign-out).
  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final UserProfileDao _dao;

  AuthLocalDataSourceImpl({required UserProfileDao dao}) : _dao = dao;

  @override
  Stream<UserModel?> watchCurrentUser() {
    return _dao.watchCurrentUser().map(
      (row) => row == null ? null : UserModel.fromDrift(row),
    );
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final row = await _dao.getCurrentUser();
    return row == null ? null : UserModel.fromDrift(row);
  }

  @override
  Future<void> saveUser(UserModel user) => _dao.saveUser(user.toDriftCompanion());

  @override
  Future<void> clear() => _dao.clear();
}
