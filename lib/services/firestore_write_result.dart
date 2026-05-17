class FirestoreWriteResult {
  const FirestoreWriteResult({
    required this.id,
    required this.pendingSync,
  });

  final String id;
  final bool pendingSync;
}
