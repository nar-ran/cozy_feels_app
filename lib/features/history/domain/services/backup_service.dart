import 'dart:convert';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../entities/history_entry.dart';

class BackupService {
  // --- EXPORTAR ---
  static Future<void> exportBackup(List<HistoryEntry> history) async {
    try {
      final now = DateTime.now();
      // Formato para el nombre del archivo: cozy_backup_YYYY-MM-DD_HHmm.json
      final dateSlug = DateFormat('yyyy-MM-dd_HHmm').format(now);
      final formattedDisplayDate =
          DateFormat('d MMM yyyy, h:mm a').format(now);

      final Map<String, dynamic> backupPayload = {
        'app': 'Cozy Feels',
        'version': '2.0.0',
        'exportedAt': now.toIso8601String(),
        'history': history.map((e) => e.toJson()).toList(),
      };
      final String jsonString = jsonEncode(backupPayload);

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/cozy_backup_$dateSlug.json');
      await file.writeAsString(jsonString);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Cozy Feels Backup ($formattedDisplayDate)',
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  // --- IMPORTAR ---
  static Future<List<HistoryEntry>?> importBackup() async {
    try {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'JSON',
        extensions: <String>['json'],
        mimeTypes: <String>['application/json', 'text/plain'],
      );

      final XFile? file =
          await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);

      if (file != null) {
        final String content = await file.readAsString();
        return parseBackupJson(content);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  static List<HistoryEntry>? parseBackupJson(String content) {
    try {
      final dynamic decoded = jsonDecode(content);

      List<dynamic> jsonList;
      if (decoded is List) {
        // Formato v1 heredado
        jsonList = decoded;
      } else if (decoded is Map<String, dynamic>) {
        // Formato v2 con metadatos y fecha de exportación
        jsonList = (decoded['history'] ?? decoded['entries'] ?? []) as List<dynamic>;
      } else {
        return null;
      }

      return jsonList.map((e) => HistoryEntry.fromJson(e)).toList();
    } catch (_) {
      return null;
    }
  }
}
