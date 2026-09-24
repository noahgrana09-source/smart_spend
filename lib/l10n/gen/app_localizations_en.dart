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

  @override
  String onbGetStartedGreeting(String name) {
    return 'Hi $name, let\'s get you started!';
  }

  @override
  String get onbStartButton => 'Start';

  @override
  String get onbPickNationalityTitle => 'Pick your nationality';

  @override
  String get onbNationalityLabel => 'Nationality';

  @override
  String get onbNextButton => 'Next';

  @override
  String get onbFinishButton => 'Finish';

  @override
  String onbErrorGeneric(String title) {
    return 'Something went wrong: $title. Please try again.';
  }

  @override
  String get onbTestTimeHorizonQuestion =>
      'How long do you plan to keep this money invested before you might need it?';

  @override
  String get onbTestTimeHorizonOption1 => 'Less than 1 year';

  @override
  String get onbTestTimeHorizonOption2 => '1 to 3 years';

  @override
  String get onbTestTimeHorizonOption3 => '3 to 7 years';

  @override
  String get onbTestTimeHorizonOption4 => 'More than 7 years';

  @override
  String get onbTestMarketDropQuestion =>
      'Your portfolio drops 20% in a few weeks. What do you do?';

  @override
  String get onbTestMarketDropOption1 =>
      'Sell everything to avoid further losses';

  @override
  String get onbTestMarketDropOption2 => 'Sell part of it to reduce risk';

  @override
  String get onbTestMarketDropOption3 => 'Do nothing and wait it out';

  @override
  String get onbTestMarketDropOption4 => 'Buy more while prices are low';

  @override
  String get onbTestGoalQuestion => 'What\'s your main investment goal?';

  @override
  String get onbTestGoalOption1 => 'Preserve my capital';

  @override
  String get onbTestGoalOption2 => 'Generate steady income';

  @override
  String get onbTestGoalOption3 => 'Grow my capital moderately';

  @override
  String get onbTestGoalOption4 => 'Maximize long-term growth';

  @override
  String get onbTestSituationQuestion =>
      'Which of these describe your financial situation? (Select all that apply)';

  @override
  String get onbTestSituationOption1 =>
      'I have an emergency fund covering 3+ months of expenses';

  @override
  String get onbTestSituationOption2 => 'I have stable, predictable income';

  @override
  String get onbTestSituationOption3 =>
      'I have other savings or investments besides this';

  @override
  String get onbTestSituationOption4 =>
      'This money is earmarked for a near-term expense';

  @override
  String get onbTestExperienceQuestion =>
      'How would you describe your investing experience?';

  @override
  String get onbTestExperienceOption1 => 'None, I\'m new to investing';

  @override
  String get onbTestExperienceOption2 => 'Some, I understand the basics';

  @override
  String get onbTestExperienceOption3 => 'Good, I actively follow the markets';

  @override
  String get onbTestExperienceOption4 =>
      'Extensive, I have advanced or professional experience';
}
