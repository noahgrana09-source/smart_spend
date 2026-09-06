import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/error/failures.dart';
import 'package:smart_spend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:smart_spend/features/auth/data/models/user_model.dart';
import 'package:smart_spend/features/auth/data/repositories/auth_repository_impl.dart';

import '../auth_data_mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUpAll(() {
    // Needed for the `saveUser(any())` stubs below — mocktail requires a
    // fallback instance for any custom type used with `any()`.
    registerFallbackValue(
      UserModel(
        uid: 'fallback',
        email: 'fallback@example.com',
        createdAt: DateTime(2024, 1, 1),
      ),
    );
  });

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockDataSource,
      localDataSource: mockLocalDataSource,
    );

    // Best-effort local caching happens on every successful remote call —
    // stub it to succeed by default so tests that don't care about it
    // don't need to repeat this. Tests below override these when the
    // caching behavior itself is what's under test.
    when(() => mockLocalDataSource.saveUser(any())).thenAnswer((_) async {});
    when(() => mockLocalDataSource.clear()).thenAnswer((_) async {});
    when(() => mockLocalDataSource.getCurrentUser()).thenAnswer((_) async => null);
    when(
      () => mockLocalDataSource.watchCurrentUser(),
    ).thenAnswer((_) => const Stream.empty());
  });

  final tUserModel = UserModel(
    uid: '123',
    email: 'test@example.com',
    displayName: 'Test User',
    photoUrl: 'https://photo.url',
    isEmailVerified: true,
    createdAt: DateTime(2024, 1, 1),
  );

  final tUserEntity = tUserModel.toEntity();

  group('signInWithGoogle', () {
    test('should return UserEntity when data source succeeds', () async {
      when(
        () => mockDataSource.signInWithGoogle(),
      ).thenAnswer((_) async => tUserModel);

      final result = await repository.signInWithGoogle();

      expect(result, Right(tUserEntity));
      verify(() => mockDataSource.signInWithGoogle()).called(1);
    });

    test(
      'should return AuthFailure when FirebaseAuthException is thrown',
      () async {
        when(() => mockDataSource.signInWithGoogle()).thenThrow(
          FirebaseAuthException(
            code: 'account-exists-with-different-credential',
          ),
        );

        final result = await repository.signInWithGoogle();

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<AuthFailure>());
          expect(failure.code, 'account-exists-with-different-credential');
        }, (_) => fail('Should be Left'));
      },
    );

    test(
      'should return GoogleSignInFailure with the Google code on GoogleSignInException',
      () async {
        when(() => mockDataSource.signInWithGoogle()).thenThrow(
          const GoogleSignInException(
            code: GoogleSignInExceptionCode.interrupted,
          ),
        );

        final result = await repository.signInWithGoogle();

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<GoogleSignInFailure>());
          expect(failure.code, 'interrupted');
        }, (_) => fail('Should be Left'));
      },
    );

    test('should return GoogleSignInFailure on generic Exception', () async {
      when(
        () => mockDataSource.signInWithGoogle(),
      ).thenThrow(Exception('Sign in cancelled'));

      final result = await repository.signInWithGoogle();

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<GoogleSignInFailure>());
        expect(failure.code, 'unknown-error');
      }, (_) => fail('Should be Left'));
    });

    test(
      'should return GoogleSignInFailure with the datasource code on AuthDataSourceException',
      () async {
        when(() => mockDataSource.signInWithGoogle()).thenThrow(
          const AuthDataSourceException(
            code: 'null-user',
            message: 'Firebase sign-in returned null user',
          ),
        );

        final result = await repository.signInWithGoogle();

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<GoogleSignInFailure>());
          expect(failure.code, 'null-user');
        }, (_) => fail('Should be Left'));
      },
    );

    test(
      'should return UserPersistenceFailure when UserPersistenceException is thrown',
      () async {
        when(() => mockDataSource.signInWithGoogle()).thenThrow(
          const UserPersistenceException(
            code: 'permission-denied',
            message: 'Missing or insufficient permissions',
          ),
        );

        final result = await repository.signInWithGoogle();

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<UserPersistenceFailure>());
          expect(failure.code, 'permission-denied');
          expect(failure.message, 'Missing or insufficient permissions');
        }, (_) => fail('Should be Left'));
      },
    );

    test(
      'should return GoogleSignInFailure with an invalid-data code on FormatException',
      () async {
        when(
          () => mockDataSource.signInWithGoogle(),
        ).thenThrow(const FormatException('Email not found'));

        final result = await repository.signInWithGoogle();

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<GoogleSignInFailure>());
          expect(failure.code, 'invalid-data');
        }, (_) => fail('Should be Left'));
      },
    );
  });

  group('signInWithEmailAndPassword', () {
    test('should return UserEntity when data source succeeds', () async {
      when(
        () => mockDataSource.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => tUserModel);

      final result = await repository.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, Right(tUserEntity));
      verify(
        () => mockDataSource.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
    });

    test('should return AuthFailure on FirebaseAuthException', () async {
      when(
        () => mockDataSource.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      final result = await repository.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'wrong',
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.code, 'wrong-password');
      }, (_) => fail('Should be Left'));
    });

    test('should return ServerFailure on generic Exception', () async {
      when(
        () => mockDataSource.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(Exception('Unexpected error'));

      final result = await repository.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.code, 'unknown-error');
      }, (_) => fail('Should be Left'));
    });

    test(
      'should return ServerFailure with the datasource code on AuthDataSourceException',
      () async {
        when(
          () => mockDataSource.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(
          const AuthDataSourceException(
            code: 'null-user',
            message: 'Firebase sign-in returned null user',
          ),
        );

        final result = await repository.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.code, 'null-user');
        }, (_) => fail('Should be Left'));
      },
    );

    test(
      'should return ServerFailure with an invalid-data code on FormatException',
      () async {
        when(
          () => mockDataSource.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const FormatException('Email not found'));

        final result = await repository.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.code, 'invalid-data');
        }, (_) => fail('Should be Left'));
      },
    );
  });

  group('signUpWithEmailAndPassword', () {
    test('should return UserEntity when data source succeeds', () async {
      when(
        () => mockDataSource.signUpWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) async => tUserModel);

      final result = await repository.signUpWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User',
      );

      expect(result, Right(tUserEntity));
      verify(
        () => mockDataSource.signUpWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
        ),
      ).called(1);
    });

    test('should return AuthFailure on FirebaseAuthException', () async {
      when(
        () => mockDataSource.signUpWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      final result = await repository.signUpWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User',
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.code, 'email-already-in-use');
      }, (_) => fail('Should be Left'));
    });

    test('should return ServerFailure on generic Exception', () async {
      when(
        () => mockDataSource.signUpWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenThrow(Exception('Server error'));

      final result = await repository.signUpWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User',
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.code, 'unknown-error');
      }, (_) => fail('Should be Left'));
    });

    test(
      'should return ServerFailure with the datasource code on AuthDataSourceException',
      () async {
        when(
          () => mockDataSource.signUpWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
            name: any(named: 'name'),
          ),
        ).thenThrow(
          const AuthDataSourceException(
            code: 'profile-update-failed',
            message: 'User not found after profile update',
          ),
        );

        final result = await repository.signUpWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
        );

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.code, 'profile-update-failed');
        }, (_) => fail('Should be Left'));
      },
    );

    test(
      'should return UserPersistenceFailure when UserPersistenceException is thrown',
      () async {
        when(
          () => mockDataSource.signUpWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
            name: any(named: 'name'),
          ),
        ).thenThrow(
          const UserPersistenceException(
            code: 'permission-denied',
            message: 'Missing or insufficient permissions',
          ),
        );

        final result = await repository.signUpWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
        );

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<UserPersistenceFailure>());
          expect(failure.code, 'permission-denied');
        }, (_) => fail('Should be Left'));
      },
    );

    test(
      'should return ServerFailure with an invalid-data code on FormatException',
      () async {
        when(
          () => mockDataSource.signUpWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
            name: any(named: 'name'),
          ),
        ).thenThrow(const FormatException('Email not found'));

        final result = await repository.signUpWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
        );

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.code, 'invalid-data');
        }, (_) => fail('Should be Left'));
      },
    );
  });

  group('signOut', () {
    test('should return Right(unit) when sign out succeeds', () async {
      when(() => mockDataSource.signOut()).thenAnswer((_) async {});

      final result = await repository.signOut();

      expect(result, const Right(unit));
      verify(() => mockDataSource.signOut()).called(1);
    });

    test('should return ServerFailure when sign out fails', () async {
      when(
        () => mockDataSource.signOut(),
      ).thenThrow(Exception('Sign out failed'));

      final result = await repository.signOut();

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.code, 'unknown-error');
      }, (_) => fail('Should be Left'));
    });
  });

  group('resendEmailVerification', () {
    test('should return Right(unit) when the data source succeeds', () async {
      when(
        () => mockDataSource.sendEmailVerification(),
      ).thenAnswer((_) async {});

      final result = await repository.resendEmailVerification();

      expect(result, const Right(unit));
      verify(() => mockDataSource.sendEmailVerification()).called(1);
    });

    test('should return ServerFailure on generic Exception', () async {
      when(
        () => mockDataSource.sendEmailVerification(),
      ).thenThrow(Exception('boom'));

      final result = await repository.resendEmailVerification();

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.code, 'unknown-error');
      }, (_) => fail('Should be Left'));
    });

    test(
      'should return ServerFailure with the datasource code on AuthDataSourceException',
      () async {
        when(() => mockDataSource.sendEmailVerification()).thenThrow(
          const AuthDataSourceException(
            code: 'no-current-user',
            message: 'No signed-in user',
          ),
        );

        final result = await repository.resendEmailVerification();

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.code, 'no-current-user');
        }, (_) => fail('Should be Left'));
      },
    );
  });

  group('checkEmailVerified', () {
    test('should return Right(true) when the email is verified', () async {
      when(
        () => mockDataSource.reloadAndCheckEmailVerified(),
      ).thenAnswer((_) async => true);

      final result = await repository.checkEmailVerified();

      expect(result, const Right(true));
    });

    test(
      'should return Right(false) when the email is not verified yet',
      () async {
        when(
          () => mockDataSource.reloadAndCheckEmailVerified(),
        ).thenAnswer((_) async => false);

        final result = await repository.checkEmailVerified();

        expect(result, const Right(false));
      },
    );

    test('should return ServerFailure on generic Exception', () async {
      when(
        () => mockDataSource.reloadAndCheckEmailVerified(),
      ).thenThrow(Exception('boom'));

      final result = await repository.checkEmailVerified();

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.code, 'unknown-error');
      }, (_) => fail('Should be Left'));
    });
  });

  group('getCurrentUser', () {
    test('should return UserEntity when user is authenticated', () {
      when(() => mockDataSource.getCurrentUser()).thenReturn(tUserModel);

      final result = repository.getCurrentUser();

      expect(result, tUserEntity);
      verify(() => mockDataSource.getCurrentUser()).called(1);
    });

    test('should return null when no user is authenticated', () {
      when(() => mockDataSource.getCurrentUser()).thenReturn(null);

      final result = repository.getCurrentUser();

      expect(result, isNull);
      verify(() => mockDataSource.getCurrentUser()).called(1);
    });
  });

  group('resolveCurrentUser', () {
    test('should return UserEntity when a session resolves', () async {
      when(
        () => mockDataSource.resolveCurrentUser(),
      ).thenAnswer((_) async => tUserModel);

      final result = await repository.resolveCurrentUser();

      expect(result, tUserEntity);
      verify(() => mockDataSource.resolveCurrentUser()).called(1);
    });

    test('should return null when no session resolves', () async {
      when(
        () => mockDataSource.resolveCurrentUser(),
      ).thenAnswer((_) async => null);

      final result = await repository.resolveCurrentUser();

      expect(result, isNull);
      verify(() => mockDataSource.resolveCurrentUser()).called(1);
    });
  });

  group('local caching on successful sign-in', () {
    test('signInWithGoogle caches the user locally', () async {
      when(
        () => mockDataSource.signInWithGoogle(),
      ).thenAnswer((_) async => tUserModel);

      await repository.signInWithGoogle();
      await untilCalled(() => mockLocalDataSource.saveUser(any()));

      verify(() => mockLocalDataSource.saveUser(tUserModel)).called(1);
    });

    test('signInWithEmailAndPassword caches the user locally', () async {
      when(
        () => mockDataSource.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => tUserModel);

      await repository.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );
      await untilCalled(() => mockLocalDataSource.saveUser(any()));

      verify(() => mockLocalDataSource.saveUser(tUserModel)).called(1);
    });

    test('signUpWithEmailAndPassword caches the user locally', () async {
      when(
        () => mockDataSource.signUpWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) async => tUserModel);

      await repository.signUpWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User',
      );
      await untilCalled(() => mockLocalDataSource.saveUser(any()));

      verify(() => mockLocalDataSource.saveUser(tUserModel)).called(1);
    });

    test(
      'a local caching failure does not turn a successful sign-in into a Failure',
      () async {
        when(
          () => mockLocalDataSource.saveUser(any()),
        ).thenThrow(Exception('disk full'));
        when(
          () => mockDataSource.signInWithGoogle(),
        ).thenAnswer((_) async => tUserModel);

        final result = await repository.signInWithGoogle();

        expect(result, Right(tUserEntity));
      },
    );
  });

  group('signOut clears the local cache', () {
    test('clears the cache after a successful sign out', () async {
      when(() => mockDataSource.signOut()).thenAnswer((_) async {});

      await repository.signOut();
      await untilCalled(() => mockLocalDataSource.clear());

      verify(() => mockLocalDataSource.clear()).called(1);
    });
  });

  group('watchCurrentUser', () {
    test('maps the local cache stream to UserEntity', () {
      when(
        () => mockLocalDataSource.watchCurrentUser(),
      ).thenAnswer((_) => Stream.value(tUserModel));

      final stream = repository.watchCurrentUser();

      expect(stream, emits(tUserEntity));
    });

    test('emits null when the local cache is empty', () {
      when(
        () => mockLocalDataSource.watchCurrentUser(),
      ).thenAnswer((_) => Stream.value(null));

      final stream = repository.watchCurrentUser();

      expect(stream, emits(isNull));
    });

    group('backfill', () {
      test(
        'fetches from Firestore and caches it when the local cache is '
        'empty but a Firebase session exists',
        () async {
          when(
            () => mockLocalDataSource.getCurrentUser(),
          ).thenAnswer((_) async => null);
          when(() => mockDataSource.getCurrentUser()).thenReturn(tUserModel);
          when(
            () => mockDataSource.fetchUserProfile('123'),
          ).thenAnswer((_) async => tUserModel);

          repository.watchCurrentUser();
          await untilCalled(() => mockLocalDataSource.saveUser(any()));

          verify(() => mockDataSource.fetchUserProfile('123')).called(1);
          verify(() => mockLocalDataSource.saveUser(tUserModel)).called(1);
        },
      );

      test('does nothing when the local cache already has a user', () async {
        when(
          () => mockLocalDataSource.getCurrentUser(),
        ).thenAnswer((_) async => tUserModel);

        repository.watchCurrentUser();
        // Let the fire-and-forget backfill run its course.
        await Future<void>.delayed(Duration.zero);

        verifyNever(() => mockDataSource.fetchUserProfile(any()));
      });

      test('does nothing when there is no Firebase session either', () async {
        when(
          () => mockLocalDataSource.getCurrentUser(),
        ).thenAnswer((_) async => null);
        when(() => mockDataSource.getCurrentUser()).thenReturn(null);

        repository.watchCurrentUser();
        await Future<void>.delayed(Duration.zero);

        verifyNever(() => mockDataSource.fetchUserProfile(any()));
      });
    });
  });
}
