import 'package:collection/collection.dart';
import 'package:expense_tracking_app/consts/expense_constants.dart';
import 'package:expense_tracking_app/models/expense.dart';
import 'package:expense_tracking_app/utils/expense_date_filter.dart';
import 'package:expense_tracking_app/utils/expense_list_filters.dart';
import 'package:expense_tracking_app/utils/expense_sort.dart';
import 'package:expense_tracking_app/views/add_expense/cubit/expenses_cubit.dart';
import 'package:expense_tracking_app/widgets/activity_filters_sheet.dart';
import 'package:expense_tracking_app/widgets/expense_item_card.dart';
import 'package:expense_tracking_app/widgets/transaction_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ActivityTab extends StatefulWidget {
  const ActivityTab({
    super.key,
    required this.onAddTransaction,
    required this.onRefresh,
  });

  final VoidCallback onAddTransaction;
  final Future<void> Function() onRefresh;

  @override
  State<ActivityTab> createState() => ActivityTabState();
}

class ActivityTabState extends State<ActivityTab> {
  ExpenseListFilters _filters = const ExpenseListFilters();
  final _searchController = TextEditingController();

  void applyFilters(ExpenseListFilters filters) {
    setState(() {
      _filters = filters;
      _searchController.text = filters.searchQuery;
    });
  }

  Future<void> _openFiltersSheet(BuildContext context) async {
    final cubit = context.read<ExpensesCubit>();
    final result = await showActivityFiltersSheet(
      context: context,
      initialFilters: _filters,
      categories: cubit.allCategories,
    );
    if (result != null && mounted) {
      applyFilters(
        result.copyWith(searchQuery: _searchController.text),
      );
    }
  }

  void _toggleThisMonth() {
    setState(() {
      _filters = _filters.copyWith(
        dateFilter: _filters.dateFilter == ExpenseDateFilter.thisMonth
            ? ExpenseDateFilter.all
            : ExpenseDateFilter.thisMonth,
      );
    });
  }

  void _toggleType(ExpenseType type) {
    setState(() {
      if (_filters.typeFilter == type) {
        _filters = _filters.copyWith(clearTypeFilter: true);
      } else {
        _filters = _filters.copyWith(typeFilter: type);
      }
    });
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
    return BlocBuilder<ExpensesCubit, ExpensesCubitState>(
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
        final activeTags = _filters.activeTags();
        final filterCount = _filters.activeFilterCount;

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      MediaQuery.paddingOf(context).top + 8,
                      16,
                      8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search description or category',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _ActivitySearchSuffix(
                              showClear: _searchController.text.isNotEmpty,
                              filterCount: filterCount,
                              onClearSearch: () {
                                _searchController.clear();
                                setState(
                                  () => _filters = _filters.copyWith(
                                    searchQuery: '',
                                  ),
                                );
                              },
                              onOpenFilters: () => _openFiltersSheet(context),
                            ),
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
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('This month'),
                                selected: _filters.dateFilter ==
                                    ExpenseDateFilter.thisMonth,
                                onSelected: (_) => _toggleThisMonth(),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Expenses'),
                                selected:
                                    _filters.typeFilter == ExpenseType.expense,
                                onSelected: (_) =>
                                    _toggleType(ExpenseType.expense),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Income'),
                                selected:
                                    _filters.typeFilter == ExpenseType.income,
                                onSelected: (_) =>
                                    _toggleType(ExpenseType.income),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('More filters'),
                                selected: _filters.hasAdvancedFilters,
                                avatar: _filters.hasAdvancedFilters
                                    ? Icon(
                                        Icons.tune,
                                        size: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      )
                                    : const Icon(Icons.tune, size: 18),
                                onSelected: (_) => _openFiltersSheet(context),
                              ),
                            ],
                          ),
                        ),
                        if (activeTags.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: activeTags.map((tag) {
                                    return InputChip(
                                      label: Text(tag.label),
                                      onDeleted: () {
                                        setState(
                                          () => _filters =
                                              tag.applyRemove(_filters),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(
                                    () => _filters = _filters.clearFilters(),
                                  );
                                },
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                      ],
                    ),
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
                    child: TransactionEmptyState(
                      title: 'No transactions yet',
                      message:
                          'Add your first expense or income to start tracking.',
                      actionLabel: 'Add transaction',
                      onAction: widget.onAddTransaction,
                    ),
                  )
                else if (filtered.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: TransactionEmptyState(
                      title: 'No matches',
                      message: 'Try changing your search or filters.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, sectionIndex) {
                          final date = sortedDates[sectionIndex];
                          final sectionExpenses = List<Expense>.from(
                            grouped[date]!,
                          )..sort(compareExpensesByDisplayOrder);
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
                                (expense) => ExpenseItemCard(expense: expense),
                              ),
                            ],
                          );
                        },
                        childCount: sortedDates.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActivitySearchSuffix extends StatelessWidget {
  const _ActivitySearchSuffix({
    required this.showClear,
    required this.filterCount,
    required this.onClearSearch,
    required this.onOpenFilters,
  });

  final bool showClear;
  final int filterCount;
  final VoidCallback onClearSearch;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showClear)
          IconButton(
            onPressed: onClearSearch,
            icon: const Icon(Icons.clear),
            tooltip: 'Clear search',
          ),
        Badge(
          isLabelVisible: filterCount > 0,
          label: Text('$filterCount'),
          child: IconButton(
            onPressed: onOpenFilters,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filters',
          ),
        ),
      ],
    );
  }
}
