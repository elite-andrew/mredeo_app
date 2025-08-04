import 'package:flutter/material.dart';
import 'package:redeo_app/widgets/common/app_bottom_navigation.dart';
import 'package:redeo_app/widgets/common/custom_app_bar.dart';

class TransactionsHistoryScreen extends StatelessWidget {
  const TransactionsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: Column(
        children: [
          const CustomAppBar(title: 'Transactions History'),
          const Expanded(child: Center(child: Text('Transactions History'))),
        ],
      ),

      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }
}
