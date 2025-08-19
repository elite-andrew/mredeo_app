class AppNotification {
  final String id;
  final String? senderId;
  final String title;
  final String message;
  final String
  notificationType; // 'general', 'contribution_request', 'payment_reminder'
  final String? contributionTypeId;
  final DateTime? dueDate;
  final bool isActive;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;
  final String? beneficiaryUserId; // For emergency contributions
  final Map<String, dynamic>? emergencyDetails;

  AppNotification({
    required this.id,
    this.senderId,
    required this.title,
    required this.message,
    required this.notificationType,
    this.contributionTypeId,
    this.dueDate,
    required this.isActive,
    required this.createdAt,
    required this.isRead,
    this.readAt,
    this.beneficiaryUserId,
    this.emergencyDetails,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      senderId: json['sender_id']?.toString(),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      notificationType: json['notification_type'] ?? 'general',
      contributionTypeId: json['contribution_type_id']?.toString(),
      dueDate:
          json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      beneficiaryUserId: json['beneficiary_user_id']?.toString(),
      emergencyDetails:
          json['emergency_details'] != null
              ? Map<String, dynamic>.from(json['emergency_details'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'title': title,
      'message': message,
      'notification_type': notificationType,
      'contribution_type_id': contributionTypeId,
      'due_date': dueDate?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'beneficiary_user_id': beneficiaryUserId,
      'emergency_details': emergencyDetails,
    };
  }

  AppNotification copyWith({
    String? id,
    String? senderId,
    String? title,
    String? message,
    String? notificationType,
    String? contributionTypeId,
    DateTime? dueDate,
    bool? isActive,
    DateTime? createdAt,
    bool? isRead,
    DateTime? readAt,
    String? beneficiaryUserId,
    Map<String, dynamic>? emergencyDetails,
  }) {
    return AppNotification(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      title: title ?? this.title,
      message: message ?? this.message,
      notificationType: notificationType ?? this.notificationType,
      contributionTypeId: contributionTypeId ?? this.contributionTypeId,
      dueDate: dueDate ?? this.dueDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      beneficiaryUserId: beneficiaryUserId ?? this.beneficiaryUserId,
      emergencyDetails: emergencyDetails ?? this.emergencyDetails,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
