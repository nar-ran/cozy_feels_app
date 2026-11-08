import 'package:flutter/material.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/features/history/domain/entities/app_tag.dart';
import 'package:cozy_feels_app/features/history/domain/services/mood_storage_service.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';
import 'manage_tags_dialog.dart';
import 'new_tag_dialog.dart';
import 'tag_chip.dart';

class TagSelectorRow extends StatefulWidget {
  final List<String> selectedTags;
  final ValueChanged<List<String>> onTagsChanged;

  const TagSelectorRow({
    super.key,
    required this.selectedTags,
    required this.onTagsChanged,
  });

  @override
  State<TagSelectorRow> createState() => _TagSelectorRowState();
}

class _TagSelectorRowState extends State<TagSelectorRow> {
  final MoodStorageService _storage = MoodStorageService();
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _loadUserTags();
  }

  Future<void> _loadUserTags() async {
    final tags = await _storage.loadUserTags();
    if (mounted) {
      setState(() => _tags = tags);

      // Si alguna etiqueta seleccionada fue eliminada, actualizar la lista
      final validSelected =
          widget.selectedTags.where((t) => tags.contains(t)).toList();
      if (validSelected.length != widget.selectedTags.length) {
        widget.onTagsChanged(validSelected);
      }
    }
  }

  void _toggleTag(String tagId) {
    final updated = List<String>.from(widget.selectedTags);
    if (updated.contains(tagId)) {
      updated.remove(tagId);
    } else {
      updated.add(tagId);
    }
    widget.onTagsChanged(updated);
  }

  Future<void> _showNewTagDialog() async {
    final newTag = await showDialog<String>(
      context: context,
      builder: (context) => NewTagDialog(existingTags: _tags),
    );

    if (newTag != null && newTag.isNotEmpty) {
      await _storage.addUserTag(newTag);
      await _loadUserTags();
      _toggleTag(newTag);
    }
  }

  Future<void> _openManageTags() async {
    await showDialog<bool>(
      context: context,
      builder: (context) => ManageTagsDialog(
        onTagsChanged: () async {
          await _loadUserTags();
        },
      ),
    );
    await _loadUserTags();
  }

  Future<void> _confirmDeleteSingleTag(String tagId) async {
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
      await _loadUserTags();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final itemCount = _tags.length + 2;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == _tags.length) {
            // Botón de + Añadir etiqueta
            return GestureDetector(
              onTap: _showNewTagDialog,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.naranjaPiel.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.rosaFuerte.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 18,
                      color: AppColors.rosaFuerte,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.tag_add_new,
                      style: TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 22,
                        height: 1.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.rosaFuerte,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (index == _tags.length + 1) {
            // Botón para Gestionar y Reordenar etiquetas
            return Tooltip(
              message: l10n.tag_manage_tooltip,
              child: GestureDetector(
                onTap: _openManageTags,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.naranjaPiel.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.rosaFuerte.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: AppColors.rosaFuerte,
                  ),
                ),
              ),
            );
          }

          final tagId = _tags[index];
          final isSelected = widget.selectedTags.contains(tagId);

          return TagChip(
            tagId: tagId,
            isSelected: isSelected,
            onTap: () => _toggleTag(tagId),
            onLongPress: () => _confirmDeleteSingleTag(tagId),
          );
        },
      ),
    );
  }
}
