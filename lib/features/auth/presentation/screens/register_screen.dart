import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../auth_utils/auth_messages.dart';
import '../auth_utils/auth_validators.dart';
import '../auth_utils/password_strength.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';
import '../providers/common_passwords_provider.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_mode_link.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/form_scaffold.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/password_strength_banner.dart';
import 'email_verification_screen.dart';

/// Create-account screen. `name` and `confirmPassword` are client-side
/// only (Firebase needs email + password + displayName). The sign-up
/// password policy is NIST-style — a length floor + a common-password
/// blocklist ([commonPasswordsProvider]), no composition rules — with a
/// non-blocking weak/strong [PasswordStrengthBanner] under the field on
/// top. A server-side "email already in use" comes back on [authProvider]
/// as [AuthErrorKind.emailAlreadyInUse] and is shown under the email
/// field.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  String _lastPasswordValue = '';

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_mirrorGeneratedPassword);
  }

  /// The OS's "suggest strong password" (via the `newPassword` autofill
  /// hint) only fills this field, never the separate confirm field — so
  /// mirror it there too. Detected as a multi-character jump (a suggested
  /// password, or a paste) rather than a single keystroke, and only while
  /// confirm is still empty, so it never overwrites something the user
  /// already typed there themselves.
  void _mirrorGeneratedPassword() {
    final value = _passwordController.text;
    final isBulkChange = (value.length - _lastPasswordValue.length).abs() > 1;
    _lastPasswordValue = value;
    if (isBulkChange && _confirmController.text.isEmpty) {
      _confirmController.text = value;
    }
  }

  @override
  void dispose() {
    _passwordController.removeListener(_mirrorGeneratedPassword);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authProvider.notifier)
        .submitSignUp(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    // Re-run the validators after next frame's rebuild so an "email
    // already in use" (which the email validator only returns once the
    // rebuilt state carries it) shows under the field. There's no
    // as-you-type validation, so this is the only thing that paints it.
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _formKey.currentState?.validate();
    });
  }

  // Same as on the login screen: Google sign-in creates the account on
  // first use, so there's nothing register-specific to do here.
  Future<void> _submitGoogle() async {
    FocusScope.of(context).unfocus();
    await ref.read(authProvider.notifier).submitGoogle();
  }

  Future<void> _openEmailVerification(String email) {
    return Navigator.of(context).push<void>(
      PlatformUtils.isCupertino
          ? CupertinoPageRoute(
              builder: (_) => EmailVerificationScreen(email: email),
            )
          : MaterialPageRoute(
              builder: (_) => EmailVerificationScreen(email: email),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthVerifying) _openEmailVerification(next.email);
    });
    final authState = ref.watch(authProvider);
    final commonPasswords =
        ref.watch(commonPasswordsProvider).value ?? const <String>{};
    final isLoading = authState is AuthLoading;
    final generalError = authState is AuthError &&
            authState.kind == AuthErrorKind.general
        ? authErrorMessage(l10n, authState)
        : null;
    final emailInUseError = authState is AuthError &&
            authState.kind == AuthErrorKind.emailAlreadyInUse
        ? authErrorMessage(l10n, authState)
        : null;

    return FormScaffold(
      title: l10n.authRegisterTitle,
      // "Unlocked" reads as a login motion, and this form is already
      // tall — keep it to the login screen.
      showAnimation: false,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthErrorBanner(message: generalError),
            if (generalError != null) const SizedBox(height: 16),
            AuthTextField(
              controller: _nameController,
              label: l10n.authNameLabel,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: (value) {
                final error = AuthValidators.name(value);
                return error == null
                    ? null
                    : authFieldErrorMessage(l10n, error);
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _emailController,
              label: l10n.authEmailLabel,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              onChanged: (_) {
                if (emailInUseError != null) {
                  ref.read(authProvider.notifier).reset();
                }
              },
              validator: (value) {
                final error = AuthValidators.email(value);
                if (error != null) return authFieldErrorMessage(l10n, error);
                return emailInUseError;
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _passwordController,
              label: l10n.authPasswordLabel,
              enablePassword: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              validator: (value) {
                final error = AuthValidators.signUpPassword(
                  value,
                  email: _emailController.text.trim(),
                  commonPasswords: commonPasswords,
                );
                return error == null
                    ? null
                    : authFieldErrorMessage(l10n, error);
              },
            ),
            ListenableBuilder(
              listenable: Listenable.merge([
                _passwordController,
                _emailController,
              ]),
              builder: (context, _) {
                final strength = evaluatePassword(
                  _passwordController.text,
                  email: _emailController.text.trim(),
                  common: commonPasswords,
                );
                return Padding(
                  padding: EdgeInsets.only(top: strength == null ? 0 : 8),
                  child: PasswordStrengthBanner(
                    strength: strength,
                    message: strength == null
                        ? null
                        : passwordStrengthMessage(l10n, strength),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _confirmController,
              label: l10n.authConfirmPasswordLabel,
              enablePassword: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onFieldSubmitted: (_) => _submit(),
              validator: (value) {
                final error = AuthValidators.confirmPassword(
                  value,
                  _passwordController.text,
                );
                return error == null
                    ? null
                    : authFieldErrorMessage(l10n, error);
              },
            ),
            const SizedBox(height: 24),
            AuthPrimaryButton(
              label: l10n.authRegisterButton,
              onPressed: isLoading ? null : _submit,
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
              prompt: l10n.authGoToLoginPrompt,
              action: l10n.authGoToLoginAction,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
