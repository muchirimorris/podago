import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';
import '../services/simple_storage_service.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;



  // Stream of notifications for the current user
  Stream<List<NotificationModel>> getUserNotifications() async* {
    final session = await SimpleStorageService.getUserSession();
    final userId = session?['userId'];

    if (userId == null) {
      yield [];
      return;
    }

    yield* _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  // Count unread notifications
  Stream<int> getUnreadCount() async* {
    final session = await SimpleStorageService.getUserSession();
    final userId = session?['userId'];

    if (userId == null) {
      yield 0;
      return;
    }

    yield* _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  // Mark ALL as read
  Future<void> markAllAsRead() async {
    final session = await SimpleStorageService.getUserSession();
    final userId = session?['userId'];

    if (userId == null) return;

    final batch = _db.batch();
    final unreadDocs = await _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in unreadDocs.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }
}
