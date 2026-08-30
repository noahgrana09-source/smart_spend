import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

/// OAuth Client ID for the "Web client (auto created by Google Service)"
/// entry in Google Cloud Console. Unlike Android/iOS, the web platform
/// has no native config file (google-services.json /
/// GoogleService-Info.plist) for google_sign_in_web to read this from —
/// it must be passed explicitly, or GoogleSignIn.initialize() fails on
/// web with an Error (not an Exception) that no catch clause upstream
/// is written to expect, leaving the caller's Future pending forever.
const _webGoogleClientId =
    '782341238024-ds3l96ve505jsd5b12adq88mrssr3rtm.apps.googleusercontent.com';

/// Abstract interface for the authentication remote data source.
///
/// Defines all remote authentication operations that interact with
/// Firebase Auth and Google Sign-In services.

class AuthDataSourceException implements Exception {
  /// A stable identifier for the specific invariant that was violated,
  /// assigned here at the throw site since this is the layer that
  /// actually knows why it happened.
  final String code;
  final String message;
  const AuthDataSourceException({required this.code, required this.message});

  @override
  String toString() => 'AuthDataSourceException: $message';
}

/// Thrown when reading or writing the user's profile document fails.
///
/// Kept separate from [AuthDataSourceException] so the repository can
/// tell "the profile persistence step failed" apart from other
/// datasource-level errors, even though in both cases Firebase Auth
/// itself already succeeded.
class UserPersistenceException implements Exception {
  final String code;
  final String message;
  const UserPersistenceException({required this.code, required this.message});

  @override
  String toString() => 'UserPersistenceException: $message';
}

abstract class AuthRemoteDataSource {
  /// Signs in the user using Google authentication.
  ///
  /// Uses Google Sign-In 7.2.0 with the new reactive API.
  /// Throws [Exception] if the sign-in is cancelled or fails.
  Future<UserModel> signInWithGoogle();

  /// Emits a [UserModel] each time a Google sign-in completes outside of
  /// [signInWithGoogle] — i.e. via the web-rendered Google button, whose
  /// result only ever surfaces through [GoogleSignIn.authenticationEvents].
  /// Emits a stream error (mapped by the repository, same as
  /// [signInWithGoogle]'s thrown exceptions) if completing the sign-in
  /// fails after the Google account was obtained.
  Stream<UserModel> get googleSignInEvents;

  /// Signs in the user with email and password.
  ///
  /// Throws [FirebaseAuthException] on authentication failure.
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Creates a new user account with email, password, and display name.
  ///
  /// Throws [FirebaseAuthException] on account creation failure.
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  /// Signs out the currently authenticated user from all providers.
  Future<void> signOut();

  /// Returns the currently authenticated user, or `null` if not signed in.
  UserModel? getCurrentUser();

  /// Reads the `users/{uid}` document directly from Firestore, or `null`
  /// if it doesn't exist. Used by [AuthRepositoryImpl] to backfill the
  /// local Drift cache when it's empty but a Firebase Auth session is
  /// still alive (fresh install, cleared local database, etc.).
  Future<UserModel?> fetchUserProfile(String uid);
}

