import 'package:flutter/material.dart';
import 'package:redeo_app/core/theme/app_colors.dart';

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String? amount; // For member dashboard (string with formatting)
  final num? value; // For admin dashboard (numeric value)
  final bool? isPaid;
  final bool? isPending;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool showStatus; // Control whether to show status indicators

  const DashboardStatCard({
    super.key,
    required this.title,
    this.amount,
    this.value,
    this.isPaid,
    this.isPending,
    this.icon,
    this.onTap,
    this.showStatus = true,
  }) : assert(
         (amount != null) != (value != null),
         'Either amount or value must be provided, but not both',
       );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withAlpha(13),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.primary.withAlpha(13), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with icon and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon container
                if (icon != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withAlpha(20),
                          AppColors.primary.withAlpha(10),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withAlpha(30),
                      ),
                    ),
                    child: Icon(icon!, color: AppColors.primary, size: 24),
                  ),

                // Status indicator (only show if showStatus is true and status info is available)
                if (showStatus && (isPaid != null || isPending != null))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _getStatusColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusText(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Amount or Value
            Text(
              _getDisplayValue(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),

            // Trend indicator or additional info
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.trending_up, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  '+12% from last month',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayValue() {
    if (amount != null) return amount!;
    if (value != null) {
      // Format numeric values for better display
      final numValue = value!;
      if (numValue >= 1000000) {
        return '${(numValue / 1000000).toStringAsFixed(1)}M';
      } else if (numValue >= 1000) {
        return '${(numValue / 1000).toStringAsFixed(1)}K';
      } else {
        return numValue.toString();
      }
    }
    return '';
  }

  String _getStatusText() {
    if (isPaid == true) return 'Paid';
    if (isPending == true) return 'Pending';
    return 'Unpaid';
  }

  Color _getStatusColor() {
    if (isPaid == true) return Colors.green;
    if (isPending == true) return Colors.orange;
    return Colors.red;
  }
}
