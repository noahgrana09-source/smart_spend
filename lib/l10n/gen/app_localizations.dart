import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginTitle;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authRegisterTitle;

  /// No description provided for @authEmailVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get authEmailVerificationTitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get authNameLabel;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInButton;

  /// No description provided for @authRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authRegisterButton;

  /// No description provided for @authGoogleButton.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authGoogleButton;

  /// No description provided for @authEmailVerificationDescription.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to {email}. Check your inbox, and if you don\'t see it, look in your spam folder.'**
  String authEmailVerificationDescription(String email);

  /// No description provided for @authEmailVerifiedButton.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get authEmailVerifiedButton;

  /// No description provided for @authResendEmailButton.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get authResendEmailButton;

  /// No description provided for @authBackToRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Back to register'**
  String get authBackToRegisterButton;

  /// No description provided for @authGoToRegisterPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authGoToRegisterPrompt;

  /// No description provided for @authGoToRegisterAction.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authGoToRegisterAction;

  /// No description provided for @authGoToLoginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authGoToLoginPrompt;

  /// No description provided for @authGoToLoginAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authGoToLoginAction;

  /// No description provided for @authValidationEmailEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authValidationEmailEmpty;

  /// No description provided for @authValidationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get authValidationEmailInvalid;

  /// No description provided for @authValidationPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authValidationPasswordEmpty;

  /// No description provided for @authValidationPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {min} characters'**
  String authValidationPasswordTooShort(int min);

  /// No description provided for @authValidationPasswordTooCommon.
  ///
  /// In en, this message translates to:
  /// **'That password is too common, pick another one'**
  String get authValidationPasswordTooCommon;

  /// No description provided for @authValidationPasswordContainsIdentity.
  ///
  /// In en, this message translates to:
  /// **'Password can\'t contain your email or obvious patterns'**
  String get authValidationPasswordContainsIdentity;

  /// No description provided for @authValidationNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get authValidationNameEmpty;

  /// No description provided for @authValidationConfirmPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Repeat your password'**
  String get authValidationConfirmPasswordEmpty;

  /// No description provided for @authValidationConfirmPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get authValidationConfirmPasswordMismatch;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorEmailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists'**
  String get authErrorEmailAlreadyInUse;

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authErrorGeneric;

  /// No description provided for @authErrorEmailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Your email isn\'t verified yet'**
  String get authErrorEmailNotVerified;

  /// No description provided for @authPasswordStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak password'**
  String get authPasswordStrengthWeak;

  /// No description provided for @authPasswordStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong password'**
  String get authPasswordStrengthStrong;

  /// No description provided for @onbDropdownDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get onbDropdownDone;

  /// No description provided for @onbGetStartedGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi {name}, let\'s get you started!'**
  String onbGetStartedGreeting(String name);

  /// No description provided for @onbStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onbStartButton;

  /// No description provided for @onbPickNationalityTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your nationality'**
  String get onbPickNationalityTitle;

  /// No description provided for @onbNationalityLabel.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get onbNationalityLabel;

  /// No description provided for @onbNextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onbNextButton;

  /// No description provided for @onbFinishButton.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get onbFinishButton;

  /// No description provided for @onbErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {title}. Please try again.'**
  String onbErrorGeneric(String title);

  /// No description provided for @onbTestTimeHorizonQuestion.
  ///
  /// In en, this message translates to:
  /// **'How long do you plan to keep this money invested before you might need it?'**
  String get onbTestTimeHorizonQuestion;

  /// No description provided for @onbTestTimeHorizonOption1.
  ///
  /// In en, this message translates to:
  /// **'Less than 1 year'**
  String get onbTestTimeHorizonOption1;

  /// No description provided for @onbTestTimeHorizonOption2.
  ///
  /// In en, this message translates to:
  /// **'1 to 3 years'**
  String get onbTestTimeHorizonOption2;

  /// No description provided for @onbTestTimeHorizonOption3.
  ///
  /// In en, this message translates to:
  /// **'3 to 7 years'**
  String get onbTestTimeHorizonOption3;

  /// No description provided for @onbTestTimeHorizonOption4.
  ///
  /// In en, this message translates to:
  /// **'More than 7 years'**
  String get onbTestTimeHorizonOption4;

  /// No description provided for @onbTestMarketDropQuestion.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio drops 20% in a few weeks. What do you do?'**
  String get onbTestMarketDropQuestion;

  /// No description provided for @onbTestMarketDropOption1.
  ///
  /// In en, this message translates to:
  /// **'Sell everything to avoid further losses'**
  String get onbTestMarketDropOption1;

  /// No description provided for @onbTestMarketDropOption2.
  ///
  /// In en, this message translates to:
  /// **'Sell part of it to reduce risk'**
  String get onbTestMarketDropOption2;

  /// No description provided for @onbTestMarketDropOption3.
  ///
  /// In en, this message translates to:
  /// **'Do nothing and wait it out'**
  String get onbTestMarketDropOption3;

  /// No description provided for @onbTestMarketDropOption4.
  ///
  /// In en, this message translates to:
  /// **'Buy more while prices are low'**
  String get onbTestMarketDropOption4;

  /// No description provided for @onbTestGoalQuestion.
  ///
  /// In en, this message translates to:
  /// **'What\'s your main investment goal?'**
  String get onbTestGoalQuestion;

  /// No description provided for @onbTestGoalOption1.
  ///
  /// In en, this message translates to:
  /// **'Preserve my capital'**
  String get onbTestGoalOption1;

  /// No description provided for @onbTestGoalOption2.
  ///
  /// In en, this message translates to:
  /// **'Generate steady income'**
  String get onbTestGoalOption2;

  /// No description provided for @onbTestGoalOption3.
  ///
  /// In en, this message translates to:
  /// **'Grow my capital moderately'**
  String get onbTestGoalOption3;

  /// No description provided for @onbTestGoalOption4.
  ///
  /// In en, this message translates to:
  /// **'Maximize long-term growth'**
  String get onbTestGoalOption4;

  /// No description provided for @onbTestSituationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Which of these describe your financial situation? (Select all that apply)'**
  String get onbTestSituationQuestion;

  /// No description provided for @onbTestSituationOption1.
  ///
  /// In en, this message translates to:
  /// **'I have an emergency fund covering 3+ months of expenses'**
  String get onbTestSituationOption1;

  /// No description provided for @onbTestSituationOption2.
  ///
  /// In en, this message translates to:
  /// **'I have stable, predictable income'**
  String get onbTestSituationOption2;

  /// No description provided for @onbTestSituationOption3.
  ///
  /// In en, this message translates to:
  /// **'I have other savings or investments besides this'**
  String get onbTestSituationOption3;

  /// No description provided for @onbTestSituationOption4.
  ///
  /// In en, this message translates to:
  /// **'This money is earmarked for a near-term expense'**
  String get onbTestSituationOption4;

  /// No description provided for @onbTestExperienceQuestion.
  ///
  /// In en, this message translates to:
  /// **'How would you describe your investing experience?'**
  String get onbTestExperienceQuestion;

  /// No description provided for @onbTestExperienceOption1.
  ///
  /// In en, this message translates to:
  /// **'None, I\'m new to investing'**
  String get onbTestExperienceOption1;

  /// No description provided for @onbTestExperienceOption2.
  ///
  /// In en, this message translates to:
  /// **'Some, I understand the basics'**
  String get onbTestExperienceOption2;

  /// No description provided for @onbTestExperienceOption3.
  ///
  /// In en, this message translates to:
  /// **'Good, I actively follow the markets'**
  String get onbTestExperienceOption3;

  /// No description provided for @onbTestExperienceOption4.
  ///
  /// In en, this message translates to:
  /// **'Extensive, I have advanced or professional experience'**
  String get onbTestExperienceOption4;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
