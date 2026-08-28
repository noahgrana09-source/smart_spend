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

  /// Emits a result each time a Google sign-in completes outside of an
  /// explicit [signInWithGoogle] call — specifically, on web, where the
  /// rendered Google button (not a widget we control) drives the whole
  /// flow and the result only surfaces through this stream.
  Stream<Either<Failure, UserEntity>> get googleSignInEvents;

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

  /// Returns the currently authenticated user, or `null` if not signed in.
  UserEntity? getCurrentUser();
}
