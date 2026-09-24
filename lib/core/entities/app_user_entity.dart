import 'package:equatable/equatable.dart';

/// A read-only, cross-feature view of the signed-in user's basic profile
/// data — not to be confused with `features/auth`'s `UserEntity`, which
/// is auth's own session model (adds `uid`, `isEmailVerified`,
/// `createdAt`) and isn't meant to be read outside that feature. Lives
/// in `core/` because more than one feature needs to show a user's
/// name/email/photo without depending on `auth`.
class AppUserEntity extends Equatable {
  /// The user's email address.
  final String email;

  /// The user's display name.
  final String displayName;

  /// The URL of the user's profile photo, or `null` if they have none
  /// (e.g. signed up with email/password instead of Google).
  final String? photoUrl;

  /// Creates an [AppUserEntity] with the given [email], [displayName],
  /// and optional [photoUrl].
  const AppUserEntity({
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [email, displayName, photoUrl];
}
