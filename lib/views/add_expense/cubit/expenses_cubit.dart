import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracking_app/models/expense.dart';
import 'package:expense_tracking_app/services/firebase_services.dart';
import 'package:expense_tracking_app/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'expenses_cubit_state.dart';

class ExpensesCubit extends Cubit<ExpensesCubitState> {
  ExpensesCubit() : super(ExpenseCubitInitial());

  final FirebaseServices _firebaseServices = FirebaseServices();
  final formKey = GlobalKey<FormState>();

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  String selectedCategory = 'Grocery';
  DateTime selectedDate = DateTime.now();
  String? pickedImagePath;

  final List<Expense> allExpenses = [];

  updateSelectedCategory(String? newValue) {
    selectedCategory = newValue!;

    emit(CategoryUpdatedState());
  }

  void updateSelectedDate(DateTime date) {
    selectedDate = date;
    emit(DateUpdatedState(selectedDate));
  }

  void updatePickedImagePath(String imagePath) {
    pickedImagePath = imagePath;
    if (pickedImagePath != null) {
      emit(PickedImagePathState(pickedImagePath!));
    }
  }

  Future<void> getAllExpenses() async {
    try {
      emit(LoadingState());

      final expenses = await _firebaseServices.getAllExpenses();

      allExpenses.clear();

      allExpenses.addAll(expenses ?? []);

      emit(AllExpensesLoadedState(expenses: expenses ?? []));
    } catch (e) {
      emit(FailedState(errorMessage: 'Failed to load expenses: $e'));
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      // emit(LoadingState());

      allExpenses
          .firstWhereOrNull((element) => element.id == expenseId)
          ?.isLoading = true;
      emit(AllExpensesLoadedState(expenses: allExpenses ?? []));

      await _firebaseServices.deleteExpense(expenseId);

      allExpenses.removeWhere((expense) => expense.id == expenseId);

      emit(ExpenseDeletedState(expenseId));
    } catch (e) {
      emit(FailedState(errorMessage: 'Failed to delete expense: $e'));
    }
  }

  Future<void> _updateExpense(
    String expenseId,
  ) async {
    String? imageUrl;

    emit(LoadingState());

    if (pickedImagePath != null) {
      imageUrl = await _firebaseServices.uploadReceiptImage(
        pickedImagePath!,
      );
    }

    Expense updatedExpense = Expense(
      description: descriptionController.text,
      amount: amountController.text,
      date: selectedDate,
      category: selectedCategory,
      receiptImageUrl: imageUrl,
    );
    try {
      emit(LoadingState());
      await _firebaseServices.updateExpense(expenseId, updatedExpense);

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
    if (formKey.currentState?.validate() ?? false) {
      hideKeyBoard();
      _saveExpense();
    }
  }

  Future<void> updateExpense(
    String expenseId,
  ) async {
    if (formKey.currentState?.validate() ?? false) {
      hideKeyBoard();
      _updateExpense(expenseId);
    }
  }

  Future<void> _saveExpense() async {
    try {
      String? imageUrl;

      emit(LoadingState());

      if (pickedImagePath != null) {
        imageUrl = await _firebaseServices.uploadReceiptImage(
          pickedImagePath!,
        );
      }
      final expense = await _firebaseServices.saveExpense(Expense(
        description: descriptionController.text,
        amount: amountController.text,
        date: selectedDate,
        category: selectedCategory,
        receiptImageUrl: imageUrl,
      ));

      emit(ExpenseAddedState());
    } catch (e) {
      const FailedState(errorMessage: 'Failed to Sign up');
    }
  }
}
