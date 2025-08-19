import 'package:flutter/material.dart';
import 'package:mredeo_app/core/theme/app_colors.dart';

class ModernSortDialog extends StatelessWidget {
  final List<String> sortOptions;
  final String selectedSort;
  final bool isAscending;
  final Function(String) onSortChanged;
  final Function(bool) onOrderChanged;

  const ModernSortDialog({
    super.key,
    required this.sortOptions,
    required this.selectedSort,
    required this.isAscending,
    required this.onSortChanged,
    required this.onOrderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Sort Options',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sort options
            ...sortOptions.map((option) {
              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color:
                      selectedSort == option
                          ? AppColors.primary.withAlpha(20)
                          : Colors.transparent,
                ),
                child: RadioListTile<String>(
                  title: Text(
                    option,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight:
                          selectedSort == option
                              ? FontWeight.w600
                              : FontWeight.normal,
                    ),
                  ),
                  value: option,
                  groupValue: selectedSort,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    onSortChanged(value!);
                    Navigator.pop(context);
                  },
                ),
              );
            }),

            // Divider
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              height: 1,
              color: AppColors.primary.withAlpha(51),
            ),

            // Sort order switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.primary.withAlpha(10),
              ),
              child: Row(
                children: [
                  Icon(
                    isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ascending Order',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Switch(
                    value: isAscending,
                    onChanged: (value) {
                      onOrderChanged(value);
                      Navigator.pop(context);
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
