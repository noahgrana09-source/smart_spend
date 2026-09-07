import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../auth_utils/auth_messages.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_primary_button.dart';

/// Shown right after a successful sign-up, while the new account's email
/// is still unverified. `RegisterScreen` pushes this screen — not a route
/// on the state-driven router, same as `RegisterScreen` itself — when
/// `authProvider` moves to `AuthState.verifying`.
///
/// The global `AppState` stays `unauthenticated` until the user confirms
/// verification here; see `AuthNotifier.checkEmailVerifiedNow`.
class EmailVerificationScreen extends ConsumerWidget {
  const EmailVerificationScreen({super.key, required this.email});

  /// The address the verification link was sent to. Passed in directly
  /// (rather than read off `AuthState`) so this screen's content doesn't
  /// depend on the notifier's transient `verifying` state, which only
  /// exists to trigger the initial navigation here.
  final String email;

  /// Backing out here abandons the account this screen was created for —
  /// so it deletes it rather than leaving an orphaned, unverified Firebase
  /// Auth user nobody can ever reach again (see
  /// `AuthNotifier.deleteUser`). Only pops on success; a failure stays on
  /// this screen with the error banner so the user can retry instead of
  /// silently losing track of the account.
  Future<void> _goBackToRegister(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).deleteUser();
    if (!context.mounted) return;
    if (ref.read(authProvider) is AuthNormal) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final error = authState is AuthError
        ? authErrorMessage(l10n, authState)
        : null;
    final notifier = ref.read(authProvider.notifier);

    final body = SafeArea(
      child: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 32,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthErrorBanner(message: error),
                    if (error != null) const SizedBox(height: 16),
                    Icon(
                      PlatformUtils.isCupertino
                          ? CupertinoIcons.mail_solid
                          : Icons.mark_email_unread_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.authEmailVerificationDescription(email),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 32),
                    AuthPrimaryButton(
                      label: l10n.authEmailVerifiedButton,
                      isLoading: isLoading,
                      onPressed: isLoading
                          ? null
                          : notifier.checkEmailVerifiedNow,
                    ),
                    const SizedBox(height: 12),
                    _SecondaryButton(
                      label: l10n.authResendEmailButton,
                      onPressed: isLoading
                          ? null
                          : notifier.resendVerificationEmail,
                    ),
                    const SizedBox(height: 8),
                    _SecondaryButton(
                      label: l10n.authBackToRegisterButton,
                      onPressed: isLoading
                          ? null
                          : () => _goBackToRegister(context, ref),
                    ),
                  ],
                ),
              ),
            ),
          ),
          LoadingOverlay(visible: isLoading),
        ],
      ),
    );

    if (PlatformUtils.isCupertino) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(l10n.authEmailVerificationTitle),
        ),
        child: body,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.authEmailVerificationTitle),
        centerTitle: true,
      ),
      body: body,
    );
  }
}

/// Plain full-width text-style action, for the two non-primary buttons on
/// this screen ("resend" / "back to register").
class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return SizedBox(
        width: double.infinity,
        child: CupertinoButton(onPressed: onPressed, child: Text(label)),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: TextButton(onPressed: onPressed, child: Text(label)),
    );
  }
}
