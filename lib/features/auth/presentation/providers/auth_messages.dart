import '../../../../l10n/gen/app_localizations.dart';
import 'auth_state.dart';
import 'auth_validators.dart';

/// Bridges the context-free error enums from [AuthValidators] and
/// [AuthState] to localized strings. Lives in presentation because it
/// needs [AppLocalizations]; the validators and the notifier stay free
/// of `BuildContext`.

/// Localized text for a synchronous form problem, shown under its field.
String authFieldErrorMessage(AppLocalizations l10n, AuthFieldError error) {
  return switch (error) {
    AuthFieldError.emailEmpty => l10n.validationEmailEmpty,
    AuthFieldError.emailInvalid => l10n.validationEmailInvalid,
    AuthFieldError.passwordEmpty => l10n.validationPasswordEmpty,
    AuthFieldError.passwordTooShort => l10n.validationPasswordTooShort(
      AuthValidators.minPasswordLength,
    ),
    AuthFieldError.nameEmpty => l10n.validationNameEmpty,
    AuthFieldError.confirmPasswordEmpty => l10n.validationConfirmPasswordEmpty,
    AuthFieldError.confirmPasswordMismatch =>
      l10n.validationConfirmPasswordMismatch,
  };
}

/// Localized text for a failed submit. [AuthErrorKind.invalidCredentials]
/// and [AuthErrorKind.emailAlreadyInUse] render under a text field;
/// [AuthErrorKind.general] is the error banner ([AuthError.message] when
/// the failure carried one, otherwise a generic line).
String authErrorMessage(AppLocalizations l10n, AuthError error) {
  return switch (error.kind) {
    AuthErrorKind.invalidCredentials => l10n.errorInvalidCredentials,
    AuthErrorKind.emailAlreadyInUse => l10n.errorEmailAlreadyInUse,
    AuthErrorKind.general => error.message ?? l10n.errorGeneric,
  };
}
