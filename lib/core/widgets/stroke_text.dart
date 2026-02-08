import 'package:flutter/material.dart';

class StrokeText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final Color strokeColor;

  const StrokeText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.color,
    required this.strokeColor
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5
              ..color = strokeColor,
          ),
        ),
        Text(
          text,
          style: TextStyle(fontSize: fontSize, color: color),
        ),
      ],
    );
  }
}