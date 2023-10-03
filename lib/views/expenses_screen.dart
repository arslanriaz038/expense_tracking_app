import 'package:expense_tracking_app/views/add_expense/cubit/add_update_expense_cubit.dart';
import 'package:expense_tracking_app/views/add_expense/view/add_update_expense_screen.dart';
import 'package:expense_tracking_app/widgets/expense_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddUpdateExpenseCubit()..getAllExpenses(),
      child: BlocConsumer<AddUpdateExpenseCubit, AddUpdateExpenseCubitState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          final AddUpdateExpenseCubit cubit =
              context.read<AddUpdateExpenseCubit>();

          return Scaffold(
            appBar: AppBar(
              forceMaterialTransparency: true,
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
                    child: state is LoadingState
                        ? const Center(
                            child: CircularProgressIndicator.adaptive(),
                          )
                        : ListView.builder(
                            itemCount: cubit.allExpenses
                                .length, // Replace with the actual number of expenses.
                            itemBuilder: (BuildContext context, int index) {
                              // Replace with logic to display expense items.
                              return ExpenseItemCard(
                                // You can pass expense details to this widget.
                                expenseName:
                                    cubit.allExpenses[index].description,
                                expenseAmount: cubit.allExpenses[index].amount,
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
        },
      ),
    );
  }
}


// You can create a separate AddExpensePage for adding new expenses.

