import 'package:flutter/material.dart';
import 'package:redeo_app/widgets/common/app_bottom_navigation.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFFF3F3F3),
        elevation: 0,
      ),
      body: const Center(child: Text('Notifications')),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
    );
  }
}
