import 'package:flutter/material.dart';
import 'package:redeo_app/core/theme/app_colors.dart';

class PaymentItem {
  final String name;
  final String iconPath;

  const PaymentItem({required this.name, required this.iconPath});
}

class AppPaymentDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final List<PaymentItem> items;
  final ValueChanged<String?> onChanged;
  final String label;

  const AppPaymentDropdown({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 48, // Fixed height to match TextField
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceInput,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                hint,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              selectedItemBuilder: (BuildContext context) {
                return items.map<Widget>((PaymentItem item) {
                  return Row(
                    children: [
                      if (item.name == value) ...[
                        Image.asset(
                          item.iconPath,
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.payment,
                              size: 24,
                              color: AppColors.textPrimary,
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                }).toList();
              },
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
                size: 22,
              ),
              isDense: true,
              dropdownColor: AppColors.surfaceInput,
              items:
                  items.map((PaymentItem item) {
                    return DropdownMenuItem<String>(
                      value: item.name,
                      child: Row(
                        children: [
                          // Payment Icon
                          Container(
                            width: 28,
                            height: 28,
                            padding: const EdgeInsets.all(2),
                            child: Image.asset(
                              item.iconPath,
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.payment,
                                  size: 20,
                                  color: AppColors.textPrimary,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Payment Name
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: onChanged,
              menuMaxHeight: 300,
              borderRadius: BorderRadius.circular(13),
              itemHeight: 48,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
