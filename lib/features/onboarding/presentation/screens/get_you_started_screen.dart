import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/entities/app_user_entity.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/adaptive_progress_indicator.dart';
import '../../../../core/widgets/main_app_button.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../providers/onb_providers.dart';
import 'pick_nationality_screen.dart';

/// First onboarding screen: greets the user by name, then hands off to
/// [PickNationalityScreen].
///
/// "Start" uses `pushReplacement` (not `push`) — once onboarding is under
/// way there's nothing to come back to here, unlike the screens after it.
class GetYouStartedScreen extends ConsumerStatefulWidget {
  const GetYouStartedScreen({super.key});

  @override
  ConsumerState<GetYouStartedScreen> createState() =>
      _GetYouStartedScreenState();
}

class _GetYouStartedScreenState extends ConsumerState<GetYouStartedScreen> {
  late final Future<Either<Failure, AppUserEntity>> _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = ref
        .read(getCurrentUserUseCaseProvider)
        .call(const NoParams());
  }

  void _start() {
    Navigator.of(context).pushReplacement(
      PlatformUtils.isCupertino
          ? CupertinoPageRoute(builder: (_) => const PickNationalityScreen())
          : MaterialPageRoute(builder: (_) => const PickNationalityScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FutureBuilder<Either<Failure, AppUserEntity>>(
                  future: _currentUser,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: AdaptiveProgressIndicator());
                    }
                    final name = snapshot.data!.fold(
                      (_) => '',
                      (user) => user.displayName,
                    );
                    return Text(
                      l10n.onbGetStartedGreeting(name),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    );
                  },
                ),
                const SizedBox(height: 24),
                Lottie.asset(
                  'assets/animations/auth_success.json',
                  height: 200,
                  repeat: true,
                ),
                const SizedBox(height: 24),
                MainAppButton(label: l10n.onbStartButton, onPressed: _start),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
