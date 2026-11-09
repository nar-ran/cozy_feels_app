import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:cozy_feels_app/core/constants/app_assets.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/services/google_drive_service.dart';
import '../../domain/services/mood_storage_service.dart';

class BackupCenterDialog extends StatefulWidget {
  final List<HistoryEntry> currentHistory;
  final VoidCallback onExport;
  final VoidCallback onImport;
  final Future<void> Function(List<HistoryEntry> entries) onRestoreFromCloud;

  const BackupCenterDialog({
    super.key,
    required this.currentHistory,
    required this.onExport,
    required this.onImport,
    required this.onRestoreFromCloud,
  });

  @override
  State<BackupCenterDialog> createState() => _BackupCenterDialogState();
}

class _BackupCenterDialogState extends State<BackupCenterDialog> {
  final GoogleDriveService _driveService = GoogleDriveService.instance;
  final MoodStorageService _storage = MoodStorageService();

  bool _isLoading = false;
  bool _isSyncing = false;
  bool _isRestoring = false;
  bool _autoSync = false;
  DateTime? _lastBackupTime;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final autoSync = await _storage.isAutoCloudBackupEnabled();
    final lastTime = await _storage.getLastCloudBackupTime();

    if (mounted) {
      setState(() {
        _autoSync = autoSync;
        _lastBackupTime = lastTime;
      });
    }

