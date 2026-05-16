import 'dart:io';

import 'package:collection/collection.dart';
import 'package:expense_tracking_app/consts/expense_constants.dart';
import 'package:expense_tracking_app/gen/colors.gen.dart';
import 'package:expense_tracking_app/models/expense.dart';
import 'package:expense_tracking_app/utils/app_alerts.dart';
import 'package:expense_tracking_app/utils/app_form_fields_validator.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/utils/app_pickers.dart';
import 'package:expense_tracking_app/views/add_expense/cubit/expenses_cubit.dart';
import 'package:expense_tracking_app/widgets/manage_categories_sheet.dart';
import 'package:expense_tracking_app/widgets/my_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AddExpensePage extends StatelessWidget {
  final ExpensesCubit cubit;
  final Expense? expense;

  const AddExpensePage({
    super.key,
    this.expense,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    if (expense != null) {
      cubit.descriptionController.text = expense!.description;
      cubit.amountController.text = expense!.amount;
      cubit.selectedDate = expense!.date;
      cubit.pickedImagePath = null;
      cubit.updateSelectedCategory(expense!.category);
      cubit.updateSelectedType(expense!.type);
    } else {
      cubit.resetForm();
    }

    Future<void> pickImage() async {
      final result = await AppPickers.pickImage(context);
      if (result != null) {
        cubit.updatePickedImagePath(result.path);
      }
    }

    return BlocConsumer<ExpensesCubit, ExpensesCubitState>(
      bloc: cubit,
      listener: (context, state) {
        if (state is ExpenseAddedState || state is ExpenseUpdatedState) {
          AppNavigator.pop(context);
        } else if (state is FailedState) {
          AppAlerts.showErrorMessage(
            context,
            state.errorMessage ?? 'Something went wrong',
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(expense != null ? 'Edit transaction' : 'Add transaction'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: cubit.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<ExpenseType>(
                      segments: const [
                        ButtonSegment(
                          value: ExpenseType.expense,
                          label: Text('Expense'),
                          icon: Icon(Icons.arrow_upward),
                        ),
                        ButtonSegment(
                          value: ExpenseType.income,
                          label: Text('Income'),
                          icon: Icon(Icons.arrow_downward),
                        ),
                      ],
                      selected: {cubit.selectedType},
                      onSelectionChanged: (selection) {
                        cubit.updateSelectedType(selection.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    MyInputField(
                      controller: cubit.descriptionController,
                      hintText: 'Description',
                      validator: (value) =>
                          AppFormFieldValidator.emptyFieldValidator(
                        value,
                        'Description is required',
                      ),
                    ),
                    const SizedBox(height: 16),
                    MyInputField(
                      controller: cubit.amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      hintText: 'Amount',
                      validator: AppFormFieldValidator.amountValidator,
                    ),
                    const SizedBox(height: 16),
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
                          const Text('Date: '),
                          Text(
                            DateFormat('yyyy-MM-dd').format(cubit.selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      key: ValueKey(
                        '${cubit.selectedCategory}_${cubit.allCategories.length}',
                      ),
                      initialValue: cubit.allCategories.contains(
                            cubit.selectedCategory,
                          )
                          ? cubit.selectedCategory
                          : cubit.allCategories.firstOrNull,
                      onChanged: cubit.updateSelectedCategory,
                      items: cubit.allCategories
                          .map(
                            (value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => showManageCategoriesSheet(
                              context,
                              cubit: cubit,
                            ),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Manage categories'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (expense?.receiptImageUrl == null &&
                        cubit.pickedImagePath == null)
                      ElevatedButton(
                        onPressed: pickImage,
                        child: const Text('Attach receipt (optional)'),
                      ),
                    if (expense?.receiptImageUrl != null ||
                        cubit.pickedImagePath != null)
                      Center(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: cubit.pickedImagePath != null
                                  ? Image.file(
                                      File(cubit.pickedImagePath!),
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      expense?.receiptImageUrl ?? '',
                                      height: 200,
                                      width: double.infinity,
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
                                  child: const Icon(
                                    Icons.edit,
                                    color: ColorName.primaryColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: state is LoadingState
                            ? null
                            : () async {
                                if (expense?.id != null) {
                                  await cubit.updateExpense(
                                    expense!.id!,
                                    existingReceiptUrl:
                                        expense!.receiptImageUrl,
                                  );
                                } else {
                                  await cubit.saveExpense();
                                }
                              },
                        child: state is LoadingState
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator.adaptive(),
                              )
                            : Text(
                                expense != null
                                    ? 'Update transaction'
                                    : 'Save transaction',
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
