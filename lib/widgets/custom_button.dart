import 'package:flutter/material.dart';
import '../constants.dart';
import 'custom_font.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? width;
  final double borderRadius;
  final bool isOutlined;
  final BorderSide? borderSide;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.height = 48,
    this.width = double.infinity,
    this.borderRadius = 10,
    this.isOutlined = false,
    this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isOutlined
        ? Colors.transparent
        : (backgroundColor ?? AppColors.nuBlue);
    final fgColor = textColor ?? (isOutlined ? AppColors.nuBlue : Colors.white);

    return SizedBox(
      width: width,
      height: height,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: borderSide ??
                    BorderSide(color: backgroundColor ?? AppColors.nuBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: _buildChild(fgColor),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: fgColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: _buildChild(fgColor),
            ),
    );
  }

  Widget _buildChild(Color fgColor) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(fgColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: fgColor),
          const SizedBox(width: 8),
          CustomFont(
            text: text,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: fgColor,
            fontFamily: AppFonts.frutiger,
          ),
        ],
      );
    }

    return CustomFont(
      text: text,
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: fgColor,
      fontFamily: AppFonts.frutiger,
    );
  }
}
