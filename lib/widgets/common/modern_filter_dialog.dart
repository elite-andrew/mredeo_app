import 'package:flutter/material.dart';
import 'package:mredeo_app/core/theme/app_colors.dart';

class ModernFilterDialog extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selectedValue;
  final Function(String) onSelected;

  const ModernFilterDialog({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                options.map((option) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color:
                          selectedValue == option
                              ? AppColors.primary.withAlpha(20)
                              : Colors.transparent,
                    ),
                    child: RadioListTile<String>(
                      title: Text(
                        option,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight:
                              selectedValue == option
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                        ),
                      ),
                      value: option,
                      groupValue: selectedValue,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        onSelected(value!);
                        Navigator.pop(context);
                      },
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}
