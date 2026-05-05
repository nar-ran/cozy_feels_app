import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:intl/intl.dart';

class MoodEditorDialog extends StatefulWidget {
  final DateTime date;
  final String initialMessage;
  final String initialEmoji;
  final List<MapEntry<String, String>> emojis;
  final Function(String message, String emoji) onSave;

  const MoodEditorDialog({
    super.key,
    required this.date,
    required this.initialMessage,
    required this.initialEmoji,
    required this.emojis,
    required this.onSave,
  });

  @override
  State<MoodEditorDialog> createState() => _MoodEditorDialogState();
}

class _MoodEditorDialogState extends State<MoodEditorDialog> {
  late TextEditingController _controller;
  late String _selectedEmoji;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialMessage);
    _selectedEmoji = _findMatchingEmoji(widget.initialEmoji);
  }

  String _findMatchingEmoji(String path) {
    if (widget.emojis.any((e) => e.value == path)) {
      return path;
    }
    final fileName = path.split('/').last;
    try {
      return widget.emojis.firstWhere((e) => e.value.endsWith(fileName)).value;
    } catch (e) {
      return path;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final formattedDate = DateFormat('MMMM dd, yyyy').format(widget.date);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: AppColors.fondoSoft,
          borderRadius: BorderRadius.circular(25),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Fecha
              StrokeText(
                text: formattedDate,
                fontSize: width * 0.08,
                color: AppColors.rosaFuerte,
                strokeColor: AppColors.textoOscuro,
              ),
              const SizedBox(height: 25),

              // 2. Grid de Emojis
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  physics: const NeverScrollableScrollPhysics(),
                  children: widget.emojis.map((e) {
                    final isSelected = _selectedEmoji == e.value;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedEmoji = e.value),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.naranjaPiel
                              : Colors.transparent,
                        ),
                        padding: EdgeInsets.all(width * 0.01),
                        child: SvgPicture.asset(
                          e.value,
                          colorFilter: const ColorFilter.mode(
                            AppColors.textoOscuro,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 30),

              // 3. Cuadro de texto
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.naranjaPiel,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.rosaFuerte, width: 1.5),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: TextField(
                    controller: _controller,
                    maxLines: 4,
                    style: TextStyle(
                      color: AppColors.textoOscuro,
                      fontSize: width * 0.06,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // 4. Botón Guardar
              GestureDetector(
                onTap: () => widget.onSave(_controller.text, _selectedEmoji),
                child: Text(
                  "Save Changes",
                  style: TextStyle(
                    fontSize: width * 0.07,
                    color: AppColors.rosaFuerte,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
