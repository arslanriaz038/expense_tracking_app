import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String? id; // Unique identifier for the expense.
  final String description;
  final String amount;
  final DateTime date;
  final String category;
  final String? receiptImageUrl; // Optional receipt image URL.

  Expense({
    this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    this.receiptImageUrl,
  });

  // Convert an Expense object to a Map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date,
      'category': category,
      'receiptImageUrl': receiptImageUrl,
    };
  }

  factory Expense.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Expense(
      id: snapshot.id,
      description: data['description'] ?? '',
      amount: data['amount'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      category: data['category'] ?? '',
      receiptImageUrl: data['receiptImageUrl'],
    );
  }
}
