import 'package:expense_tracking_app/models/expense.dart';

enum ExpenseDateFilter {
  all,
  today,
  yesterday,
  lastWeek,
  thisMonth,
  lastMonth,
}

extension ExpenseDateFilterX on ExpenseDateFilter {
  String get label => switch (this) {
        ExpenseDateFilter.all => 'All',
        ExpenseDateFilter.today => 'Today',
        ExpenseDateFilter.yesterday => 'Yesterday',
        ExpenseDateFilter.lastWeek => 'Last week',
        ExpenseDateFilter.thisMonth => 'This month',
        ExpenseDateFilter.lastMonth => 'Last month',
      };
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool expenseMatchesDateFilter(
  Expense expense,
  ExpenseDateFilter filter,
  DateTime now,
) {
  if (filter == ExpenseDateFilter.all) return true;

  final expenseDate = _dateOnly(expense.date);
  final today = _dateOnly(now);

  switch (filter) {
    case ExpenseDateFilter.all:
      return true;
    case ExpenseDateFilter.today:
      return expenseDate == today;
    case ExpenseDateFilter.yesterday:
      final yesterday = today.subtract(const Duration(days: 1));
      return expenseDate == yesterday;
    case ExpenseDateFilter.lastWeek:
      final weekStart = today.subtract(const Duration(days: 6));
      return !expenseDate.isBefore(weekStart) && !expenseDate.isAfter(today);
    case ExpenseDateFilter.thisMonth:
      final monthStart = DateTime(today.year, today.month, 1);
      return !expenseDate.isBefore(monthStart) && !expenseDate.isAfter(today);
    case ExpenseDateFilter.lastMonth:
      final lastMonthStart = DateTime(today.year, today.month - 1, 1);
      final lastMonthEnd = DateTime(today.year, today.month, 0);
      return !expenseDate.isBefore(lastMonthStart) &&
          !expenseDate.isAfter(lastMonthEnd);
  }
}
