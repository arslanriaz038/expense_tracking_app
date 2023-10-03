// import 'dart:developer';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:mommy_ai/models/chat_message_model.dart';
// import 'package:mommy_ai/models/child_model.dart';
// import 'package:mommy_ai/models/conversation_model.dart';
// import 'package:mommy_ai/models/faq_model.dart';
// import 'package:mommy_ai/utils/constants/firebase_constants.dart';

// class FirebaseServices {
//   final int _maxConversations = 4;
//   final _firestoreInstance = FirebaseFirestore.instance;

//   DocumentReference? childrenDocRef;

//   Future<List<ConversationModel>?> getAllConversations(String userId) async {
//     final List<ConversationModel> conversationData = [];

//     try {
//       final QuerySnapshot snapshot = await _firestoreInstance
//           .collection(FirebaseCollections.conversations)
//           .where('userId', isEqualTo: userId)
//           .orderBy('updatedAt', descending: true)
//           .get();
//       conversationData.addAll(
//         snapshot.docs.map(
//           (document) {
//             return ConversationModel.fromDocument(
//               document,
//             );
//           },
//         ),
//       );

//       return conversationData;
//     } catch (error) {
//       log('Error retrieving conversations: $error');
//       return null;
//     }
//   }

//   Future<String?> saveConversation(
//     String userId,
//     List<ChatMessageModel> messages,
//   ) async {
//     try {
//       final CollectionReference conversations =
//           _firestoreInstance.collection(FirebaseCollections.conversations);

//       final Map<String, dynamic> data = {
//         'userId': userId,
//         'updatedAt': FieldValue.serverTimestamp(),
//         'createdAt': FieldValue.serverTimestamp(),
//         'messages': messages.map((message) => message.toMap()).toList(),
//       };
//       final doc = await conversations.add(data);

//       final QuerySnapshot snapshot = await conversations
//           .where('userId', isEqualTo: userId)
//           .orderBy('updatedAt', descending: true)
//           .get();

//       if (snapshot.docs.length > _maxConversations) {
//         await snapshot.docs.last.reference.delete();
//       }

//       return doc.id;
//     } catch (error) {
//       log('Error: $error');
//     }
//     return null;
//   }

//   Future<void> updateConversation({
//     required List<ChatMessageModel> messages,
//     required String docId,
//     String? selectedChild,
//   }) async {
//     try {
//       final CollectionReference conversations = FirebaseFirestore.instance
//           .collection(FirebaseCollections.conversations);

//       final Map<String, dynamic> data = {
//         'updatedAt': Timestamp.now().toDate(),
//         'messages': messages.map((message) => message.toMap()).toList(),
//       };
//       if (selectedChild != null) {
//         data.putIfAbsent('selected_child', () => selectedChild);
//       }
//       await conversations.doc(docId).update(data);
//       log('Conversation updated successfully!');
//     } catch (error) {
//       log('Error updating conversation: $error');
//     }
//   }

//   Future<List<ChildModel>?> getAllChildren(String userId) async {
//     try {
//       final DocumentReference userRef =
//           FirebaseFirestore.instance.collection('users').doc(userId);

//       final QuerySnapshot querySnapshot =
//           await userRef.collection(FirebaseCollections.children).get();

//       final List<ChildModel> childrenList =
//           querySnapshot.docs.map((DocumentSnapshot<Object?> documentSnapshot) {
//         return ChildModel.fromDocument(documentSnapshot);
//       }).toList();

//       return childrenList;
//     } catch (e) {
//       log('Error retrieving children: $e');
//       return [];
//     }
//   }

//   Future<ChildModel?> getChild(String userId, String childId) async {
//     try {
//       final DocumentReference userRef =
//           FirebaseFirestore.instance.collection('users').doc(userId);

//       final DocumentSnapshot childSnapshot = await userRef
//           .collection(FirebaseCollections.children)
//           .doc(childId)
//           .get();

//       if (childSnapshot.exists) {
//         return ChildModel.fromDocument(childSnapshot);
//       } else {
//         return null; // Child document does not exist
//       }
//     } catch (e) {
//       log('Error retrieving child: $e');
//       return null;
//     }
//   }

//   Future<void> resetPassword(String email) async {
//     try {
//       await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
//     } catch (error) {
//       rethrow;
//     }
//   }

//   Future<List<FaqModel>?> getAllFaqs() async {
//     final List<FaqModel> faqsData = [];

//     try {
//       final QuerySnapshot snapshot = await _firestoreInstance
//           .collection(FirebaseCollections.faqs)
//           .orderBy('updatedAt', descending: true)
//           .get();
//       faqsData.addAll(
//         snapshot.docs.map(
//           (document) {
//             return FaqModel.fromDocument(
//               document,
//             );
//           },
//         ),
//       );

//       return faqsData;
//     } catch (error) {
//       return null;
//     }
//   }
// }
