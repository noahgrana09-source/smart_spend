import 'auth_validators.dart';

/// Non-blocking weak/strong hint for the sign-up password field.
enum PasswordStrength { weak, strong }

/// Rates [password] for the strength banner shown *below* the field.
///
/// Returns `null` while the password isn't acceptable — the blocking
/// rules in [AuthValidators.signUpPassword] (length, not derived from the
/// email, no trivial run, not a common password) own that case and their
/// field error takes precedence.
///
/// Otherwise a length- and variety-weighted score picks
/// [PasswordStrength.weak] vs [PasswordStrength.strong]:
///
/// - +1 for each of length >= 10, >= 12, >= 16, >= 20
/// - +1 for 3 or more character classes (lower, upper, digit, symbol)
/// - score >= 3 is [PasswordStrength.strong]
PasswordStrength? evaluatePassword(
  String password, {
  required String email,
  required Set<String> common,
}) {
  final blocking = AuthValidators.signUpPassword(
    password,
    email: email,
    commonPasswords: common,
  );
  if (blocking != null) return null;

  var score = 0;
  if (password.length >= 10) score++;
  if (password.length >= 12) score++;
  if (password.length >= 16) score++;
  if (password.length >= 20) score++;
  if (_characterClasses(password) >= 3) score++;

  return score >= 3 ? PasswordStrength.strong : PasswordStrength.weak;
}

int _characterClasses(String value) {
  var classes = 0;
  if (value.contains(RegExp(r'[a-z]'))) classes++;
  if (value.contains(RegExp(r'[A-Z]'))) classes++;
  if (value.contains(RegExp(r'\d'))) classes++;
  if (value.contains(RegExp(r'[^A-Za-z0-9]'))) classes++;
  return classes;
}
