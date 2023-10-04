import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracking_app/consts/firebase_constants.dart';
import 'package:expense_tracking_app/models/user_model.dart';

class UserServices {
  Future<UserModel?> getUserFromId(String id) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection(FirebaseCollections.users);
    final DocumentSnapshot document = await usersCollection.doc(id).get();
    if (document.exists) {
      return UserModel.fromDocument(document);
    }
    return null;
  }

  Future<UserModel> signUpUser({
    required String id,
    String? email,
    String? name,
    String? phone,
    String? profilePictureUrl,
    String? providerId,
  }) async {
    final user = await getUserFromId(id);
    if (user != null) {
      return user;
    } else {
      final user = UserModel(
        id: id,
        email: email,
        name: name,
        profilePictureUrl: profilePictureUrl,
        createdAt: Timestamp.now().toDate(),
        updatedAt: Timestamp.now().toDate(),
        providerId: providerId,
      );
      await _createUser(user);
      return user;
    }
  }

  Future<void> _createUser(UserModel user) async {
    try {
      await FirebaseFirestore.instance
          .collection(FirebaseCollections.users)
          .doc(user.id)
          .set(
            user.toDocument(),
          );
    } catch (e) {
      rethrow;
    }
  }
}
