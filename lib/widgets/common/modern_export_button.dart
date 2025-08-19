import 'package:flutter/material.dart';
import 'package:mredeo_app/core/theme/app_colors.dart';

class ModernExportButton extends StatelessWidget {
  final Function(String) onExport;
  final List<ExportOption> exportOptions;

  const ModernExportButton({
    super.key,
    required this.onExport,
    this.exportOptions = const [
      ExportOption(
        value: 'pdf',
        label: 'Export as PDF',
        icon: Icons.picture_as_pdf,
        color: Colors.red,
      ),
      ExportOption(
        value: 'excel',
        label: 'Export as Excel',
        icon: Icons.table_chart,
        color: Colors.green,
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.file_download, color: Colors.white, size: 24),
      ),
      onSelected: onExport,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.surface,
      itemBuilder:
          (context) =>
              exportOptions.map((option) {
                return PopupMenuItem(
                  value: option.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(option.icon, color: option.color, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          option.label,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
    );
  }
}

class ExportOption {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const ExportOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}
