import 'package:collection/collection.dart';
import 'package:expense_tracking_app/models/expense.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/utils/expense_date_filter.dart';
import 'package:expense_tracking_app/views/add_expense/cubit/expenses_cubit.dart';
import 'package:expense_tracking_app/views/add_expense/view/add_expense_screen.dart';
import 'package:expense_tracking_app/widgets/expense_item_card.dart';
import 'package:expense_tracking_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  ExpenseDateFilter _selectedFilter = ExpenseDateFilter.all;

  List<Expense> _filteredExpenses(List<Expense> expenses) {
    final now = DateTime.now();
    return expenses
        .where((e) => expenseMatchesDateFilter(e, _selectedFilter, now))
        .toList();
  }

  double? _periodTotal(List<Expense> expenses) {
    var hasAmount = false;
    var total = 0.0;
    for (final expense in expenses) {
      final amount = double.tryParse(expense.amount);
      if (amount != null) {
        hasAmount = true;
        total += amount;
      }
    }
    return hasAmount ? total : null;
  }

  String _sectionHeader(DateTime date, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    if (dateOnly == today) return 'Today';
    if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExpensesCubit()..getAllExpenses(),
      child: BlocConsumer<ExpensesCubit, ExpensesCubitState>(
        listener: (context, state) {
          if (state is ExpenseAddedState) {
            context.read<ExpensesCubit>().getAllExpenses();
          }
        },
        builder: (context, state) {
          final ExpensesCubit cubit = context.read<ExpensesCubit>();
          final filtered = _filteredExpenses(cubit.allExpenses);
          final grouped = groupBy(
            filtered,
            (Expense e) => DateTime(e.date.year, e.date.month, e.date.day),
          );
          final sortedDates = grouped.keys.toList()
            ..sort((a, b) => b.compareTo(a));
          final periodTotal = _periodTotal(filtered);
          final now = DateTime.now();

          return Scaffold(
            appBar: AppBar(
              forceMaterialTransparency: true,
              title: const Text(' Track Expenses'),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: UserProfileAvatar(
                    showOnlineIndicator: false,
                    expensesList: cubit.allExpenses,
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'History',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ExpenseDateFilter.values.map((filter) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(filter.label),
                            selected: _selectedFilter == filter,
                            onSelected: (_) {
                              setState(() => _selectedFilter = filter);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  if (state is! LoadingState && cubit.allExpenses.isNotEmpty)
                    Text(
                      periodTotal != null
                          ? 'Total: ${periodTotal.toStringAsFixed(2)}'
                          : 'Total: —',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: state is LoadingState
                        ? const Center(
                            child: CircularProgressIndicator.adaptive(),
                          )
                        : cubit.allExpenses.isEmpty
                            ? const Center(
                                child: Text('No expenses yet'),
                              )
                            : filtered.isEmpty
                                ? const Center(
                                    child: Text('No expenses for this period'),
                                  )
                                : ListView.builder(
                                    itemCount: sortedDates.length,
                                    itemBuilder: (context, sectionIndex) {
                                      final date = sortedDates[sectionIndex];
                                      final sectionExpenses = grouped[date]!;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8.0,
                                              bottom: 4.0,
                                            ),
                                            child: Text(
                                              _sectionHeader(date, now),
                                              style: const TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          ...sectionExpenses.map(
                                            (expense) => ExpenseItemCard(
                                              expense: expense,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                AppNavigator.push(
                  context,
                  AddExpensePage(
                    cubit: cubit,
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
