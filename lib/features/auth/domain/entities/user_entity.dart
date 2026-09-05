import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

/// Represents an authenticated user in the domain layer.
///
/// This is the core user entity used throughout the application.
/// It is immutable and generated using [freezed].
@freezed
abstract class UserEntity with _$UserEntity {
  /// Creates a [UserEntity] with the required user properties.
  ///
  /// - [uid]: The unique identifier of the user.
  /// - [email]: The user's email address.
  /// - [displayName]: The user's display name (optional).
  /// - [photoUrl]: The URL of the user's profile photo (optional).
  /// - [isEmailVerified]: Whether the user's email has been verified.
  const factory UserEntity({
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
  }) = _UserEntity;
}
