import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redeo_app/config/app_routes.dart';
import 'package:redeo_app/widgets/specific/settings_item_tile.dart';
import 'package:redeo_app/widgets/common/app_bottom_navigation.dart';
import 'package:redeo_app/widgets/common/custom_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentLanguage = 'TZ'; // 'TZ' for Tanzania, 'UK' for UK

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: Column(
        children: [
          Stack(
            children: [
              const CustomAppBar(title: 'Settings'),
              Positioned(
                right: 16,
                top: MediaQuery.of(context).padding.top + 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      setState(() {
                        _currentLanguage = value;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentLanguage == 'TZ' ? '🇹🇿' : '🇬🇧',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_drop_down,
                          size: 20,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'TZ',
                            child: Row(
                              children: [
                                Text('🇹🇿'),
                                SizedBox(width: 8),
                                Text('Swahili'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'UK',
                            child: Row(
                              children: [
                                Text('🇬🇧'),
                                SizedBox(width: 8),
                                Text('English'),
                              ],
                            ),
                          ),
                        ],
                  ),
                ),
              ),
            ],
          ),

          // Add spacing between AppBar and Settings Items
          const SizedBox(height: 20),

          // Settings Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                SettingsItemTile(
                  icon: Icons.person,
                  title: 'My Account',
                  onTap: () => context.push(AppRoutes.memberProfile),
                ),
                SettingsItemTile(
                  icon: Icons.menu_book,
                  title: 'Terms and Conditions',
                  onTap: () => context.push(AppRoutes.termsAndConditions),
                ),
                SettingsItemTile(
                  icon: Icons.call,
                  title: 'Customer Support',
                  onTap: () => context.push(AppRoutes.customerSupport),
                ),
                SettingsItemTile(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  onTap: () {
                    context.go(AppRoutes.login);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 3),
    );
  }
}
