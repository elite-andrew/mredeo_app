class UserContributionStatus {
  final String id;
  final String userId;
  final String notificationId;
  final String contributionTypeId;
  final double requiredAmount;
  final double paidAmount;
  final String paymentStatus; // 'unpaid', 'partial', 'paid', 'overdue'
  final String? lastPaymentId;
  final DateTime? lastPaidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserContributionStatus({
    required this.id,
    required this.userId,
    required this.notificationId,
    required this.contributionTypeId,
    required this.requiredAmount,
    required this.paidAmount,
    required this.paymentStatus,
    this.lastPaymentId,
    this.lastPaidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserContributionStatus.fromJson(Map<String, dynamic> json) {
    return UserContributionStatus(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      notificationId: json['notification_id']?.toString() ?? '',
      contributionTypeId: json['contribution_type_id']?.toString() ?? '',
      requiredAmount: (json['required_amount'] ?? 0.0).toDouble(),
      paidAmount: (json['paid_amount'] ?? 0.0).toDouble(),
      paymentStatus: json['payment_status'] ?? 'unpaid',
      lastPaymentId: json['last_payment_id']?.toString(),
      lastPaidAt:
          json['last_paid_at'] != null
              ? DateTime.parse(json['last_paid_at'])
              : null,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'notification_id': notificationId,
      'contribution_type_id': contributionTypeId,
      'required_amount': requiredAmount,
      'paid_amount': paidAmount,
      'payment_status': paymentStatus,
      'last_payment_id': lastPaymentId,
      'last_paid_at': lastPaidAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  bool get isPaid => paymentStatus == 'paid';
  bool get isUnpaid => paymentStatus == 'unpaid';
  bool get isPartial => paymentStatus == 'partial';
  bool get isOverdue => paymentStatus == 'overdue';

  double get remainingAmount => requiredAmount - paidAmount;
  double get paidPercentage =>
      requiredAmount > 0 ? (paidAmount / requiredAmount) * 100 : 0;

  UserContributionStatus copyWith({
    String? id,
    String? userId,
    String? notificationId,
    String? contributionTypeId,
    double? requiredAmount,
    double? paidAmount,
    String? paymentStatus,
    String? lastPaymentId,
    DateTime? lastPaidAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserContributionStatus(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      notificationId: notificationId ?? this.notificationId,
      contributionTypeId: contributionTypeId ?? this.contributionTypeId,
      requiredAmount: requiredAmount ?? this.requiredAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      lastPaymentId: lastPaymentId ?? this.lastPaymentId,
      lastPaidAt: lastPaidAt ?? this.lastPaidAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
