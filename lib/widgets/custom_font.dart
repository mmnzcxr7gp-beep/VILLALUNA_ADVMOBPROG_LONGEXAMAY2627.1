import 'package:flutter/material.dart';
import '../constants.dart';

class CustomFont extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final String? fontFamily;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? height;
  final double? letterSpacing;
  final TextDecoration? decoration;

  const CustomFont({
    super.key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.fontFamily = AppFonts.frutiger,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.height,
    this.letterSpacing,
    this.decoration,
  });

  const CustomFont.klavika({
    super.key,
    required this.text,
    this.fontSize = 20,
    this.fontWeight = FontWeight.bold,
    this.color,
    this.fontFamily = AppFonts.klavika,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.height,
    this.letterSpacing = 0.5,
    this.decoration,
  });

  const CustomFont.frutiger({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.color,
    this.fontFamily = AppFonts.frutiger,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.height,
    this.letterSpacing,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.textTheme.bodyMedium?.color;

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: effectiveColor,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
      ),
    );
  }
}
