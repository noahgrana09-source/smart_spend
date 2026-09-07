import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/failures.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Concrete implementation of [AuthRepository].
///
/// Delegates operations to [AuthRemoteDataSource] and maps exceptions
/// to domain [Failure] types using [Either] from dartz. Every successful
/// remote result is also cached into [AuthLocalDataSource] (Drift)
/// best-effort — a cache write failure never turns a successful auth
/// result into a [Failure]; Firebase Auth/Firestore stay the source of
/// truth, Drift is a read cache for the rest of the app.
class AuthRepositoryImpl implements AuthRepository {
  /// The remote data source for authentication operations.
  final AuthRemoteDataSource _remoteDataSource;

  /// The local (Drift) cache of the signed-in user's profile.
  final AuthLocalDataSource _localDataSource;

  /// Creates an [AuthRepositoryImpl] with the given data sources.
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final userModel = await _remoteDataSource.signInWithGoogle();
      unawaited(_cacheLocally(userModel));
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
      unawaited(_cacheLocally(userModel));
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
      unawaited(_cacheLocally(userModel));
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
      unawaited(_clearLocalCache());
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
      unawaited(_clearLocalCache());
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

  @override
  Stream<UserEntity?> watchCurrentUser() {
    unawaited(_backfillIfEmpty());
    return _localDataSource.watchCurrentUser().map((model) => model?.toEntity());
  }

  /// If the local cache is empty but a Firebase Auth session is still
  /// alive, re-fetches the profile from Firestore and re-populates it —
  /// covers a fresh install or a cleared local database while signed in.
  /// If there's no session either, there's nothing to back-fill: that
  /// case belongs to the presentation layer (routing back to
  /// unauthenticated), not to this cache. Best-effort throughout: any
  /// failure is swallowed, the next [watchCurrentUser] subscription
  /// retries.
  Future<void> _backfillIfEmpty() async {
    try {
      if (await _localDataSource.getCurrentUser() != null) return;
      final sessionUser = _remoteDataSource.getCurrentUser();
      if (sessionUser == null) return;
      final profile = await _remoteDataSource.fetchUserProfile(
        sessionUser.uid,
      );
      if (profile != null) await _localDataSource.saveUser(profile);
    } catch (_) {
      // Best-effort.
    }
  }

  /// Best-effort local cache write — see the class doc comment.
  Future<void> _cacheLocally(UserModel userModel) async {
    try {
      await _localDataSource.saveUser(userModel);
    } catch (_) {
      // Best-effort: the next watchCurrentUser() backfill retries.
    }
  }

  Future<void> _clearLocalCache() async {
    try {
      await _localDataSource.clear();
    } catch (_) {
      // Best-effort.
    }
  }
}
