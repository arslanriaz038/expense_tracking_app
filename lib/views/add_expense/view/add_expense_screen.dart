import 'dart:io';

import 'package:expense_tracking_app/gen/colors.gen.dart';
import 'package:expense_tracking_app/models/expense.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/utils/app_pickers.dart';
import 'package:expense_tracking_app/views/add_expense/cubit/expenses_cubit.dart';
import 'package:expense_tracking_app/widgets/my_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      cubit.pickedImagePath = null;
      cubit.updateSelectedCategory(expense!.category);
    } else {
      cubit.descriptionController.text = '';
      cubit.amountController.text = '';
      cubit.selectedDate = DateTime.now();
      cubit.pickedImagePath = null;
      cubit.updateSelectedCategory('Food');
    }

    Future<void> pickImage() async {
      final result = await AppPickers.pickImage(context);
      if (result != null) {
        cubit.updatePickedImagePath(result.path);
      }
    }

    return BlocConsumer<ExpensesCubit, ExpensesCubitState>(
      bloc: cubit,
      listener: (context, state) {},
      builder: (context, state) {
        String? pickedImagePath;

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
                      if (pickedDate != null &&
                          pickedDate != cubit.selectedDate) {
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
                  if (expense?.receiptImageUrl == null)
                    ElevatedButton(
                      onPressed: () {
                        pickImage();
                      },
                      child: const Text('Attach Receipt Image'),
                    ),
                  if (expense?.receiptImageUrl != null ||
                      cubit.pickedImagePath != null)
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      height: 120,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: cubit.pickedImagePath != null
                                ? Image.file(
                                    File(cubit.pickedImagePath!),
                                    height: 120,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    expense?.receiptImageUrl ?? '',
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Positioned(
                            right: 5,
                            top: 5,
                            child: GestureDetector(
                              onTap: pickImage,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.edit,
                                    color: ColorName.primaryColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: state is LoadingState
                          ? null
                          : () async {
                              if (expense?.id != null) {
                                cubit.updateExpense(
                                  expense!.id!,
                                );
                              } else {
                                await cubit.saveExpense();
                              }

                              AppNavigator.pop(context);
                            },
                      child: state is LoadingState
                          ? const Center(
                              child: CircularProgressIndicator.adaptive())
                          : Text(expense != null
                              ? 'Update Expense'
                              : 'Save Expense'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
