import 'package:expense_tracking_app/views/add_expense/cubit/add_update_expense_cubit.dart';
import 'package:expense_tracking_app/widgets/my_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddExpensePage extends StatelessWidget {
  final bool isEditing;

  const AddExpensePage({Key? key, this.isEditing = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddUpdateExpenseCubit(),
      child: BlocConsumer<AddUpdateExpenseCubit, AddUpdateExpenseCubitState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          final AddUpdateExpenseCubit cubit =
              context.read<AddUpdateExpenseCubit>();

          return Scaffold(
            appBar: AppBar(
              title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
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
                      onTap: () {
                        // Implement date picker to select the date.
                      },
                      child: Row(
                        children: [
                          const Text('Expense Date: '),
                          Text(
                            cubit.selectedDate
                                .toString(), // Display the selected date here.
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
                      onPressed: () {
                        // Implement logic to upload receipt image (if needed).
                      },
                      child: const Text('Attach Receipt Image'),
                    ),
                    const SizedBox(height: 32.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Implement logic to save or update the expense based on widget.isEditing.
                          if (isEditing) {
                            // Update existing expense logic here.
                          } else {
                            await cubit.saveExpense();
                          }
                        },
                        child:
                            Text(isEditing ? 'Update Expense' : 'Save Expense'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
