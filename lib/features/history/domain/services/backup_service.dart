import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../entities/history_entry.dart';

class BackupService {
  static Future<void> exportBackup(List<HistoryEntry> history) async {
    try {
      // 1. Convertimos la lista a JSON
      final List<Map<String, dynamic>> jsonList =
          history.map((e) => e.toJson()).toList();
      final String jsonString = jsonEncode(jsonList);

      // 2. Creamos un archivo temporal
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/cozy_backup.json');

      await file.writeAsString(jsonString);

      // 3. Compartimos el archivo
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My Cozy Feels History Backup ✨',
      );
    } catch (e) {
      print("Error en el backup: $e");
    }
  }
}
