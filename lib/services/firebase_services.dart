import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracking_app/models/expense.dart';
import 'package:expense_tracking_app/models/monthly_budget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class FirebaseServices {
  final _firestoreInstance = FirebaseFirestore.instance;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  CollectionReference<Map<String, dynamic>>? get _expensesRef {
    final userId = _currentUser?.uid;
    if (userId == null) return null;
    return _firestoreInstance
        .collection('users')
        .doc(userId)
        .collection('expenses');
  }

  DocumentReference<Map<String, dynamic>>? get _userDocRef {
    final userId = _currentUser?.uid;
    if (userId == null) return null;
    return _firestoreInstance.collection('users').doc(userId);
  }

  Stream<List<Expense>> watchExpenses() {
    final expenseRef = _expensesRef;
    if (expenseRef == null) {
      return Stream.value([]);
    }

    return expenseRef.orderBy('date', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((document) => Expense.fromSnapshot(document))
              .toList(),
        );
  }

  Future<List<Expense>> getAllExpenses() async {
    final expenseRef = _expensesRef;
    if (expenseRef == null) return [];

    try {
      final querySnapshot =
          await expenseRef.orderBy('date', descending: true).get();
      return querySnapshot.docs
          .map((document) => Expense.fromSnapshot(document))
          .toList();
    } catch (e) {
      throw Exception('Error getting expenses: $e');
    }
  }

  Future<void> saveExpense(Expense expense) async {
    final expenseRef = _expensesRef;
    if (expenseRef == null) {
      throw Exception('User not signed in');
    }

    try {
      await expenseRef.add(expense.toMap());
    } catch (error) {
      throw Exception('Error saving expense: $error');
    }
  }

  Future<String?> uploadReceiptImage(String imagePath) async {
    final userId = _currentUser?.uid;
    if (userId == null) return null;

    final storageRef = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('receipts')
        .child(userId)
        .child(DateTime.now().millisecondsSinceEpoch.toString());
    final uploadTask = storageRef.putFile(File(imagePath));
    await uploadTask.whenComplete(() => null);
    return storageRef.getDownloadURL();
  }

  Future<void> updateExpense(String expenseId, Expense updatedExpense) async {
    final expenseRef = _expensesRef;
    if (expenseRef == null) {
      throw Exception('User not signed in');
    }

    try {
      await expenseRef.doc(expenseId).update(updatedExpense.toMap());
    } catch (error) {
      throw Exception('Error updating expense: $error');
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    final expenseRef = _expensesRef;
    if (expenseRef == null) {
      throw Exception('User not signed in');
    }

    try {
      await expenseRef.doc(expenseId).delete();
    } catch (error) {
      throw Exception('Error deleting expense: $error');
    }
  }

  Future<MonthlyBudget> getMonthlyBudget() async {
    final userDoc = _userDocRef;
    if (userDoc == null) return const MonthlyBudget();

    try {
      final snapshot = await userDoc.get();
      final data = snapshot.data();
      if (data == null) return const MonthlyBudget();
      return MonthlyBudget.fromMap(
        data['monthlyBudget'] as Map<String, dynamic>?,
      );
    } catch (e) {
      throw Exception('Error loading budget: $e');
    }
  }

  Future<void> saveMonthlyBudget(MonthlyBudget budget) async {
    final userDoc = _userDocRef;
    if (userDoc == null) {
      throw Exception('User not signed in');
    }

    try {
      await userDoc.set(
        {'monthlyBudget': budget.toMap()},
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Error saving budget: $e');
    }
  }

  Stream<List<String>> watchCustomCategories() {
    final userDoc = _userDocRef;
    if (userDoc == null) {
      return Stream.value([]);
    }

    return userDoc.snapshots().map((snapshot) {
      final raw = snapshot.data()?['customCategories'];
      if (raw is! List) return <String>[];
      return raw.map((item) => item.toString()).toList();
    });
  }

  Future<List<String>> getCustomCategories() async {
    final userDoc = _userDocRef;
    if (userDoc == null) return [];

    try {
      final snapshot = await userDoc.get();
      final raw = snapshot.data()?['customCategories'];
      if (raw is! List) return [];
      return raw.map((item) => item.toString()).toList();
    } catch (e) {
      throw Exception('Error loading categories: $e');
    }
  }

  Future<void> saveCustomCategories(List<String> categories) async {
    final userDoc = _userDocRef;
    if (userDoc == null) {
      throw Exception('User not signed in');
    }

    try {
      await userDoc.set(
        {'customCategories': categories},
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Error saving categories: $e');
    }
  }

  Future<void> deleteAllUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not signed in');
    }

    final expensesRef = _firestoreInstance
        .collection('users')
        .doc(userId)
        .collection('expenses');

    await _deleteCollectionInBatches(expensesRef);
    await _firestoreInstance.collection('users').doc(userId).delete();
    await _deleteReceiptStorage(userId);
  }

  Future<void> _deleteCollectionInBatches(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    const batchSize = 400;

    while (true) {
      final snapshot = await collection.limit(batchSize).get();
      if (snapshot.docs.isEmpty) break;

      final batch = _firestoreInstance.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  Future<void> _deleteReceiptStorage(String userId) async {
    try {
      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('receipts')
          .child(userId);

      await _deleteStorageFolder(storageRef);
    } catch (_) {}
  }

  Future<void> _deleteStorageFolder(
    firebase_storage.Reference folderRef,
  ) async {
    final listing = await folderRef.listAll();

    for (final item in listing.items) {
      await item.delete();
    }

    for (final prefix in listing.prefixes) {
      await _deleteStorageFolder(prefix);
    }
  }
}
