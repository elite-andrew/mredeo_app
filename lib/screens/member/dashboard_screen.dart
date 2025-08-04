import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redeo_app/config/app_routes.dart';
import 'package:redeo_app/widgets/common/app_bottom_navigation.dart';
import 'package:redeo_app/widgets/common/app_button.dart';
import 'package:redeo_app/widgets/specific/dashboard_stat_card.dart';
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
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
                    const SizedBox(height: 140),
                    AppButton(
                      text: 'Pay Now',
                      onPressed: () {
                        // TODO: Navigate to payment screen
                        context.push(AppRoutes.makePayment);
                      },
                    ),
                    const SizedBox(height: 20),
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
      decoration: const BoxDecoration(
        color: Color(0xFF2ECC71),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000), // 25% black shadow
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
            backgroundColor: Colors.white,
            child: Text(
              'BS', // Replace with user initials
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000000),
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
