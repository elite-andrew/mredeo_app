import 'package:flutter/material.dart';
import 'package:mredeo_app/core/theme/app_colors.dart';

class ModernFiltersSection extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final List<Widget> filterChips;

  const ModernFiltersSection({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.filterChips,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 6),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.filter_list,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Filters & Search',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withAlpha(26)),
            ),
            child: TextField(
              onChanged: onSearchChanged,
              style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by name or description...',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.search, color: AppColors.primary, size: 20),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Filter Chips
          Wrap(spacing: 8, runSpacing: 8, children: filterChips),
        ],
      ),
    );
  }
}
