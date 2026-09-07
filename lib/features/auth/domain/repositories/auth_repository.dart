import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// Abstract contract for the authentication repository.
///
/// Defines all authentication operations available in the domain layer.
/// The data layer must provide a concrete implementation of this interface.
/// All methods return [Either<Failure, T>] for functional error handling.
abstract class AuthRepository {
  /// Signs in the user using Google authentication.
  ///
  /// Returns [UserEntity] on success or a [Failure] on error.
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Signs in the user with email and password credentials.
  ///
  /// Returns [UserEntity] on success or a [Failure] on error.
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Creates a new user account with email, password, and display name.
  ///
  /// Returns [UserEntity] on success or a [Failure] on error.
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  /// Signs out the currently authenticated user.
  ///
  /// Returns [Unit] on success or a [Failure] on error.
  Future<Either<Failure, Unit>> signOut();

  /// Re-sends the verification email to the currently signed-in user.
  ///
  /// Returns [Unit] on success or a [Failure] on error.
  Future<Either<Failure, Unit>> resendEmailVerification();

  /// Reloads the currently signed-in user from Firebase Auth and returns
  /// whether their email is verified now.
  ///
  /// Returns `false` (not a [Failure]) when the reload succeeds but the
  /// email still isn't verified — that's an expected outcome, not an
  /// error.
  Future<Either<Failure, bool>> checkEmailVerified();

  /// Deletes the currently signed-in user's Firebase Auth account.
  ///
  /// Used to clean up an unverified account the user is abandoning (e.g.
  /// backing out of the post-sign-up email-verification screen) — without
  /// this, the account (and its email) would sit unverified forever,
  /// unreachable and unrecoverable.
  Future<Either<Failure, Unit>> deleteUser();

  /// Returns the currently authenticated user, or `null` if not signed in.
  ///
  /// Can spuriously return `null` right after app startup, before
  /// Firebase Auth finishes restoring a persisted session from disk. For
  /// a reliable read at startup, use [resolveCurrentUser] instead.
  UserEntity? getCurrentUser();

  /// Resolves once Firebase Auth has determined whether a session
  /// exists — reliable at app startup, unlike [getCurrentUser].
  Future<UserEntity?> resolveCurrentUser();

  /// Watches the signed-in user's profile from the local Drift cache — a
  /// best-effort mirror of Firestore kept for offline reads elsewhere in
  /// the app (e.g. showing the display name on Home). It is not the
  /// source of truth for *whether* the user is authenticated — that's
  /// Firebase Auth's session, reflected by [getCurrentUser] and the sign
  /// in/out methods above. Emits `null` when there's nothing cached yet.
  Stream<UserEntity?> watchCurrentUser();
}
