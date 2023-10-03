// import 'dart:io';

// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:mommy_ai/utils/app_data.dart';

// class FireStoreServices {
//   Future<String> uploadUserProfileImage(File imageFile) async {
//     try {
//       final String fileName =
//           "${AppData.currentUser?.name}_${DateTime.now().millisecondsSinceEpoch}";

//       final Reference storageRef =
//           FirebaseStorage.instance.ref().child('user_profile_images/$fileName');

//       await storageRef.putFile(imageFile);

//       final String downloadUrl = await storageRef.getDownloadURL();

//       return downloadUrl;
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
