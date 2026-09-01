/// Client-side, synchronous form problems the auth screens detect before
/// calling [AuthNotifier]. Each screen maps these to a localized string
/// in its `TextFormField.validator` (see `auth_messages.dart`), and runs
/// `formKey.currentState!.validate()` before submitting.
enum AuthFieldError {
  emailEmpty,
  emailInvalid,
  passwordEmpty,
  passwordTooShort,
  nameEmpty,
  confirmPasswordEmpty,
  confirmPasswordMismatch,
}

/// Pure form validators for the login and register screens. No
/// dependency on Flutter or l10n so they unit-test directly.
abstract final class AuthValidators {
  /// Firebase Auth rejects passwords shorter than this on sign-up; the
  /// login field enforces it too so a too-short entry fails fast without
  /// a round-trip.
  static const int minPasswordLength = 6;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static AuthFieldError? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return AuthFieldError.emailEmpty;
    if (!_emailPattern.hasMatch(trimmed)) return AuthFieldError.emailInvalid;
    return null;
  }

  static AuthFieldError? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return AuthFieldError.passwordEmpty;
    if (password.length < minPasswordLength) {
      return AuthFieldError.passwordTooShort;
    }
    return null;
  }

  static AuthFieldError? name(String? value) {
    if ((value?.trim() ?? '').isEmpty) return AuthFieldError.nameEmpty;
    return null;
  }

  static AuthFieldError? confirmPassword(String? value, String? password) {
    final confirm = value ?? '';
    if (confirm.isEmpty) return AuthFieldError.confirmPasswordEmpty;
    if (confirm != (password ?? '')) {
      return AuthFieldError.confirmPasswordMismatch;
    }
    return null;
  }
}
