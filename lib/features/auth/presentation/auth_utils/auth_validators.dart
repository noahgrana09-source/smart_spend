/// Client-side, synchronous form problems the auth screens detect before
/// calling `AuthNotifier`. Each screen maps these to a localized string
/// in its `TextFormField.validator` (see `auth_messages.dart`), and runs
/// `formKey.currentState!.validate()` before submitting.
enum AuthFieldError {
  emailEmpty,
  emailInvalid,
  passwordEmpty,
  passwordTooShort,
  passwordTooCommon,
  passwordContainsIdentity,
  nameEmpty,
  confirmPasswordEmpty,
  confirmPasswordMismatch,
}

/// Pure form validators for the login and register screens. No
/// dependency on Flutter or l10n so they unit-test directly.
///
/// The sign-up password policy follows NIST SP 800-63B: a length floor
/// plus a blocklist of common/breached passwords, and no composition
/// rules (an upper-case + digit + symbol requirement pushes users to
/// predictable patterns like `Password1!`).
abstract final class AuthValidators {
  /// NIST 800-63B floor for user-chosen secrets.
  static const int minPasswordLength = 8;

  /// A local-part this short isn't distinctive enough to treat a
  /// substring match as "the password contains your identity".
  static const int _minIdentityFragment = 3;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static AuthFieldError? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return AuthFieldError.emailEmpty;
    if (!_emailPattern.hasMatch(trimmed)) return AuthFieldError.emailInvalid;
    return null;
  }

  /// Sign-in only checks the field isn't empty: an existing account's
  /// password may predate the current policy, so anything more would
  /// lock the user out of their own account before the request is made.
  static AuthFieldError? signInPassword(String? value) {
    if ((value ?? '').isEmpty) return AuthFieldError.passwordEmpty;
    return null;
  }

  /// Sign-up password policy: not empty, at least [minPasswordLength], not
  /// derived from the user's email or an obvious pattern, and not in
  /// [commonPasswords] (compared lower-cased). `evaluatePassword` adds a
  /// non-blocking weak/strong hint on top of this.
  static AuthFieldError? signUpPassword(
    String? value, {
    required String email,
    required Set<String> commonPasswords,
  }) {
    final password = value ?? '';
    if (password.isEmpty) return AuthFieldError.passwordEmpty;
    if (password.length < minPasswordLength) {
      return AuthFieldError.passwordTooShort;
    }
    if (_looksLikeIdentity(password, email)) {
      return AuthFieldError.passwordContainsIdentity;
    }
    if (commonPasswords.contains(password.toLowerCase())) {
      return AuthFieldError.passwordTooCommon;
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

  static bool _looksLikeIdentity(String password, String email) {
    final lower = password.toLowerCase();
    final localPart = email.split('@').first.toLowerCase();
    if (localPart.length >= _minIdentityFragment && lower.contains(localPart)) {
      return true;
    }
    if (lower.contains('smartspend')) return true;
    return _isTrivialRun(lower);
  }

  /// `aaaaaaaa`, `12345678`, `87654321` and the like — a single repeated
  /// character or a straight ascending/descending run of code units.
  static bool _isTrivialRun(String value) {
    if (value.length < 2) return false;
    if (value.split('').every((char) => char == value[0])) return true;
    var ascending = true;
    var descending = true;
    for (var i = 1; i < value.length; i++) {
      final delta = value.codeUnitAt(i) - value.codeUnitAt(i - 1);
      if (delta != 1) ascending = false;
      if (delta != -1) descending = false;
    }
    return ascending || descending;
  }
}
