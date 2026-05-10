// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get sectionCommon => '========== COMMON / SYSTEM ==========';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get common_accept => 'Accept';

  @override
  String get common_error => 'An error occurred';

  @override
  String get common_back => 'Back';

  @override
  String get common_import => 'Import';

  @override
  String get common_continue => 'Continue';

  @override
  String get common_delete => 'Delete';

  @override
  String get sectionHome => '========== HOME SCREEN ==========';

  @override
  String get home_title => 'How do you feel today?';

  @override
  String get home_hint_text => 'Let it all out...';

  @override
  String get home_no_words_question => 'You prefer no words?';

  @override
  String get home_already_recorded => 'You\'ve already recorded your mood for today!';

  @override
  String get sectionEditor => '========== MOOD EDITOR ==========';

  @override
  String get editor_title => 'Edit Mood';

  @override
  String get editor_save_button => 'Save Changes';

  @override
  String get editor_hint_empty => 'Write something about your day...';

  @override
  String get sectionHistory => '========== HISTORY SECTION ==========';

  @override
  String get history_title => 'History';

  @override
  String get history_empty_state => 'No entries yet...';

  @override
  String get history_no_words => 'No words today...';

  @override
  String get history_delete_confirm => 'Delete this memory?';

  @override
  String get sectionSettings => '========== SETTINGS & BACKUP ==========';

  @override
  String get settings_export_title => 'Export Backup';

  @override
  String get settings_export_subtitle => 'Save your history to a file';

  @override
  String get settings_import_title => 'Import Backup';

  @override
  String get settings_import_subtitle => 'Restore your feelings from a file';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_current_language_label => 'English';

  @override
  String get settings_import_success => 'Memories imported successfully!';

  @override
  String get sectionPreview => '========== IMPORT PREVIEW ==========';

  @override
  String get import_preview_title => 'Import Preview';

  @override
  String get import_preview_at_date => 'Everything is up to date!';

  @override
  String import_preview_found(int count) {
    return 'Found $count new entries:';
  }

  @override
  String get import_preview_empty => 'No words...';

  @override
  String import_preview_duplicate(int count) {
    return '$count days already exist in your history and will be skipped.';
  }

  @override
  String get sectionTimezone => '========== TIMEZONE SELECTOR ==========';

  @override
  String get timezone_title => 'Select Zone';

  @override
  String get timezone_ny => 'Eastern Time (US/Canada)';

  @override
  String get timezone_madrid => 'Central Europe (Madrid/Paris)';

  @override
  String get timezone_ba => 'Argentina / Brazil (South)';

  @override
  String get timezone_singapore => 'Singapore / SE Asia';

  @override
  String get timezone_london => 'London / Dublin (GMT)';

  @override
  String get sectionLanguage => '========== LANGUAGE SELECTOR ==========';

  @override
  String get language_title => 'Select Language';

  @override
  String get sectionOnboarding => '========== ONBOARDING ==========';

  @override
  String onboarding_guide_step(int current, int total) {
    return 'Guide $current/$total';
  }

  @override
  String get onboarding_next => 'Next';

  @override
  String get onboarding_finish => 'Got it!';

  @override
  String get onboarding_step1 => 'Write (optional) and TAP AN EMOJI to save your day.';

  @override
  String get onboarding_step2 => 'Slide up the history and TAP ANY ENTRY to edit';

  @override
  String get onboarding_step3 => 'TAP THE DATE at the top to change your Timezone.';
}
