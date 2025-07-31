import 'package:flutter/material.dart';

class LoadingPaymentScreen extends StatelessWidget {
  const LoadingPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loading Payment')),
      body: const Center(child: Text('Loading Payment')),
    );
  }
}
