enum PaymentStatus { pending, success, failed, cancelled }

enum TelcoProvider { vodacom, tigo, airtel, halotel, zantel, other }

class Payment {
  final String id;
  final String userId;
  final String contributionTypeId;
  final double amountPaid;
  final TelcoProvider telco;
  final String phoneNumberUsed;
  final String transactionReference;
  final PaymentStatus paymentStatus;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ContributionType? contributionType;

  Payment({
    required this.id,
    required this.userId,
    required this.contributionTypeId,
    required this.amountPaid,
    required this.telco,
    required this.phoneNumberUsed,
    required this.transactionReference,
    required this.paymentStatus,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
    this.contributionType,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      contributionTypeId: json['contribution_type_id'] ?? '',
      amountPaid: (json['amount_paid'] ?? 0.0).toDouble(),
      telco: TelcoProvider.values.firstWhere(
        (e) => e.name == json['telco'],
        orElse: () => TelcoProvider.other,
      ),
      phoneNumberUsed: json['phone_number_used'] ?? '',
      transactionReference: json['transaction_reference'] ?? '',
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['payment_status'],
        orElse: () => PaymentStatus.pending,
      ),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      contributionType:
          json['contribution_type'] != null
              ? ContributionType.fromJson(json['contribution_type'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'contribution_type_id': contributionTypeId,
      'amount_paid': amountPaid,
      'telco': telco.name,
      'phone_number_used': phoneNumberUsed,
      'transaction_reference': transactionReference,
      'payment_status': paymentStatus.name,
      'paid_at': paidAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (contributionType != null)
        'contribution_type': contributionType!.toJson(),
    };
  }

  String get formattedAmount =>
      'TZS ${amountPaid.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';

  bool get isPaid => paymentStatus == PaymentStatus.success;
  bool get isPending => paymentStatus == PaymentStatus.pending;
  bool get isFailed => paymentStatus == PaymentStatus.failed;
}

class ContributionType {
  final String id;
  final String name;
  final double amount;
  final String? description;
  final bool isActive;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContributionType({
    required this.id,
    required this.name,
    required this.amount,
    this.description,
    required this.isActive,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContributionType.fromJson(Map<String, dynamic> json) {
    return ContributionType(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      description: json['description'],
      isActive: json['is_active'] ?? true,
      createdBy: json['created_by'],
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
      'name': name,
      'amount': amount,
      'description': description,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedAmount =>
      'TZS ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
}

class PaymentRequest {
  final String contributionTypeId;
  final double amount;
  final TelcoProvider telco;
  final String phoneNumber;

  PaymentRequest({
    required this.contributionTypeId,
    required this.amount,
    required this.telco,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'contribution_type_id': contributionTypeId,
      'amount_paid': amount,
      'telco': telco.name,
      'phone_number_used': phoneNumber,
    };
  }
}

class IssuedPayment {
  final String id;
  final String issuedBy;
  final String issuedTo;
  final String memberName;
  final String memberPhone;
  final double amount;
  final String purpose;
  final String type;
  final String description;
  final String transactionReference;
  final DateTime issuedAt;
  final DateTime createdAt;

  IssuedPayment({
    required this.id,
    required this.issuedBy,
    required this.issuedTo,
    required this.memberName,
    required this.memberPhone,
    required this.amount,
    required this.purpose,
    required this.type,
    required this.description,
    required this.transactionReference,
    required this.issuedAt,
    required this.createdAt,
  });

  factory IssuedPayment.fromJson(Map<String, dynamic> json) {
    return IssuedPayment(
      id: json['id'] ?? '',
      issuedBy: json['issued_by'] ?? '',
      issuedTo: json['issued_to'] ?? '',
      memberName: json['member_name'] ?? json['issued_to_name'] ?? 'Unknown',
      memberPhone: json['member_phone'] ?? json['issued_to_phone'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      purpose: json['purpose'] ?? '',
      type: json['type'] ?? json['contribution_type'] ?? 'Other',
      description: json['description'] ?? json['purpose'] ?? '',
      transactionReference: json['transaction_reference'] ?? '',
      issuedAt: DateTime.parse(
        json['issued_at'] ?? DateTime.now().toIso8601String(),
      ),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'issued_by': issuedBy,
      'issued_to': issuedTo,
      'member_name': memberName,
      'member_phone': memberPhone,
      'amount': amount,
      'purpose': purpose,
      'type': type,
      'description': description,
      'transaction_reference': transactionReference,
      'issued_at': issuedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get formattedAmount =>
      'TZS ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
}
