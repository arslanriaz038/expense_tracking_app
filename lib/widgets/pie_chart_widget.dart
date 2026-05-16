import 'package:expense_tracking_app/models/expense.dart';
import 'package:expense_tracking_app/utils/expense_list_filters.dart';
import 'package:expense_tracking_app/utils/money_format.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatelessWidget {
  final List<Expense> expensesList;

  const PieChartWidget(this.expensesList, {super.key});

  static const _colors = [
    Color(0xFF4E79A7),
    Color(0xFFF28E2B),
    Color(0xFFE15759),
    Color(0xFF76B7B2),
    Color(0xFF59A14F),
    Color(0xFFEDC948),
    Color(0xFFB07AA1),
  ];

  @override
  Widget build(BuildContext context) {
    final categoryTotals = categorySpending(expensesList);

    if (categoryTotals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'No expense data to chart yet',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return AspectRatio(
      aspectRatio: 1.2,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            for (var i = 0; i < entries.length; i++)
              PieChartSectionData(
                color: _colors[i % _colors.length],
                value: entries[i].value,
                radius: 52,
                title: '${entries[i].key}\n${MoneyFormat.format(entries[i].value)}',
                titleStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
