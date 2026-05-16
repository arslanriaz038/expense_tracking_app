class ExpenseCategories {
  ExpenseCategories._();

  static const all = [
    'Grocery',
    'Transportation',
    'Entertainment',
    'Bills',
    'Health',
    'Other',
  ];
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
