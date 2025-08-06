import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redeo_app/config/app_routes.dart';
import 'package:redeo_app/providers/auth_provider.dart';
import 'package:redeo_app/providers/payment_provider.dart';
import 'package:redeo_app/providers/notification_provider.dart';
import 'package:redeo_app/widgets/common/app_bottom_navigation.dart';
import 'package:redeo_app/widgets/common/app_button.dart';
import 'package:redeo_app/widgets/specific/dashboard_stat_card.dart';
import 'package:redeo_app/core/theme/app_colors.dart';
import 'package:redeo_app/data/models/payment_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    await Future.wait([
      paymentProvider.loadContributionTypes(),
      paymentProvider.loadPaymentHistory(),
      notificationProvider.loadUnreadCount(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: false,
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: Column(
          children: [
            const HeaderSection(),
            Expanded(
              child: Consumer<PaymentProvider>(
                builder: (context, paymentProvider, child) {
                  if (paymentProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Contribution Status",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Build contribution cards dynamically
                          ...paymentProvider.contributionTypes
                              .where((type) => type.isActive)
                              .map(
                                (contributionType) => _buildContributionCard(
                                  contributionType,
                                  paymentProvider.paymentHistory,
                                ),
                              )
                              ,

                          const SizedBox(height: 40),

                          // Pay Now Button
                          const SizedBox(height: 120),
                          AppButton(
                            text: 'Pay Now',
                            onPressed: () {
                              context.push(AppRoutes.makePayment);
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildContributionCard(
    ContributionType contributionType,
    List<Payment> paymentHistory,
  ) {
    // Find the latest payment for this contribution type
    final latestPayment = paymentHistory
        .where((payment) => payment.contributionTypeId == contributionType.id)
        .fold<Payment?>(null, (latest, current) {
          if (latest == null) return current;
          return current.createdAt.isAfter(latest.createdAt) ? current : latest;
        });

    final isPaid = latestPayment?.isPaid ?? false;
    final isPending = latestPayment?.isPending ?? false;

    IconData icon;
    switch (contributionType.name.toLowerCase()) {
      case 'monthly':
        icon = Icons.calendar_month;
        break;
      case 'yearly':
        icon = Icons.calendar_today;
        break;
      case 'condolences':
        icon = Icons.favorite;
        break;
      case 'farewell':
        icon = Icons.handshake;
        break;
      default:
        icon = Icons.layers;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: DashboardStatCard(
              title: contributionType.name,
              amount: contributionType.formattedAmount,
              isPaid: isPaid,
              isPending: isPending,
              icon: icon,
              onTap: () {
                // Navigate to payment details or make payment
                if (!isPaid && !isPending) {
                  context.push(AppRoutes.makePayment, extra: contributionType);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, NotificationProvider>(
      builder: (context, authProvider, notificationProvider, child) {
        final user = authProvider.currentUser;
        final unreadCount = notificationProvider.unreadCount;

        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + 20,
            20,
            30,
          ),
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.surface,
                backgroundImage:
                    user?.profilePicture != null
                        ? NetworkImage(user!.profilePicture!)
                        : null,
                child:
                    user?.profilePicture == null
                        ? Text(
                          user?.initials ?? 'U',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hi,',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    Text(
                      user?.fullName.split(' ').first ?? 'User',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (unreadCount > 0)
                GestureDetector(
                  onTap: () => context.push(AppRoutes.notifications),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
