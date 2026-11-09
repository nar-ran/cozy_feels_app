import 'package:flutter/material.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class NewTagDialog extends StatefulWidget {
  final List<String> existingTags;

  const NewTagDialog({
    super.key,
    required this.existingTags,
  });

  @override
  State<NewTagDialog> createState() => _NewTagDialogState();
}

class _NewTagDialogState extends State<NewTagDialog> {
  late final TextEditingController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final l10n = AppLocalizations.of(context)!;
    final text = _controller.text.trim();

    if (text.isEmpty) {
      return;
    }

    final lower = text.toLowerCase();
    final alreadyExists = widget.existingTags
        .any((t) => t.toLowerCase() == lower);

    if (alreadyExists) {
      setState(() {
        _errorMessage = l10n.tag_dialog_already_exists;
      });
      return;
    }

    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
          children: [
            StrokeText(
              text: l10n.tag_dialog_title,
              fontSize: width * 0.08,
              color: AppColors.rosaFuerte,
              strokeColor: AppColors.strokeColor,
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 20,
              style: TextStyle(
                color: AppColors.textoOscuro,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: l10n.tag_dialog_hint,
                hintStyle: TextStyle(
                  color: AppColors.textoOscuro.withValues(alpha: 0.5),
                ),
                errorText: _errorMessage,
                counterText: '',
                filled: true,
                fillColor: AppColors.naranjaPiel,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppColors.rosaFuerte.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppColors.rosaFuerte.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppColors.rosaFuerte,
                    width: 2,
                  ),
                ),
              ),
              onSubmitted: (_) => _handleSubmit(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.common_cancel,
                    style: TextStyle(
                      fontFamily: 'Dongle',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textoOscuro.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rosaFuerte,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 6),
                  ),
                  child: Text(
                    l10n.tag_dialog_add,
                    style: const TextStyle(
                      fontFamily: 'Dongle',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
