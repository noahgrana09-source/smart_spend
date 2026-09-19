import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/failures.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Concrete implementation of [AuthRepository].
///
/// Delegates operations to [AuthRemoteDataSource] and maps exceptions to
/// domain [Failure] types using [Either] from dartz. Deliberately has no
/// local (on-device) persistence of its own: Firebase Auth/Firestore are
/// the only source of truth for a session, and the profile fields this
/// feature deals with (email, display name, verification status) are
/// sensitive enough that caching them in an unencrypted local database
/// for no reader isn't worth the exposure. See "Dual persistence" in the
/// root README for the project-wide pattern this deliberately opts out
/// of, and "Technical decisions" under `auth` for why.
class AuthRepositoryImpl implements AuthRepository {
  /// The remote data source for authentication operations.
  final AuthRemoteDataSource _remoteDataSource;

  /// Creates an [AuthRepositoryImpl] with the given data source.
  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final userModel = await _remoteDataSource.signInWithGoogle();
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(_mapGoogleSignInError(e));
    }
  }

  /// Maps anything [AuthRemoteDataSource.signInWithGoogle] can throw to a
  /// [Failure]. Catches non-[Exception] throwables too (e.g. an [Error]
  /// from a misconfigured platform SDK) so callers always get a
  /// [Failure] back instead of an unhandled rejection that would leave
  /// the UI stuck in a loading state forever.
  Failure _mapGoogleSignInError(Object error) {
    return switch (error) {
      FirebaseAuthException e => AuthFailure(
        code: e.code,
        message: e.message ?? '',
      ),
      GoogleSignInException e => GoogleSignInFailure(
        code: e.code.name,
        message: 'Error at Google Sign In ${e.code}',
      ),
      AuthDataSourceException e => GoogleSignInFailure(
        code: e.code,
        message: e.message,
      ),
      UserPersistenceException e => UserPersistenceFailure(
        code: e.code,
        message: e.message,
      ),
      FormatException e => GoogleSignInFailure(
        code: 'invalid-data',
        message: e.toString(),
      ),
      _ => GoogleSignInFailure(code: 'unknown-error', message: error.toString()),
    };
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(userModel.toEntity());
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(code: e.code, message: e.message ?? ''));
    } on AuthDataSourceException catch (e) {
      return Left(ServerFailure(code: e.code, message: e.message));
    } on FormatException catch (e) {
      return Left(ServerFailure(code: 'invalid-data', message: e.toString()));
    } on Exception catch (e) {
      return Left(ServerFailure(code: 'unknown-error', message: e.toString()));
    } catch (e) {
      return Left(ServerFailure(code: 'unknown-error', message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userModel = await _remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );
      return Right(userModel.toEntity());
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(code: e.code, message: e.message ?? ''));
    } on AuthDataSourceException catch (e) {
      return Left(ServerFailure(code: e.code, message: e.message));
    } on UserPersistenceException catch (e) {
      return Left(UserPersistenceFailure(code: e.code, message: e.message));
    } on FormatException catch (e) {
      return Left(ServerFailure(code: 'invalid-data', message: e.toString()));
    } on Exception catch (e) {
      return Left(ServerFailure(code: 'unknown-error', message: e.toString()));
    } catch (e) {
      return Left(ServerFailure(code: 'unknown-error', message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(unit);
    } on Exception catch (e) {
      return Left(ServerFailure(code: 'unknown-error', message: e.toString()));
    } catch (e) {
      return Left(ServerFailure(code: 'unknown-error', message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> resendEmailVerification() async {
    try {
      await _remoteDataSource.sendEmailVerification();
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(code: e.code, message: e.message ?? ''));
    } on AuthDataSourceException catch (e) {
      return Left(ServerFailure(code: e.code, message: e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(code: 'unknown-error', message: e.toString()));
    } catch (e) {
      return Left(ServerFailure(code: 'unknown-error', message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkEmailVerified() async {
    try {
      final isVerified = await _remoteDataSource.reloadAndCheckEmailVerified();
      return Right(isVerified);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(code: e.code, message: e.message ?? ''));
    } on AuthDataSourceException catch (e) {
      return Left(ServerFailure(code: e.code, message: e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(code: 'unknown-error', message: e.toString()));
    } catch (e) {
      return Left(ServerFailure(code: 'unknown-error', message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteUser() async {
    try {
      await _remoteDataSource.deleteCurrentUser();
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(code: e.code, message: e.message ?? ''));
    } on AuthDataSourceException catch (e) {
      return Left(ServerFailure(code: e.code, message: e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(code: 'unknown-error', message: e.toString()));
    } catch (e) {
      return Left(ServerFailure(code: 'unknown-error', message: e.toString()));
    }
  }

  @override
  UserEntity? getCurrentUser() {
    return _remoteDataSource.getCurrentUser()?.toEntity();
  }

  @override
  Future<UserEntity?> resolveCurrentUser() async {
    final model = await _remoteDataSource.resolveCurrentUser();
    return model?.toEntity();
  }
}
