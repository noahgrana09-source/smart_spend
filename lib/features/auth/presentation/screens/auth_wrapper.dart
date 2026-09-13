import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/state/app_states.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/adaptive_progress_indicator.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_providers.dart';
import '../providers/auth_state.dart';
import 'email_verification_screen.dart';
import 'login_screen.dart';

/// `auth`'s boot-time gate — what the `/login` route actually shows.
///
/// `main()` no longer decides any of this (see its doc comment). What to
/// render is driven entirely by `authProvider`'s [AuthState]: [AuthNormal]
/// -> [LoginScreen], [AuthVerifying] -> [EmailVerificationScreen]. That
/// covers both origins the same way — a fresh sign-up
/// (`RegisterScreen.submitSignUp` moves to `verifying` and pops itself,
/// revealing this widget already showing the right thing underneath) and
/// an existing-but-unverified session found at boot (below). `AuthLoading`
/// / `AuthError` are deliberately *not* mapped here — those are
/// [LoginScreen]/[EmailVerificationScreen]'s own in-flight/failed states,
/// already handled by whichever of the two is currently showing; reacting
/// to them here would rip that screen away mid-action.
///
/// The boot-time check itself: resolves the persisted Firebase Auth
/// session, if any, right after the first frame. Until that resolves,
/// shows a bare loading spinner rather than [LoginScreen] — resolving is
/// async (it waits on Firebase's own native session restoration), so
/// something has to paint during that gap, and it must not be either
/// real screen (a returning, already-verified user would otherwise see
/// a flash of the login form right before being routed straight past
/// it). No session -> the spinner gives way to `AuthNormal` ->
/// [LoginScreen]. A session with a verified email -> advances
/// `appStateProvider` to [AppState.authenticated] and *stays* on the
/// spinner — `AppStateListener` replaces this whole route imminently, so
/// there's nothing worth resolving the spinner for. A session that isn't
/// verified -> [AuthNotifier.resumeVerifying].
///
/// This one-shot flag is intentionally separate from the `AuthNormal`/
/// `AuthVerifying` switch below: it only ever gates the *first* build,
/// set once and never touched again, so it can't re-intercept a later,
/// live transition (e.g. a fresh sign-up) the way reusing it for routing
/// decisions once did.
class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _resolvedBoot = false;
  bool _showEmailVerification = false;
  String? _verifyingEmail;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final user = await ref.read(resolveCurrentUserUseCaseProvider).call();
    if (!mounted) return;

    if (user != null && user.isEmailVerified) {
      ref.read(appStateProvider.notifier).update(const AppState.authenticated());
      return; // Left resolving on purpose — see the class doc comment.
    }

    if (user != null) {
      ref.read(authProvider.notifier).resumeVerifying(email: user.email);
    }
    setState(() => _resolvedBoot = true);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      switch (next) {
        case AuthNormal():
          setState(() => _showEmailVerification = false);
        case AuthVerifying(email: final email):
          setState(() {
            _showEmailVerification = true;
            _verifyingEmail = email;
          });
        case AuthLoading():
        case AuthError():
          break; // Handled by whichever screen is already showing.
      }
    });

    if (!_resolvedBoot) return const _BootLoading();
    if (_showEmailVerification) {
      return EmailVerificationScreen(email: _verifyingEmail!);
    }
    return const LoginScreen();
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
