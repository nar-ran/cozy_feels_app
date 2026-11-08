import 'package:flutter_test/flutter_test.dart';
import 'package:cozy_feels_app/features/history/domain/services/google_drive_service.dart';
import 'package:cozy_feels_app/features/history/domain/services/mood_storage_service.dart';
import 'package:cozy_feels_app/features/history/domain/services/backup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('GoogleDriveService singleton instance exists and is unique', () {
    final s1 = GoogleDriveService.instance;
    final s2 = GoogleDriveService.instance;
    expect(s1, equals(s2));
    expect(s1.isSignedIn, isFalse);
  });

  test('CloudBackupInfo holds correct metadata', () {
    final now = DateTime.now();
    final info = CloudBackupInfo(
      fileId: 'test_file_123',
      modifiedTime: now,
      sizeBytes: 2048,
    );

    expect(info.fileId, 'test_file_123');
    expect(info.modifiedTime, now);
    expect(info.sizeBytes, 2048);
  });

  test('MoodStorageService persists auto cloud backup preference', () async {
    final storage = MoodStorageService();
    expect(await storage.isAutoCloudBackupEnabled(), isFalse);

    await storage.setAutoCloudBackupEnabled(true);
    expect(await storage.isAutoCloudBackupEnabled(), isTrue);

    await storage.setAutoCloudBackupEnabled(false);
    expect(await storage.isAutoCloudBackupEnabled(), isFalse);
  });

  test('MoodStorageService persists last cloud backup time', () async {
    final storage = MoodStorageService();
    expect(await storage.getLastCloudBackupTime(), isNull);

    final timestamp = DateTime(2026, 11, 7, 13, 30);
    await storage.setLastCloudBackupTime(timestamp);

    final loaded = await storage.getLastCloudBackupTime();
    expect(loaded, isNotNull);
    expect(loaded!.year, 2026);
    expect(loaded.month, 11);
    expect(loaded.day, 7);
    expect(loaded.hour, 13);
    expect(loaded.minute, 30);
  });

  test('BackupService.parseBackupJson parses legacy v1 List format correctly', () {
    const legacyJson = '''
    [
      {"date": "2026-11-01T10:00:00.000", "message": "Día tranquilo", "emojiPath": "assets/emojis/calm.png"}
    ]
    ''';
    final entries = BackupService.parseBackupJson(legacyJson);
    expect(entries, isNotNull);
    expect(entries!.length, 1);
    expect(entries.first.message, 'Día tranquilo');
    expect(entries.first.emojiPath, 'assets/emojis/calm.png');
  });

  test('BackupService.parseBackupJson parses v2 format with metadata and exportedAt', () {
    const v2Json = '''
    {
      "app": "Cozy Feels",
      "version": "2.0.0",
      "exportedAt": "2026-11-07T14:00:00.000",
      "history": [
        {"date": "2026-11-07T12:00:00.000", "message": "Muy feliz", "emojiPath": "assets/emojis/happy.png"}
      ]
    }
    ''';
    final entries = BackupService.parseBackupJson(v2Json);
    expect(entries, isNotNull);
    expect(entries!.length, 1);
    expect(entries.first.message, 'Muy feliz');
    expect(entries.first.emojiPath, 'assets/emojis/happy.png');
  });

  test('BackupService.parseBackupJson returns null on malformed json', () {
    expect(BackupService.parseBackupJson('not a json'), isNull);
    expect(BackupService.parseBackupJson('{"unknownKey": 123}'), isNotNull);
  });
}
