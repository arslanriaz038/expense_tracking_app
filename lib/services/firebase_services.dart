import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracking_app/consts/firebase_constants.dart';
import 'package:expense_tracking_app/models/expense.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServices {
  final int _maxConversations = 4;
  final _firestoreInstance = FirebaseFirestore.instance;

  DocumentReference? childrenDocRef;

  // Future<List<ConversationModel>?> getAllConversations(String userId) async {
  //   final List<ConversationModel> conversationData = [];

  //   try {
  //     final QuerySnapshot snapshot = await _firestoreInstance
  //         .collection(FirebaseCollections.conversations)
  //         .where('userId', isEqualTo: userId)
  //         .orderBy('updatedAt', descending: true)
  //         .get();
  //     conversationData.addAll(
  //       snapshot.docs.map(
  //         (document) {
  //           return ConversationModel.fromDocument(
  //             document,
  //           );
  //         },
  //       ),
  //     );

  //     return conversationData;
  //   } catch (error) {
  //     log('Error retrieving conversations: $error');
  //     return null;
  //   }
  // }

  Future<void> saveExpense(Expense expense) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userId = user.uid;
        final CollectionReference expenseRef = FirebaseFirestore.instance
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

  // Future<void> updateConversation({
  //   required List<ChatMessageModel> messages,
  //   required String docId,
  //   String? selectedChild,
  // }) async {
  //   try {
  //     final CollectionReference conversations = FirebaseFirestore.instance
  //         .collection(FirebaseCollections.conversations);

  //     final Map<String, dynamic> data = {
  //       'updatedAt': Timestamp.now().toDate(),
  //       'messages': messages.map((message) => message.toMap()).toList(),
  //     };
  //     if (selectedChild != null) {
  //       data.putIfAbsent('selected_child', () => selectedChild);
  //     }
  //     await conversations.doc(docId).update(data);
  //     log('Conversation updated successfully!');
  //   } catch (error) {
  //     log('Error updating conversation: $error');
  //   }
  // }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (error) {
      rethrow;
    }
  }
}
