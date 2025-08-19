import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mredeo_app/core/core.dart' as app_core;
import 'package:mredeo_app/widgets/widgets.dart';
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
            backgroundColor: app_core.AppColors.error,
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
              seedColor: app_core.AppColors.primary,
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
            backgroundColor: app_core.AppColors.primary,
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
            backgroundColor: app_core.AppColors.error,
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
      backgroundColor: app_core.AppColors.background,
      drawer: const AdminDrawer(),
      body: Column(
        children: [
          // Modern Header Section
          ModernHeader(
            title: 'Payment History',
            subtitle: 'View all issued payments',
            actions: [ModernExportButton(onExport: _exportData)],
          ),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                final filteredPayments = _getFilteredPayments(
                  adminProvider.issuedPayments,
                );

                return Column(
                  children: [
                    // Modern Filters Section
                    ModernFiltersSection(
                      searchQuery: _searchQuery,
                      onSearchChanged:
                          (value) => setState(() => _searchQuery = value),
                      filterChips: [
                        ModernFilterChip(
                          label:
                              _selectedType == 'All'
                                  ? 'All Types'
                                  : _selectedType,
                          icon: Icons.category,
                          isSelected: _selectedType != 'All',
                          onTap: () => _showTypeFilterDialog(),
                          onClear:
                              _selectedType != 'All'
                                  ? () => setState(() => _selectedType = 'All')
                                  : null,
                        ),
                        ModernFilterChip(
                          label:
                              _startDate != null && _endDate != null
                                  ? '${app_core.DateUtils.formatDate(_startDate!)} - ${app_core.DateUtils.formatDate(_endDate!)}'
                                  : 'Date Range',
                          icon: Icons.date_range,
                          isSelected: _startDate != null && _endDate != null,
                          onTap: _selectDateRange,
                          onClear:
                              _startDate != null && _endDate != null
                                  ? _clearDateRange
                                  : null,
                        ),
                        ModernFilterChip(
                          label: 'Sort: $_sortBy ${_sortAscending ? '↑' : '↓'}',
                          icon: Icons.sort,
                          isSelected: true,
                          onTap: () => _showSortDialog(),
                        ),
                      ],
                    ),

                    // Payment List
                    Expanded(
                      child:
                          filteredPayments.isEmpty
                              ? const ModernEmptyState(
                                icon: Icons.receipt_long_outlined,
                                title: 'No Payment History Found',
                                subtitle:
                                    'Try adjusting your filters or date range',
                              )
                              : Container(
                                margin: const EdgeInsets.fromLTRB(
                                  24,
                                  6,
                                  24,
                                  24,
                                ),
                                child: ListView.builder(
                                  itemCount: filteredPayments.length,
                                  itemBuilder: (context, index) {
                                    final payment = filteredPayments[index];
                                    return ModernPaymentCard(payment: payment);
                                  },
                                ),
                              ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTypeFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => ModernFilterDialog(
            title: 'Filter by Type',
            options: _contributionTypes,
            selectedValue: _selectedType,
            onSelected: (value) => setState(() => _selectedType = value),
          ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder:
          (context) => ModernSortDialog(
            sortOptions: _sortOptions,
            selectedSort: _sortBy,
            isAscending: _sortAscending,
            onSortChanged: (value) => setState(() => _sortBy = value),
            onOrderChanged: (value) => setState(() => _sortAscending = value),
          ),
    );
  }
}
