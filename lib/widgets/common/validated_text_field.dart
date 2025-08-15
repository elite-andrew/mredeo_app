import 'package:flutter/material.dart';
import 'package:redeo_app/core/theme/app_colors.dart';

class ValidatedTextField extends StatelessWidget {
  final String hintText;
  final String? label;
  final TextEditingController controller;
  final bool obscureText;
  final IconData? prefixIcon;
  final VoidCallback? onToggleVisibility;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool readOnly;

  const ValidatedTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.label,
    this.obscureText = false,
    this.prefixIcon,
    this.onToggleVisibility,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
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
          decoration: BoxDecoration(
            color:
                enabled && !readOnly
                    ? AppColors.surfaceInput
                    : AppColors.surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color:
                  enabled && !readOnly
                      ? AppColors.border
                      : AppColors.border.withValues(alpha: 0.5),
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            enabled: enabled,
            readOnly: readOnly,
            style: TextStyle(
              color:
                  enabled && !readOnly
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
              fontSize: 14,
            ),
            onChanged: onChanged,
            validator: validator,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon:
                  prefixIcon != null
                      ? Icon(
                        prefixIcon,
                        color:
                            enabled && !readOnly
                                ? AppColors.primary
                                : AppColors.textSecondary,
                        size: 20,
                      )
                      : null,
              suffixIcon:
                  onToggleVisibility != null
                      ? TextButton(
                        onPressed: onToggleVisibility,
                        child: Text(
                          obscureText ? 'Show' : 'Hide',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      )
                      : null,
              errorStyle: TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
