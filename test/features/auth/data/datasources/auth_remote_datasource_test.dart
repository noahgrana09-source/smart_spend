import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/features/auth/data/datasources/auth_remote_datasource.dart';

import '../auth_data_mocks.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocRef;
  late MockDocumentSnapshot mockSnapshot;
  late MockUserCredential mockUserCredential;
  late MockFirebaseUser mockUser;
  late MockUserMetadata mockMetadata;
  late AuthRemoteDataSourceImpl dataSource;
  late MockGoogleSignInAccount mockGoogleSignInAccount;
  late MockGoogleSignInAuthentication mockGoogleSignInAuthentication;

  setUpAll(() {
    registerFallbackValue(SetOptions(merge: false));
    registerFallbackValue(
      GoogleAuthProvider.credential(idToken: 'fallback-token'),
    );
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockGoogleSignIn = MockGoogleSignIn();
    mockCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();
    mockSnapshot = MockDocumentSnapshot();
    mockUserCredential = MockUserCredential();
    mockUser = MockFirebaseUser();
    mockMetadata = MockUserMetadata();
    mockGoogleSignInAccount = MockGoogleSignInAccount();
    mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();

    dataSource = AuthRemoteDataSourceImpl(
      firebaseAuth: mockFirebaseAuth,
      firestore: mockFirestore,
      googleSignIn: mockGoogleSignIn,
    );

    when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
    when(() => mockCollection.doc(any())).thenReturn(mockDocRef);

    when(() => mockUser.uid).thenReturn('uid-123');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockUser.displayName).thenReturn('Test User');
    when(() => mockUser.photoURL).thenReturn(null);
    when(() => mockUser.emailVerified).thenReturn(false);
    when(() => mockUser.metadata).thenReturn(mockMetadata);
    when(() => mockMetadata.creationTime).thenReturn(DateTime(2024, 1, 1));

    when(() => mockUserCredential.user).thenReturn(mockUser);
  });

  group('signUpWithEmailAndPassword', () {
    void stubSuccessfulAccountCreation() {
      when(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => mockUserCredential);
      when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async {});
      when(() => mockUser.reload()).thenAnswer((_) async {});
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.sendEmailVerification()).thenAnswer((_) async {});
    }

    test(
      'creates the profile document when it does not already exist',
      () async {
        stubSuccessfulAccountCreation();
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
        when(() => mockSnapshot.exists).thenReturn(false);
        when(() => mockDocRef.set(any(), any())).thenAnswer((_) async {});

        final result = await dataSource.signUpWithEmailAndPassword(
          email: 'test@example.com',
          password: 'Password1!',
          name: 'Test User',
        );

        expect(result.uid, 'uid-123');
        verify(() => mockDocRef.set(any(), any())).called(1);
        verifyNever(() => mockUser.delete());
        verify(() => mockUser.sendEmailVerification()).called(1);
      },
    );

    test(
      'still returns the UserModel when sending the verification email fails',
      () async {
        stubSuccessfulAccountCreation();
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
        when(() => mockSnapshot.exists).thenReturn(false);
        when(() => mockDocRef.set(any(), any())).thenAnswer((_) async {});
        when(
          () => mockUser.sendEmailVerification(),
        ).thenThrow(FirebaseAuthException(code: 'too-many-requests'));

        final result = await dataSource.signUpWithEmailAndPassword(
          email: 'test@example.com',
          password: 'Password1!',
          name: 'Test User',
        );

        expect(result.uid, 'uid-123');
      },
    );

    test(
      'deletes the just-created user and rethrows when persisting the profile fails',
      () async {
        stubSuccessfulAccountCreation();
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
        when(() => mockSnapshot.exists).thenReturn(false);
        when(() => mockDocRef.set(any(), any())).thenThrow(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
            message: 'Missing or insufficient permissions',
          ),
        );
        when(() => mockUser.delete()).thenAnswer((_) async {});

        await expectLater(
          () => dataSource.signUpWithEmailAndPassword(
            email: 'test@example.com',
            password: 'Password1!',
            name: 'Test User',
          ),
          throwsA(
            isA<UserPersistenceException>().having(
              (e) => e.code,
              'code',
              'permission-denied',
            ),
          ),
        );
        verify(() => mockUser.delete()).called(1);
      },
    );

    test(
      'still surfaces the original persistence error even if the rollback delete itself fails',
      () async {
        stubSuccessfulAccountCreation();
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
        when(() => mockSnapshot.exists).thenReturn(false);
        when(() => mockDocRef.set(any(), any())).thenThrow(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
            message: 'Missing or insufficient permissions',
          ),
        );
        when(
          () => mockUser.delete(),
        ).thenThrow(FirebaseAuthException(code: 'requires-recent-login'));

        await expectLater(
          () => dataSource.signUpWithEmailAndPassword(
            email: 'test@example.com',
            password: 'Password1!',
            name: 'Test User',
          ),
          throwsA(isA<UserPersistenceException>()),
        );
        verify(() => mockUser.delete()).called(1);
      },
    );

    test(
      'throws AuthDataSourceException with a null-user code when account creation returns no user',
      () async {
        when(
          () => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => mockUserCredential);
        when(() => mockUserCredential.user).thenReturn(null);

        await expectLater(
          () => dataSource.signUpWithEmailAndPassword(
            email: 'test@example.com',
            password: 'Password1!',
            name: 'Test User',
          ),
          throwsA(
            isA<AuthDataSourceException>().having(
              (e) => e.code,
              'code',
              'null-user',
            ),
          ),
        );
      },
    );
  });

  group('signInWithEmailAndPassword', () {
    test('returns the UserModel when sign-in succeeds', () async {
      when(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => mockUserCredential);

      final result = await dataSource.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'Password1!',
      );

      expect(result.uid, 'uid-123');
    });

    test(
      'throws AuthDataSourceException with a null-user code when the credential has no user',
      () async {
        when(
          () => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => mockUserCredential);
        when(() => mockUserCredential.user).thenReturn(null);

        await expectLater(
          () => dataSource.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'Password1!',
          ),
          throwsA(
            isA<AuthDataSourceException>().having(
              (e) => e.code,
              'code',
              'null-user',
            ),
          ),
        );
      },
    );
  });

  group('signInWithGoogle', () {
    setUp(() {
      when(() => mockGoogleSignIn.initialize()).thenAnswer((_) async {});
      when(
        () => mockGoogleSignIn.authenticate(),
      ).thenAnswer((_) async => mockGoogleSignInAccount);
      when(
        () => mockGoogleSignInAccount.authentication,
      ).thenReturn(mockGoogleSignInAuthentication);
      when(() => mockGoogleSignInAuthentication.idToken).thenReturn("idToken");
      when(
        () => mockFirebaseAuth.signInWithCredential(any()),
      ).thenAnswer((_) async => mockUserCredential);
      // signInWithGoogle also calls _saveUserToFirestore internally.
      when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(false);
      when(() => mockDocRef.set(any(), any())).thenAnswer((_) async {});
    });
    test('returns UserModel when sign-in with google succedes', () async {
      final result = await dataSource.signInWithGoogle();

      expect(result.uid, 'uid-123');
      verify(() => mockGoogleSignIn.initialize()).called(1);
      verify(() => mockGoogleSignIn.authenticate()).called(1);
      verify(() => mockFirebaseAuth.signInWithCredential(any())).called(1);
      verify(() => mockDocRef.set(any(), any())).called(1);
      verifyNever(() => mockUser.delete());
    });

    test(
      'throws AuthDataSourceException with a null-user code when the credential has no user',
      () async {
        when(() => mockUserCredential.user).thenReturn(null);
        await expectLater(
          () => dataSource.signInWithGoogle(),
          throwsA(
            isA<AuthDataSourceException>().having(
              (e) => e.code,
              'code',
              'null-user',
            ),
          ),
        );
        verify(() => mockFirebaseAuth.signInWithCredential(any())).called(1);
        verifyNever(() => mockDocRef.get());
        verifyNever(() => mockDocRef.set(any(), any()));
        verifyNever(() => mockUser.delete());
      },
    );
  });

  group('signOut', () {
    test(
      'returns once Firebase sign-out completes, without waiting on the '
      'best-effort Google sign-out',
      () async {
        when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});
        when(() => mockGoogleSignIn.initialize()).thenAnswer((_) async {});
        final googleBlock = Completer<void>();
        addTearDown(() {
          if (!googleBlock.isCompleted) googleBlock.complete();
        });
        when(
          () => mockGoogleSignIn.signOut(),
        ).thenAnswer((_) => googleBlock.future);

        // Would hang forever if signOut() awaited the Google part.
        await dataSource.signOut();

        verify(() => mockFirebaseAuth.signOut()).called(1);
      },
    );

    test('a throwing Google sign-out never surfaces', () async {
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});
      when(
        () => mockGoogleSignIn.initialize(),
      ).thenThrow(StateError('not configured'));

      await dataSource.signOut(); // must not throw

      verify(() => mockFirebaseAuth.signOut()).called(1);
    });
  });

  group('sendEmailVerification', () {
    test('calls sendEmailVerification on the current user', () async {
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.sendEmailVerification()).thenAnswer((_) async {});

      await dataSource.sendEmailVerification();

      verify(() => mockUser.sendEmailVerification()).called(1);
    });

    test(
      'throws AuthDataSourceException with a no-current-user code when there is no signed-in user',
      () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        await expectLater(
          () => dataSource.sendEmailVerification(),
          throwsA(
            isA<AuthDataSourceException>().having(
              (e) => e.code,
              'code',
              'no-current-user',
            ),
          ),
        );
      },
    );
  });

  group('reloadAndCheckEmailVerified', () {
    test('reloads the user and returns the fresh emailVerified value',
        () async {
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.reload()).thenAnswer((_) async {});
      when(() => mockUser.emailVerified).thenReturn(true);

      final result = await dataSource.reloadAndCheckEmailVerified();

      expect(result, true);
      verify(() => mockUser.reload()).called(1);
    });

    test('returns false when the reloaded user is still not verified',
        () async {
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.reload()).thenAnswer((_) async {});
      when(() => mockUser.emailVerified).thenReturn(false);

      final result = await dataSource.reloadAndCheckEmailVerified();

      expect(result, false);
    });

    test(
      'throws AuthDataSourceException with a no-current-user code when there is no signed-in user',
      () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        await expectLater(
          () => dataSource.reloadAndCheckEmailVerified(),
          throwsA(
            isA<AuthDataSourceException>().having(
              (e) => e.code,
              'code',
              'no-current-user',
            ),
          ),
        );
      },
    );
  });

  group('deleteCurrentUser', () {
    test('deletes the current user and their Firestore profile', () async {
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.delete()).thenAnswer((_) async {});
      when(() => mockDocRef.delete()).thenAnswer((_) async {});

      await dataSource.deleteCurrentUser();

      verify(() => mockUser.delete()).called(1);
      verify(() => mockCollection.doc('uid-123')).called(1);
      verify(() => mockDocRef.delete()).called(1);
    });

    test(
      'still succeeds when deleting the Firestore profile fails (best-effort)',
      () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.delete()).thenAnswer((_) async {});
        when(() => mockDocRef.delete()).thenThrow(
          FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
        );

        await dataSource.deleteCurrentUser(); // must not throw

        verify(() => mockUser.delete()).called(1);
      },
    );

    test('propagates a failure deleting the user (unlike rollback deletes)',
        () async {
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(
        () => mockUser.delete(),
      ).thenThrow(FirebaseAuthException(code: 'requires-recent-login'));

      await expectLater(
        () => dataSource.deleteCurrentUser(),
        throwsA(isA<FirebaseAuthException>()),
      );
      verifyNever(() => mockDocRef.delete());
    });

    test(
      'throws AuthDataSourceException with a no-current-user code when there is no signed-in user',
      () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        await expectLater(
          () => dataSource.deleteCurrentUser(),
          throwsA(
            isA<AuthDataSourceException>().having(
              (e) => e.code,
              'code',
              'no-current-user',
            ),
          ),
        );
      },
    );
  });

  group('getCurrentUser', () {
    test('returns null when there is no signed-in user', () {
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      expect(dataSource.getCurrentUser(), isNull);
    });

    test('returns the UserModel when there is a signed-in user', () {
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

      final result = dataSource.getCurrentUser();

      expect(result?.uid, 'uid-123');
    });
  });

  group('resolveCurrentUser', () {
    test(
      'returns null once authStateChanges emits with no user, even if '
      'currentUser would say otherwise',
      () async {
        when(
          () => mockFirebaseAuth.authStateChanges(),
        ).thenAnswer((_) => Stream.value(null));
        // Simulates the real race this method exists to avoid: a stale
        // currentUser read while Firebase Auth is still restoring state.
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

        expect(await dataSource.resolveCurrentUser(), isNull);
      },
    );

    test(
      'an already-verified session is returned without reloading',
      () async {
        when(() => mockUser.emailVerified).thenReturn(true);
        when(
          () => mockFirebaseAuth.authStateChanges(),
        ).thenAnswer((_) => Stream.value(mockUser));

        final result = await dataSource.resolveCurrentUser();

        expect(result?.uid, 'uid-123');
        expect(result?.isEmailVerified, true);
        verifyNever(() => mockUser.reload());
      },
    );

    test(
      'an unverified session reloads and re-reads the fresh currentUser '
      '(the cached emailVerified flag can be stale)',
      () async {
        when(() => mockUser.emailVerified).thenReturn(false);
        when(
          () => mockFirebaseAuth.authStateChanges(),
        ).thenAnswer((_) => Stream.value(mockUser));
        when(() => mockUser.reload()).thenAnswer((_) async {});

        // A distinct instance for what `currentUser` returns *after* the
        // reload, so the assertion can only pass if the method actually
        // re-reads it instead of reusing the stale stream value.
        final reloadedUser = MockFirebaseUser();
        when(() => reloadedUser.uid).thenReturn('uid-123');
        when(() => reloadedUser.email).thenReturn('test@example.com');
        when(() => reloadedUser.displayName).thenReturn('Test User');
        when(() => reloadedUser.photoURL).thenReturn(null);
        when(() => reloadedUser.emailVerified).thenReturn(true);
        when(() => reloadedUser.metadata).thenReturn(mockMetadata);
        when(() => mockFirebaseAuth.currentUser).thenReturn(reloadedUser);

        final result = await dataSource.resolveCurrentUser();

        verify(() => mockUser.reload()).called(1);
        expect(result?.isEmailVerified, true);
      },
    );

    test(
      'falls back to the stale cached value when the reload fails '
      '(e.g. offline)',
      () async {
        when(() => mockUser.emailVerified).thenReturn(false);
        when(
          () => mockFirebaseAuth.authStateChanges(),
        ).thenAnswer((_) => Stream.value(mockUser));
        when(() => mockUser.reload()).thenThrow(Exception('offline'));
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        final result = await dataSource.resolveCurrentUser();

        expect(result?.uid, 'uid-123');
        expect(result?.isEmailVerified, false);
      },
    );
  });

  group('fetchUserProfile', () {
    test('returns null when the document does not exist', () async {
      when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(false);

      final result = await dataSource.fetchUserProfile('uid-123');

      expect(result, isNull);
      verify(() => mockFirestore.collection('users')).called(1);
      verify(() => mockCollection.doc('uid-123')).called(1);
    });

    test('returns the UserModel from the document when it exists', () async {
      when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.id).thenReturn('uid-123');
      when(() => mockSnapshot.data()).thenReturn({
        'email': 'test@example.com',
        'displayName': 'Test User',
        'photoUrl': null,
        'isEmailVerified': false,
        'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
      });

      final result = await dataSource.fetchUserProfile('uid-123');

      expect(result?.uid, 'uid-123');
      expect(result?.email, 'test@example.com');
    });
  });
}
