import 'package:flutter/material.dart';
import 'package:mredeo_app/data/models/pending_notification.dart';
import 'package:mredeo_app/core/theme/app_colors.dart';

class PendingPaymentsTable extends StatelessWidget {
  final List<PendingNotification> payments;

  const PendingPaymentsTable({super.key, required this.payments});

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'All Caught Up!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No pending payments at the moment',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(5),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              _buildHeaderCell('No', flex: 1),
              _buildHeaderCell('Type', flex: 2),
              _buildHeaderCell('Beneficiary', flex: 3),
              _buildHeaderCell('Status', flex: 2),
            ],
          ),
        ),
        // Content
        ...payments.asMap().entries.map((entry) {
          final i = entry.key + 1;
          final payment = entry.value;
          final isLast = i == payments.length;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color:
                      isLast
                          ? Colors.transparent
                          : AppColors.primary.withAlpha(13),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                _buildDataCell(
                  i.toString(),
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      i.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                _buildDataCell(
                  payment.type,
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(payment.type).withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      payment.type,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getTypeColor(payment.type),
                      ),
                    ),
                  ),
                ),
                _buildDataCell(
                  payment.beneficiaryName,
                  flex: 3,
                  child: Text(
                    payment.beneficiaryName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildDataCell(
                  payment.status,
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(payment.status).withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      payment.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(payment.status),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildDataCell(String text, {int flex = 1, Widget? child}) {
    return Expanded(
      flex: flex,
      child:
          child ??
          Text(
            text,
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'condolences':
        return Colors.purple;
      case 'farewell':
        return Colors.blue;
      case 'monthly':
        return Colors.green;
      case 'yearly':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'processing':
        return Colors.blue;
      default:
        return AppColors.textSecondary;
    }
  }
}
