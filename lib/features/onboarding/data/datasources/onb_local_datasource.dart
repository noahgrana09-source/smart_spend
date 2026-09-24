import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/database/daos/user_profile_dao.dart';
import '../models/onb_data_model.dart';
import '../models/onb_user_model.dart';

/// Thrown by [OnbLocalDataSource] operations.
///
/// A stable [code] is assigned here at the throw site, since this is the
/// layer that actually knows why it happened.
class OnbLocalDataSourceException implements Exception {
  final String code;
  final String message;
  const OnbLocalDataSourceException({required this.code, required this.message});

  @override
  String toString() => 'OnbLocalDataSourceException: $message';
}

/// Abstract interface for the onboarding local data source.
///
/// Defines the local (Drift/SQLite) onboarding operations. The data
/// layer's [OnbRepositoryImpl] depends on this, not on the concrete
/// implementation.
abstract class OnbLocalDataSource {
  /// Persists the user's [nationality] and [investorProfile] for the
  /// currently signed-in Firebase user.
  ///
  /// Throws [OnbLocalDataSourceException] if there is no signed-in user.
  Future<OnbDataModel> saveData({
    required String nationality,
    required String investorProfile,
  });

  /// Returns the currently signed-in user's display name.
  ///
  /// Throws [OnbLocalDataSourceException] if there is no signed-in user,
  /// or if the signed-in user has no display name.
  Future<OnbUserModel> getCurrentUser();

  /// Returns the currently signed-in user's onboarding row from
  /// `UserProfiles`, or `null` if there's no signed-in user or no row
  /// for them yet — unlike the other methods here, a missing row isn't
  /// exceptional, it's the normal "hasn't onboarded on this device yet"
  /// state.
  Future<OnbDataModel?> getLocalData();
}

/// Implementation of [OnbLocalDataSource] using Drift, keyed by the
/// current Firebase Auth session's `uid`.
class OnbLocalDataSourceImpl implements OnbLocalDataSource {
  /// The Firebase Authentication instance, used only to resolve the
  /// current `uid` — this datasource has no persistence of its own for
  /// session state.
  final FirebaseAuth _firebaseAuth;

  /// The DAO for the local onboarding profile row.
  final UserProfileDao _userProfileDao;

  OnbLocalDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required UserProfileDao userProfileDao,
  }) : _firebaseAuth = firebaseAuth,
       _userProfileDao = userProfileDao;

  @override
  Future<OnbDataModel> saveData({
    required String nationality,
    required String investorProfile,
  }) async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) {
      throw const OnbLocalDataSourceException(
        code: 'no-current-user',
        message: 'No signed-in user to save onboarding data for',
      );
    }

    final model = OnbDataModel(
      uid: uid,
      nationality: nationality,
      investorProfile: investorProfile,
    );
    await _userProfileDao.saveProfile(model.toDriftCompanion());
    return model;
  }

  @override
  Future<OnbUserModel> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const OnbLocalDataSourceException(
        code: 'no-current-user',
        message: 'No signed-in user to get onboarding data for',
      );
    }
    return OnbUserModel.fromFirebaseUser(user);
  }

  @override
  Future<OnbDataModel?> getLocalData() async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) return null;

    final row = await _userProfileDao.getProfile(uid);
    if (row == null) return null;
    return OnbDataModel.fromRow(row);
  }
}