/// Implementation of [AuthRemoteDataSource] using Firebase Auth and Google Sign-In.
///
/// Uses Google Sign-In 7.2.0 with the new singleton API:
/// - [GoogleSignIn.instance] for accessing the singleton
/// - [GoogleSignIn.instance.initialize] for initialization
/// - [GoogleSignIn.instance.authenticate] for the sign-in flow
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  /// The Firebase Authentication instance.
  final FirebaseAuth _firebaseAuth;

  /// The Firestore instance for persisting user data.
  final FirebaseFirestore _firestore;

  /// The Google Sign-In instance.
  final GoogleSignIn _googleSignIn;

  /// Whether [_initializeGoogleSignIn] has already run. A second real
  /// call to [GoogleSignIn.initialize] throws `Bad state: init() has
  /// already been called` on web — it is not safe to call more than
  /// once, unlike what an earlier version of this comment assumed.
  bool _googleSignInInitialized = false;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore,
       _googleSignIn = googleSignIn;

  /// Initializes Google Sign-In. Required before *any* use of
  /// [_googleSignIn] in 7.2.0 — not just [signInWithGoogle], [signOut]
  /// needs it too. On web there's no native config file to read the
  /// client ID from (see [_webGoogleClientId]); skipping this call on
  /// web leaves the underlying JS client unusable, and calls to it
  /// then hang indefinitely instead of failing. Passing a clientId on
  /// Android/iOS would override the native config, so it's left null
  /// there and the native SDK resolves it as before. Guarded to run at
  /// most once per instance — see [_googleSignInInitialized].
  Future<void> _initializeGoogleSignIn() async {
    if (_googleSignInInitialized) return;
    await _googleSignIn.initialize(
      clientId: kIsWeb ? _webGoogleClientId : null,
    );
    _googleSignInInitialized = true;
  }

  /// Everything that happens once a [GoogleSignInAccount] has been
  /// obtained, regardless of whether it came from [signInWithGoogle]'s
  /// [GoogleSignIn.authenticate] call or from a sign-in event on
  /// [googleSignInEvents]: exchange it for a Firebase credential, sign
  /// in to Firebase, and persist the user's profile (rolling back the
  /// just-created account if persistence fails).
  Future<UserModel> _completeGoogleSignIn(
    GoogleSignInAccount googleUser,
  ) async {
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _firebaseAuth
        .signInWithCredential(credential);

    final User? user = userCredential.user;
    if (user == null) {
      throw const AuthDataSourceException(
        code: 'null-user',
        message: 'Firebase sign-in returned null user',
      );
    }

    final userModel = UserModel.fromFirebaseUser(user);

    try {
      await _saveUserToFirestore(userModel);
    } catch (e) {
      // Only roll back if this sign-in just created the account: an
      // existing user must never be deleted over a transient failure
      // reading/writing its profile.
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _deleteUser(user);
      }
      rethrow;
    }

    return userModel;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    await _initializeGoogleSignIn();

    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
    return _completeGoogleSignIn(googleUser);
  }

  @override
  Stream<UserModel> get googleSignInEvents {
    // Unlike signInWithGoogle/signOut, nothing else calls
    // _initializeGoogleSignIn before this stream is subscribed to — on
    // web specifically, this is the only path left that would ever
    // trigger it, and the rendered Google button needs the client
    // initialized to show anything at all (without it, it's stuck on
    // Google's own "Getting ready" placeholder forever).
    return Stream.fromFuture(_initializeGoogleSignIn()).asyncExpand(
      (_) => _googleSignIn.authenticationEvents
          .where((event) => event is GoogleSignInAuthenticationEventSignIn)
          .cast<GoogleSignInAuthenticationEventSignIn>()
          .asyncMap((event) => _completeGoogleSignIn(event.user)),
    );
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final UserCredential userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);

    final User? user = userCredential.user;
    if (user == null) {
      throw const AuthDataSourceException(
        code: 'null-user',
        message: 'Firebase sign-in returned null user',
      );
    }

    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    final UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);

    final User? user = userCredential.user;
    if (user == null) {
      throw const AuthDataSourceException(
        code: 'null-user',
        message: 'Firebase sign-up returned null user',
      );
    }

    await user.updateDisplayName(name);
    await user.reload();

    final User? updatedUser = _firebaseAuth.currentUser;
    if (updatedUser == null) {
      throw const AuthDataSourceException(
        code: 'profile-update-failed',
        message: 'User not found after profile update',
      );
    }

    final userModel = UserModel.fromFirebaseUser(updatedUser);
    try {
      await _saveUserToFirestore(userModel);
    } catch (e) {
      // This account was just created in this same call, so it is
      // always safe to roll it back: undo the sign-up rather than
      // leaving an orphaned Firebase Auth account with no profile,
      // which would block retrying with the same email.
      await _deleteUser(updatedUser);
      rethrow;
    }
    return userModel;
  }

  @override
  Future<void> signOut() async {
    await _initializeGoogleSignIn();
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }

  @override
  UserModel? getCurrentUser() {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<UserModel?> fetchUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Best-effort rollback: deletes [user] if the account was left
  /// without a persisted profile. Swallows any secondary failure so
  /// the original persistence error is what gets surfaced regardless.
  Future<void> _deleteUser(User user) async {
    try {
      await user.delete();
    } catch (_) {
      // Ignored: nothing more we can do here.
    }
  }

  Future<void> _saveUserToFirestore(UserModel model) async {
    try {
      final userDoc = await _firestore.collection('users').doc(model.uid).get();
      if (!userDoc.exists) {
        await _firestore
            .collection('users')
            .doc(model.uid)
            .set(model.toFirestore(), SetOptions(merge: false));
      }
    } on FirebaseException catch (e) {
      throw UserPersistenceException(
        code: e.code,
        message: e.message ?? 'Failed to persist user profile',
      );
    }
  }
}
