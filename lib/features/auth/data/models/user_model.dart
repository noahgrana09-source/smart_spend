import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' show Value;
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Data model representing a user from Firebase Authentication.
///
/// Maps between Firebase's [firebase.User] and the domain [UserEntity].
/// Uses [freezed] for immutability and [json_serializable] for serialization.
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    /// The unique identifier of the user.
    required String uid,

    /// The user's email address.
    required String email,

    /// The user's display name.
    String? displayName,

    /// The URL of the user's profile photo.
    String? photoUrl,

    /// Whether the user's email has been verified.
    @Default(false) bool isEmailVerified,

    /// The date and time when the user account was created.
    required DateTime createdAt,
  }) = _UserModel;

  /// Private constructor required for adding custom methods to freezed classes.
  const UserModel._();

  /// Creates a [UserModel] from a Firebase [firebase.User].
  factory UserModel.fromFirebaseUser(firebase.User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? (throw FormatException('Email not found')),
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      isEmailVerified: firebaseUser.emailVerified,
      createdAt:
          firebaseUser.metadata.creationTime ??
          (throw FormatException('CreatedAt not found')),
    );
  }

  /// Creates a [UserModel] from a JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Converts this [UserModel] to a Firestore-compatible map.
  ///
  /// The [uid] is omitted because it is used as the document ID.
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isEmailVerified': isEmailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Converts this [UserModel] to a [UserProfilesCompanion] for
  /// [UserProfileDao.saveUser].
  UserProfilesCompanion toDriftCompanion() {
    return UserProfilesCompanion.insert(
      uid: uid,
      email: email,
      displayName: Value(displayName),
      photoUrl: Value(photoUrl),
      isEmailVerified: Value(isEmailVerified),
      createdAt: createdAt,
    );
  }

  /// Converts this [UserModel] to a domain [UserEntity].
  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
    );
  }
}
