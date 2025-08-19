import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mredeo_app/providers/auth_provider.dart';
import 'package:mredeo_app/providers/profile_provider.dart';
import 'package:mredeo_app/core/theme/app_colors.dart';
import 'package:mredeo_app/core/utils/image_cache_manager.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          // Modern Header with Gradient
          _buildDrawerHeader(context),

          // Menu Items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.dashboard_outlined,
                    title: "Dashboard",
                    subtitle: "Overview & Analytics",
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go("/admin_dashboard");
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildMenuItem(
                    context,
                    icon: Icons.analytics_outlined,
                    title: "Payment Reports",
                    subtitle: "Financial Analysis",
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, "/admin/payment-reports");
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildMenuItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: "Send Notification",
                    subtitle: "Send Alerts",
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, "/admin/notifications");
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildMenuItem(
                    context,
                    icon: Icons.payment_outlined,
                    title: "Issue Payment",
                    subtitle: "Process Transactions",
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, "/admin/issue-payment");
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildMenuItem(
                    context,
                    icon: Icons.history_outlined,
                    title: "Payment History",
                    subtitle: "Transaction Logs",
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, "/admin/payment-history");
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline,
                    title: "Admin Profile",
                    subtitle: "Account Settings",
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go("/admin_profile");
                    },
                  ),

                  const SizedBox(height: 20),

                  // Divider
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.primary.withAlpha(51),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildMenuItem(
                    context,
                    icon: Icons.swap_horiz_outlined,
                    title: "Switch to User Mode",
                    subtitle: "Member Dashboard",
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, "/member/dashboard");
                    },
                  ),

                  const Spacer(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Consumer2<AuthProvider, ProfileProvider>(
      builder: (context, authProvider, profileProvider, child) {
        final user = profileProvider.user ?? authProvider.currentUser;
        String? profilePictureUrl = user?.profilePictureUrl;

        if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
          final separator = profilePictureUrl.contains('?') ? '&' : '?';
          profilePictureUrl =
              '$profilePictureUrl${separator}t=${DateTime.now().millisecondsSinceEpoch}';
        }

        return Container(
          height: 260,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(blue: AppColors.primary.b + 30),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(51),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Pattern
              Positioned.fill(
                child: CustomPaint(painter: _DrawerHeaderPatternPainter()),
              ),

              // Content
              Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  MediaQuery.of(context).padding.top + 16,
                  24,
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Admin Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withAlpha(77)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.admin_panel_settings,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ADMINISTRATOR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Profile Section
                    Row(
                      children: [
                        // Profile Picture
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withAlpha(77),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(51),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white,
                            child:
                                profilePictureUrl != null
                                    ? ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: profilePictureUrl,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        cacheManager:
                                            ImageCacheManager.instance,
                                        placeholder:
                                            (context, url) => Container(
                                              width: 64,
                                              height: 64,
                                              decoration: const BoxDecoration(
                                                color: AppColors.surface,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      color: AppColors.primary,
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                            ),
                                        errorWidget:
                                            (context, url, error) => Text(
                                              user?.initials ?? 'A',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                      ),
                                    )
                                    : Text(
                                      user?.initials ?? 'A',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.fullName ?? 'Administrator',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatRole(user?.role ?? 'admin'),
                                style: TextStyle(
                                  color: Colors.white.withAlpha(200),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(51)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withAlpha(13),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
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
      case 'admin_treasurer':
        return 'Treasurer';
      default:
        return 'Administrator';
    }
  }
}

class _DrawerHeaderPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withAlpha(26)
          ..style = PaintingStyle.fill;

    // Draw subtle pattern circles
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 3; j++) {
        final x = (i * 40.0) - 20;
        final y = (j * 60.0) + 40;
        canvas.drawCircle(Offset(x, y), 15 - (i * 2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
