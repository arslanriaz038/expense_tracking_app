import 'package:collection/collection.dart';
import 'package:expense_tracking_app/consts/expense_constants.dart';
import 'package:expense_tracking_app/models/expense.dart';
import 'package:expense_tracking_app/utils/expense_date_filter.dart';
import 'package:expense_tracking_app/utils/expense_list_filters.dart';
import 'package:expense_tracking_app/views/add_expense/cubit/expenses_cubit.dart';
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
  bool _filtersExpanded = false;

  void applyFilters(ExpenseListFilters filters) {
    setState(() {
      _filters = filters;
      _searchController.text = filters.searchQuery;
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

        return Scaffold(
          appBar: AppBar(
            title: const Text('Activity'),
            centerTitle: false,
          ),
          body: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            setState(() => _filtersExpanded = !_filtersExpanded);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Icon(
                                  _filtersExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Filters',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const Spacer(),
                                if (_filters.dateFilter !=
                                        ExpenseDateFilter.all ||
                                    _filters.typeFilter != null ||
                                    _filters.category != null)
                                  Text(
                                    'Active',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (_filtersExpanded) ...[
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  ExpenseDateFilter.values.map((filter) {
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
                                for (final category in cubit.allCategories)
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
