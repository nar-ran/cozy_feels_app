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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('es')
  ];

  /// No description provided for @sectionCommon.
  ///
  /// In en, this message translates to:
  /// **'========== COMMON / SYSTEM =========='**
  String get sectionCommon;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get common_accept;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get common_error;

  /// No description provided for @common_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// No description provided for @common_import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get common_import;

  /// No description provided for @common_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get common_continue;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @sectionHome.
  ///
  /// In en, this message translates to:
  /// **'========== HOME SCREEN =========='**
  String get sectionHome;

  /// No description provided for @home_title.
  ///
  /// In en, this message translates to:
  /// **'How do you feel today?'**
  String get home_title;

  /// No description provided for @home_hint_text.
  ///
  /// In en, this message translates to:
  /// **'Let it all out...'**
  String get home_hint_text;

  /// No description provided for @home_no_words_question.
  ///
  /// In en, this message translates to:
  /// **'You prefer no words?'**
  String get home_no_words_question;

  /// No description provided for @home_already_recorded.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already recorded your mood for today!'**
  String get home_already_recorded;

  /// No description provided for @sectionEditor.
  ///
  /// In en, this message translates to:
  /// **'========== MOOD EDITOR =========='**
  String get sectionEditor;

  /// No description provided for @editor_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Mood'**
  String get editor_title;

  /// No description provided for @editor_save_button.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get editor_save_button;

  /// No description provided for @editor_hint_empty.
  ///
  /// In en, this message translates to:
  /// **'Write something about your day...'**
  String get editor_hint_empty;

  /// No description provided for @sectionHistory.
  ///
  /// In en, this message translates to:
  /// **'========== HISTORY SECTION =========='**
  String get sectionHistory;

  /// No description provided for @history_title.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history_title;

  /// No description provided for @history_empty_state.
  ///
  /// In en, this message translates to:
  /// **'No entries yet...'**
  String get history_empty_state;

  /// No description provided for @history_no_words.
  ///
  /// In en, this message translates to:
  /// **'No words today...'**
  String get history_no_words;

  /// No description provided for @history_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this memory?'**
  String get history_delete_confirm;

  /// No description provided for @sectionSettings.
  ///
  /// In en, this message translates to:
  /// **'========== SETTINGS & BACKUP =========='**
  String get sectionSettings;

  /// No description provided for @settings_export_title.
  ///
  /// In en, this message translates to:
  /// **'Export Backup'**
  String get settings_export_title;

  /// No description provided for @settings_export_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your history to a file'**
  String get settings_export_subtitle;

  /// No description provided for @settings_import_title.
  ///
  /// In en, this message translates to:
  /// **'Import Backup'**
  String get settings_import_title;

  /// No description provided for @settings_import_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore your feelings from a file'**
  String get settings_import_subtitle;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_current_language_label.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settings_current_language_label;

  /// No description provided for @settings_import_success.
  ///
  /// In en, this message translates to:
  /// **'Memories imported successfully!'**
  String get settings_import_success;

  /// No description provided for @sectionPreview.
  ///
  /// In en, this message translates to:
  /// **'========== IMPORT PREVIEW =========='**
  String get sectionPreview;

  /// No description provided for @import_preview_title.
  ///
  /// In en, this message translates to:
  /// **'Import Preview'**
  String get import_preview_title;

  /// No description provided for @import_preview_at_date.
  ///
  /// In en, this message translates to:
  /// **'Everything is up to date!'**
  String get import_preview_at_date;

  /// No description provided for @import_preview_found.
  ///
  /// In en, this message translates to:
  /// **'Found {count} new entries:'**
  String import_preview_found(int count);

  /// No description provided for @import_preview_empty.
  ///
  /// In en, this message translates to:
  /// **'No words...'**
  String get import_preview_empty;

  /// No description provided for @import_preview_duplicate.
  ///
  /// In en, this message translates to:
  /// **'{count} days already exist in your history and will be skipped.'**
  String import_preview_duplicate(int count);

  /// No description provided for @sectionTimezone.
  ///
  /// In en, this message translates to:
  /// **'========== TIMEZONE SELECTOR =========='**
  String get sectionTimezone;

  /// No description provided for @timezone_title.
  ///
  /// In en, this message translates to:
  /// **'Select Zone'**
  String get timezone_title;

  /// No description provided for @timezone_ny.
  ///
  /// In en, this message translates to:
  /// **'Eastern Time (US/Canada)'**
  String get timezone_ny;

  /// No description provided for @timezone_madrid.
  ///
  /// In en, this message translates to:
  /// **'Central Europe (Madrid/Paris)'**
  String get timezone_madrid;

  /// No description provided for @timezone_ba.
  ///
  /// In en, this message translates to:
  /// **'Argentina / Brazil (South)'**
  String get timezone_ba;

  /// No description provided for @timezone_singapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore / SE Asia'**
  String get timezone_singapore;

  /// No description provided for @timezone_london.
  ///
  /// In en, this message translates to:
  /// **'London / Dublin (GMT)'**
  String get timezone_london;

  /// No description provided for @sectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'========== LANGUAGE SELECTOR =========='**
  String get sectionLanguage;

  /// No description provided for @language_title.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get language_title;

  /// No description provided for @sectionOnboarding.
  ///
  /// In en, this message translates to:
  /// **'========== ONBOARDING =========='**
  String get sectionOnboarding;

  /// No description provided for @onboarding_guide_step.
  ///
  /// In en, this message translates to:
  /// **'Guide {current}/{total}'**
  String onboarding_guide_step(int current, int total);

  /// No description provided for @onboarding_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboarding_next;

  /// No description provided for @onboarding_finish.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get onboarding_finish;

  /// No description provided for @onboarding_step1.
  ///
  /// In en, this message translates to:
  /// **'Write (optional) and TAP AN EMOJI to save your day.'**
  String get onboarding_step1;

  /// No description provided for @onboarding_step2.
  ///
  /// In en, this message translates to:
  /// **'Slide up the history and TAP ANY ENTRY to edit'**
  String get onboarding_step2;

  /// No description provided for @onboarding_step3.
  ///
  /// In en, this message translates to:
  /// **'TAP THE DATE at the top to change your Timezone.'**
  String get onboarding_step3;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
