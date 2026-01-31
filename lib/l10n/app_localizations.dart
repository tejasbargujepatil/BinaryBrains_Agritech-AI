import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_mr.dart';

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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('mr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'KrishiMitra'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your AI Agriculture Partner'**
  String get appTagline;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get pleaseWait;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login to KrishiMitra'**
  String get loginTitle;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @registerNow.
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get registerNow;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @loginNow.
  ///
  /// In en, this message translates to:
  /// **'Login Now'**
  String get loginNow;

  /// No description provided for @fetchingLocation.
  ///
  /// In en, this message translates to:
  /// **'Fetching your location...'**
  String get fetchingLocation;

  /// No description provided for @fetchingWeather.
  ///
  /// In en, this message translates to:
  /// **'Fetching weather data...'**
  String get fetchingWeather;

  /// No description provided for @fetchingSoil.
  ///
  /// In en, this message translates to:
  /// **'Fetching soil data...'**
  String get fetchingSoil;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @crops.
  ///
  /// In en, this message translates to:
  /// **'Crops'**
  String get crops;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @weather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weather;

  /// No description provided for @soil.
  ///
  /// In en, this message translates to:
  /// **'Soil'**
  String get soil;

  /// No description provided for @addNewCrop.
  ///
  /// In en, this message translates to:
  /// **'Add New Crop'**
  String get addNewCrop;

  /// No description provided for @agentView.
  ///
  /// In en, this message translates to:
  /// **'Agent View'**
  String get agentView;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @rainfall.
  ///
  /// In en, this message translates to:
  /// **'Rainfall'**
  String get rainfall;

  /// No description provided for @rainProbability.
  ///
  /// In en, this message translates to:
  /// **'Rain Probability'**
  String get rainProbability;

  /// No description provided for @wind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get wind;

  /// No description provided for @forecast.
  ///
  /// In en, this message translates to:
  /// **'Forecast'**
  String get forecast;

  /// No description provided for @dayForecast.
  ///
  /// In en, this message translates to:
  /// **'7-Day Forecast'**
  String get dayForecast;

  /// No description provided for @cropImpact.
  ///
  /// In en, this message translates to:
  /// **'Crop Impact'**
  String get cropImpact;

  /// No description provided for @soilType.
  ///
  /// In en, this message translates to:
  /// **'Soil Type'**
  String get soilType;

  /// No description provided for @soilMoisture.
  ///
  /// In en, this message translates to:
  /// **'Soil Moisture'**
  String get soilMoisture;

  /// No description provided for @nitrogen.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen (N)'**
  String get nitrogen;

  /// No description provided for @phosphorus.
  ///
  /// In en, this message translates to:
  /// **'Phosphorus (P)'**
  String get phosphorus;

  /// No description provided for @potassium.
  ///
  /// In en, this message translates to:
  /// **'Potassium (K)'**
  String get potassium;

  /// No description provided for @soilAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Soil Analysis'**
  String get soilAnalysis;

  /// No description provided for @cropName.
  ///
  /// In en, this message translates to:
  /// **'Crop Name'**
  String get cropName;

  /// No description provided for @sowingDate.
  ///
  /// In en, this message translates to:
  /// **'Sowing Date'**
  String get sowingDate;

  /// No description provided for @landArea.
  ///
  /// In en, this message translates to:
  /// **'Land Area'**
  String get landArea;

  /// No description provided for @irrigationType.
  ///
  /// In en, this message translates to:
  /// **'Irrigation Type'**
  String get irrigationType;

  /// No description provided for @cropVariety.
  ///
  /// In en, this message translates to:
  /// **'Crop Variety'**
  String get cropVariety;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'(Optional)'**
  String get optional;

  /// No description provided for @selectCrop.
  ///
  /// In en, this message translates to:
  /// **'Select Crop'**
  String get selectCrop;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectIrrigation.
  ///
  /// In en, this message translates to:
  /// **'Select Irrigation Type'**
  String get selectIrrigation;

  /// No description provided for @acres.
  ///
  /// In en, this message translates to:
  /// **'Acres'**
  String get acres;

  /// No description provided for @hectares.
  ///
  /// In en, this message translates to:
  /// **'Hectares'**
  String get hectares;

  /// No description provided for @myCrops.
  ///
  /// In en, this message translates to:
  /// **'My Crops'**
  String get myCrops;

  /// No description provided for @cropHealth.
  ///
  /// In en, this message translates to:
  /// **'Crop Health'**
  String get cropHealth;

  /// No description provided for @currentStage.
  ///
  /// In en, this message translates to:
  /// **'Current Stage'**
  String get currentStage;

  /// No description provided for @lastUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last Update'**
  String get lastUpdate;

  /// No description provided for @noCrops.
  ///
  /// In en, this message translates to:
  /// **'No crops added yet'**
  String get noCrops;

  /// No description provided for @addYourFirstCrop.
  ///
  /// In en, this message translates to:
  /// **'Add your first crop to get started'**
  String get addYourFirstCrop;

  /// No description provided for @cropDashboard.
  ///
  /// In en, this message translates to:
  /// **'Crop Dashboard'**
  String get cropDashboard;

  /// No description provided for @suitability.
  ///
  /// In en, this message translates to:
  /// **'Crop Suitability & Soil Validation'**
  String get suitability;

  /// No description provided for @governmentSchemes.
  ///
  /// In en, this message translates to:
  /// **'Government Schemes'**
  String get governmentSchemes;

  /// No description provided for @sowingPlan.
  ///
  /// In en, this message translates to:
  /// **'Sowing Time & Weather Planning'**
  String get sowingPlan;

  /// No description provided for @fertilization.
  ///
  /// In en, this message translates to:
  /// **'Fertilization Plan'**
  String get fertilization;

  /// No description provided for @lowCostAlternatives.
  ///
  /// In en, this message translates to:
  /// **'Low-Cost Alternatives'**
  String get lowCostAlternatives;

  /// No description provided for @irrigationSchedule.
  ///
  /// In en, this message translates to:
  /// **'Irrigation Schedule'**
  String get irrigationSchedule;

  /// No description provided for @diseaseProbability.
  ///
  /// In en, this message translates to:
  /// **'Disease Probability Timeline'**
  String get diseaseProbability;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhoto;

  /// No description provided for @photoForDisease.
  ///
  /// In en, this message translates to:
  /// **'Upload photo for disease monitoring'**
  String get photoForDisease;

  /// No description provided for @harvestTiming.
  ///
  /// In en, this message translates to:
  /// **'Harvest Timing & Yield Prediction'**
  String get harvestTiming;

  /// No description provided for @cropResidue.
  ///
  /// In en, this message translates to:
  /// **'Crop Residue & Waste Utilization'**
  String get cropResidue;

  /// No description provided for @storageGuidance.
  ///
  /// In en, this message translates to:
  /// **'Storage Guidance'**
  String get storageGuidance;

  /// No description provided for @pricePrediction.
  ///
  /// In en, this message translates to:
  /// **'Price Prediction'**
  String get pricePrediction;

  /// No description provided for @valueAddedProducts.
  ///
  /// In en, this message translates to:
  /// **'Value-Added Products'**
  String get valueAddedProducts;

  /// No description provided for @directSelling.
  ///
  /// In en, this message translates to:
  /// **'Direct Selling Platforms'**
  String get directSelling;

  /// No description provided for @avoidMiddlemen.
  ///
  /// In en, this message translates to:
  /// **'Avoid Middlemen'**
  String get avoidMiddlemen;

  /// No description provided for @alliedBusiness.
  ///
  /// In en, this message translates to:
  /// **'Allied Farm Business Ideas'**
  String get alliedBusiness;

  /// No description provided for @fertilizerBill.
  ///
  /// In en, this message translates to:
  /// **'Upload Fertilizer Bill'**
  String get fertilizerBill;

  /// No description provided for @costComparison.
  ///
  /// In en, this message translates to:
  /// **'Cost Comparison'**
  String get costComparison;

  /// No description provided for @alertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts & Notifications'**
  String get alertsTitle;

  /// No description provided for @diseaseAlert.
  ///
  /// In en, this message translates to:
  /// **'Disease Alert'**
  String get diseaseAlert;

  /// No description provided for @weatherWarning.
  ///
  /// In en, this message translates to:
  /// **'Weather Warning'**
  String get weatherWarning;

  /// No description provided for @harvestReminder.
  ///
  /// In en, this message translates to:
  /// **'Harvest Reminder'**
  String get harvestReminder;

  /// No description provided for @photoReminder.
  ///
  /// In en, this message translates to:
  /// **'Photo Upload Reminder'**
  String get photoReminder;

  /// No description provided for @noAlerts.
  ///
  /// In en, this message translates to:
  /// **'No alerts at this time'**
  String get noAlerts;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as Read'**
  String get markAsRead;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @refreshData.
  ///
  /// In en, this message translates to:
  /// **'Refresh Soil & Weather Data'**
  String get refreshData;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @marathi.
  ///
  /// In en, this message translates to:
  /// **'Marathi'**
  String get marathi;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @dataRefresh.
  ///
  /// In en, this message translates to:
  /// **'Auto Refresh Data'**
  String get dataRefresh;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @fair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get fair;

  /// No description provided for @poor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get poor;

  /// No description provided for @sowing.
  ///
  /// In en, this message translates to:
  /// **'Sowing'**
  String get sowing;

  /// No description provided for @germination.
  ///
  /// In en, this message translates to:
  /// **'Germination'**
  String get germination;

  /// No description provided for @vegetative.
  ///
  /// In en, this message translates to:
  /// **'Vegetative Growth'**
  String get vegetative;

  /// No description provided for @flowering.
  ///
  /// In en, this message translates to:
  /// **'Flowering'**
  String get flowering;

  /// No description provided for @fruiting.
  ///
  /// In en, this message translates to:
  /// **'Fruiting'**
  String get fruiting;

  /// No description provided for @maturity.
  ///
  /// In en, this message translates to:
  /// **'Maturity'**
  String get maturity;

  /// No description provided for @harvesting.
  ///
  /// In en, this message translates to:
  /// **'Harvesting'**
  String get harvesting;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get serverError;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please login again.'**
  String get authError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred.'**
  String get unknownError;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidMobile.
  ///
  /// In en, this message translates to:
  /// **'Invalid mobile number'**
  String get invalidMobile;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @successLogin.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get successLogin;

  /// No description provided for @successRegister.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get successRegister;

  /// No description provided for @successCropAdded.
  ///
  /// In en, this message translates to:
  /// **'Crop added successfully!'**
  String get successCropAdded;

  /// No description provided for @successUpdate.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully!'**
  String get successUpdate;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirmLogout;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this?'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get confirmDeleteAccount;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @nextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next Week'**
  String get nextWeek;

  /// No description provided for @tapToViewDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap to view details'**
  String get tapToViewDetails;

  /// No description provided for @tapToExpand.
  ///
  /// In en, this message translates to:
  /// **'Tap to expand'**
  String get tapToExpand;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;
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
      <String>['en', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
