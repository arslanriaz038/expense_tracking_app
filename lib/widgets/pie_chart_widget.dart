import 'package:expense_tracking_app/models/expense.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatelessWidget {
  final List<Expense> expensesList;

  const PieChartWidget(this.expensesList, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: PieChart(PieChartData(
        sections: _chartSections(expensesList),
        centerSpaceRadius: 48.0,
      )),
    );
  }

  List<PieChartSectionData> _chartSections(List<Expense> expensesList) {
    final Map<String, double> categoryToTotalAmount = {};

    // Calculate the total amount for each category
    for (var expense in expensesList) {
      final category = expense.category;
      final amount = expense.amount;

      if (categoryToTotalAmount.containsKey(category)) {
        categoryToTotalAmount[category] =
            categoryToTotalAmount[category]! + (double.tryParse(amount) ?? 0);
      } else {
        categoryToTotalAmount[category] = double.tryParse(amount) ?? 0;
      }
    }

    final List<PieChartSectionData> list = [];

    // Generate pie chart sections based on categories and total amounts
    int index = 0;
    for (var category in categoryToTotalAmount.keys) {
      const double radius = 40.0;
      final double totalAmount = categoryToTotalAmount[category]!;
      final data = PieChartSectionData(
        color: _getRandomColor(index), // Generate a color for the category
        value: totalAmount.toDouble(), // Cast the value to double
        radius: radius,
        title:
            '$category\n\$${totalAmount.toStringAsFixed(2)}', // Display category and amount as the title
      );
      list.add(data);
      index++;
    }

    return list;
  }

  Color _getRandomColor(int index) {
    // You can generate random colors or use a predefined list of colors here
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
    ];

    // Use modulo to loop through colors if there are more categories than colors
    return colors[index % colors.length];
  }
}
