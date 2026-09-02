import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/google_sign_in_button.dart';
import 'register_screen.dart';

/// Email/password + Google sign-in. Empty/format problems are caught by
/// the form's own validators before the notifier is called; a
/// server-side "wrong email or password" comes back on [authProvider] as
/// [AuthErrorKind.invalidCredentials] and is re-surfaced under the
/// password field by re-running [FormState.validate] after the await.
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
    // Paint a credential error returned by the notifier, if any.
    if (mounted) _formKey.currentState!.validate();
  }

  Future<void> _submitGoogle() async {
    FocusScope.of(context).unfocus();
    await ref.read(authProvider.notifier).submitGoogle();
  }

  Future<void> _openRegister() async {
    final notifier = ref.read(authProvider.notifier);
    notifier.reset();
    await Navigator.of(context).push<void>(
      PlatformUtils.isCupertino
          ? CupertinoPageRoute(builder: (_) => const RegisterScreen())
          : MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
    if (mounted) notifier.reset();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final generalError = authState is AuthError &&
            authState.kind == AuthErrorKind.general
        ? authErrorMessage(l10n, authState)
        : null;
    final credentialError = authState is AuthError &&
            authState.kind == AuthErrorKind.invalidCredentials
        ? authErrorMessage(l10n, authState)
        : null;

    void clearCredentialError(String _) {
      if (credentialError != null) ref.read(authProvider.notifier).reset();
    }

    return AuthScaffold(
      title: l10n.authLoginTitle,
      child: Form(
        key: _formKey,
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
                return error == null
                    ? null
                    : authFieldErrorMessage(l10n, error);
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _passwordController,
              label: l10n.authPasswordLabel,
              obscureText: true,
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
              label: l10n.authGoToRegister,
              onPressed: _openRegister,
            ),
          ],
        ),
      ),
    );
  }
}
