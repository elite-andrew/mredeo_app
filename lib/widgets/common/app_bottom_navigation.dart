import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mredeo_app/config/app_routes.dart';
import 'package:mredeo_app/core/theme/app_colors.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavigation({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: AppColors.primary,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 24,
          landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Icon(Icons.home_outlined),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Icon(Icons.receipt_long_outlined),
              ),
              label: 'Transactions',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Icon(Icons.notifications_outlined),
              ),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Icon(Icons.settings),
              ),
              label: 'Settings',
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                context.push(AppRoutes.dashboard);
                break;
              case 1:
                context.push(AppRoutes.transactionHistory);
                break;
              case 2:
                context.push(AppRoutes.notifications);
                break;
              case 3:
                context.push(AppRoutes.settings);
                break;
            }
          },
        ),
      ),
    );
  }
}
