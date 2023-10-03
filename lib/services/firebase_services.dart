import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracking_app/consts/firebase_constants.dart';
import 'package:expense_tracking_app/models/expense.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServices {
  final int _maxConversations = 4;
  final _firestoreInstance = FirebaseFirestore.instance;

  final user = FirebaseAuth.instance.currentUser;

  DocumentReference? childrenDocRef;

  Future<List<Expense>?> getAllExpenses() async {
    final List<Expense> allExpensesList = [];
    if (user != null) {
      final userId = user?.uid;
      final expenseRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('expenses');

      try {
        final querySnapshot = await expenseRef
            .orderBy('date',
                descending:
                    true) // Replace 'timestamp' with the field you want to sort by
            .get();

        allExpensesList.addAll(
          querySnapshot.docs.map(
            (document) {
              return Expense.fromSnapshot(
                document,
              );
            },
          ),
        );

        return allExpensesList;
      } catch (e) {
        print('Error getting expenses: $e');
      }
    } else {}
    return null;
  }

  Future<void> saveExpense(Expense expense) async {
    try {
      if (user != null) {
        final userId = user?.uid;
        final CollectionReference expenseRef = _firestoreInstance
            .collection('users')
            .doc(userId)
            .collection('expenses');

        final Map<String, dynamic> expenseData = expense.toMap();

        await expenseRef.add(expenseData);
      }
    } catch (error) {
      print('Error saving expense to Firestore: $error');
      // Handle the error as needed (e.g., show an error message to the user).
    }
  }

  Future<void> updateExpense(String expenseId, Expense updatedExpense) async {
    try {
      if (user != null) {
        final userId = user?.uid;
        final DocumentReference expenseRef = _firestoreInstance
            .collection('users')
            .doc(userId)
            .collection('expenses')
            .doc(expenseId);

        final Map<String, dynamic> updatedExpenseData = updatedExpense.toMap();

        await expenseRef.update(updatedExpenseData);
      }
    } catch (error) {
      print('Error updating expense in Firestore: $error');
      // Handle the error as needed (e.g., show an error message to the user).
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      if (user != null) {
        final userId = user?.uid;
        final DocumentReference expenseRef = _firestoreInstance
            .collection('users')
            .doc(userId)
            .collection('expenses')
            .doc(expenseId);

        await expenseRef.delete();
      }
    } catch (error) {
      print('Error deleting expense from Firestore: $error');
      // Handle the error as needed (e.g., show an error message to the user).
    }
  }
}
