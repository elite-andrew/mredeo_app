import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redeo_app/core/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Color textColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 16,
        16,
        16,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go(
                  '/dashboard',
                ); // Change this to your desired fallback route
              }
            },
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(width: 48), // To balance the row
        ],
      ),
    );
  }
}
