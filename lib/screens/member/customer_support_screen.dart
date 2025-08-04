import 'package:flutter/material.dart';
import 'package:redeo_app/widgets/common/custom_app_bar.dart';

class CustomerSupportScreen extends StatelessWidget {
  const CustomerSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: Column(
        children: [
          const CustomAppBar(title: 'Customer Support'),
          const Expanded(child: Center(child: Text('Customer Support'))),
        ],
      ),
    );
  }
}
