import 'package:collection/collection.dart';
import 'package:expense_tracking_app/consts/expense_constants.dart';
import 'package:expense_tracking_app/models/expense.dart';
import 'package:expense_tracking_app/utils/app_alerts.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/utils/expense_date_filter.dart';
import 'package:expense_tracking_app/utils/expense_list_filters.dart';
import 'package:expense_tracking_app/views/add_expense/cubit/expenses_cubit.dart';
import 'package:expense_tracking_app/views/add_expense/view/add_expense_screen.dart';
import 'package:expense_tracking_app/widgets/budget_progress_section.dart';
import 'package:expense_tracking_app/widgets/budget_settings_sheet.dart';
import 'package:expense_tracking_app/widgets/category_breakdown_chart.dart';
import 'package:expense_tracking_app/widgets/expense_item_card.dart';
import 'package:expense_tracking_app/widgets/expense_summary_banner.dart';
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
  ExpenseListFilters _filters = const ExpenseListFilters();
  final _searchController = TextEditingController();

  List<Expense> _thisMonthExpenses(List<Expense> expenses, DateTime now) {
    return expenses
        .where(
          (e) => expenseMatchesDateFilter(
            e,
            ExpenseDateFilter.thisMonth,
            now,
          ),
        )
        .toList();
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExpensesCubit()
        ..startListening()
        ..loadBudget(),
      child: BlocConsumer<ExpensesCubit, ExpensesCubitState>(
        listener: (context, state) {
          if (state is FailedState) {
            AppAlerts.showErrorMessage(
              context,
              state.errorMessage ?? 'Something went wrong',
            );
          } else if (state is ExpenseDeletedState) {
            AppAlerts.showSuccessMessage(context, 'Deleted successfully');
          } else if (state is ExpenseAddedState) {
            AppAlerts.showSuccessMessage(context, 'Saved successfully');
          } else if (state is ExpenseUpdatedState) {
            AppAlerts.showSuccessMessage(context, 'Updated successfully');
          } else if (state is BudgetSavedState) {
            AppAlerts.showSuccessMessage(context, 'Budgets updated');
          }
        },
        builder: (context, state) {
          final cubit = context.read<ExpensesCubit>();
          final now = DateTime.now();
          final filtered = _filters.apply(cubit.allExpenses, now);
          final grouped = groupBy(
            filtered,
            (Expense e) => DateTime(e.date.year, e.date.month, e.date.day),
          );
          final sortedDates = grouped.keys.toList()
            ..sort((a, b) => b.compareTo(a));
          final totals = calculateTotals(filtered);
          final breakdown = categorySpending(filtered);
          final monthExpenses = _thisMonthExpenses(cubit.allExpenses, now);
          final monthSpending = calculateTotals(monthExpenses).expenses;
          final monthCategorySpending = categorySpending(monthExpenses);

          return Scaffold(
            appBar: AppBar(
              forceMaterialTransparency: true,
              title: const Text('Track Expenses'),
              centerTitle: true,
              actions: [
                IconButton(
                  tooltip: 'Budget settings',
                  onPressed: () => showBudgetSettingsSheet(context),
                  icon: const Icon(Icons.savings_outlined),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: UserProfileAvatar(
                    showOnlineIndicator: false,
                    expensesList: cubit.allExpenses,
                  ),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                await cubit.refreshExpenses();
                await cubit.loadBudget();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search description or category',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(
                                          () => _filters = _filters.copyWith(
                                            searchQuery: '',
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.clear),
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              isDense: true,
                            ),
                            onChanged: (value) {
                              setState(
                                () => _filters = _filters.copyWith(
                                  searchQuery: value,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: ExpenseDateFilter.values.map((filter) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(filter.label),
                                    selected: _filters.dateFilter == filter,
                                    onSelected: (_) {
                                      setState(
                                        () => _filters = _filters.copyWith(
                                          dateFilter: filter,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                FilterChip(
                                  label: const Text('All types'),
                                  selected: _filters.typeFilter == null,
                                  onSelected: (_) {
                                    setState(
                                      () => _filters = _filters.copyWith(
                                        clearTypeFilter: true,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                for (final type in ExpenseType.values)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(type.label),
                                      selected: _filters.typeFilter == type,
                                      onSelected: (_) {
                                        setState(
                                          () => _filters = _filters.copyWith(
                                            typeFilter: type,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                FilterChip(
                                  label: const Text('All categories'),
                                  selected: _filters.category == null,
                                  onSelected: (_) {
                                    setState(
                                      () => _filters = _filters.copyWith(
                                        clearCategory: true,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                for (final category in ExpenseCategories.all)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(category),
                                      selected: _filters.category == category,
                                      onSelected: (_) {
                                        setState(
                                          () => _filters = _filters.copyWith(
                                            category: category,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ExpenseSummaryBanner(totals: totals),
                          const SizedBox(height: 12),
                          CategoryBreakdownChart(categoryTotals: breakdown),
                          const SizedBox(height: 12),
                          BudgetProgressSection(
                            budget: cubit.monthlyBudget,
                            monthSpending: monthSpending,
                            categorySpending: monthCategorySpending,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'History',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    if (state is LoadingState && cubit.allExpenses.isEmpty)
                      const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    else if (cubit.allExpenses.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyState(
                          title: 'No transactions yet',
                          message: 'Add your first expense or income to start tracking.',
                          actionLabel: 'Add transaction',
                          onAction: () => _openAddExpense(context, cubit),
                        ),
                      )
                    else if (filtered.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyState(
                          title: 'No matches',
                          message: 'Try changing your search or filters.',
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, sectionIndex) {
                            final date = sortedDates[sectionIndex];
                            final sectionExpenses = grouped[date]!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 4,
                                  ),
                                  child: Text(
                                    _sectionHeader(date, now),
                                    style: const TextStyle(
                                      fontSize: 16,
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
                          childCount: sortedDates.length,
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 88)),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _openAddExpense(context, cubit),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          );
        },
      ),
    );
  }

  void _openAddExpense(BuildContext context, ExpensesCubit cubit) {
    cubit.resetForm();
    AppNavigator.push(
      context,
      AddExpensePage(cubit: cubit),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
