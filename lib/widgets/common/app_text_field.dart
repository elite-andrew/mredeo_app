import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;

  const AppTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAFBF0),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.black38),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          if (onToggleVisibility != null)
            TextButton(
              onPressed: onToggleVisibility,
              child: Text(
                obscureText ? 'Show' : 'Hide',
                style: const TextStyle(color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }
}
