import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/entities/onb_data_entity.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/state/app_states.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/widgets/adaptive_progress_indicator.dart';
import '../../../onboarding/presentation/providers/onb_providers.dart';

/// TEMPORARY: `portfolio` doesn't have a real Home screen yet — this just
/// reads back the signed-in user's `UserProfiles` row (via onboarding's
/// own `GetLocalDataUseCase`) to verify the local Drift connection
/// actually works end to end. Replace with the real Home screen.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final Future<Either<Failure, OnbDataEntity?>> _localData;

  @override
  void initState() {
    super.initState();
    _localData = ref.read(getLocalDataUseCaseProvider).call(const NoParams());
  }

  /// Similar to `AuthRemoteDataSourceImpl.signOut`: Firebase Auth is what
  /// "signed out" means, so that's the only part this waits on. Google
  /// sign-out only clears the cached account for next time, so it's
  /// fired in the background instead of blocking this on it.
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    unawaited(_signOutGoogleBestEffort());
    if (!mounted) return;
    ref.read(appStateProvider.notifier).update(const AppState.unauthenticated());
  }

  /// `GoogleSignIn.instance` is a real singleton — if this user signed in
  /// with Google earlier in the same session, `auth`'s own datasource
  /// already called `.initialize()` on it, and doing so again throws
  /// ("init() has already been called"). Caught separately from
  /// `.signOut()` so that doesn't skip the actual sign-out.
  Future<void> _signOutGoogleBestEffort() async {
    try {
      await GoogleSignIn.instance.initialize();
    } catch (_) {
      // Already initialized elsewhere this session — fine.
    }
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignored — secondary cleanup.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<Either<Failure, OnbDataEntity?>>(
              future: _localData,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const AdaptiveProgressIndicator();
                }
                return snapshot.data!.fold(
                  (failure) => Text('Local read failed: ${failure.message}'),
                  (entity) => entity == null
                      ? const Text('No local UserProfiles row for this user')
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Nationality: ${entity.nationality}'),
                            Text('Investor profile: ${entity.investorProfile}'),
                          ],
                        ),
                );
              },
            ),
            const SizedBox(height: 24),
            TextButton(onPressed: _signOut, child: const Text('Log out')),
          ],
        ),
      ),
    );
  }
}
