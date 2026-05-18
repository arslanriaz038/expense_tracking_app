import 'package:expense_tracking_app/models/expense.dart';

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// Newest transaction date first; within the same day, newest entry first.
int compareExpensesByDisplayOrder(Expense a, Expense b) {
  final dateCompare =
      _dateOnly(b.date).compareTo(_dateOnly(a.date));
  if (dateCompare != 0) return dateCompare;

  final aCreated = a.createdAt ?? a.date;
  final bCreated = b.createdAt ?? b.date;
  final createdCompare = bCreated.compareTo(aCreated);
  if (createdCompare != 0) return createdCompare;

  return (b.id ?? '').compareTo(a.id ?? '');
}

void sortExpensesByDisplayOrder(List<Expense> expenses) {
  expenses.sort(compareExpensesByDisplayOrder);
}
