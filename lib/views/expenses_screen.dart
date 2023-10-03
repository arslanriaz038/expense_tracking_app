import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/views/add_expense/cubit/expenses_cubit.dart';
import 'package:expense_tracking_app/views/add_expense/view/add_expense_screen.dart';
import 'package:expense_tracking_app/widgets/expense_item_card.dart';
import 'package:expense_tracking_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExpensesCubit()..getAllExpenses(),
      child: BlocConsumer<ExpensesCubit, ExpensesCubitState>(
        listener: (context, state) {},
        builder: (context, state) {
          final ExpensesCubit cubit = context.read<ExpensesCubit>();

          return Scaffold(
            appBar: AppBar(
              forceMaterialTransparency: true,
              title: const Text('Expenses'),
              actions: const [
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: UserProfileAvatar(showOnlineIndicator: false),
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'My Expenses',
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
                            itemCount: cubit.allExpenses.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ExpenseItemCard(
                                expense: cubit.allExpenses[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                AppNavigator.push(
                    context,
                    AddExpensePage(
                      cubit: cubit,
                    ));
              },
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
