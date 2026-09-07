import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_providers.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/check_email_verified_usecase.dart';
import '../../domain/usecases/delete_user_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/resend_email_verification_usecase.dart';
import '../../domain/usecases/resolve_current_user_usecase.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_with_email_usecase.dart';
import '../../domain/usecases/watch_current_user_usecase.dart';

part 'auth_providers.g.dart';

/// Composition root for the `auth` feature.
///
/// `domain/` and `data/` stay free of Riverpod; this file assembles the
/// dependency graph (SDK singletons -> datasources -> repository -> use
/// cases) and is the only place presentation reaches into `data/`. Every
/// link is `keepAlive`: they're stateless and shared for the whole
/// session.

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(Ref ref) => FirebaseFirestore.instance;

@Riverpod(keepAlive: true)
GoogleSignIn googleSignIn(Ref ref) => GoogleSignIn.instance;

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) => AuthRemoteDataSourceImpl(
  firebaseAuth: ref.watch(firebaseAuthProvider),
  firestore: ref.watch(firebaseFirestoreProvider),
  googleSignIn: ref.watch(googleSignInProvider),
);

@Riverpod(keepAlive: true)
AuthLocalDataSource authLocalDataSource(Ref ref) =>
    AuthLocalDataSourceImpl(dao: ref.watch(userProfileDaoProvider));

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
  remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  localDataSource: ref.watch(authLocalDataSourceProvider),
);

@Riverpod(keepAlive: true)
SignInWithEmailUseCase signInWithEmailUseCase(Ref ref) =>
    SignInWithEmailUseCase(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
SignUpWithEmailUseCase signUpWithEmailUseCase(Ref ref) =>
    SignUpWithEmailUseCase(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
SignInWithGoogleUseCase signInWithGoogleUseCase(Ref ref) =>
    SignInWithGoogleUseCase(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
SignOutUseCase signOutUseCase(Ref ref) =>
    SignOutUseCase(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
ResendEmailVerificationUseCase resendEmailVerificationUseCase(Ref ref) =>
    ResendEmailVerificationUseCase(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
CheckEmailVerifiedUseCase checkEmailVerifiedUseCase(Ref ref) =>
    CheckEmailVerifiedUseCase(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
DeleteUserUseCase deleteUserUseCase(Ref ref) =>
    DeleteUserUseCase(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
GetCurrentUserUseCase getCurrentUserUseCase(Ref ref) =>
    GetCurrentUserUseCase(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
ResolveCurrentUserUseCase resolveCurrentUserUseCase(Ref ref) =>
    ResolveCurrentUserUseCase(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
WatchCurrentUserUseCase watchCurrentUserUseCase(Ref ref) =>
    WatchCurrentUserUseCase(ref.watch(authRepositoryProvider));
