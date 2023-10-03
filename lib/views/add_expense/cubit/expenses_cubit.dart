import 'package:equatable/equatable.dart';
import 'package:expense_tracking_app/models/expense.dart';
import 'package:expense_tracking_app/services/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'expenses_cubit_state.dart';

class ExpensesCubit extends Cubit<ExpensesCubitState> {
  ExpensesCubit() : super(ExpenseCubitInitial());

  final FirebaseServices _firebaseServices = FirebaseServices();

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  String selectedCategory = 'Food'; // Default category
  DateTime selectedDate = DateTime.now(); // Default date

  final List<Expense> allExpenses = [];

  updateSelectedCategory(String? newValue) {
    selectedCategory = newValue!;

    emit(CategoryUpdatedState());
  }

  void updateSelectedDate(DateTime date) {
    selectedDate = date;
    emit(DateUpdatedState(selectedDate));
  }

  Future<void> getAllExpenses() async {
    try {
      emit(LoadingState());

      final expenses = await _firebaseServices.getAllExpenses();

      allExpenses.addAll(expenses ?? []);

      emit(AllExpensesLoadedState(expenses: expenses ?? []));
    } catch (e) {
      emit(FailedState(errorMessage: 'Failed to load expenses: $e'));
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      emit(LoadingState());

      // Call the function from FirebaseServices to delete the expense
      await _firebaseServices.deleteExpense(expenseId);

      // Remove the deleted expense from the local list
      allExpenses.removeWhere((expense) => expense.id == expenseId);

      emit(ExpenseDeletedState(expenseId));
    } catch (e) {
      emit(FailedState(errorMessage: 'Failed to delete expense: $e'));
    }
  }

  Future<void> updateExpense(
    String expenseId,
  ) async {
    Expense updatedExpense = Expense(
        description: descriptionController.text,
        amount: amountController.text,
        date: selectedDate,
        category: selectedCategory);
    try {
      // Call the function from FirebaseServices to update the expense

      emit(LoadingState());
      await _firebaseServices.updateExpense(expenseId, updatedExpense);

      // Update the local list with the updated expense
      final index =
          allExpenses.indexWhere((expense) => expense.id == expenseId);
      if (index != -1) {
        allExpenses[index] = updatedExpense;
      }

      emit(ExpenseUpdatedState(updatedExpense));
    } catch (e) {
      emit(FailedState(errorMessage: 'Failed to update expense: $e'));
    }
  }

  Future<void> saveExpense() async {
    try {
      final expense = await _firebaseServices.saveExpense(Expense(
          description: descriptionController.text,
          amount: amountController.text,
          date: selectedDate,
          category: selectedCategory));

      emit(SuccessState());
    } catch (e) {
      const FailedState(errorMessage: 'Failed to Sign up');
    }
  }
}
