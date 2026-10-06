import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

import '../../../../core/entities/app_user_entity.dart';
import '../datasources/onb_local_datasource.dart';

/// Data model wrapping the signed-in Firebase user's basic profile.
class OnbUserModel extends Equatable {
  /// The user's email address.
  final String email;

  /// The user's display name.
  final String displayName;

  /// The URL of the user's profile photo, if any.
  final String? photoUrl;

  /// Creates an [OnbUserModel] with the given [email], [displayName], and
  /// optional [photoUrl].
  const OnbUserModel({
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  /// Creates an [OnbUserModel] from a Firebase [firebase.User].
  ///
  /// Throws [OnbLocalDataSourceException] if the user has no email or no
  /// display name — every real sign-up path in this app sets both
  /// (email/password requires a name, Google supplies its own; email is
  /// required by both), so a signed-in user reaching onboarding without
  /// them is an invariant violation, not a valid state to model as
  /// nullable. [photoUrl] stays nullable — email/password sign-up never
  /// sets one.
  factory OnbUserModel.fromFirebaseUser(firebase.User firebaseUser) {
    final displayName = firebaseUser.displayName;
    if (displayName == null) {
      throw const OnbLocalDataSourceException(
        code: 'no-display-name',
        message: 'Signed-in user has no display name',
      );
    }
    final email = firebaseUser.email;
    if (email == null) {
      throw const OnbLocalDataSourceException(
        code: 'no-email',
        message: 'Signed-in user has no email',
      );
    }
    return OnbUserModel(
      email: email,
      displayName: displayName,
      photoUrl: firebaseUser.photoURL,
    );
  }

  /// Converts this [OnbUserModel] to a domain [AppUserEntity].
  AppUserEntity toEntity() {
    return AppUserEntity(
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  @override
  List<Object?> get props => [email, displayName, photoUrl];
}
