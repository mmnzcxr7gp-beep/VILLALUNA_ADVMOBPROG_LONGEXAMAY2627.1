import 'package:flutter/material.dart';
import '../constants.dart';
import 'custom_font.dart';

class CustomInkwellButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget? child;
  final IconData? icon;
  final String? label;
  final Color? iconColor;
  final Color? textColor;
  final double iconSize;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final Color? splashColor;
  final Color? highlightColor;
  final Color? backgroundColor;

  const CustomInkwellButton({
    super.key,
    this.onTap,
    this.child,
    this.icon,
    this.label,
    this.iconColor,
    this.textColor,
    this.iconSize = 18,
    this.fontSize = 13,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.borderRadius,
    this.splashColor,
    this.highlightColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final rRadius = borderRadius ?? BorderRadius.circular(6);

    return Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: rRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: rRadius,
        splashColor: splashColor ?? (isDark ? Colors.white10 : AppColors.fbBlueLight),
        highlightColor: highlightColor ?? (isDark ? Colors.white12 : Colors.black12),
        child: Padding(
          padding: padding,
          child: child ??
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: iconSize,
                      color: iconColor ??
                          (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary),
                    ),
                    if (label != null) const SizedBox(width: 6),
                  ],
                  if (label != null)
                    CustomFont(
                      text: label!,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: textColor ??
                          (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary),
                    ),
                ],
              ),
        ),
      ),
    );
  }
}
