import 'package:expense_tracking_app/models/expense.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/views/add_expense/cubit/expenses_cubit.dart';
import 'package:expense_tracking_app/widgets/my_input_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddExpensePage extends StatelessWidget {
  final ExpensesCubit cubit;
  final Expense? expense;

  const AddExpensePage({
    Key? key,
    this.expense,
    required this.cubit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (expense != null) {
      cubit.descriptionController.text = expense!.description;
      cubit.amountController.text = expense!.amount.toString();
      cubit.selectedDate = expense!.date;
      cubit.updateSelectedCategory(expense!.category);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(expense != null ? 'Edit Expense' : 'Add Expense'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Expense Details',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              MyInputField(
                controller: cubit.descriptionController,
                hintText: 'Expense Description',
              ),
              const SizedBox(height: 16.0),
              MyInputField(
                controller: cubit.amountController,
                keyboardType: TextInputType.number,
                hintText: 'Expense Amount',
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: cubit.selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null && pickedDate != cubit.selectedDate) {
                    cubit.updateSelectedDate(pickedDate);
                  }
                },
                child: Row(
                  children: [
                    const Text('Expense Date: '),
                    Text(
                      DateFormat('yyyy-MM-dd').format(cubit.selectedDate),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: cubit.selectedCategory,
                onChanged: (String? newValue) {
                  cubit.updateSelectedCategory(newValue);
                },
                items: <String>[
                  'Food',
                  'Transportation',
                  'Entertainment',
                  'Other'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Expense Category',
                ),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Attach Receipt Image'),
              ),
              const SizedBox(height: 32.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (expense != null) {
                      cubit.updateExpense(
                        expense!
                            .id!, // Pass the expense ID to identify which expense to update
                      );
                    } else {
                      await cubit.saveExpense();
                    }

                    AppNavigator.pop(context);
                  },
                  child:
                      Text(expense != null ? 'Update Expense' : 'Save Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
