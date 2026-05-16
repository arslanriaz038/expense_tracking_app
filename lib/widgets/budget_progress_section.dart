import 'package:expense_tracking_app/consts/expense_constants.dart';
import 'package:expense_tracking_app/models/monthly_budget.dart';
import 'package:expense_tracking_app/utils/money_format.dart';
import 'package:flutter/material.dart';

class BudgetProgressSection extends StatelessWidget {
  const BudgetProgressSection({
    super.key,
    required this.budget,
    required this.monthSpending,
    required this.categorySpending,
  });

  final MonthlyBudget budget;
  final double monthSpending;
  final Map<String, double> categorySpending;

  @override
  Widget build(BuildContext context) {
    if (!budget.hasAnyLimit) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly budget',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            if (budget.overallLimit != null && budget.overallLimit! > 0)
              _BudgetBar(
                label: 'Overall',
                spent: monthSpending,
                limit: budget.overallLimit!,
              ),
            for (final category in ExpenseCategories.all)
              if (budget.categoryLimits[category] != null &&
                  budget.categoryLimits[category]! > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _BudgetBar(
                    label: category,
                    spent: categorySpending[category] ?? 0,
                    limit: budget.categoryLimits[category]!,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _BudgetBar extends StatelessWidget {
  const _BudgetBar({
    required this.label,
    required this.spent,
    required this.limit,
  });

  final String label;
  final double spent;
  final double limit;

  @override
  Widget build(BuildContext context) {
    final progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final isOver = spent > limit;
    final color = isOver ? Colors.red : Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              '${MoneyFormat.format(spent)} / ${MoneyFormat.format(limit)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isOver ? Colors.red : null,
                    fontWeight: isOver ? FontWeight.w600 : null,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.15),
            color: color,
          ),
        ),
        if (isOver)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Over budget by ${MoneyFormat.format(spent - limit)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                  ),
            ),
          ),
      ],
    );
  }
}
