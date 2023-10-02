import 'package:flutter/material.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Your Expenses',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Replace with the actual number of expenses.
                itemBuilder: (BuildContext context, int index) {
                  // Replace with logic to display expense items.
                  return ExpenseItemCard(
                    // You can pass expense details to this widget.
                    expenseName: 'Expense ${index + 1}',
                    expenseAmount: 50.0 * (index + 1),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to a screen for adding a new expense.
          // You can create this screen separately.
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  const AddExpensePage(), // Replace with your add expense screen.
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ExpenseItemCard extends StatelessWidget {
  final String expenseName;
  final double expenseAmount;

  const ExpenseItemCard({super.key, 
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

// You can create a separate AddExpensePage for adding new expenses.
class AddExpensePage extends StatelessWidget {
  const AddExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Add form fields and buttons for adding a new expense here.
          ],
        ),
      ),
    );
  }
}
