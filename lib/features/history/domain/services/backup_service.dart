import 'dart:convert';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../entities/history_entry.dart';

class BackupService {
  // --- EXPORTAR ---
  static Future<void> exportBackup(List<HistoryEntry> history) async {
    try {
      final List<Map<String, dynamic>> jsonList =
          history.map((e) => e.toJson()).toList();
      final String jsonString = jsonEncode(jsonList);

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/cozy_backup.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My Cozy Feels History Backup',
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
        final List<dynamic> jsonList = jsonDecode(content);

        return jsonList.map((e) => HistoryEntry.fromJson(e)).toList();
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
