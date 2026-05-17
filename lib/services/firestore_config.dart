import 'package:cloud_firestore/cloud_firestore.dart';

/// Enables Firestore offline persistence so reads/writes work without network
/// and sync automatically when connectivity returns.
Future<void> configureFirestore() async {
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
}
