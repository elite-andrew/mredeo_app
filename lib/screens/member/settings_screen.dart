import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redeo_app/config/app_routes.dart';
import 'package:redeo_app/widgets/specific/settings_item_tile.dart';
import 'package:redeo_app/widgets/common/app_bottom_navigation.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentLanguage = 'TZ'; // 'TZ' for Tanzania, 'UK' for UK

  @override
  Widget build(BuildContext context) {
    final user = {
      'name': 'Benedict Sandy',
      'phone': '0754528***',
      'email': 'bensandyf@gmail.com',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      extendBodyBehindAppBar: false,
      body: Column(
        children: [
          // Top Header with Status Bar
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 20,
              20,
              30,
            ),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    'BS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user['phone']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        user['email']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      setState(() {
                        _currentLanguage = value;
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          _currentLanguage == 'TZ' ? '🇹🇿' : '🇬🇧',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF2ECC71),
                        ),
                      ],
                    ),
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'TZ',
                            child: Row(
                              children: [
                                const Text(
                                  '🇹🇿',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 8),
                                const Text('Swahili'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'UK',
                            child: Row(
                              children: [
                                const Text(
                                  '🇬🇧',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 8),
                                const Text('English'),
                              ],
                            ),
                          ),
                        ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation Bar
          Container(
            color: const Color(0xFFF3F3F3),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => context.pop(),
                ),
                const Expanded(
                  child: Text(
                    'Settings',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Balance the back button
              ],
            ),
          ),

          // Settings Items
          Expanded(
            child: ListView(
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
                  onTap: () {
                    // Add support logic
                  },
                ),
                SettingsItemTile(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  onTap: () {
                    // Exit the app and navigate to login
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
