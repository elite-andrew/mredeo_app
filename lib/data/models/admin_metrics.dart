class AdminMetrics {
  final num yearlyTotal;
  final num monthlyTotal;
  final num condolencesTotal;
  final num farewellTotal;

  AdminMetrics({
    required this.yearlyTotal,
    required this.monthlyTotal,
    required this.condolencesTotal,
    required this.farewellTotal,
  });

  factory AdminMetrics.fromJson(Map<String, dynamic> json) {
    return AdminMetrics(
      yearlyTotal: json['yearlyTotal'] ?? 0,
      monthlyTotal: json['monthlyTotal'] ?? 0,
      condolencesTotal: json['condolencesTotal'] ?? 0,
      farewellTotal: json['farewellTotal'] ?? 0,
    );
  }
}
