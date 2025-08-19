import 'package:flutter/material.dart';
import 'package:mredeo_app/core/theme/app_colors.dart';

/// Common utility functions for creating modern UI components
class ModernUIUtils {
  ModernUIUtils._();

  /// Creates a standard container decoration with shadow and border radius
  static BoxDecoration createCardDecoration({
    Color? backgroundColor,
    double borderRadius = 12,
    bool hasShadow = true,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      border:
          borderColor != null
              ? Border.all(color: borderColor)
              : Border.all(color: AppColors.primary.withAlpha(26)),
      boxShadow:
          hasShadow
              ? [
                BoxShadow(
                  color: AppColors.shadow.withAlpha(13),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
              : null,
    );
  }

  /// Creates a standard icon container decoration
  static BoxDecoration createIconContainerDecoration({
    Color? backgroundColor,
    double borderRadius = 8,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.primary.withAlpha(20),
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  /// Creates a standard text style for primary text
  static TextStyle createPrimaryTextStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.textPrimary,
    );
  }

  /// Creates a standard text style for secondary text
  static TextStyle createSecondaryTextStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.textSecondary,
    );
  }

  /// Creates a standard badge decoration
  static BoxDecoration createBadgeDecoration({
    Color? backgroundColor,
    double borderRadius = 8,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.primary.withAlpha(20),
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  /// Shows a standardized loading dialog
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Row(
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(width: 16),
                Expanded(child: Text(message, style: createPrimaryTextStyle())),
              ],
            ),
          ),
    );
  }

  /// Shows a standardized success/error snackbar
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action:
            actionLabel != null
                ? SnackBarAction(
                  label: actionLabel,
                  textColor: Colors.white,
                  onPressed: onAction ?? () {},
                )
                : null,
      ),
    );
  }

  /// Creates a standard shimmer effect for loading states
  static Widget createShimmerPlaceholder({
    double width = double.infinity,
    double height = 60,
    double borderRadius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(26),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
