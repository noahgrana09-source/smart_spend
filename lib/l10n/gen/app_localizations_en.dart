// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get authLoginTitle => 'Sign in';

  @override
  String get authRegisterTitle => 'Create account';

  @override
  String get authEmailVerificationTitle => 'Verify your email';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authNameLabel => 'Name';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authSignInButton => 'Sign in';

  @override
  String get authRegisterButton => 'Create account';

  @override
  String get authGoogleButton => 'Continue with Google';

  @override
  String authEmailVerificationDescription(String email) {
    return 'We sent a verification link to $email. Check your inbox, and if you don\'t see it, look in your spam folder.';
  }

  @override
  String get authEmailVerifiedButton => 'Email verified';

  @override
  String get authResendEmailButton => 'Resend email';

  @override
  String get authBackToRegisterButton => 'Back to register';

  @override
  String get authGoToRegisterPrompt => 'Don\'t have an account?';

  @override
  String get authGoToRegisterAction => 'Sign up';

  @override
  String get authGoToLoginPrompt => 'Already have an account?';

  @override
  String get authGoToLoginAction => 'Sign in';

  @override
  String get authValidationEmailEmpty => 'Enter your email';

  @override
  String get authValidationEmailInvalid => 'Enter a valid email';

  @override
  String get authValidationPasswordEmpty => 'Enter your password';

  @override
  String authValidationPasswordTooShort(int min) {
    return 'Password must be at least $min characters';
  }

  @override
  String get authValidationPasswordTooCommon =>
      'That password is too common, pick another one';

  @override
  String get authValidationPasswordContainsIdentity =>
      'Password can\'t contain your email or obvious patterns';

  @override
  String get authValidationNameEmpty => 'Enter your name';

  @override
  String get authValidationConfirmPasswordEmpty => 'Repeat your password';

  @override
  String get authValidationConfirmPasswordMismatch => 'Passwords don\'t match';

  @override
  String get authErrorInvalidCredentials => 'Wrong email or password';

  @override
  String get authErrorEmailAlreadyInUse =>
      'An account with this email already exists';

  @override
  String get authErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get authErrorEmailNotVerified => 'Your email isn\'t verified yet';

  @override
  String get authPasswordStrengthWeak => 'Weak password';

  @override
  String get authPasswordStrengthStrong => 'Strong password';

  @override
  String get onbDropdownDone => 'Done';
}
