import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracking_app/consts/expense_constants.dart';
import 'package:expense_tracking_app/models/expense.dart';
import 'package:expense_tracking_app/models/monthly_budget.dart';
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
  String selectedCategory = ExpenseCategories.all.first;
  ExpenseType selectedType = ExpenseType.expense;
  DateTime selectedDate = DateTime.now();
  String? pickedImagePath;

  final List<Expense> allExpenses = [];
  MonthlyBudget monthlyBudget = const MonthlyBudget();

  StreamSubscription<List<Expense>>? _expensesSubscription;

  void startListening() {
    _expensesSubscription?.cancel();
    emit(LoadingState());

    _expensesSubscription = _firebaseServices.watchExpenses().listen(
      (expenses) {
        allExpenses
          ..clear()
          ..addAll(expenses);
        emit(AllExpensesLoadedState(expenses: List.from(allExpenses)));
      },
      onError: (Object e) {
        emit(FailedState(errorMessage: 'Failed to load expenses: $e'));
      },
    );
  }

  Future<void> loadBudget() async {
    try {
      monthlyBudget = await _firebaseServices.getMonthlyBudget();
      emit(BudgetLoadedState(monthlyBudget));
    } catch (e) {
      emit(FailedState(errorMessage: e.toString()));
    }
  }

  Future<void> saveBudget(MonthlyBudget budget) async {
    try {
      await _firebaseServices.saveMonthlyBudget(budget);
      monthlyBudget = budget;
      emit(BudgetSavedState(budget));
      emit(AllExpensesLoadedState(expenses: List.from(allExpenses)));
    } catch (e) {
      emit(FailedState(errorMessage: e.toString()));
    }
  }

  void updateSelectedCategory(String? newValue) {
    if (newValue == null) return;
    selectedCategory = newValue;
    emit(CategoryUpdatedState());
  }

  void updateSelectedType(ExpenseType type) {
    selectedType = type;
    emit(TypeUpdatedState(type));
  }

  void updateSelectedDate(DateTime date) {
    selectedDate = date;
    emit(DateUpdatedState(selectedDate));
  }

  void updatePickedImagePath(String? imagePath) {
    pickedImagePath = imagePath;
    if (pickedImagePath != null) {
      emit(PickedImagePathState(pickedImagePath!));
    }
  }

  Future<void> refreshExpenses() async {
    try {
      final expenses = await _firebaseServices.getAllExpenses();
      allExpenses
        ..clear()
        ..addAll(expenses);
      emit(AllExpensesLoadedState(expenses: List.from(allExpenses)));
    } catch (e) {
      emit(FailedState(errorMessage: 'Failed to refresh expenses: $e'));
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      allExpenses
          .firstWhereOrNull((element) => element.id == expenseId)
          ?.isLoading = true;
      emit(AllExpensesLoadedState(expenses: List.from(allExpenses)));

      await _firebaseServices.deleteExpense(expenseId);
      emit(ExpenseDeletedState(expenseId));
    } catch (e) {
      emit(FailedState(errorMessage: 'Failed to delete expense: $e'));
    }
  }

  Future<void> _updateExpense(String expenseId, {String? existingReceiptUrl}) async {
    emit(LoadingState());

    String? imageUrl = existingReceiptUrl;
    if (pickedImagePath != null) {
      imageUrl = await _firebaseServices.uploadReceiptImage(pickedImagePath!);
    }

    final updatedExpense = Expense(
      description: descriptionController.text.trim(),
      amount: amountController.text.trim(),
      date: selectedDate,
      category: selectedCategory,
      type: selectedType,
      receiptImageUrl: imageUrl,
    );

    try {
      await _firebaseServices.updateExpense(expenseId, updatedExpense);
      emit(ExpenseUpdatedState(updatedExpense));
    } catch (e) {
      emit(FailedState(errorMessage: 'Failed to update expense: $e'));
    }
  }

  Future<void> saveExpense() async {
    if (formKey.currentState?.validate() ?? false) {
      hideKeyBoard();
      await _saveExpense();
    }
  }

  Future<void> updateExpense(
    String expenseId, {
    String? existingReceiptUrl,
  }) async {
    if (formKey.currentState?.validate() ?? false) {
      hideKeyBoard();
      await _updateExpense(
        expenseId,
        existingReceiptUrl: existingReceiptUrl,
      );
    }
  }

  Future<void> _saveExpense() async {
    try {
      emit(LoadingState());

      String? imageUrl;
      if (pickedImagePath != null) {
        imageUrl = await _firebaseServices.uploadReceiptImage(pickedImagePath!);
      }

      await _firebaseServices.saveExpense(
        Expense(
          description: descriptionController.text.trim(),
          amount: amountController.text.trim(),
          date: selectedDate,
          category: selectedCategory,
          type: selectedType,
          receiptImageUrl: imageUrl,
        ),
      );

      emit(ExpenseAddedState());
    } catch (e) {
      emit(FailedState(errorMessage: 'Failed to save expense: $e'));
    }
  }

  void resetForm() {
    descriptionController.clear();
    amountController.clear();
    selectedCategory = ExpenseCategories.all.first;
    selectedType = ExpenseType.expense;
    selectedDate = DateTime.now();
    pickedImagePath = null;
  }

  @override
  Future<void> close() {
    _expensesSubscription?.cancel();
    descriptionController.dispose();
    amountController.dispose();
    return super.close();
  }
}
