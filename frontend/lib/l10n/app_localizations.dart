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
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('en', 'US')
  ];

  String get signUp;
  String get signIn;
  String get dontHaveAnAccount;
  String get welcomeBack;
  String get loginToYourAccount;
  String get username;
  String get rememberMeNextTime;
  String get forgotPassword;
  String get phoneNumber;
  String get enterYourPhoneNumber;
  String get sendCode;
  String get pleaseCheckYourEmail;
  String get verify;
  String get yourCodeWasSentToYouViaEmail;
  String get didntReceiveCode;
  String get requestAgain;
  String get yourPasswordHasBeenSuccessfullyChanged;
  String get login;
  String get chooseYourLanguage;
  String get select;
  String get register;
  String get email;
  String get name;
  String get dob;
  String get password;
  String get confirmPassword;
  String get termsAndConditions;
  String get user;
  String get history;
  String get done;
  String get next;
  String get hello;
  String get home;
  String get account;
  String get features;
  String get settings;
  String get help;
  String get delete;
  String get yes;
  String get no;
  String get loginFailed;
  String get registerAccount;
  String get firstName;
  String get lastName;
  String get welcomeMessage;
  String get pleaseEnterValidEmail;
  String get pleaseEnterValidName;
  String get pleaseEnterValidDOB;
  String get pleaseEnterValidPhoneNumber;
  String get pleaseEnterValidPassword;
  String get passwordAndConfirmPasswordDoNotMatch;
  String get readiculous;
  String get findRecommendedBooksForUser;
  String get findRecommendedBooksForYourLibrary;
  String get whichGenresDoYouPrefer;
  String get pleaseEnterValidLocation;
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