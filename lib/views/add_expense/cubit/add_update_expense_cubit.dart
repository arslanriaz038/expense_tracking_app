import 'package:equatable/equatable.dart';
import 'package:expense_tracking_app/models/expense.dart';
import 'package:expense_tracking_app/services/firebase_services.dart';
import 'package:expense_tracking_app/services/user_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';

part 'add_update_expense_cubit_state.dart';

class AddUpdateExpenseCubit extends Cubit<AddUpdateExpenseCubitState> {
  AddUpdateExpenseCubit() : super(AddUpdateExpenseCubitInitial());

  final FirebaseServices _firebaseServices = FirebaseServices();

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  String selectedCategory = 'Food'; // Default category
  final DateTime selectedDate = DateTime.now(); // Default date

  updateSelectedCategory(String? newValue) {
    selectedCategory = newValue!;

    emit(CategoryUpdatedState());
  }

  Future<void> saveExpense() async {
    try {
      final expense = await _firebaseServices.saveExpense(Expense(
          description: descriptionController.text,
          amount: amountController.text,
          date: DateTime.now(),
          category: selectedCategory));

      emit(SuccessState());
    } catch (e) {
      const FailedState(errorMessage: 'Failed to Sign up');
    }
  }
}
