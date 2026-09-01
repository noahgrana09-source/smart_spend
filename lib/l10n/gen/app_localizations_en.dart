// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginTitle => 'Sign in';

  @override
  String get registerTitle => 'Create account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get nameLabel => 'Name';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get signInButton => 'Sign in';

  @override
  String get registerButton => 'Create account';

  @override
  String get googleButton => 'Continue with Google';

  @override
  String get goToRegister => 'Don\'t have an account? Sign up';

  @override
  String get goToLogin => 'Already have an account? Sign in';

  @override
  String get validationEmailEmpty => 'Enter your email';

  @override
  String get validationEmailInvalid => 'Enter a valid email';

  @override
  String get validationPasswordEmpty => 'Enter your password';

  @override
  String validationPasswordTooShort(int min) {
    return 'Password must be at least $min characters';
  }

  @override
  String get validationNameEmpty => 'Enter your name';

  @override
  String get validationConfirmPasswordEmpty => 'Repeat your password';

  @override
  String get validationConfirmPasswordMismatch => 'Passwords don\'t match';

  @override
  String get errorInvalidCredentials => 'Wrong email or password';

  @override
  String get errorEmailAlreadyInUse =>
      'An account with this email already exists';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';
}
