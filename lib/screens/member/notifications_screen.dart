import 'package:flutter/material.dart';
import 'package:redeo_app/widgets/common/app_bottom_navigation.dart';
import 'package:redeo_app/widgets/common/custom_app_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: Column(
        children: [
          const CustomAppBar(title: 'Notifications'),
          const Expanded(child: Center(child: Text('Notifications'))),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
    );
  }
}
