import 'package:flutter/material.dart';

class StrokeText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final Color strokeColor;
  final TextAlign textAlign;

  const StrokeText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.color,
    required this.strokeColor,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          textAlign: textAlign,
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
          textAlign: textAlign,
          style: TextStyle(fontSize: fontSize, color: color),
        ),
      ],
    );
  }
}