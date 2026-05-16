import 'package:expense_tracking_app/utils/expense_date_filter.dart';
import 'package:expense_tracking_app/utils/expense_list_filters.dart';
import 'package:expense_tracking_app/views/add_expense/cubit/expenses_cubit.dart';
import 'package:expense_tracking_app/widgets/budget_progress_section.dart';
import 'package:expense_tracking_app/widgets/budget_settings_sheet.dart';
import 'package:expense_tracking_app/widgets/category_breakdown_chart.dart';
import 'package:expense_tracking_app/widgets/expense_summary_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InsightsTab extends StatelessWidget {
  const InsightsTab({
    super.key,
    required this.onRefresh,
  });

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpensesCubit, ExpensesCubitState>(
      builder: (context, state) {
        final cubit = context.read<ExpensesCubit>();
        final now = DateTime.now();
        final monthExpenses = cubit.allExpenses
            .where(
              (e) => expenseMatchesDateFilter(
                e,
                ExpenseDateFilter.thisMonth,
                now,
              ),
            )
            .toList();
        final totals = calculateTotals(monthExpenses);
        final breakdown = categorySpending(monthExpenses);
        final monthSpending = totals.expenses;
        final monthCategorySpending = breakdown;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Insights'),
            centerTitle: false,
            actions: [
              IconButton(
                tooltip: 'Edit budgets',
                onPressed: () => showBudgetSettingsSheet(context),
                icon: const Icon(Icons.savings_outlined),
              ),
            ],
          ),
          body: state is LoadingState && cubit.allExpenses.isEmpty
              ? const Center(child: CircularProgressIndicator.adaptive())
              : RefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    children: [
                      Text(
                        'This month',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ExpenseSummaryBanner(totals: totals),
                      const SizedBox(height: 16),
                      CategoryBreakdownChart(categoryTotals: breakdown),
                      const SizedBox(height: 16),
                      BudgetProgressSection(
                        budget: cubit.monthlyBudget,
                        monthSpending: monthSpending,
                        categorySpending: monthCategorySpending,
                      ),
                      if (!cubit.monthlyBudget.hasAnyLimit)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.savings_outlined),
                            title: const Text('Set monthly budgets'),
                            subtitle: const Text(
                              'Track spending limits by category or overall.',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => showBudgetSettingsSheet(context),
                          ),
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
