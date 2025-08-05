import 'package:flutter/material.dart';
import 'package:redeo_app/core/theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  final String hintText;
  final String? label;
  final String? errorText;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.label,
    this.errorText,
    this.obscureText = false,
    this.onToggleVisibility,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceInput,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    errorStyle: const TextStyle(
                      height: 0,
                    ), // Hide the error within TextField
                  ),
                ),
              ),
              if (onToggleVisibility != null)
                TextButton(
                  onPressed: onToggleVisibility,
                  child: Text(
                    obscureText ? 'Show' : 'Hide',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
            child: Text(
              errorText!,
              style: TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
