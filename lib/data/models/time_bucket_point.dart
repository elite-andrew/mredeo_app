class TimeBucketPoint {
  final String periodLabel; // e.g. "1", "2", "2025"
  final num total;

  TimeBucketPoint({required this.periodLabel, required this.total});

  factory TimeBucketPoint.fromJson(Map<String, dynamic> json) {
    return TimeBucketPoint(
      periodLabel: json['periodLabel'].toString(),
      total: json['total'] ?? 0,
    );
  }
}
