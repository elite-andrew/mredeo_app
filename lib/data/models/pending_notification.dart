class PendingNotification {
  final String id;
  final String type;
  final String beneficiaryName;
  final num amount;
  final DateTime issuedAt;
  final String status;

  PendingNotification({
    required this.id,
    required this.type,
    required this.beneficiaryName,
    required this.amount,
    required this.issuedAt,
    required this.status,
  });

  factory PendingNotification.fromJson(Map<String, dynamic> json) {
    return PendingNotification(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      beneficiaryName: json['beneficiaryName'] ?? '',
      amount: json['amount'] ?? 0,
      issuedAt: DateTime.tryParse(json['issuedAt'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? '',
    );
  }
}
