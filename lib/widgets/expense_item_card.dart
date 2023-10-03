import 'package:expense_tracking_app/models/expense.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/views/add_expense/cubit/expenses_cubit.dart';
import 'package:expense_tracking_app/views/add_expense/view/add_expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpenseItemCard extends StatelessWidget {
  final Expense expense;

  const ExpenseItemCard({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final ExpensesCubit cubit = context.read<ExpensesCubit>();

    return Card(
      elevation: 3.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(expense.description),
        subtitle: Text(expense.amount),
        trailing: SizedBox(
          width: 100,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddExpensePage(
                        expense: expense,
                        cubit: cubit,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  if (expense.id != null) {
                    await cubit.deleteExpense(expense.id!);
                  }
                },
              ),
            ],
          ),
        ),
        onTap: () {
          AppNavigator.push(
              context,
              AddExpensePage(
                cubit: cubit,
                expense: expense,
              ));
        },
      ),
    );
  }
}
