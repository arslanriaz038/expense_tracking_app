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
  String selectedCategory = ExpenseCategories.defaults.first;
  ExpenseType selectedType = ExpenseType.expense;
  DateTime selectedDate = DateTime.now();
  String? pickedImagePath;

  final List<Expense> allExpenses = [];
  final List<String> customCategories = [];
  MonthlyBudget monthlyBudget = const MonthlyBudget();

  StreamSubscription<List<Expense>>? _expensesSubscription;
  StreamSubscription<List<String>>? _categoriesSubscription;

  List<String> get allCategories => ExpenseCategories.resolve(
        customCategories: customCategories,
        expenseCategories: allExpenses.map((e) => e.category).toList(),
      );

  void startListening() {
    _expensesSubscription?.cancel();
    _categoriesSubscription?.cancel();
    emit(LoadingState());

    _expensesSubscription = _firebaseServices.watchExpenses().listen(
      (expenses) {
        allExpenses
          ..clear()
          ..addAll(expenses);
        _ensureSelectedCategoryValid();
        emit(AllExpensesLoadedState(expenses: List.from(allExpenses)));
      },
      onError: (Object e) {
        emit(FailedState(errorMessage: 'Failed to load expenses: $e'));
      },
    );

    _categoriesSubscription =
        _firebaseServices.watchCustomCategories().listen(
      (categories) {
        customCategories
          ..clear()
          ..addAll(categories);
        _ensureSelectedCategoryValid();
        emit(CategoriesUpdatedState(allCategories));
        if (allExpenses.isNotEmpty) {
          emit(AllExpensesLoadedState(expenses: List.from(allExpenses)));
        }
      },
      onError: (Object e) {
        emit(FailedState(errorMessage: 'Failed to load categories: $e'));
      },
    );
  }

  Future<void> loadCategories() async {
    try {
      final categories = await _firebaseServices.getCustomCategories();
      customCategories
        ..clear()
        ..addAll(categories);
      _ensureSelectedCategoryValid();
      emit(CategoriesUpdatedState(allCategories));
    } catch (e) {
      emit(FailedState(errorMessage: e.toString()));
    }
  }

  Future<void> addCustomCategory(String name) async {
    final normalized = ExpenseCategories.normalizeName(name);
    if (normalized == null) return;

    final error = ExpenseCategories.validateNewCategory(
      normalized,
      existingCategories: allCategories,
    );
    if (error != null) {
      emit(FailedState(errorMessage: error));
      return;
    }

    try {
      final updated = [...customCategories, normalized]..sort();
      await _firebaseServices.saveCustomCategories(updated);
      customCategories
        ..clear()
        ..addAll(updated);
      selectedCategory = normalized;
      emit(CategoryAddedState(normalized));
      emit(CategoriesUpdatedState(allCategories));
    } catch (e) {
      emit(FailedState(errorMessage: e.toString()));
    }
  }

  Future<void> removeCustomCategory(String name) async {
    if (ExpenseCategories.isDefault(name)) {
      emit(const FailedState(errorMessage: 'Default categories cannot be removed'));
      return;
    }

    try {
      final updated = customCategories.where((c) => c != name).toList();
      await _firebaseServices.saveCustomCategories(updated);
      customCategories
        ..clear()
        ..addAll(updated);
      _ensureSelectedCategoryValid();
      emit(CategoryRemovedState(name));
      emit(CategoriesUpdatedState(allCategories));
    } catch (e) {
      emit(FailedState(errorMessage: e.toString()));
    }
  }

  void _ensureSelectedCategoryValid() {
    final categories = allCategories;
    if (categories.isEmpty) return;
    if (!categories.contains(selectedCategory)) {
      selectedCategory = categories.first;
    }
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
    selectedDate = DateTime(date.year, date.month, date.day);
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
      _ensureSelectedCategoryValid();
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
    selectedCategory = allCategories.first;
    selectedType = ExpenseType.expense;
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    pickedImagePath = null;
  }

  @override
  Future<void> close() {
    _expensesSubscription?.cancel();
    _categoriesSubscription?.cancel();
    descriptionController.dispose();
    amountController.dispose();
    return super.close();
  }
}
