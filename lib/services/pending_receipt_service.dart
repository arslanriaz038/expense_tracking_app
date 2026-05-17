import 'package:expense_tracking_app/consts/my_preferences_constants.dart';
import 'package:expense_tracking_app/services/firebase_services.dart';
import 'package:expense_tracking_app/utils/network_status.dart';
import 'package:get_storage/get_storage.dart';

class PendingReceiptUpload {
  PendingReceiptUpload({
    required this.expenseId,
    required this.localPath,
  });

  final String expenseId;
  final String localPath;

  Map<String, dynamic> toMap() => {
        'expenseId': expenseId,
        'localPath': localPath,
      };

  factory PendingReceiptUpload.fromMap(Map<dynamic, dynamic> map) {
    return PendingReceiptUpload(
      expenseId: map['expenseId'] as String,
      localPath: map['localPath'] as String,
    );
  }
}

/// Receipt images require Firebase Storage (network). Queue locally and upload
/// when back online while expense data syncs via Firestore offline cache.
class PendingReceiptService {
  PendingReceiptService._();

  static final _storage = GetStorage();

  static Future<void> enqueue({
    required String expenseId,
    required String localPath,
  }) async {
    final pending = _readAll()
      ..removeWhere((item) => item.expenseId == expenseId)
      ..add(
        PendingReceiptUpload(expenseId: expenseId, localPath: localPath),
      );

    await _storage.write(
      MyPreferencesConstants.pendingReceiptUploads,
      pending.map((item) => item.toMap()).toList(),
    );
  }

  static Future<int> processQueue(FirebaseServices firebaseServices) async {
    if (!await NetworkStatus.isOnline) return 0;

    final pending = _readAll();
    if (pending.isEmpty) return 0;

    var uploaded = 0;

    for (final item in pending) {
      try {
        final url = await firebaseServices.uploadReceiptImage(item.localPath);
        if (url == null) continue;

        await firebaseServices.updateReceiptUrl(item.expenseId, url);
        await _remove(item.expenseId);
        uploaded++;
      } catch (_) {
        // Keep in queue; retry on next connectivity change.
      }
    }

    return uploaded;
  }

  static List<PendingReceiptUpload> _readAll() {
    final raw = _storage.read(MyPreferencesConstants.pendingReceiptUploads);
    if (raw is! List) return [];

    return raw
        .whereType<Map>()
        .map((item) => PendingReceiptUpload.fromMap(item))
        .toList();
  }

  static Future<void> _remove(String expenseId) async {
    final pending = _readAll()..removeWhere((item) => item.expenseId == expenseId);

    if (pending.isEmpty) {
      await _storage.remove(MyPreferencesConstants.pendingReceiptUploads);
      return;
    }

    await _storage.write(
      MyPreferencesConstants.pendingReceiptUploads,
      pending.map((item) => item.toMap()).toList(),
    );
  }
}
