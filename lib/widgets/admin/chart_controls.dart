import 'package:flutter/material.dart';
import 'package:mredeo_app/widgets/admin/contribution_filter_sheet.dart';
import 'package:mredeo_app/core/theme/app_colors.dart';

class ChartControls extends StatelessWidget {
  final String currentScale;
  final String currentType;
  final Function(String) onScaleChanged;
  final Function(String) onTypeChanged;

  const ChartControls({
    super.key,
    required this.currentScale,
    required this.currentType,
    required this.onScaleChanged,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Time Scale Selector
          Row(
            children: [
              Icon(Icons.schedule, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Time Scale:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withAlpha(30)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: currentScale,
                    isDense: true,
                    dropdownColor: AppColors.surface,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "monthly",
                        child: Text("Monthly"),
                      ),
                      DropdownMenuItem(value: "yearly", child: Text("Yearly")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        onScaleChanged(val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          // Filter Button
          GestureDetector(
            onTap: () async {
              await showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder:
                    (_) => ContributionFilterSheet(
                      current: currentType,
                      onSelect: onTypeChanged,
                    ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withAlpha(30)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune, color: AppColors.primary, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Filter',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
