import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracking_app/consts/expense_constants.dart';
import 'package:expense_tracking_app/utils/money_format.dart';

class Expense {
  final String? id;
  final String description;
  final String amount;
  final DateTime date;
  final String category;
  final ExpenseType type;
  final String? receiptImageUrl;
  bool isLoading;

  Expense({
    this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    this.type = ExpenseType.expense,
    this.receiptImageUrl,
    this.isLoading = false,
  });

  double? get amountValue => MoneyFormat.parse(amount);

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'amount': amount,
      'date': date,
      'category': category,
      'type': type.firestoreValue,
      'receiptImageUrl': receiptImageUrl,
    };
  }

  factory Expense.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Expense(
      id: snapshot.id,
      description: data['description'] ?? '',
      amount: data['amount']?.toString() ?? '',
      date: (data['date'] as Timestamp).toDate(),
      category: data['category'] ?? 'Other',
      type: ExpenseType.fromFirestore(data['type'] as String?),
      receiptImageUrl: data['receiptImageUrl'],
    );
  }

  Expense copyWith({
    String? id,
    String? description,
    String? amount,
    DateTime? date,
    String? category,
    ExpenseType? type,
    String? receiptImageUrl,
    bool? isLoading,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      type: type ?? this.type,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
