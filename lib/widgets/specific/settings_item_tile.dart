import 'package:flutter/material.dart';

class SettingsItemTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsItemTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: ListTile(
            onTap: onTap,
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2ECC71),
              child: Icon(icon, color: Colors.black),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
        const Divider(
          height: 1,
          thickness: 0.6,
          // No indent or endIndent - end-to-end divider
        ),
      ],
    );
  }
}
