import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ExpenseItemCard extends StatelessWidget {
  final String expenseName;
  final double expenseAmount;

  const ExpenseItemCard({
    super.key,
    required this.expenseName,
    required this.expenseAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(expenseName),
        subtitle: Text('\$$expenseAmount'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            // Implement logic to delete this expense.
          },
        ),
        onTap: () {
          // Implement logic to view or edit this expense.
        },
      ),
    );
  }
}
