import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mredeo_app/core/theme/app_colors.dart';
import 'package:mredeo_app/widgets/common/custom_app_bar.dart';
import 'package:mredeo_app/widgets/common/app_button.dart';
import 'package:mredeo_app/providers/payment_provider.dart';
import 'package:mredeo_app/data/models/payment_model.dart';

class PaymentStatusScreen extends StatefulWidget {
  const PaymentStatusScreen({super.key});

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomAppBar(title: 'Payment Status'),
          Expanded(
            child: Consumer<PaymentProvider>(
              builder: (context, paymentProvider, child) {
                final currentPayment = paymentProvider.currentPayment;

                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Status Icon and Message
                      _buildStatusIcon(
                        currentPayment?.paymentStatus ?? PaymentStatus.pending,
                      ),
                      const SizedBox(height: 24),

                      Text(
                        _getStatusTitle(
                          currentPayment?.paymentStatus ??
                              PaymentStatus.pending,
                        ),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        _getStatusMessage(
                          currentPayment?.paymentStatus ??
                              PaymentStatus.pending,
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      if (currentPayment != null) ...[
                        const SizedBox(height: 32),

                        // Payment Details Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 16),

                              _buildDetailRow(
                                'Amount',
                                'TZS ${currentPayment.amountPaid.toStringAsFixed(0)}',
                              ),
                              _buildDetailRow(
                                'Contribution Type',
                                currentPayment.contributionType?.name ??
                                    'Unknown',
                              ),
                              _buildDetailRow(
                                'Payment Method',
                                _getTelcoName(currentPayment.telco),
                              ),
                              _buildDetailRow(
                                'Phone Number',
                                currentPayment.phoneNumberUsed,
                              ),
                              _buildDetailRow(
                                'Transaction Reference',
                                currentPayment.transactionReference,
                              ),
                              _buildDetailRow(
                                'Date',
                                _formatDate(currentPayment.createdAt),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),

                      // Action Buttons
                      if (currentPayment?.paymentStatus ==
                          PaymentStatus.pending) ...[
                        AppButton(
                          text: 'Check Status',
                          onPressed:
                              () => _checkPaymentStatus(
                                currentPayment!.transactionReference,
                              ),
                          isLoading: paymentProvider.isLoading,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Text(
                            'Back to Payment',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ] else ...[
                        AppButton(
                          text: 'Done',
                          onPressed: () {
                            paymentProvider.clearCurrentPayment();
                            context.pop();
                          },
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(PaymentStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case PaymentStatus.success:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case PaymentStatus.pending:
        icon = Icons.access_time;
        color = Colors.orange;
        break;
      case PaymentStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
      case PaymentStatus.cancelled:
        icon = Icons.cancel;
        color = Colors.grey;
        break;
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 50, color: color),
    );
  }

  String _getStatusTitle(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.success:
        return 'Payment Successful!';
      case PaymentStatus.pending:
        return 'Payment Pending';
      case PaymentStatus.failed:
        return 'Payment Failed';
      case PaymentStatus.cancelled:
        return 'Payment Cancelled';
    }
  }

  String _getStatusMessage(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.success:
        return 'Your contribution payment has been processed successfully.';
      case PaymentStatus.pending:
        return 'Your payment is being processed. Please wait for confirmation.';
      case PaymentStatus.failed:
        return 'Your payment could not be processed. Please try again.';
      case PaymentStatus.cancelled:
        return 'Your payment has been cancelled.';
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTelcoName(TelcoProvider telco) {
    switch (telco) {
      case TelcoProvider.vodacom:
        return 'M-Pesa';
      case TelcoProvider.tigo:
        return 'TigoPesa';
      case TelcoProvider.airtel:
        return 'AirtelMoney';
      case TelcoProvider.halotel:
        return 'HaloPesa';
      case TelcoProvider.zantel:
        return 'EzyPesa';
      case TelcoProvider.other:
        return 'Other';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _checkPaymentStatus(String transactionReference) async {
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );
    await paymentProvider.checkPaymentStatus(transactionReference);
  }
}