    // Intentar inicio de sesión silencioso si estaba previamente conectado
    if (!_driveService.isSignedIn) {
      final account = await _driveService.signInSilently();
      if (account != null && mounted) {
        setState(() {});
        _checkRemoteBackupInfo();
      }
    } else {
      _checkRemoteBackupInfo();
    }
  }

  Future<void> _checkRemoteBackupInfo() async {
    final info = await _driveService.getCloudBackupInfo();
    if (info != null && info.modifiedTime != null && mounted) {
      setState(() {
        _lastBackupTime = info.modifiedTime;
      });
      await _storage.setLastCloudBackupTime(info.modifiedTime!);
    }
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final account = await _driveService.signIn();
      if (account != null && mounted) {
        await _checkRemoteBackupInfo();
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignOut() async {
    setState(() => _isLoading = true);
    try {
      await _driveService.signOut();
    } catch (e) {
      if (mounted) {
        _showSnack('Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSyncNow() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSyncing = true);
    try {
      final time = await _driveService.uploadBackup(widget.currentHistory);
      await _storage.setLastCloudBackupTime(time);
      if (mounted) {
        setState(() => _lastBackupTime = time);
        _showSnack(l10n.backup_cloud_sync_success);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _handleRestoreFromCloud() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isRestoring = true);
    try {
      final downloadedEntries = await _driveService.downloadBackup();
      if (downloadedEntries == null || downloadedEntries.isEmpty) {
        if (mounted) {
          _showSnack(l10n.backup_cloud_no_remote_file);
        }
        return;
      }

      if (mounted) {
        Navigator.pop(context);
        await widget.onRestoreFromCloud(downloadedEntries);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.rosaFuerte,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final user = _driveService.currentUser;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: AppColors.fondoSoft,
          borderRadius: BorderRadius.circular(35),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título del centro de respaldos
            StrokeText(
              text: l10n.backup_center_dialog_title,
              fontSize: width * 0.08,
              color: AppColors.rosaFuerte,
              strokeColor: AppColors.strokeColor,
            ),
            const SizedBox(height: 16),

            // Contenido con scroll seguro
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ============================================
                    // 1. BLOQUE: GOOGLE DRIVE (NUBE)
                    // ============================================
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.naranjaPiel,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppAssets.featureIcons['Upload']!,
                                width: 24,
                                height: 24,
                                colorFilter: ColorFilter.mode(
                                    AppColors.rosaFuerte, BlendMode.srcIn),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.backup_cloud_title,
                                style: TextStyle(
                                  fontFamily: 'Dongle',
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textoOscuro,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          if (user == null) ...[
                            // Estado No Conectado
                            Text(
                              l10n.backup_cloud_desc,
                              style: TextStyle(
                                fontFamily: 'Dongle',
                                fontSize: 20,
                                color: AppColors.textoOscuro.withValues(alpha: 0.8),
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Center(
                              child: _isLoading
                                  ? const CircularProgressIndicator()
                                  : ElevatedButton.icon(
                                      onPressed: _handleSignIn,
                                      icon: const Icon(Icons.cloud_upload_outlined),
                                      label: Text(
                                        l10n.backup_cloud_connect,
                                        style: const TextStyle(
                                          fontFamily: 'Dongle',
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.rosaFuerte,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                            ),
                          ] else ...[
                            // Estado Conectado: Cuenta del usuario
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.rosaFuerte
                                      .withValues(alpha: 0.3),
                                  backgroundImage: user.photoUrl != null
                                      ? NetworkImage(user.photoUrl!)
                                      : null,
                                  child: user.photoUrl == null
                                      ? Text(
                                          (user.displayName ?? user.email)
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textoOscuro,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (user.displayName != null &&
                                          user.displayName!.isNotEmpty)
                                        Text(
                                          user.displayName!,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: AppColors.textoOscuro,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      Text(
                                        user.email,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textoOscuro
                                              .withValues(alpha: 0.7),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: _isLoading ? null : _handleSignOut,
                                  child: Text(
                                    l10n.backup_cloud_disconnect,
                                    style: TextStyle(
                                      fontFamily: 'Dongle',
                                      fontSize: 18,
                                      color: AppColors.rosaFuerte,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),
                            Divider(
                              color: AppColors.textoOscuro.withValues(alpha: 0.2),
                              height: 1,
                            ),
                            const SizedBox(height: 10),

                            // Última copia
                            Text(
                              _lastBackupTime != null
                                  ? l10n.backup_cloud_last_backup(
                                      DateFormat('d MMM, h:mm a',
                                              Localizations.localeOf(context)
                                                  .languageCode)
                                          .format(_lastBackupTime!))
                                  : l10n.backup_cloud_no_backup,
                              style: TextStyle(
                                fontFamily: 'Dongle',
                                fontSize: 20,
                                color: AppColors.textoOscuro.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Botones de acción: Sincronizar y Restaurar
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: (_isSyncing || _isRestoring)
                                        ? null
                                        : _handleSyncNow,
                                    icon: _isSyncing
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white),
                                          )
                                        : const Icon(Icons.sync, size: 18),
                                    label: Text(
                                      l10n.backup_cloud_sync_now,
                                      style: const TextStyle(
                                        fontFamily: 'Dongle',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.rosaFuerte,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: (_isSyncing || _isRestoring)
                                        ? null
                                        : _handleRestoreFromCloud,
                                    icon: _isRestoring
                                        ? SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.rosaFuerte),
                                          )
                                        : const Icon(Icons.download, size: 18),
                                    label: Text(
                                      l10n.backup_cloud_restore,
                                      style: const TextStyle(
                                        fontFamily: 'Dongle',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.rosaFuerte,
                                      side: BorderSide(
                                          color: AppColors.rosaFuerte, width: 1.5),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Switch de sincronización automática al abrir la app
                            SwitchListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              activeThumbColor: AppColors.rosaFuerte,
                              activeTrackColor:
                                  AppColors.rosaFuerte.withValues(alpha: 0.4),
                              title: Text(
                                l10n.backup_cloud_auto_sync,
                                style: TextStyle(
                                  fontFamily: 'Dongle',
                                  fontSize: 20,
                                  color: AppColors.textoOscuro,
                                ),
                              ),
                              value: _autoSync,
                              onChanged: (val) async {
                                setState(() => _autoSync = val);
                                await _storage.setAutoCloudBackupEnabled(val);
                              },
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ============================================
                    // 2. BLOQUE: RESPALDOS LOCALES (ARCHIVOS)
                    // ============================================
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.naranjaPiel,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.backup_local_title,
                            style: TextStyle(
                              fontFamily: 'Dongle',
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textoOscuro,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: SvgPicture.asset(
                              AppAssets.featureIcons['Upload']!,
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                  AppColors.rosaFuerte, BlendMode.srcIn),
                            ),
                            title: Text(
                              l10n.backup_local_export,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textoOscuro,
                              ),
                            ),
                            subtitle: Text(
                              l10n.backup_local_export_subtitle,
                              style: TextStyle(
                                  color: AppColors.textoOscuro
                                      .withValues(alpha: 0.6)),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              widget.onExport();
                            },
                          ),
                          Divider(
                            color: AppColors.textoOscuro.withValues(alpha: 0.15),
                            height: 1,
                          ),
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: SvgPicture.asset(
                              AppAssets.featureIcons['Restore']!,
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                  AppColors.rosaFuerte, BlendMode.srcIn),
                            ),
                            title: Text(
                              l10n.backup_local_import,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textoOscuro,
                              ),
                            ),
                            subtitle: Text(
                              l10n.backup_local_import_subtitle,
                              style: TextStyle(
                                  color: AppColors.textoOscuro
                                      .withValues(alpha: 0.6)),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              widget.onImport();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Botón de Cerrar / Aceptar
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.common_accept,
                style: TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoOscuro,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
