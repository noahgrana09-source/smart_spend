import 'package:equatable/equatable.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/onb_data_entity.dart';

/// Data model representing the user's onboarding data.
///
/// Maps between the local Drift row (`UserProfilesCompanion`/
/// `UserProfile`) and the domain [OnbDataEntity]. Carries `uid` (unlike
/// [OnbDataEntity]) since it's needed to address the row in
/// `UserProfiles` — the datasource resolves it from the current Firebase
/// session and passes it in when building this model.
class OnbDataModel extends Equatable {
  /// The Firebase Auth uid this row belongs to.
  final String uid;

  /// The user's nationality.
  final String nationality;

  /// The user's investor risk profile.
  final String investorProfile;

  /// Creates an [OnbDataModel] with the given [uid], [nationality], and
  /// [investorProfile].
  const OnbDataModel({
    required this.uid,
    required this.nationality,
    required this.investorProfile,
  });

  /// Converts this [OnbDataModel] to a [UserProfilesCompanion] for
  /// [UserProfileDao.saveProfile].
  UserProfilesCompanion toDriftCompanion() {
    return UserProfilesCompanion.insert(
      uid: uid,
      nationality: nationality,
      investorProfile: investorProfile,
    );
  }

  /// Converts this [OnbDataModel] to a domain [OnbDataEntity].
  OnbDataEntity toEntity() {
    return OnbDataEntity(
      nationality: nationality,
      investorProfile: investorProfile,
    );
  }

  @override
  List<Object?> get props => [uid, nationality, investorProfile];
}
