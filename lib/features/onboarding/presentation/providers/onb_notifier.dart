import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/state/app_states.dart';
import '../../../../core/state/state_providers.dart';
import '../../domain/usecases/save_data_usecase.dart';
import 'onb_providers.dart';
import 'onb_state.dart';

part 'onb_notifier.g.dart';

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
