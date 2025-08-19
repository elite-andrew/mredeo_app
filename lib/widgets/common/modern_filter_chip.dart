import 'package:flutter/material.dart';
import 'package:mredeo_app/core/theme/app_colors.dart';

class ModernFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final VoidCallback? onClear;

  const ModernFilterChip({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withAlpha(20)
                  : AppColors.background,
          border: Border.all(
            color:
                isSelected
                    ? AppColors.primary
                    : AppColors.primary.withAlpha(51),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (onClear != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 14, color: AppColors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
