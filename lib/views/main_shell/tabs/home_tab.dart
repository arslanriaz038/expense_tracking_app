import 'package:expense_tracking_app/models/expense.dart';
import 'package:expense_tracking_app/utils/expense_date_filter.dart';
import 'package:expense_tracking_app/utils/expense_list_filters.dart';
import 'package:expense_tracking_app/utils/my_pref.dart';
import 'package:expense_tracking_app/views/add_expense/cubit/expenses_cubit.dart';
import 'package:expense_tracking_app/widgets/budget_progress_section.dart';
import 'package:expense_tracking_app/widgets/expense_item_card.dart';
import 'package:expense_tracking_app/widgets/expense_summary_banner.dart';
import 'package:expense_tracking_app/widgets/transaction_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.onViewAllActivity,
    required this.onAddTransaction,
    required this.onOpenInsights,
  });

  final void Function({ExpenseListFilters? filters}) onViewAllActivity;
  final VoidCallback onAddTransaction;
  final VoidCallback onOpenInsights;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  ExpenseDateFilter _period = ExpenseDateFilter.thisMonth;

  List<Expense> _periodExpenses(List<Expense> all, DateTime now) {
    return all.where((e) => expenseMatchesDateFilter(e, _period, now)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpensesCubit, ExpensesCubitState>(
      builder: (context, state) {
        final cubit = context.read<ExpensesCubit>();
        final now = DateTime.now();
        final periodExpenses = _periodExpenses(cubit.allExpenses, now);
        final totals = calculateTotals(periodExpenses);
        final recentFive = periodExpenses.take(5).toList();
        final monthExpenses = cubit.allExpenses
            .where(
              (e) => expenseMatchesDateFilter(
                e,
                ExpenseDateFilter.thisMonth,
                now,
              ),
            )
            .toList();
        final monthSpending = calculateTotals(monthExpenses).expenses;
        final monthCategorySpending = categorySpending(monthExpenses);

        return Scaffold(
          body: state is LoadingState && cubit.allExpenses.isEmpty
              ? const Center(child: CircularProgressIndicator.adaptive())
              : RefreshIndicator(
                  onRefresh: () async {
                    await cubit.refreshExpenses();
                    await cubit.loadBudget();
                    await cubit.loadCategories();
                  },
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      MediaQuery.paddingOf(context).top + 8,
                      16,
                      100,
                    ),
                    children: [
                      Text(
                        'Hello, ${MyPref.readUserInfo()?.name ?? 'there'}',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Here is your spending overview',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ExpenseDateFilter.thisMonth,
                            ExpenseDateFilter.today,
                            ExpenseDateFilter.lastWeek,
                          ].map((filter) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(filter.label),
                                selected: _period == filter,
                                onSelected: (_) {
                                  setState(() => _period = filter);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ExpenseSummaryBanner(totals: totals),
                      if (cubit.monthlyBudget.hasAnyLimit) ...[
                        const SizedBox(height: 12),
                        BudgetProgressSection(
                          budget: cubit.monthlyBudget,
                          monthSpending: monthSpending,
                          categorySpending: monthCategorySpending,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: widget.onOpenInsights,
                            child: const Text('Full insights'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (periodExpenses.isNotEmpty)
                            TextButton(
                              onPressed: () => widget.onViewAllActivity(
                                filters:
                                    ExpenseListFilters(dateFilter: _period),
                              ),
                              child: const Text('View all'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (cubit.allExpenses.isEmpty)
                        TransactionEmptyState(
                          title: 'No transactions yet',
                          message:
                              'Add your first expense or income to start tracking.',
                          actionLabel: 'Add transaction',
                          onAction: widget.onAddTransaction,
                        )
                      else if (recentFive.isEmpty)
                        const TransactionEmptyState(
                          title: 'Nothing this period',
                          message:
                              'Try a different time range or add a transaction.',
                        )
                      else
                        ...recentFive.map(
                          (expense) => ExpenseItemCard(expense: expense),
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
