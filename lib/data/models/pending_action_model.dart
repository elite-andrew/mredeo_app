class PendingAction {
  final String id;
  final String
  actionType; // 'payment_due', 'approval_needed', 'emergency_contribution'
  final String? relatedNotificationId;
  final String? beneficiaryUserId;
  final DateTime? dueDate;
  final String priority; // 'high', 'normal', 'low'
  final bool isResolved;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final String? beneficiaryName;
  final String? beneficiaryPhone;
  final String? contributionType;
  final double? expectedAmount;

  PendingAction({
    required this.id,
    required this.actionType,
    this.relatedNotificationId,
    this.beneficiaryUserId,
    this.dueDate,
    required this.priority,
    required this.isResolved,
    this.resolvedAt,
    required this.createdAt,
    this.beneficiaryName,
    this.beneficiaryPhone,
    this.contributionType,
    this.expectedAmount,
  });

  factory PendingAction.fromJson(Map<String, dynamic> json) {
    return PendingAction(
      id: json['id']?.toString() ?? '',
      actionType: json['action_type'] ?? '',
      relatedNotificationId: json['related_notification_id']?.toString(),
      beneficiaryUserId: json['beneficiary_user_id']?.toString(),
      dueDate:
          json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      priority: json['priority'] ?? 'normal',
      isResolved: json['is_resolved'] ?? false,
      resolvedAt:
          json['resolved_at'] != null
              ? DateTime.parse(json['resolved_at'])
              : null,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      beneficiaryName: json['beneficiary_name'],
      beneficiaryPhone: json['beneficiary_phone'],
      contributionType: json['contribution_type'],
      expectedAmount: json['expected_amount']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action_type': actionType,
      'related_notification_id': relatedNotificationId,
      'beneficiary_user_id': beneficiaryUserId,
      'due_date': dueDate?.toIso8601String(),
      'priority': priority,
      'is_resolved': isResolved,
      'resolved_at': resolvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'beneficiary_name': beneficiaryName,
      'beneficiary_phone': beneficiaryPhone,
      'contribution_type': contributionType,
      'expected_amount': expectedAmount,
    };
  }

  // Helper getters
  bool get isHighPriority => priority == 'high';
  bool get isOverdue =>
      dueDate != null && dueDate!.isBefore(DateTime.now()) && !isResolved;
  bool get isDueSoon =>
      dueDate != null &&
      dueDate!.difference(DateTime.now()).inDays <= 3 &&
      dueDate!.isAfter(DateTime.now()) &&
      !isResolved;

  String get statusText {
    if (isResolved) return 'Resolved';
    if (isOverdue) return 'Overdue';
    if (isDueSoon) return 'Due Soon';
    return 'Pending';
  }

  PendingAction copyWith({
    String? id,
    String? actionType,
    String? relatedNotificationId,
    String? beneficiaryUserId,
    DateTime? dueDate,
    String? priority,
    bool? isResolved,
    DateTime? resolvedAt,
    DateTime? createdAt,
    String? beneficiaryName,
    String? beneficiaryPhone,
    String? contributionType,
    double? expectedAmount,
  }) {
    return PendingAction(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      relatedNotificationId:
          relatedNotificationId ?? this.relatedNotificationId,
      beneficiaryUserId: beneficiaryUserId ?? this.beneficiaryUserId,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isResolved: isResolved ?? this.isResolved,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      createdAt: createdAt ?? this.createdAt,
      beneficiaryName: beneficiaryName ?? this.beneficiaryName,
      beneficiaryPhone: beneficiaryPhone ?? this.beneficiaryPhone,
      contributionType: contributionType ?? this.contributionType,
      expectedAmount: expectedAmount ?? this.expectedAmount,
    );
  }
}
