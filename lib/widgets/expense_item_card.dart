import 'package:expense_tracking_app/views/add_expense/view/add_update_expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ExpenseItemCard extends StatelessWidget {
  final String expenseName;
  final String expenseAmount;

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
        subtitle: Text(expenseAmount),
        trailing: SizedBox(
          width: 100,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Implement logic to delete this expense.
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddExpensePage(
                        isEditing: true,
                      ), // Replace with your add expense screen.
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // Implement logic to delete this expense.
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddExpensePage(
                        isEditing: true,
                      ), // Replace with your add expense screen.
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        onTap: () {
          // Implement logic to view or edit this expense.
        },
      ),
    );
  }
}
