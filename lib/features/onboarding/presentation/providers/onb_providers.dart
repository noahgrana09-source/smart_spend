import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_providers.dart';
import '../../data/datasources/onb_local_datasource.dart';
import '../../data/repositories/onb_repository_impl.dart';
import '../../domain/repositories/onb_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/get_local_data_usecase.dart';
import '../../domain/usecases/save_data_usecase.dart';

part 'onb_providers.g.dart';

/// Composition root for the `onboarding` feature.
///
/// `domain/` and `data/` stay free of Riverpod; this file assembles the
/// dependency graph (SDK singletons -> datasource -> repository -> use
/// cases) and is the only place presentation reaches into `data/`. Every
/// link is `keepAlive`: they're stateless and shared for the whole
/// session.

@Riverpod(keepAlive: true)
FirebaseAuth onbFirebaseAuth(Ref ref) => FirebaseAuth.instance;

@Riverpod(keepAlive: true)
OnbLocalDataSource onbLocalDataSource(Ref ref) => OnbLocalDataSourceImpl(
  firebaseAuth: ref.watch(onbFirebaseAuthProvider),
  userProfileDao: ref.watch(userProfileDaoProvider),
);

@Riverpod(keepAlive: true)
OnbRepository onbRepository(Ref ref) =>
    OnbRepositoryImpl(localDataSource: ref.watch(onbLocalDataSourceProvider));

@Riverpod(keepAlive: true)
SaveDataUseCase saveDataUseCase(Ref ref) =>
    SaveDataUseCase(ref.watch(onbRepositoryProvider));

@Riverpod(keepAlive: true)
GetCurrentUserUseCase getCurrentUserUseCase(Ref ref) =>
    GetCurrentUserUseCase(ref.watch(onbRepositoryProvider));

@Riverpod(keepAlive: true)
GetLocalDataUseCase getLocalDataUseCase(Ref ref) =>
    GetLocalDataUseCase(ref.watch(onbRepositoryProvider));
