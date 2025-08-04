import 'package:flutter/material.dart';
import 'package:redeo_app/widgets/common/custom_app_bar.dart';
import 'package:redeo_app/widgets/common/app_button.dart';

class MemberProfileScreen extends StatelessWidget {
  const MemberProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock user data - in a real app, this would come from a provider or API
    final userData = {
      'name': 'Benedict Sandy',
      'phone': '0754528***',
      'email': 'bensandyf@gmail.com',
      'memberId': 'MR001234',
      'joinDate': 'January 2024',
      'membershipType': 'Premium Member',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: Column(
        children: [
          // Using the existing CustomAppBar widget
          const CustomAppBar(title: 'My Profile'),

          // Profile Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile Avatar Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Color(0xFF2ECC71),
                          child: Text(
                            'BS',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userData['name']!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userData['membershipType']!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2ECC71),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Profile Information Cards
                  _buildInfoCard('Member ID', userData['memberId']!, Icons.badge),
                  const SizedBox(height: 12),
                  _buildInfoCard('Phone Number', userData['phone']!, Icons.phone),
                  const SizedBox(height: 12),
                  _buildInfoCard('Email', userData['email']!, Icons.email),
                  const SizedBox(height: 12),
                  _buildInfoCard('Member Since', userData['joinDate']!, Icons.calendar_today),

                  const SizedBox(height: 30),

                  // Action Buttons using AppButton widget
                  AppButton(
                    text: 'Edit Profile',
                    onPressed: () {
                      // TODO: Implement edit profile functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Edit profile feature coming soon!'),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),

                  const SizedBox(height: 12),

                  AppButton(
                    text: 'Change Password',
                    onPressed: () {
                      // TODO: Implement change password functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Change password feature coming soon!'),
                        ),
                      );
                    },
                    backgroundColor: Colors.white,
                    textColor: const Color(0xFF2ECC71),
                    icon: const Icon(
                      Icons.lock,
                      color: Color(0xFF2ECC71),
                      size: 18,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2ECC71),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}