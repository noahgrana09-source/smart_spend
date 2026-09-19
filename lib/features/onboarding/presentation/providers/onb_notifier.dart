import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_providers.dart';
import '../../../../core/state/app_states.dart';
import '../../../../core/state/state_providers.dart';
import '../../data/datasources/onb_local_datasource.dart';
import '../../data/repositories/onb_repository_impl.dart';
import '../../domain/repositories/onb_repository.dart';
import '../../domain/usecases/save_data_usecase.dart';
import 'onb_state.dart';

part 'onb_notifier.g.dart';

/// Composition root for the `onboarding` feature, inlined here instead of
/// a separate `onb_providers.dart` — a single use case doesn't earn its
/// own file. Every link is `keepAlive`: stateless, shared for the whole
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

/// Drives the onboarding screens and owns the transition to
/// `AppState.onboarded()` once the user's data is saved.
///
/// `keepAlive`: mirrors `AuthNotifier` — [submitSaveData] touches `ref`
/// after an `await`, and an auto-disposing notifier could be collected
/// mid-await if the calling screen only `ref.read`s it.
@Riverpod(keepAlive: true)
class OnbNotifier extends _$OnbNotifier {
  @override
  OnbState build() => const OnbState.normal();

  Future<void> submitSaveData({
    required String nationality,
    required String investorProfile,
  }) async {
    state = const OnbState.loading();
    final result = await ref
        .read(saveDataUseCaseProvider)
        .call(
          SaveDataParams(
            nationality: nationality,
            investorProfile: investorProfile,
          ),
        );
    state = result.fold((failure) => OnbState.error(failure), (_) {
      ref.read(appStateProvider.notifier).update(const AppState.onboarded());
      return const OnbState.normal();
    });
  }
}
