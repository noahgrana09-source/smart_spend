import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

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

  /// Re-sends the verification email to the currently signed-in user.
  ///
  /// Throws [AuthDataSourceException] if there is no signed-in user.
  Future<void> sendEmailVerification();

  /// Reloads the currently signed-in user and returns whether their email
  /// is verified now. If it just became verified, best-effort syncs that
  /// onto the `users/{uid}` Firestore profile too — otherwise it would
  /// stay stuck at the `false` signup wrote it as, which is what
  /// `deleteUnverifiedUsers` (the Cloud Function that reaps unverified
  /// accounts) actually queries against.
  ///
  /// Throws [AuthDataSourceException] if there is no signed-in user.
  Future<bool> reloadAndCheckEmailVerified();

  /// Deletes the currently signed-in user from Firebase Auth.
  ///
  /// Unlike the best-effort rollback used internally during sign-up,
  /// this propagates any failure — it's a deliberate, user-facing
  /// deletion, not secondary cleanup. Throws [AuthDataSourceException] if
  /// there is no signed-in user.
  Future<void> deleteCurrentUser();

  /// Returns the currently authenticated user, or `null` if not signed in.
  ///
  /// Reads [FirebaseAuth.currentUser] synchronously, which can spuriously
  /// return `null` right after app startup — Firebase Auth restores a
  /// persisted session from disk asynchronously, and this can race ahead
  /// of that. Safe to use once the app is running (e.g. right after a
  /// sign-in call in the same session); for a reliable read at startup,
  /// use [resolveCurrentUser] instead.
  UserModel? getCurrentUser();

  /// Resolves once Firebase Auth has restored (or confirmed the absence
  /// of) a persisted session, via the first event of [FirebaseAuth
  /// .authStateChanges]. Unlike [getCurrentUser], this cannot race ahead
  /// of Firebase's own session restoration — it's what `AuthWrapper`
  /// uses at app boot (via [ResolveCurrentUserUseCase]). Also reloads
  /// (and best-effort syncs Firestore, like [reloadAndCheckEmailVerified])
  /// when the cached `emailVerified` still reads `false` — otherwise a
  /// session that got verified while the app was closed would report
  /// stale.
  Future<UserModel?> resolveCurrentUser();
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
  /// already been called` — not safe to call more than once per
  /// instance.
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
  /// needs it too. The native SDK resolves the client ID from the
  /// platform config file (`google-services.json` /
  /// `GoogleService-Info.plist`), so nothing needs to be passed here.
  /// Guarded to run at most once per instance — see
  /// [_googleSignInInitialized].
  Future<void> _initializeGoogleSignIn() async {
    if (_googleSignInInitialized) return;
    await _googleSignIn.initialize();
    _googleSignInInitialized = true;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    await _initializeGoogleSignIn();

    // 1. Prompt the native Google flow for an account.
    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

    // 2. Exchange that account for a Firebase credential and sign in.
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

    // 3. Persist the profile document. If this fails on an account that
    // was just created here, roll the account back so we never leave a
    // Firebase Auth user without a matching profile; an account that
    // already existed is left untouched (see the comment below).
    try {
      await _saveUserToFirestore(userModel);
    } catch (e) {
      // Only roll back if this sign-in just created the account: an
      // existing user must never be deleted over a transient failure
      // reading/writing its profile.
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        try {
          await _deleteUser(user);
        } catch (_) {
          // Ignored: nothing more we can do here — the persistence
          // error below is what gets surfaced regardless.
        }
      }
      rethrow;
    }

    return userModel;
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
    // Picks up the just-set displayName (unrelated to email verification —
    // that's a separate reload in `reloadAndCheckEmailVerified`).
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
      try {
        await _deleteUser(updatedUser);
      } catch (_) {
        // Ignored: nothing more we can do here — the persistence error
        // below is what gets surfaced regardless.
      }
      rethrow;
    }

    // Best-effort: a failed send shouldn't fail the whole sign-up, since
    // the verification screen offers a "resend" action for retrying.
    try {
      await updatedUser.sendEmailVerification();
    } catch (_) {
      // Ignored — the user can resend from the verification screen.
    }

    return userModel;
  }

  @override
  Future<void> signOut() async {
    // Firebase Auth is what "signed out" means — this is the only part
    // that must succeed, and it's what the repository's Either reflects.
    await _firebaseAuth.signOut();

    // Google sign-out only clears the cached Google account for the next
    // Google sign-in. Fire it in the background: on a session that
    // signed in with email/password, `GoogleSignIn` was never
    // initialized, and initializing + signing out here can hang or throw
    // on-device — which would otherwise leave `submitSignOut` stuck on
    // its `await`, the app never advancing to unauthenticated.
    unawaited(_signOutGoogleBestEffort());
  }

  Future<void> _signOutGoogleBestEffort() async {
    try {
      await _initializeGoogleSignIn();
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignored — secondary cleanup.
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthDataSourceException(
        code: 'no-current-user',
        message: 'No signed-in user to send a verification email to',
      );
    }
    await user.sendEmailVerification();
  }

  @override
  Future<bool> reloadAndCheckEmailVerified() async {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthDataSourceException(
        code: 'no-current-user',
        message: 'No signed-in user to check email verification for',
      );
    }
    await user.reload();
    final freshUser = _firebaseAuth.currentUser;
    final isVerified = freshUser?.emailVerified ?? false;
    if (freshUser != null) await _syncEmailVerifiedToFirestore(freshUser);

    return isVerified;
  }

  @override
  Future<void> deleteCurrentUser() async {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthDataSourceException(
        code: 'no-current-user',
        message: 'No signed-in user to delete',
      );
    }
    await _deleteUser(user);
  }

  @override
  UserModel? getCurrentUser() {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<UserModel?> resolveCurrentUser() async {
    final User? user = await _firebaseAuth.authStateChanges().first;
    if (user == null) return null;

    // The cached `emailVerified` flag can be stale: verifying happens by
    // opening a link outside the app (email client / browser), so
    // nothing local ever refreshes it on its own — a session restored
    // right after that would otherwise still read `false` here. Only
    // worth reloading when it does: once true, it never goes back to
    // false, so there's nothing to gain from reloading an
    // already-verified session on every cold start.
    if (!user.emailVerified) {
      try {
        await user.reload();
      } catch (_) {
        // Best-effort (e.g. offline) — fall back to the cached value.
      }
    }
    final freshUser = _firebaseAuth.currentUser ?? user;
    await _syncEmailVerifiedToFirestore(freshUser);
    return UserModel.fromFirebaseUser(freshUser);
  }

  /// Best-effort: syncs a freshly-reloaded [user]'s `emailVerified` onto
  /// their `users/{uid}` Firestore profile, which otherwise only ever
  /// reflects whatever `signUpWithEmailAndPassword` wrote at sign-up time
  /// (`false`) — verifying happens outside the app, so nothing else ever
  /// updates it. Shared by [resolveCurrentUser] (checked at boot) and
  /// [reloadAndCheckEmailVerified] (checked from the "email verified"
  /// button); both call this only after their own reload, so [user]'s
  /// flag is current. A failure here never fails the caller — it only
  /// matters for keeping `deleteUnverifiedUsers` (which queries
  /// Firestore, not Auth) from reaping an account that actually got
  /// verified while nothing was around to record it.
  Future<void> _syncEmailVerifiedToFirestore(User user) async {
    if (!user.emailVerified) return;
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'isEmailVerified': true,
      });
    } catch (_) {
      // Ignored — see doc comment above.
    }
  }

  /// Deletes [user] from Firebase Auth, and best-effort deletes their
  /// `users/{uid}` Firestore profile alongside it — once Auth is gone
  /// (the part that actually frees up the email address), a stray
  /// leftover profile doc isn't worth blocking on or reporting as a
  /// failure.
  ///
  /// Deleting [user] itself still propagates — callers that use this for
  /// best-effort rollback (an account left without a persisted profile)
  /// catch around their own call instead, so the original persistence
  /// error is what gets surfaced regardless; [deleteCurrentUser] lets it
  /// propagate on purpose.
  Future<void> _deleteUser(User user) async {
    await user.delete();
    try {
      await _firestore.collection('users').doc(user.uid).delete();
    } catch (_) {
      // Best-effort — see the doc comment above.
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
