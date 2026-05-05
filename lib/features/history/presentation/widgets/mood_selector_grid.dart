import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';

class MoodSelectorGrid extends StatelessWidget {
  final List<MapEntry<String, String>> emojis;
  final Function(String) onEmojiSelected;

  const MoodSelectorGrid(
      {super.key, required this.emojis, required this.onEmojiSelected});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: emojis.length,
      itemBuilder: (context, index) {
        final emoji = emojis[index];
        return GestureDetector(
          onTap: () => onEmojiSelected(emoji.value),
          child: Padding(
            padding: EdgeInsets.all(width * 0.01),
            child: SvgPicture.asset(
              emoji.value,
              colorFilter: const ColorFilter.mode(
                  AppColors.textoOscuro, BlendMode.srcIn),
            ),
          ),
        );
      },
    );
  }
}
