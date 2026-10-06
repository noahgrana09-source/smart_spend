import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/state/app_states.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/adaptive_progress_indicator.dart';
import '../providers/onb_providers.dart';
import 'get_you_started_screen.dart';

/// `onboarding`'s boot-time gate — what the `/onboarding` route actually
/// shows. Without this, an already-onboarded user (their `UserProfiles`
/// row already exists on this device) would land on
/// [GetYouStartedScreen] again on every login, instead of going straight
/// to `/home`.
///
/// Resolves once, right after the first frame: a local row already
/// exists -> advances `appStateProvider` to [AppState.onboarded] and
/// stays on the spinner (`AppStateListener` replaces this whole route
/// imminently, so there's nothing worth resolving it for — same
/// reasoning as `AuthWrapper`'s verified-session case). No row -> shows
/// [GetYouStartedScreen]. Either way, a bare spinner covers the async
/// gap so neither screen ever flashes before the right one is known.
class OnbWrapper extends ConsumerStatefulWidget {
  const OnbWrapper({super.key});

  @override
  ConsumerState<OnbWrapper> createState() => _OnbWrapperState();
}

class _OnbWrapperState extends ConsumerState<OnbWrapper> {
  bool _resolvedBoot = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final result = await ref
        .read(getLocalDataUseCaseProvider)
        .call(const NoParams());
    if (!mounted) return;

    final hasLocalData = result.fold((_) => false, (entity) => entity != null);
    if (hasLocalData) {
      ref.read(appStateProvider.notifier).update(const AppState.onboarded());
      return; // Left resolving on purpose — see the class doc comment.
    }
    setState(() => _resolvedBoot = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_resolvedBoot) return const _BootLoading();
    return const GetYouStartedScreen();
  }
}

class _BootLoading extends StatelessWidget {
  const _BootLoading();

  @override
  Widget build(BuildContext context) {
    const body = Center(child: AdaptiveProgressIndicator());
    if (PlatformUtils.isCupertino) {
      return const CupertinoPageScaffold(child: body);
    }
    return const Scaffold(body: body);
  }
}
