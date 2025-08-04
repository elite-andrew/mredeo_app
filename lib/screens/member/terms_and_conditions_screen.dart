import 'package:flutter/material.dart';
import 'package:redeo_app/core/theme/app_colors.dart';
import 'package:redeo_app/widgets/common/custom_app_bar.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomAppBar(title: 'Terms and Conditions'),
          // Placeholder until content is loaded
          const Expanded(
            child: Center(
              child: Text(
                'Coming soon...',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
