import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redeo_app/config/app_routes.dart';
import 'package:redeo_app/widgets/common/app_bottom_navigation.dart';
import 'package:redeo_app/widgets/common/app_button.dart';
import 'package:redeo_app/widgets/specific/dashboard_stat_card.dart';
import 'package:redeo_app/core/theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: false,
      body: Column(
        children: [
          const HeaderSection(),
          Expanded(
            child: SingleChildScrollView(
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
                    // Add contribution cards here

                    // First row - Monthly and Yearly
                    const Row(
                      children: [
                        Expanded(
                          child: DashboardStatCard(
                            title: 'Monthly',
                            amount: 'TZS 30,000',
                            isPaid: true,
                            icon: Icons.layers,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: DashboardStatCard(
                            title: 'Yearly',
                            amount: 'TZS 30,000',
                            isPaid: true,
                            icon: Icons.layers,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Second row - Condolences and Farewell
                    const Row(
                      children: [
                        Expanded(
                          child: DashboardStatCard(
                            title: 'Condolences',
                            amount: 'TZS 50,000',
                            isPaid: false,
                            icon: Icons.favorite,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: DashboardStatCard(
                            title: 'Farewell',
                            amount: 'TZS 100,000',
                            isPaid: true,
                            icon: Icons.layers,
                          ),
                        ),
                      ],
                    ),
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
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
    );
  }
}

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        30,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow, // Using our shadow color
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.surface,
            child: Text(
              'BS', // Replace with user initials
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hi,', style: TextStyle(color: Colors.black, fontSize: 18)),
              Text(
                'Benedict!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
