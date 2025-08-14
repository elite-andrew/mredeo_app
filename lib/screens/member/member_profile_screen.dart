import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redeo_app/widgets/common/custom_app_bar.dart';
import 'package:redeo_app/widgets/common/app_button.dart';
import 'package:redeo_app/core/theme/app_colors.dart';
import 'package:redeo_app/providers/auth_provider.dart';
import 'package:redeo_app/providers/profile_provider.dart';

class MemberProfileScreen extends StatefulWidget {
  const MemberProfileScreen({super.key});

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    await profileProvider.loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomAppBar(title: 'My Account'),
          Expanded(
            child: Consumer2<AuthProvider, ProfileProvider>(
              builder: (context, authProvider, profileProvider, child) {
                if (profileProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (profileProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profileProvider.errorMessage!,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        AppButton(text: 'Retry', onPressed: _loadProfile),
                      ],
                    ),
                  );
                }

                final user = authProvider.currentUser ?? profileProvider.user;
                if (user == null) {
                  return const Center(
                    child: Text(
                      'No profile data available',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Profile Avatar Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(26),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Profile Picture
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.primary,
                              backgroundImage:
                                  user.profilePicture != null
                                      ? NetworkImage(user.profilePicture!)
                                      : null,
                              child:
                                  user.profilePicture == null
                                      ? Text(
                                        _getInitials(user.fullName),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )
                                      : null,
                            ),
                            const SizedBox(height: 16),

                            // User Name
                            Text(
                              user.fullName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // User Role
                            Text(
                              _formatRole(user.role),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Profile Information Cards
                      _buildInfoCard('Username', user.username, Icons.person),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        'Phone Number',
                        user.phoneNumber,
                        Icons.phone,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        'Email',
                        user.email ?? 'Not provided',
                        Icons.email,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        'Member Since',
                        _formatDate(user.createdAt),
                        Icons.calendar_today,
                      ),

                      const SizedBox(height: 30),

                      // Action Buttons
                      AppButton(
                        text: 'Edit Profile',
                        onPressed: () => _editProfile(profileProvider),
                        icon: Icon(
                          Icons.edit,
                          color: AppColors.textPrimary,
                          size: 18,
                        ),
                      ),

                      const SizedBox(height: 12),

                      AppButton(
                        text: 'Change Password',
                        onPressed: () => _changePassword(profileProvider),
                        icon: Icon(
                          Icons.lock,
                          color: AppColors.textPrimary,
                          size: 18,
                        ),
                      ),

                      const SizedBox(height: 12),

                      AppButton(
                        text: 'Update Settings',
                        onPressed: () => _updateSettings(profileProvider),
                        icon: Icon(
                          Icons.settings,
                          color: AppColors.textPrimary,
                          size: 18,
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                );
              },
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
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

  String _getInitials(String name) {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _formatRole(String role) {
    switch (role.toLowerCase()) {
      case 'member':
        return 'Member';
      case 'admin_chairperson':
        return 'Chairperson';
      case 'admin_secretary':
        return 'Secretary';
      case 'admin_signatory':
        return 'Signatory';
      default:
        return 'Member';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _editProfile(ProfileProvider profileProvider) {
    // TODO: Navigate to edit profile screen or show edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit profile feature will be implemented next'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _changePassword(ProfileProvider profileProvider) {
    // TODO: Navigate to change password screen or show change password dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Change password feature will be implemented next'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _updateSettings(ProfileProvider profileProvider) {
    // TODO: Navigate to settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings feature will be implemented next'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
