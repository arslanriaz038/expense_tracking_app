import 'package:expense_tracking_app/gen/colors.gen.dart';
import 'package:expense_tracking_app/utils/expense_list_filters.dart';
import 'package:expense_tracking_app/utils/money_format.dart';
import 'package:flutter/material.dart';

class ExpenseSummaryBanner extends StatelessWidget {
  const ExpenseSummaryBanner({
    super.key,
    required this.totals,
  });

  final ExpenseTotals totals;

  @override
  Widget build(BuildContext context) {
    if (!totals.hasData) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      color: ColorName.primaryColor.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _SummaryItem(
                label: 'Income',
                value: MoneyFormat.format(totals.income),
                color: Colors.green.shade700,
              ),
            ),
            Expanded(
              child: _SummaryItem(
                label: 'Spent',
                value: MoneyFormat.format(totals.expenses),
                color: Colors.red.shade700,
              ),
            ),
            Expanded(
              child: _SummaryItem(
                label: 'Net',
                value: MoneyFormat.formatSigned(
                  totals.net,
                  isIncome: totals.net >= 0,
                ),
                color: totals.net >= 0
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
