import 'package:expense_tracking_app/consts/expense_constants.dart';
import 'package:expense_tracking_app/utils/expense_date_filter.dart';
import 'package:expense_tracking_app/utils/expense_list_filters.dart';
import 'package:flutter/material.dart';

Future<ExpenseListFilters?> showActivityFiltersSheet({
  required BuildContext context,
  required ExpenseListFilters initialFilters,
  required List<String> categories,
}) {
  return showModalBottomSheet<ExpenseListFilters>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return _ActivityFiltersSheetBody(
        initialFilters: initialFilters,
        categories: categories,
      );
    },
  );
}

class _ActivityFiltersSheetBody extends StatefulWidget {
  const _ActivityFiltersSheetBody({
    required this.initialFilters,
    required this.categories,
  });

  final ExpenseListFilters initialFilters;
  final List<String> categories;

  @override
  State<_ActivityFiltersSheetBody> createState() =>
      _ActivityFiltersSheetBodyState();
}

class _ActivityFiltersSheetBodyState extends State<_ActivityFiltersSheetBody> {
  late ExpenseDateFilter _dateFilter;
  late ExpenseType? _typeFilter;
  late String? _category;

  @override
  void initState() {
    super.initState();
    _dateFilter = widget.initialFilters.dateFilter;
    _typeFilter = widget.initialFilters.typeFilter;
    _category = widget.initialFilters.category;
  }

  ExpenseListFilters _buildResult() {
    return ExpenseListFilters(
      searchQuery: widget.initialFilters.searchQuery,
      dateFilter: _dateFilter,
      typeFilter: _typeFilter,
      category: _category,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filters',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Refine your transaction list',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: 'Period'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExpenseDateFilter.values.map((filter) {
                return FilterChip(
                  label: Text(filter.label),
                  selected: _dateFilter == filter,
                  onSelected: (_) => setState(() => _dateFilter = filter),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: 'Type'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _typeFilter == null,
                  onSelected: (_) => setState(() => _typeFilter = null),
                ),
                for (final type in ExpenseType.values)
                  FilterChip(
                    label: Text(type.label),
                    selected: _typeFilter == type,
                    onSelected: (_) => setState(() => _typeFilter = type),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: 'Category'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('All categories'),
                  selected: _category == null,
                  onSelected: (_) => setState(() => _category = null),
                ),
                for (final category in widget.categories)
                  FilterChip(
                    label: Text(category),
                    selected: _category == category,
                    onSelected: (_) => setState(() => _category = category),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      widget.initialFilters.clearFilters(),
                    );
                  },
                  child: const Text('Clear all'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(_buildResult()),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
