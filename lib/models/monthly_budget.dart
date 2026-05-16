class MonthlyBudget {
  const MonthlyBudget({
    this.overallLimit,
    this.categoryLimits = const {},
  });

  final double? overallLimit;
  final Map<String, double> categoryLimits;

  factory MonthlyBudget.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const MonthlyBudget();

    final rawCategories = data['categoryLimits'];
    final categoryLimits = <String, double>{};
    if (rawCategories is Map) {
      rawCategories.forEach((key, value) {
        final parsed = _toDouble(value);
        if (parsed != null) {
          categoryLimits[key.toString()] = parsed;
        }
      });
    }

    return MonthlyBudget(
      overallLimit: _toDouble(data['overallLimit']),
      categoryLimits: categoryLimits,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (overallLimit != null) 'overallLimit': overallLimit,
      if (categoryLimits.isNotEmpty) 'categoryLimits': categoryLimits,
    };
  }

  MonthlyBudget copyWith({
    double? overallLimit,
    Map<String, double>? categoryLimits,
    bool clearOverall = false,
  }) {
    return MonthlyBudget(
      overallLimit: clearOverall ? null : (overallLimit ?? this.overallLimit),
      categoryLimits: categoryLimits ?? this.categoryLimits,
    );
  }

  bool get hasAnyLimit =>
      (overallLimit != null && overallLimit! > 0) || categoryLimits.isNotEmpty;

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
