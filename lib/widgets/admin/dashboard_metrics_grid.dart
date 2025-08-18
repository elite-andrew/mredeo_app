import 'package:flutter/material.dart';
import 'package:redeo_app/widgets/specific/dashboard_stat_card.dart';
import 'package:redeo_app/data/models/admin_metrics.dart';
import 'package:redeo_app/core/theme/app_colors.dart';

class DashboardMetricsGrid extends StatelessWidget {
  final AdminMetrics? metrics;
  final bool showStatus;

  const DashboardMetricsGrid({
    super.key,
    required this.metrics,
    this.showStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    if (metrics == null) {
      return Container(
        height: 280,
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading financial data...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // First Row - Yearly and Monthly
        Row(
          children: [
            Expanded(
              child: DashboardStatCard(
                title: "Yearly Contributions",
                value: metrics!.yearlyTotal,
                showStatus: showStatus,
                icon: Icons.calendar_today,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DashboardStatCard(
                title: "Monthly Contributions",
                value: metrics!.monthlyTotal,
                showStatus: showStatus,
                icon: Icons.calendar_month,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Second Row - Condolences and Farewell
        Row(
          children: [
            Expanded(
              child: DashboardStatCard(
                title: "Condolences Fund",
                value: metrics!.condolencesTotal,
                showStatus: showStatus,
                icon: Icons.favorite,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DashboardStatCard(
                title: "Farewell Fund",
                value: metrics!.farewellTotal,
                showStatus: showStatus,
                icon: Icons.waving_hand,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
