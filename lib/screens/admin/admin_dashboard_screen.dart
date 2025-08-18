import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:redeo_app/providers/admin_provider.dart';
import 'package:redeo_app/providers/auth_provider.dart';
import 'package:redeo_app/providers/profile_provider.dart';
import 'package:redeo_app/widgets/admin/dashboard_chart.dart';
import 'package:redeo_app/widgets/admin/pending_payments_table.dart';
import 'package:redeo_app/widgets/admin/admin_drawer.dart';
import 'package:redeo_app/widgets/admin/dashboard_metrics_grid.dart';
import 'package:redeo_app/widgets/admin/chart_controls.dart';
import 'package:redeo_app/core/theme/app_colors.dart';
import 'package:redeo_app/core/utils/image_cache_manager.dart';
import 'package:redeo_app/core/utils/app_logger.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );

      // Set up connection between providers for cross-updates
      profileProvider.setAuthProvider(authProvider);

      // If AuthProvider has user data but ProfileProvider doesn't, sync first
      if (authProvider.currentUser != null && profileProvider.user == null) {
        debugPrint(
          'AuthProvider has user data, syncing to ProfileProvider first',
        );
        profileProvider.syncWithAuthProvider();
      }

      await Future.wait([
        adminProvider.refreshAll(),
        profileProvider.loadProfile(),
      ]);
    } catch (e) {
      // Handle provider access errors gracefully
      debugPrint('Error loading admin dashboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: false,
      drawer: const AdminDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: Column(
          children: [
            const AdminHeaderSection(),
            Expanded(
              child: Consumer<AdminProvider>(
                builder: (context, adminProvider, child) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome Admin Section
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withAlpha(20),
                                  AppColors.primary.withAlpha(5),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withAlpha(30),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.admin_panel_settings,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Administrator Dashboard',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Monitor system performance and manage operations',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Metrics Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Financial Overview',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (adminProvider.loading)
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          DashboardMetricsGrid(
                            metrics: adminProvider.metrics,
                            showStatus: false,
                          ),

                          const SizedBox(height: 32),

                          // Charts Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Contribution Trends',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(20),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primary.withAlpha(50),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.trending_up,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Live Data',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          ChartControls(
                            currentScale: adminProvider.scale,
                            currentType: adminProvider.selectedType,
                            onScaleChanged:
                                (val) => adminProvider.setScale(val),
                            onTypeChanged: (val) => adminProvider.setType(val),
                          ),
                          const SizedBox(height: 16),

                          DashboardChart(
                            data: adminProvider.series,
                            scale: adminProvider.scale,
                          ),

                          const SizedBox(height: 32),

                          // Pending Payments Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pending Actions',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withAlpha(20),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${adminProvider.pending.length}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow.withAlpha(13),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(10),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.pending_actions,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Payment Queue',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: PendingPaymentsTable(
                                    payments: adminProvider.pending,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Quick Actions
                          Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.5,
                            children: [
                              _buildQuickActionCard(
                                'Issue Payment',
                                Icons.payment,
                                Colors.green,
                                () => context.push('/admin/issue-payment'),
                              ),
                              _buildQuickActionCard(
                                'Send Notification',
                                Icons.notifications_active,
                                Colors.blue,
                                () => context.push('/admin/notifications'),
                              ),
                              _buildQuickActionCard(
                                'View Reports',
                                Icons.analytics,
                                Colors.purple,
                                () => context.push('/admin/payment-reports'),
                              ),
                              _buildQuickActionCard(
                                'Payment History',
                                Icons.history,
                                Colors.orange,
                                () => context.push('/admin/payment-history'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AdminHeaderSection extends StatelessWidget {
  const AdminHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ProfileProvider>(
      builder: (context, authProvider, profileProvider, child) {
        // Try to get user from ProfileProvider first (most up-to-date), then AuthProvider
        final user = profileProvider.user ?? authProvider.currentUser;

        // Use the full URL from the User model
        String? profilePictureUrl = user?.profilePictureUrl;

        // Debug logging for dashboard
        AppLogger.info(
          'Admin Dashboard: Raw profile picture: ${user?.profilePicture}',
          'AdminDashboardScreen',
        );
        AppLogger.info(
          'Admin Dashboard: Constructed URL: $profilePictureUrl',
          'AdminDashboardScreen',
        );

        if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
          final separator = profilePictureUrl.contains('?') ? '&' : '?';
          profilePictureUrl =
              '$profilePictureUrl${separator}t=${DateTime.now().millisecondsSinceEpoch}';
          AppLogger.info(
            'Admin Dashboard: Final URL with cache buster: $profilePictureUrl',
            'AdminDashboardScreen',
          );
        }

        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + 20,
            20,
            30,
          ),
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.menu, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/admin_profile'),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child:
                      profilePictureUrl != null
                          ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: profilePictureUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              cacheManager: ImageCacheManager.instance,
                              placeholder:
                                  (context, url) => Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      color: AppColors.surface,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      color: AppColors.surface,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        user?.initials ?? 'A',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                              fadeInDuration: const Duration(milliseconds: 300),
                              fadeOutDuration: const Duration(
                                milliseconds: 100,
                              ),
                            ),
                          )
                          : Text(
                            user?.initials ?? 'A',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
