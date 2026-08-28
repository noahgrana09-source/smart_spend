import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/failures.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Concrete implementation of [AuthRepository].
///
/// Delegates operations to [AuthRemoteDataSource] and maps exceptions
/// to domain [Failure] types using [Either] from dartz.
class AuthRepositoryImpl implements AuthRepository {
  /// The remote data source for authentication operations.
  final AuthRemoteDataSource _remoteDataSource;

  /// Creates an [AuthRepositoryImpl] with the given [remoteDataSource].
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

  @override
  Stream<Either<Failure, UserEntity>> get googleSignInEvents {
    return _remoteDataSource.googleSignInEvents.transform(
      StreamTransformer.fromHandlers(
        handleData: (userModel, sink) =>
            sink.add(Right(userModel.toEntity())),
        handleError: (error, stackTrace, sink) =>
            sink.add(Left(_mapGoogleSignInError(error))),
      ),
    );
  }

  /// Maps anything [AuthRemoteDataSource.signInWithGoogle] or
  /// [AuthRemoteDataSource.googleSignInEvents] can throw to a [Failure].
  /// Shared by both so the two Google sign-in entry points (the explicit
  /// call and the web-rendered-button stream) report failures the same
  /// way. Catches non-[Exception] throwables too (e.g. an [Error] from a
  /// misconfigured platform SDK) so callers always get a [Failure] back
  /// instead of an unhandled rejection that would leave the UI stuck in
  /// a loading state forever.
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
  UserEntity? getCurrentUser() {
    return _remoteDataSource.getCurrentUser()?.toEntity();
  }
}
