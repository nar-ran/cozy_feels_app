import 'package:flutter/material.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:cozy_feels_app/features/history/domain/entities/app_tag.dart';
import 'package:cozy_feels_app/features/history/domain/services/mood_storage_service.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';
import 'new_tag_dialog.dart';

class ManageTagsDialog extends StatefulWidget {
  final VoidCallback? onTagsChanged;

  const ManageTagsDialog({
    super.key,
    this.onTagsChanged,
  });

  @override
  State<ManageTagsDialog> createState() => _ManageTagsDialogState();
}

class _ManageTagsDialogState extends State<ManageTagsDialog> {
  final MoodStorageService _storage = MoodStorageService();
  List<String> _tags = [];
  bool _isLoading = true;
  bool _didChange = false;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    final tags = await _storage.loadUserTags();
    if (mounted) {
      setState(() {
        _tags = tags;
        _isLoading = false;
      });
    }
  }

  void _onReorderItem(int oldIndex, int newIndex) async {
    setState(() {
      final item = _tags.removeAt(oldIndex);
      _tags.insert(newIndex, item);
      _didChange = true;
    });
    await _storage.saveUserTags(_tags);
    widget.onTagsChanged?.call();
  }

  Future<void> _addNewTag() async {
    final newTag = await showDialog<String>(
      context: context,
      builder: (context) => NewTagDialog(existingTags: _tags),
    );

    if (newTag != null && newTag.isNotEmpty) {
      await _storage.addUserTag(newTag);
      _didChange = true;
      await _loadTags();
      widget.onTagsChanged?.call();
    }
  }

  Future<void> _confirmDelete(String tagId) async {
    final l10n = AppLocalizations.of(context)!;
    final tagName = AppTag.getLabelForTag(tagId, l10n);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.fondoSoft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: AppColors.rosaFuerte.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        title: Text(
          l10n.tag_delete_confirm_title,
          style: TextStyle(
            color: AppColors.textoOscuro,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          l10n.tag_delete_confirm_message(tagName),
          style: TextStyle(
            color: AppColors.textoOscuro,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(
              l10n.common_cancel,
              style: TextStyle(
                color: AppColors.textoOscuro.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rosaFuerte,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(
              l10n.tag_delete_btn,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storage.deleteUserTag(tagId);
      _didChange = true;
      await _loadTags();
      widget.onTagsChanged?.call();
    }
  }

  Future<void> _confirmResetDefaults() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.fondoSoft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: AppColors.rosaFuerte.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        title: Text(
          l10n.tag_reset_confirm_title,
          style: TextStyle(
            color: AppColors.textoOscuro,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          l10n.tag_reset_confirm_message,
          style: TextStyle(
            color: AppColors.textoOscuro,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(
              l10n.common_cancel,
              style: TextStyle(
                color: AppColors.textoOscuro.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rosaFuerte,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(
              l10n.tag_reset_defaults,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storage.resetDefaultTags();
      _didChange = true;
      await _loadTags();
      widget.onTagsChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Etiquetas predeterminadas faltantes en la lista activa
    final missingPredefined =
        AppTag.predefinedTags.where((p) => !_tags.contains(p.id)).toList();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {},
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: height * 0.82,
            maxWidth: 440,
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: BoxDecoration(
            color: AppColors.fondoSoft,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppColors.rosaFuerte.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: AppColors.rosaFuerte,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StrokeText(
                      text: l10n.tag_manage_title,
                      fontSize: width * 0.07,
                      color: AppColors.rosaFuerte,
                      strokeColor: AppColors.strokeColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.textoOscuro.withValues(alpha: 0.7),
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(_didChange),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.tag_manage_subtitle,
                style: TextStyle(
                  color: AppColors.textoOscuro.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),

              // Lista Reordenable de Etiquetas
              Flexible(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.rosaFuerte,
                        ),
                      )
                    : _tags.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.label_off_outlined,
                                  size: 46,
                                  color: AppColors.rosaFuerte
                                      .withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.tag_manage_empty,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textoOscuro
                                        .withValues(alpha: 0.6),
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: ReorderableListView.builder(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              buildDefaultDragHandles: false,
                              itemCount: _tags.length,
                              onReorderItem: _onReorderItem,
                              proxyDecorator: (child, index, animation) {
                                return Material(
                                  color: Colors.transparent,
                                  elevation: 6,
                                  shadowColor: AppColors.rosaFuerte
                                      .withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(16),
                                  child: child,
                                );
                              },
                              itemBuilder: (context, index) {
                                final tagId = _tags[index];
                                final label =
                                    AppTag.getLabelForTag(tagId, l10n);
                                final icon = AppTag.getIconForTag(tagId);

                                return Container(
                                  key: ValueKey(tagId),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.naranjaPiel
                                        .withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.rosaFuerte
                                          .withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Drag Handle
                                      ReorderableDragStartListener(
                                        index: index,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8),
                                          child: Icon(
                                            Icons.drag_indicator_rounded,
                                            color: AppColors.rosaFuerte
                                                .withValues(alpha: 0.6),
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                      // Icono de la etiqueta
                                      Icon(
                                        icon,
                                        color: AppColors.rosaFuerte,
                                        size: 19,
                                      ),
                                      const SizedBox(width: 8),
                                      // Nombre
                                      Expanded(
                                        child: Text(
                                          label,
                                          style: TextStyle(
                                            fontFamily: 'Dongle',
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textoOscuro,
                                            height: 1.0,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Botón de eliminar
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline_rounded,
                                          color: AppColors.rosaFuerte,
                                          size: 20,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        tooltip: l10n.tag_delete_btn,
                                        onPressed: () => _confirmDelete(tagId),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
              ),

              // Sección para restaurar etiquetas predeterminadas eliminadas
              if (missingPredefined.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  l10n.tag_restore_available,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoOscuro.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: missingPredefined.map((tag) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          avatar: Icon(
                            tag.icon,
                            size: 14,
                            color: AppColors.rosaFuerte,
                          ),
                          label: Text(
                            AppTag.getLabelForTag(tag.id, l10n),
                            style: TextStyle(
                              fontFamily: 'Dongle',
                              fontSize: 19,
                              height: 1.0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textoOscuro,
                            ),
                          ),
                          backgroundColor:
                              AppColors.naranjaPiel.withValues(alpha: 0.5),
                          side: BorderSide(
                            color: AppColors.rosaFuerte.withValues(alpha: 0.35),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          onPressed: () async {
                            await _storage.addUserTag(tag.id);
                            _didChange = true;
                            await _loadTags();
                            widget.onTagsChanged?.call();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Botones de acción inferiores
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _addNewTag,
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: Text(
                        l10n.tag_add_new,
                        style: const TextStyle(
                          fontFamily: 'Dongle',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rosaFuerte,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: l10n.tag_reset_defaults,
                    child: OutlinedButton(
                      onPressed: _confirmResetDefaults,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.rosaFuerte,
                        side: BorderSide(
                          color: AppColors.rosaFuerte.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Icon(Icons.refresh_rounded, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
