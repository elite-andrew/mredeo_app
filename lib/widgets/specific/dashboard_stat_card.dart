import 'package:flutter/material.dart';
import 'package:redeo_app/core/theme/app_colors.dart';

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String amount;
  final bool isPaid;
  final bool isPending;
  final IconData icon;
  final VoidCallback? onTap;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.amount,
    required this.isPaid,
    this.isPending = false,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
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
            // Icon container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.getPrimaryWithAlpha(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Amount
            Text(
              amount,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Status
            Text(
              _getStatusText(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _getStatusColor(),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText() {
    if (isPaid) return 'Paid';
    if (isPending) return 'Pending';
    return 'Unpaid';
  }

  Color _getStatusColor() {
    if (isPaid) return AppColors.primary;
    if (isPending) return Colors.orange;
    return AppColors.error;
  }
}
