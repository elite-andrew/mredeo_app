import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mredeo_app/core/theme/app_colors.dart';
import 'package:mredeo_app/widgets/admin/admin_drawer.dart';
import 'package:mredeo_app/providers/admin_provider.dart';
import 'package:mredeo_app/data/models/payment_model.dart';

class IssuedPaymentHistoryScreen extends StatefulWidget {
  const IssuedPaymentHistoryScreen({super.key});

  @override
  State<IssuedPaymentHistoryScreen> createState() =>
      _IssuedPaymentHistoryScreenState();
}

class _IssuedPaymentHistoryScreenState
    extends State<IssuedPaymentHistoryScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedType = 'All';
  String _sortBy = 'Date';
  bool _sortAscending = false;
  String _searchQuery = '';

  final List<String> _contributionTypes = [
    'All',
    'Monthly Contribution',
    'Emergency Fund',
    'Project Fund',
    'Welfare',
  ];
  final List<String> _sortOptions = ['Date', 'Amount', 'Name', 'Type'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPaymentHistory();
    });
  }

  Future<void> _loadPaymentHistory() async {
    try {
      await context.read<AdminProvider>().loadIssuedPayments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading payment history: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          _startDate != null && _endDate != null
              ? DateTimeRange(start: _startDate!, end: _endDate!)
              : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.light,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadPaymentHistory();
    }
  }

  void _clearDateRange() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _loadPaymentHistory();
  }

  Future<void> _exportData(String format) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              content: Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  Text('Exporting to ${format.toUpperCase()}...'),
                ],
              ),
            ),
      );

      // TODO: Implement actual export with backend API
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Export feature will be implemented with backend API for ${format.toUpperCase()} format.',
            ),
            backgroundColor: AppColors.primary,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  List<IssuedPayment> _getFilteredPayments(List<IssuedPayment> payments) {
    List<IssuedPayment> filtered = payments;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (payment) =>
                    payment.memberName.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    payment.description.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    // Filter by date range
    if (_startDate != null && _endDate != null) {
      filtered =
          filtered
              .where(
                (payment) =>
                    payment.createdAt.isAfter(
                      _startDate!.subtract(const Duration(days: 1)),
                    ) &&
                    payment.createdAt.isBefore(
                      _endDate!.add(const Duration(days: 1)),
                    ),
              )
              .toList();
    }

    // Filter by type
    if (_selectedType != 'All') {
      filtered =
          filtered.where((payment) => payment.type == _selectedType).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'Date':
        filtered.sort(
          (a, b) =>
              _sortAscending
                  ? a.createdAt.compareTo(b.createdAt)
                  : b.createdAt.compareTo(a.createdAt),
        );
        break;
      case 'Amount':
        filtered.sort(
          (a, b) =>
              _sortAscending
                  ? a.amount.compareTo(b.amount)
                  : b.amount.compareTo(a.amount),
        );
        break;
      case 'Name':
        filtered.sort(
          (a, b) =>
              _sortAscending
                  ? a.memberName.compareTo(b.memberName)
                  : b.memberName.compareTo(a.memberName),
        );
        break;
      case 'Type':
        filtered.sort(
          (a, b) =>
              _sortAscending
                  ? a.type.compareTo(b.type)
                  : b.type.compareTo(a.type),
        );
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text('Issued Payment History'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.file_download, color: Colors.white),
            onSelected: _exportData,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'pdf',
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Export as PDF'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'excel',
                    child: Row(
                      children: [
                        Icon(Icons.table_chart, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Export as Excel'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          final filteredPayments = _getFilteredPayments(
            adminProvider.issuedPayments,
          );

          return Column(
            children: [
              // Filters Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      onChanged:
                          (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search by name or description...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Filter Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Date Range Picker
                          _buildFilterChip(
                            label:
                                _startDate != null && _endDate != null
                                    ? '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}'
                                    : 'Select Date Range',
                            icon: Icons.date_range,
                            onTap: _selectDateRange,
                            isSelected: _startDate != null && _endDate != null,
                            onClear:
                                _startDate != null ? _clearDateRange : null,
                          ),

                          const SizedBox(width: 8),

                          // Type Filter
                          _buildDropdownChip(
                            label: 'Type: $_selectedType',
                            icon: Icons.category,
                            value: _selectedType,
                            items: _contributionTypes,
                            onChanged:
                                (value) =>
                                    setState(() => _selectedType = value!),
                          ),

                          const SizedBox(width: 8),

                          // Sort Filter
                          _buildDropdownChip(
                            label: 'Sort: $_sortBy',
                            icon:
                                _sortAscending
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                            value: _sortBy,
                            items: _sortOptions,
                            onChanged:
                                (value) => setState(() => _sortBy = value!),
                            onIconTap:
                                () => setState(
                                  () => _sortAscending = !_sortAscending,
                                ),
                          ),
                        ],
                      ),
                    ),

                    // Results Count
                    if (filteredPayments.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${filteredPayments.length} payment${filteredPayments.length != 1 ? 's' : ''} found',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Table Section
              Expanded(
                child:
                    adminProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : filteredPayments.isEmpty
                        ? _buildEmptyState()
                        : _buildDataTable(filteredPayments),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isSelected = false,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withAlpha(26)
                  : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primary : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            if (onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 14, color: AppColors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownChip({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    VoidCallback? onIconTap,
  }) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      itemBuilder:
          (context) =>
              items
                  .map((item) => PopupMenuItem(value: item, child: Text(item)))
                  .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onIconTap,
              child: Icon(icon, size: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No payment history found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or date range',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<IssuedPayment> payments) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
          border: TableBorder.all(
            color: Colors.grey.shade200,
            width: 1,
            borderRadius: BorderRadius.circular(12),
          ),
          columns: [
            const DataColumn(
              label: Text('No', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const DataColumn(
              label: Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const DataColumn(
              label: Text(
                'Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const DataColumn(
              label: Text(
                'Amount',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const DataColumn(
              label: Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows:
              payments.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final payment = entry.value;

                return DataRow(
                  cells: [
                    DataCell(Text('$index.')),
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            payment.memberName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          if (payment.description.isNotEmpty)
                            Text(
                              payment.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getTypeColor(payment.type).withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          payment.type,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getTypeColor(payment.type),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '\$${payment.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatDate(payment.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Monthly Contribution':
        return AppColors.primary;
      case 'Emergency Fund':
        return Colors.red;
      case 'Project Fund':
        return Colors.orange;
      case 'Welfare':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
