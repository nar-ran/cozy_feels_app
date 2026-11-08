import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cozy_feels_app/features/history/domain/entities/app_tag.dart';
import 'package:cozy_feels_app/features/history/domain/entities/history_entry.dart';
import 'package:cozy_feels_app/features/history/domain/services/backup_service.dart';
import 'package:cozy_feels_app/features/history/domain/services/mood_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HistoryEntry tags serialization', () {
    test('HistoryEntry defaults to empty tags when not specified', () {
      final entry = HistoryEntry(
        date: DateTime(2026, 11, 8),
        message: 'Día tranquilo',
        emojiPath: 'assets/icons/svg/feelings/sentiment_calm.svg',
      );

      expect(entry.tags, isEmpty);
      final json = entry.toJson();
      expect(json['tags'], isEmpty);
    });

    test('HistoryEntry handles legacy JSON without tags field (backwards compatibility)', () {
      final legacyJson = {
        'date': '2026-11-08T10:00:00.000',
        'message': 'Sin etiquetas previas',
        'emojiPath': 'assets/icons/svg/feelings/sentiment_content.svg',
      };

      final entry = HistoryEntry.fromJson(legacyJson);
      expect(entry.tags, isEmpty);
      expect(entry.message, 'Sin etiquetas previas');
    });

    test('HistoryEntry correctly saves and loads tags in JSON', () {
      final entry = HistoryEntry(
        date: DateTime(2026, 11, 8),
        message: 'Trabajo intenso pero feliz',
        emojiPath: 'assets/icons/svg/feelings/sentiment_very_satisfied.svg',
        tags: ['work', 'health', 'custom_gym'],
      );

      final json = entry.toJson();
      expect(json['tags'], ['work', 'health', 'custom_gym']);

      final decoded = HistoryEntry.fromJson(json);
      expect(decoded.tags, ['work', 'health', 'custom_gym']);
    });
  });

  group('AppTag entity and helpers', () {
    test('Contains 8 standard predefined cozy tags', () {
      expect(AppTag.predefinedTags.length, 8);
      final ids = AppTag.predefinedTags.map((t) => t.id).toList();
      expect(ids, containsAll(['work', 'relationship', 'family', 'sleep', 'study', 'health', 'leisure', 'social']));
    });

    test('getIconForTag returns correct icon for predefined and fallback for custom', () {
      expect(AppTag.getIconForTag('work'), Icons.work_outline_rounded);
      expect(AppTag.getIconForTag('relationship'), Icons.favorite_border_rounded);
      expect(AppTag.getIconForTag('custom_running'), Icons.label_outline_rounded);
    });

    test('isPredefined identifies standard vs custom tags', () {
      expect(AppTag.isPredefined('work'), isTrue);
      expect(AppTag.isPredefined('sleep'), isTrue);
      expect(AppTag.isPredefined('Mascotas'), isFalse);
    });
  });

  group('MoodStorageService user tags (ordering, deleting any tag, resetting)', () {
    test('Loads 8 default tags on fresh launch', () async {
      final storage = MoodStorageService();
      final tags = await storage.loadUserTags();
      expect(tags, MoodStorageService.defaultTagIds);
    });

    test('Allows deleting any tag, including predefined ones', () async {
      final storage = MoodStorageService();
      await storage.deleteUserTag('work');
      await storage.deleteUserTag('sleep');

      final tags = await storage.loadUserTags();
      expect(tags.contains('work'), isFalse);
      expect(tags.contains('sleep'), isFalse);
      expect(tags.contains('family'), isTrue);
    });

    test('Allows reordering tags and saves custom order', () async {
      final storage = MoodStorageService();
      await storage.reorderUserTags(7, 0);

      final tags = await storage.loadUserTags();
      expect(tags.first, 'social');
    });

    test('Allows adding custom tags and resetting to defaults', () async {
      final storage = MoodStorageService();
      await storage.addUserTag('Gym');
      var tags = await storage.loadUserTags();
      expect(tags.contains('Gym'), isTrue);

      await storage.resetDefaultTags();
      tags = await storage.loadUserTags();
      expect(tags, MoodStorageService.defaultTagIds);
    });
  });

  group('BackupService with tags', () {
    test('parseBackupJson preserves tags in modern v2 payload', () {
      const v2Json = '''
      {
        "app": "Cozy Feels",
        "version": "2.0.0",
        "exportedAt": "2026-11-08T09:00:00.000",
        "history": [
          {
            "date": "2026-11-08T08:00:00.000",
            "message": "Caminata matutina",
            "emojiPath": "assets/emojis/happy.png",
            "tags": ["health", "social"]
          }
        ]
      }
      ''';

      final entries = BackupService.parseBackupJson(v2Json);
      expect(entries, isNotNull);
      expect(entries!.first.tags, ['health', 'social']);
    });
  });
}
