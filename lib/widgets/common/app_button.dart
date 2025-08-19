import 'package:flutter/material.dart';
import 'package:mredeo_app/core/theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double borderRadius;
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsets padding;
  final Widget? icon; // New optional icon widget

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.borderRadius = 18,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.textPrimary,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading || onPressed == null ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child:
            isLoading
                ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[icon!, const SizedBox(width: 12)],
                    Flexible(
                      child: Text(
                        text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
