class ExpenseCategories {
  ExpenseCategories._();

  static const defaults = [
    'Grocery',
    'Transportation',
    'Entertainment',
    'Bills',
    'Health',
    'Other',
  ];

  static const other = 'Other';

  /// Merges defaults, user custom categories, and any categories used on expenses.
  static List<String> resolve({
    required List<String> customCategories,
    List<String> expenseCategories = const [],
  }) {
    final merged = <String>{
      ...defaults,
      ...customCategories,
      ...expenseCategories,
    };

    final sorted = merged.toList()..sort((a, b) => a.compareTo(b));

    if (sorted.contains(other)) {
      sorted.remove(other);
      sorted.sort();
      sorted.add(other);
    }

    return sorted;
  }

  static String? normalizeName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }

  static String? validateNewCategory(
    String name, {
    required List<String> existingCategories,
  }) {
    final normalized = normalizeName(name);
    if (normalized == null) return 'Category name is required';
    if (normalized.length > 30) return 'Max 30 characters';
    final lower = normalized.toLowerCase();
    if (existingCategories.any((c) => c.toLowerCase() == lower)) {
      return 'Category already exists';
    }
    return null;
  }

  static bool isDefault(String category) =>
      defaults.any((d) => d.toLowerCase() == category.toLowerCase());
}

enum ExpenseType {
  expense,
  income;

  String get label => switch (this) {
        ExpenseType.expense => 'Expense',
        ExpenseType.income => 'Income',
      };

  String get firestoreValue => name;

  static ExpenseType fromFirestore(String? value) {
    return ExpenseType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => ExpenseType.expense,
    );
  }
}
