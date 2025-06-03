import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('en', 'US')
  ];

  /// No description provided for @uniquest.
  ///
  /// In en_US, this message translates to:
  /// **'UNIQUEST'**
  String get uniquest;

  /// No description provided for @yourJourneyToFindPerfectUniversity.
  ///
  /// In en_US, this message translates to:
  /// **'Your Journey to Find Perfect University'**
  String get yourJourneyToFindPerfectUniversity;

  /// No description provided for @signUp.
  ///
  /// In en_US, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In en_US, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en_US, this message translates to:
  /// **'Dont have an account?'**
  String get dontHaveAnAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en_US, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @loginToYourAccount.
  ///
  /// In en_US, this message translates to:
  /// **'Login to your account!'**
  String get loginToYourAccount;

  /// No description provided for @username.
  ///
  /// In en_US, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @rememberMeNextTime.
  ///
  /// In en_US, this message translates to:
  /// **'Remember me next time?'**
  String get rememberMeNextTime;

  /// No description provided for @forgotPassword.
  ///
  /// In en_US, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @phoneNumber.
  ///
  /// In en_US, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @enterYourPhoneNumber.
  ///
  /// In en_US, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhoneNumber;

  /// No description provided for @sendCode.
  ///
  /// In en_US, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @pleaseCheckYourEmail.
  ///
  /// In en_US, this message translates to:
  /// **'Please Check Your Email!'**
  String get pleaseCheckYourEmail;

  /// No description provided for @verify.
  ///
  /// In en_US, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @yourCodeWasSentToYouViaEmail.
  ///
  /// In en_US, this message translates to:
  /// **'Your code was sent to you via email'**
  String get yourCodeWasSentToYouViaEmail;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en_US, this message translates to:
  /// **'Didnt receive code?'**
  String get didntReceiveCode;

  /// No description provided for @requestAgain.
  ///
  /// In en_US, this message translates to:
  /// **'Request again'**
  String get requestAgain;

  /// No description provided for @yourPasswordHasBeenSuccessfullyChanged.
  ///
  /// In en_US, this message translates to:
  /// **'Your Password Has Been Successfully Changed'**
  String get yourPasswordHasBeenSuccessfullyChanged;

  /// No description provided for @login.
  ///
  /// In en_US, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @chooseYourLanguage.
  ///
  /// In en_US, this message translates to:
  /// **'Choose Your Language'**
  String get chooseYourLanguage;

  /// No description provided for @select.
  ///
  /// In en_US, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @register.
  ///
  /// In en_US, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en_US, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @name.
  ///
  /// In en_US, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @dob.
  ///
  /// In en_US, this message translates to:
  /// **'DOB - 1999/08/15'**
  String get dob;

  /// No description provided for @password.
  ///
  /// In en_US, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en_US, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @termsAndConditions.
  ///
  /// In en_US, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @universityFinder.
  ///
  /// In en_US, this message translates to:
  /// **'University Finder'**
  String get universityFinder;

  /// No description provided for @findYourPerfectUniversityBasedOnYourScores.
  ///
  /// In en_US, this message translates to:
  /// **'Find Your Perfect University Based on Your Scores'**
  String get findYourPerfectUniversityBasedOnYourScores;

  /// No description provided for @findByIELTSScore.
  ///
  /// In en_US, this message translates to:
  /// **'Find by IELTS \n Score only'**
  String get findByIELTSScore;

  /// No description provided for @findByTOEFLScore.
  ///
  /// In en_US, this message translates to:
  /// **'Find by TOEFL \n Score only'**
  String get findByTOEFLScore;

  /// No description provided for @findByGREScore.
  ///
  /// In en_US, this message translates to:
  /// **'Find by GRE \n Score only'**
  String get findByGREScore;

  /// No description provided for @findByGMATScore.
  ///
  /// In en_US, this message translates to:
  /// **'Find by GMAT \n Score only'**
  String get findByGMATScore;

  /// No description provided for @compareScores.
  ///
  /// In en_US, this message translates to:
  /// **'Compare Scores'**
  String get compareScores;

  /// No description provided for @findTopUniversities.
  ///
  /// In en_US, this message translates to:
  /// **'Find Top\nUniversities'**
  String get findTopUniversities;

  /// No description provided for @wishlistedUniversities.
  ///
  /// In en_US, this message translates to:
  /// **'Wishlisted \nUniversities'**
  String get wishlistedUniversities;

  /// No description provided for @user.
  ///
  /// In en_US, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @history.
  ///
  /// In en_US, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @done.
  ///
  /// In en_US, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en_US, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @eight_to_nine.
  ///
  /// In en_US, this message translates to:
  /// **'8.0 - 9.0'**
  String get eight_to_nine;

  /// No description provided for @seven_to_eight.
  ///
  /// In en_US, this message translates to:
  /// **'7.0 - 7.9'**
  String get seven_to_eight;

  /// No description provided for @six_to_seven.
  ///
  /// In en_US, this message translates to:
  /// **'6.0 - 6.9'**
  String get six_to_seven;

  /// No description provided for @six_or_below.
  ///
  /// In en_US, this message translates to:
  /// **'6.0 or below'**
  String get six_or_below;

  /// No description provided for @three_twenty_to_three_forty.
  ///
  /// In en_US, this message translates to:
  /// **'320 - 340'**
  String get three_twenty_to_three_forty;

  /// No description provided for @three_hundred_to_three_hundred_nineteen.
  ///
  /// In en_US, this message translates to:
  /// **'300 - 319'**
  String get three_hundred_to_three_hundred_nineteen;

  /// No description provided for @two_sixty_to_three_hundred.
  ///
  /// In en_US, this message translates to:
  /// **'260 - 300'**
  String get two_sixty_to_three_hundred;

  /// No description provided for @seven_hundred_to_hundred.
  ///
  /// In en_US, this message translates to:
  /// **'700 - 800'**
  String get seven_hundred_to_hundred;

  /// No description provided for @six_hundered_to_seven_hundred.
  ///
  /// In en_US, this message translates to:
  /// **'600 - 700'**
  String get six_hundered_to_seven_hundred;

  /// No description provided for @four_hundred_fifty_to_six_hundred.
  ///
  /// In en_US, this message translates to:
  /// **'450 - 600'**
  String get four_hundred_fifty_to_six_hundred;

  /// No description provided for @hundred_to_one_twenty.
  ///
  /// In en_US, this message translates to:
  /// **'100 - 120'**
  String get hundred_to_one_twenty;

  /// No description provided for @eighty_to_hundred.
  ///
  /// In en_US, this message translates to:
  /// **'80 - 100'**
  String get eighty_to_hundred;

  /// No description provided for @sixty_to_eighty.
  ///
  /// In en_US, this message translates to:
  /// **'60 - 80'**
  String get sixty_to_eighty;

  /// No description provided for @hello.
  ///
  /// In en_US, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @home.
  ///
  /// In en_US, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @account.
  ///
  /// In en_US, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @features.
  ///
  /// In en_US, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @settings.
  ///
  /// In en_US, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @help.
  ///
  /// In en_US, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @whatIsYourPreferredLevelOfStudy.
  ///
  /// In en_US, this message translates to:
  /// **'What is your preferred level of study?'**
  String get whatIsYourPreferredLevelOfStudy;

  /// No description provided for @undergraduate.
  ///
  /// In en_US, this message translates to:
  /// **'Undergraduate'**
  String get undergraduate;

  /// No description provided for @graduate.
  ///
  /// In en_US, this message translates to:
  /// **'Graduate'**
  String get graduate;

  /// No description provided for @phd.
  ///
  /// In en_US, this message translates to:
  /// **'PhD'**
  String get phd;

  /// No description provided for @whichCountriesDoYouPreferToStudyIn.
  ///
  /// In en_US, this message translates to:
  /// **'Which countries do you prefer to study in?'**
  String get whichCountriesDoYouPreferToStudyIn;

  /// No description provided for @usa.
  ///
  /// In en_US, this message translates to:
  /// **'USA'**
  String get usa;

  /// No description provided for @delete.
  ///
  /// In en_US, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @uk.
  ///
  /// In en_US, this message translates to:
  /// **'UK'**
  String get uk;

  /// No description provided for @australia.
  ///
  /// In en_US, this message translates to:
  /// **'Australia'**
  String get australia;

  /// No description provided for @germany.
  ///
  /// In en_US, this message translates to:
  /// **'Germany'**
  String get germany;

  /// No description provided for @loginFailed.
  ///
  /// In en_US, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginFailed;

  /// No description provided for @whatIsYourIntendedMajorOrProgramOfInterest.
  ///
  /// In en_US, this message translates to:
  /// **'What is your intended major or program of interest?'**
  String get whatIsYourIntendedMajorOrProgramOfInterest;

  /// No description provided for @whatIsYourApproximateBudgetForTuitionAndLivingExpenses.
  ///
  /// In en_US, this message translates to:
  /// **'What is your approximate budget for tuition and living expenses?'**
  String get whatIsYourApproximateBudgetForTuitionAndLivingExpenses;

  /// No description provided for @whatAreYourIELTSScore.
  ///
  /// In en_US, this message translates to:
  /// **'What are your IELTS score?'**
  String get whatAreYourIELTSScore;

  /// No description provided for @typeYourScore.
  ///
  /// In en_US, this message translates to:
  /// **'Type your score'**
  String get typeYourScore;

  /// No description provided for @yes.
  ///
  /// In en_US, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en_US, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @whatIsYourGPAOrPercentageScoreFromPreviousStudies.
  ///
  /// In en_US, this message translates to:
  /// **'What is your GPA or percentage score from previous studies?'**
  String get whatIsYourGPAOrPercentageScoreFromPreviousStudies;

  /// No description provided for @basedOnYour.
  ///
  /// In en_US, this message translates to:
  /// **'Based on your scores, here are universities tailored just for you. Start exploring your future today!'**
  String get basedOnYour;

  /// No description provided for @whatAreYourTOEFLScores.
  ///
  /// In en_US, this message translates to:
  /// **'What are your TOEFL scores?'**
  String get whatAreYourTOEFLScores;

  /// No description provided for @inputYourTOEFLScore.
  ///
  /// In en_US, this message translates to:
  /// **'Input your TOEFL score'**
  String get inputYourTOEFLScore;

  /// No description provided for @inputYourIELTSScore.
  ///
  /// In en_US, this message translates to:
  /// **'Input your IELTS score'**
  String get inputYourIELTSScore;

  /// No description provided for @inputYourGMATScore.
  ///
  /// In en_US, this message translates to:
  /// **'Input your GMAT score'**
  String get inputYourGMATScore;

  /// No description provided for @inputYourGREScore.
  ///
  /// In en_US, this message translates to:
  /// **'Input your GRE score'**
  String get inputYourGREScore;

  /// No description provided for @inputYourPreferredLocation.
  ///
  /// In en_US, this message translates to:
  /// **'Input your preferred location'**
  String get inputYourPreferredLocation;

  /// No description provided for @whatAreYourGREScores.
  ///
  /// In en_US, this message translates to:
  /// **'What are your GRE scores?'**
  String get whatAreYourGREScores;

  /// No description provided for @whatAreYourGMATScores.
  ///
  /// In en_US, this message translates to:
  /// **'What are your GMAT scores?'**
  String get whatAreYourGMATScores;

  /// No description provided for @haveYouGivenGREBefore.
  ///
  /// In en_US, this message translates to:
  /// **'Have you given GRE before?'**
  String get haveYouGivenGREBefore;

  /// No description provided for @haveYouGivenGMATBefore.
  ///
  /// In en_US, this message translates to:
  /// **'Have you given GMAT before?'**
  String get haveYouGivenGMATBefore;

  /// No description provided for @haveYouGivenTOEFLBefore.
  ///
  /// In en_US, this message translates to:
  /// **'Have you given TOEFL before?'**
  String get haveYouGivenTOEFLBefore;

  /// No description provided for @haveYouGivenIELTSBefore.
  ///
  /// In en_US, this message translates to:
  /// **'Have you given IELTS before?'**
  String get haveYouGivenIELTSBefore;

  /// No description provided for @findYourFavouriteUniversity.
  ///
  /// In en_US, this message translates to:
  /// **'FIND YOUR FAVOURITE UNIVERSITY'**
  String get findYourFavouriteUniversity;

  /// No description provided for @shareYourScores.
  ///
  /// In en_US, this message translates to:
  /// **'Share your scores and preferences, and we will match you with universities that fit your goals. Your dream starts here!'**
  String get shareYourScores;

  /// No description provided for @getStarted.
  ///
  /// In en_US, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @countryPreferences.
  ///
  /// In en_US, this message translates to:
  /// **'Country Preferences'**
  String get countryPreferences;

  /// No description provided for @preferredStudyLevel.
  ///
  /// In en_US, this message translates to:
  /// **'Preferred Study Level'**
  String get preferredStudyLevel;

  /// No description provided for @fieldOfStudy.
  ///
  /// In en_US, this message translates to:
  /// **'Field of Study'**
  String get fieldOfStudy;

  /// No description provided for @budgetRange.
  ///
  /// In en_US, this message translates to:
  /// **'Budget Range'**
  String get budgetRange;

  /// No description provided for @ieltsScore.
  ///
  /// In en_US, this message translates to:
  /// **'IELTS Score'**
  String get ieltsScore;

  /// No description provided for @gpa.
  ///
  /// In en_US, this message translates to:
  /// **'GPA'**
  String get gpa;

  /// No description provided for @gre.
  ///
  /// In en_US, this message translates to:
  /// **'GRE'**
  String get gre;

  /// No description provided for @toefl.
  ///
  /// In en_US, this message translates to:
  /// **'TOEFL'**
  String get toefl;

  /// No description provided for @course.
  ///
  /// In en_US, this message translates to:
  /// **'Course'**
  String get course;

  /// No description provided for @ai_ds.
  ///
  /// In en_US, this message translates to:
  /// **'AI/DS'**
  String get ai_ds;

  /// No description provided for @registerAccount.
  ///
  /// In en_US, this message translates to:
  /// **'Register Account'**
  String get registerAccount;

  /// No description provided for @firstName.
  ///
  /// In en_US, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en_US, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @welcomeMessage.
  ///
  /// In en_US, this message translates to:
  /// **'Welcome User'**
  String get welcomeMessage;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en_US, this message translates to:
  /// **'Please enter a valid Email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterValidName.
  ///
  /// In en_US, this message translates to:
  /// **'Please enter a valid Name'**
  String get pleaseEnterValidName;

  /// No description provided for @pleaseEnterValidDOB.
  ///
  /// In en_US, this message translates to:
  /// **'Please enter a valid Date of Birth'**
  String get pleaseEnterValidDOB;

  /// No description provided for @pleaseEnterValidPhoneNumber.
  ///
  /// In en_US, this message translates to:
  /// **'Please enter a valid Phone Number'**
  String get pleaseEnterValidPhoneNumber;

  /// No description provided for @pleaseEnterValidPassword.
  ///
  /// In en_US, this message translates to:
  /// **'Password must be at least 8 characters with uppercase, lowercase, number, and special character'**
  String get pleaseEnterValidPassword;

  /// No description provided for @passwordAndConfirmPasswordDoNotMatch.
  ///
  /// In en_US, this message translates to:
  /// **'Password and Confirm Password do not match'**
  String get passwordAndConfirmPasswordDoNotMatch;

  /// No description provided for @admissionPercentageCalculator.
  ///
  /// In en_US, this message translates to:
  /// **'Admission \nPercent \nCalculator'**
  String get admissionPercentageCalculator;

  /// No description provided for @rank.
  ///
  /// In en_US, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @statusSafe.
  ///
  /// In en_US, this message translates to:
  /// **'STATUS :\nSAFE'**
  String get statusSafe;

  /// No description provided for @applyNow.
  ///
  /// In en_US, this message translates to:
  /// **'APPLY NOW'**
  String get applyNow;

  /// No description provided for @readiculous.
  ///
  /// In en_US, this message translates to:
  /// **'READICULOUS'**
  String get readiculous;

  /// No description provided for @findRecommendedBooksForUser.
  ///
  /// In en_US, this message translates to:
  /// **'Find\nRecommended \nBooks For User'**
  String get findRecommendedBooksForUser;

  /// No description provided for @findRecommendedBooksForYourLibrary.
  ///
  /// In en_US, this message translates to:
  /// **'Find\nRecommended \nBooks For Library'**
  String get findRecommendedBooksForYourLibrary;

  /// No description provided for @whichGenresDoYouPrefer.
  ///
  /// In en_US, this message translates to:
  /// **'Which Genres do you prefer?'**
  String get whichGenresDoYouPrefer;

  /// No description provided for @pleaseEnterValidLocation.
  ///
  /// In en_US, this message translates to:
  /// **'Please Enter Valid Location'**
  String get pleaseEnterValidLocation;

  /// No description provided for @location.
  ///
  /// In en_US, this message translates to:
  /// **'Location'**
  String get location;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en': {
  switch (locale.countryCode) {
    case 'US': return AppLocalizationsEnUs();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
