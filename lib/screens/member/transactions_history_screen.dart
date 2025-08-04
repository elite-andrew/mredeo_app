import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redeo_app/config/app_routes.dart';
import 'package:redeo_app/widgets/common/app_bottom_navigation.dart';

class TransactionsHistoryScreen extends StatelessWidget {
  const TransactionsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        title: const Text('Transactions History'),
        backgroundColor: const Color(0xFFF3F3F3),
        elevation: 0,
      ),
      body: const Center(child: Text('Transactions History')),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }
}
