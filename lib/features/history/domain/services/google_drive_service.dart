import 'dart:async';
import 'dart:convert';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import '../entities/history_entry.dart';
import 'backup_service.dart';

class CloudBackupInfo {
  final String fileId;
  final DateTime? modifiedTime;
  final int sizeBytes;

  const CloudBackupInfo({
    required this.fileId,
    this.modifiedTime,
    required this.sizeBytes,
  });
}

class GoogleDriveService {
  static final GoogleDriveService instance = GoogleDriveService._internal();
  GoogleDriveService._internal();

  static const String _backupFileName = 'cozy_feels_backup.json';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveAppdataScope,
    ],
  );

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
  bool get isSignedIn => _googleSignIn.currentUser != null;

  Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _googleSignIn.onCurrentUserChanged;

  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (_) {
      return null;
    }
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<drive.DriveApi?> _getDriveApi() async {
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) return null;
    return drive.DriveApi(client);
  }

  // Sube o actualiza el archivo de respaldo en appDataFolder
  Future<DateTime> uploadBackup(List<HistoryEntry> history) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) {
      throw Exception('Not authenticated with Google');
    }

    final Map<String, dynamic> backupPayload = {
      'app': 'Cozy Feels',
      'version': '2.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'history': history.map((e) => e.toJson()).toList(),
    };
    final jsonString = jsonEncode(backupPayload);
    final bytes = utf8.encode(jsonString);

    // Buscar si ya existe el archivo en la carpeta oculta de la app
    final fileList = await driveApi.files.list(
      spaces: 'appDataFolder',
      q: "name = '$_backupFileName' and trashed = false",
      $fields: 'files(id, name, modifiedTime)',
    );

    final media = drive.Media(
      Stream.value(bytes),
      bytes.length,
      contentType: 'application/json',
    );

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      final existingFileId = fileList.files!.first.id!;
      final updated = await driveApi.files.update(
        drive.File(),
        existingFileId,
        uploadMedia: media,
      );
      return updated.modifiedTime ?? DateTime.now();
    } else {
      final newFile = drive.File()
        ..name = _backupFileName
        ..parents = ['appDataFolder'];
      final created = await driveApi.files.create(
        newFile,
        uploadMedia: media,
      );
      return created.modifiedTime ?? DateTime.now();
    }
  }

  /// Descarga el respaldo desde appDataFolder
  Future<List<HistoryEntry>?> downloadBackup() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) {
      throw Exception('Not authenticated with Google');
    }

    final fileList = await driveApi.files.list(
      spaces: 'appDataFolder',
      q: "name = '$_backupFileName' and trashed = false",
      $fields: 'files(id, name, modifiedTime)',
    );

    if (fileList.files == null || fileList.files!.isEmpty) {
      return null;
    }

    final fileId = fileList.files!.first.id!;
    final drive.Media media = await driveApi.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final List<int> bytes = [];
    await for (final chunk in media.stream) {
      bytes.addAll(chunk);
    }

    final jsonString = utf8.decode(bytes);
    return BackupService.parseBackupJson(jsonString);
  }

  /// Obtiene metadatos de la copia existente en Google Drive
  Future<CloudBackupInfo?> getCloudBackupInfo() async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return null;

      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = '$_backupFileName' and trashed = false",
        $fields: 'files(id, name, modifiedTime, size)',
      );

      if (fileList.files == null || fileList.files!.isEmpty) {
        return null;
      }

      final file = fileList.files!.first;
      return CloudBackupInfo(
        fileId: file.id ?? '',
        modifiedTime: file.modifiedTime,
        sizeBytes: int.tryParse(file.size ?? '0') ?? 0,
      );
    } catch (_) {
      return null;
    }
  }
}
