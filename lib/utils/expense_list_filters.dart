import 'package:expense_tracking_app/consts/expense_constants.dart';
import 'package:expense_tracking_app/models/expense.dart';
import 'package:expense_tracking_app/utils/expense_date_filter.dart';

class ExpenseListFilters {
  const ExpenseListFilters({
    this.dateFilter = ExpenseDateFilter.all,
    this.category,
    this.searchQuery = '',
    this.typeFilter,
  });

  final ExpenseDateFilter dateFilter;
  final String? category;
  final String searchQuery;
  final ExpenseType? typeFilter;

  ExpenseListFilters copyWith({
    ExpenseDateFilter? dateFilter,
    String? category,
    String? searchQuery,
    ExpenseType? typeFilter,
    bool clearCategory = false,
    bool clearTypeFilter = false,
  }) {
    return ExpenseListFilters(
      dateFilter: dateFilter ?? this.dateFilter,
      category: clearCategory ? null : (category ?? this.category),
      searchQuery: searchQuery ?? this.searchQuery,
      typeFilter:
          clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
    );
  }

  List<Expense> apply(List<Expense> expenses, DateTime now) {
    final query = searchQuery.trim().toLowerCase();

    return expenses.where((expense) {
      if (!expenseMatchesDateFilter(expense, dateFilter, now)) {
        return false;
      }
      if (category != null && expense.category != category) {
        return false;
      }
      if (typeFilter != null && expense.type != typeFilter) {
        return false;
      }
      if (query.isNotEmpty &&
          !expense.description.toLowerCase().contains(query) &&
          !expense.category.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();
  }
}

class ExpenseTotals {
  const ExpenseTotals({
    this.income = 0,
    this.expenses = 0,
  });

  final double income;
  final double expenses;

  double get net => income - expenses;

  bool get hasData => income > 0 || expenses > 0;
}

ExpenseTotals calculateTotals(List<Expense> expenses) {
  var income = 0.0;
  var spending = 0.0;

  for (final expense in expenses) {
    final amount = expense.amountValue;
    if (amount == null) continue;
    if (expense.type == ExpenseType.income) {
      income += amount;
    } else {
      spending += amount;
    }
  }

  return ExpenseTotals(income: income, expenses: spending);
}

Map<String, double> categorySpending(List<Expense> expenses) {
  final totals = <String, double>{};

  for (final expense in expenses) {
    if (expense.type != ExpenseType.expense) continue;
    final amount = expense.amountValue;
    if (amount == null) continue;
    totals[expense.category] = (totals[expense.category] ?? 0) + amount;
  }

  return totals;
}
