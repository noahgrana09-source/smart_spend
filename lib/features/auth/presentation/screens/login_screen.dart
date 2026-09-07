import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInput;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../auth_utils/auth_messages.dart';
import '../auth_utils/auth_validators.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_mode_link.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/form_scaffold.dart';
import '../widgets/google_sign_in_button.dart';
import 'register_screen.dart';

/// Email/password + Google sign-in. Empty/format problems are caught by
/// the form's own validators before the notifier is called; a
/// server-side "wrong email or password" comes back on [authProvider] as
/// [AuthErrorKind.invalidCredentials] and is re-surfaced under *both*
/// the email and password fields (either could be the wrong one) by
/// re-running [FormState.validate] after the await.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authProvider.notifier)
        .submitSignIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    // A successful sign-in resets the feature state to `normal` (a
    // failure would be `AuthError` instead) — tell the platform the
    // credentials just entered are good, so it can offer to save them.
    if (ref.read(authProvider) is AuthNormal) {
      TextInput.finishAutofillContext();
    }
    // The screen rebuilds with the new AuthState next frame; re-run the
    // validators *after* that, so a server-side "wrong email or
    // password" (which the field validators only return once the
    // rebuilt state carries it) shows up. There's no as-you-type
    // validation, so this explicit re-validate is the only thing that
    // paints it.
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _formKey.currentState?.validate();
    });
  }

  Future<void> _submitGoogle() async {
    FocusScope.of(context).unfocus();
    await ref.read(authProvider.notifier).submitGoogle();
  }

  Future<void> _openRegister() async {
    final notifier = ref.read(authProvider.notifier);
    // Login and register share one AuthNotifier. Clear this screen's
    // banner (the state) and its fields/field-errors (the form) before
    // Register's first build can read the same shared AuthState —
    // otherwise a leftover error here would flash on Register's screen.
    // The form only needs this once: it stays empty and untouched for
    // as long as Register is covering it.
    notifier.reset();
    _formKey.currentState?.reset();
    await Navigator.of(context).push<void>(
      PlatformUtils.isCupertino
          ? CupertinoPageRoute(builder: (_) => const RegisterScreen())
          : MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
    if (!mounted) return;
    // Same leak, the other direction: Register may have left its own
    // error (e.g. a failed sign-up) on the shared AuthState — clear it
    // so it doesn't show up on this screen's banner now that it's
    // visible again.
    notifier.reset();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final generalError =
        authState is AuthError && authState.kind == AuthErrorKind.general
        ? authErrorMessage(l10n, authState)
        : null;
    final credentialError =
        authState is AuthError &&
            authState.kind == AuthErrorKind.invalidCredentials
        ? authErrorMessage(l10n, authState)
        : null;

    void clearCredentialError(String _) {
      if (credentialError != null) ref.read(authProvider.notifier).reset();
    }

    return FormScaffold(
      title: l10n.authLoginTitle,
      child: Form(
        key: _formKey,
        // Groups the email and password fields into one autofill context,
        // so a tap on either offers the matching saved credential pair
        // instead of just the field that was tapped.
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthErrorBanner(message: generalError),
              if (generalError != null) const SizedBox(height: 16),
              AuthTextField(
                controller: _emailController,
                label: l10n.authEmailLabel,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                onChanged: clearCredentialError,
                validator: (value) {
                  final error = AuthValidators.email(value);
                  if (error != null) return authFieldErrorMessage(l10n, error);
                  return credentialError;
                },
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _passwordController,
                label: l10n.authPasswordLabel,
                enablePassword: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onChanged: clearCredentialError,
                onFieldSubmitted: (_) => _submitEmail(),
                validator: (value) {
                  final error = AuthValidators.signInPassword(value);
                  if (error != null) return authFieldErrorMessage(l10n, error);
                  return credentialError;
                },
              ),
              const SizedBox(height: 24),
              AuthPrimaryButton(
                label: l10n.authSignInButton,
                onPressed: isLoading ? null : _submitEmail,
                isLoading: isLoading,
              ),
              const SizedBox(height: 12),
              GoogleSignInButton(
                label: l10n.authGoogleButton,
                onPressed: isLoading ? null : _submitGoogle,
                isLoading: isLoading,
              ),
              const SizedBox(height: 8),
              AuthModeLink(
                prompt: l10n.authGoToRegisterPrompt,
                action: l10n.authGoToRegisterAction,
                onTap: _openRegister,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
