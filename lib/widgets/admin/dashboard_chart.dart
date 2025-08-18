import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:redeo_app/data/models/time_bucket_point.dart';
import 'package:redeo_app/core/theme/app_colors.dart';

class DashboardChart extends StatelessWidget {
  final List<TimeBucketPoint> data;
  final String scale;

  const DashboardChart({super.key, required this.data, required this.scale});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text("No data available", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 250,
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
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            horizontalInterval: _getHorizontalInterval(),
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withAlpha(77), // 0.3 * 255 ≈ 77
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.withAlpha(77), // 0.3 * 255 ≈ 77
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        data[index].periodLabel,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: _getHorizontalInterval(),
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      _formatCurrency(value),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Colors.grey.withAlpha(77),
            ), // 0.3 * 255 ≈ 77
          ),
          minX: 0,
          maxX: data.length - 1.0,
          minY: 0,
          maxY: _getMaxY(),
          lineBarsData: [
            LineChartBarData(
              spots:
                  data.asMap().entries.map((entry) {
                    return FlSpot(
                      entry.key.toDouble(),
                      entry.value.total.toDouble(),
                    );
                  }).toList(),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withAlpha(204),
                  AppColors.primary,
                ], // 0.8 * 255 ≈ 204
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter:
                    (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 4,
                      color: AppColors.primary,
                      strokeWidth: 2,
                      strokeColor: AppColors.surface,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withAlpha(26), // 0.1 * 255 ≈ 26
                    AppColors.primary.withAlpha(13), // 0.05 * 255 ≈ 13
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final flSpot = barSpot;
                  final index = flSpot.x.toInt();
                  if (index >= 0 && index < data.length) {
                    final point = data[index];
                    return LineTooltipItem(
                      '${point.periodLabel}\n${_formatCurrency(point.total.toDouble())}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return null;
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  double _getMaxY() {
    if (data.isEmpty) return 100;
    final maxValue = data
        .map((p) => p.total.toDouble())
        .reduce((a, b) => a > b ? a : b);
    return maxValue * 1.2; // Add 20% padding
  }

  double _getHorizontalInterval() {
    final maxY = _getMaxY();
    if (maxY <= 1000) return 200;
    if (maxY <= 10000) return 2000;
    if (maxY <= 100000) return 20000;
    return maxY / 5;
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}
