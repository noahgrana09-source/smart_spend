import '../../../../l10n/gen/app_localizations.dart';
import '../providers/auth_state.dart';
import 'auth_validators.dart';
import 'password_strength.dart';

/// Bridges the context-free error enums from [AuthValidators] and
/// [AuthState] to localized strings. Lives in presentation because it
/// needs [AppLocalizations]; the validators and the notifier stay free
/// of `BuildContext`.

/// Localized text for a synchronous form problem, shown under its field.
String authFieldErrorMessage(AppLocalizations l10n, AuthFieldError error) {
  return switch (error) {
    AuthFieldError.emailEmpty => l10n.authValidationEmailEmpty,
    AuthFieldError.emailInvalid => l10n.authValidationEmailInvalid,
    AuthFieldError.passwordEmpty => l10n.authValidationPasswordEmpty,
    AuthFieldError.passwordTooShort => l10n.authValidationPasswordTooShort(
      AuthValidators.minPasswordLength,
    ),
    AuthFieldError.passwordTooCommon => l10n.authValidationPasswordTooCommon,
    AuthFieldError.passwordContainsIdentity =>
      l10n.authValidationPasswordContainsIdentity,
    AuthFieldError.nameEmpty => l10n.authValidationNameEmpty,
    AuthFieldError.confirmPasswordEmpty =>
      l10n.authValidationConfirmPasswordEmpty,
    AuthFieldError.confirmPasswordMismatch =>
      l10n.authValidationConfirmPasswordMismatch,
  };
}

/// Localized text for a failed submit. [AuthErrorKind.invalidCredentials]
/// and [AuthErrorKind.emailAlreadyInUse] render under a text field;
/// [AuthErrorKind.general] and [AuthErrorKind.emailNotVerified] go to the
/// error banner ([AuthError.message] when the failure carried one,
/// otherwise a generic line).
String authErrorMessage(AppLocalizations l10n, AuthError error) {
  return switch (error.kind) {
    AuthErrorKind.invalidCredentials => l10n.authErrorInvalidCredentials,
    AuthErrorKind.emailAlreadyInUse => l10n.authErrorEmailAlreadyInUse,
    AuthErrorKind.general => error.message ?? l10n.authErrorGeneric,
    AuthErrorKind.emailNotVerified => l10n.authErrorEmailNotVerified,
  };
}

/// Localized label for the non-blocking password-strength banner.
String passwordStrengthMessage(
  AppLocalizations l10n,
  PasswordStrength strength,
) {
  return switch (strength) {
    PasswordStrength.weak => l10n.authPasswordStrengthWeak,
    PasswordStrength.strong => l10n.authPasswordStrengthStrong,
  };
}
