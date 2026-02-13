import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a notification
  static Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? complainId,
  }) async {
    try {
      final notificationId = _firestore.collection('notifications').doc().id;
      final notification = NotificationModel(
        id: notificationId,
        title: title,
        message: message,
        type: type,
        timestamp: DateTime.now(),
        isRead: false,
        complainId: complainId,
        userId: userId,
      );

      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .set(notification.toMap());

      print('✅ Notification created: $notificationId');
    } catch (e) {
      print('❌ Error creating notification: $e');
      rethrow;
    }
  }

  // Get all notifications for current user
  static Stream<List<NotificationModel>> getUserNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data()))
          .toList();
    });
  }

  // Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      rethrow;
    }
  }

  // Mark all notifications as read
  static Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      print('✅ All notifications marked as read');
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
      rethrow;
    }
  }

  // Delete a notification
  static Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      print('✅ Notification deleted: $notificationId');
    } catch (e) {
      print('❌ Error deleting notification: $e');
      rethrow;
    }
  }

  // Delete all notifications for user
  static Future<void> deleteAllNotifications(String userId) async {
    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in notifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ All notifications deleted');
    } catch (e) {
      print('❌ Error deleting all notifications: $e');
      rethrow;
    }
  }

  // Create notification when complaint status changes
  static Future<void> createStatusChangeNotification({
    required String userId,
    required String complainId,
    required String issueType,
    required String oldStatus,
    required String newStatus,
  }) async {
    String title;
    String message;
    String type;

    switch (newStatus) {
      case 'Assigned':
        title = 'Complaint Assigned';
        message = 'Your "$issueType" complaint has been assigned to the department.';
        type = 'assigned';
        break;
      case 'In Progress':
        title = 'Status Update';
        message = 'Work has started on your "$issueType" complaint.';
        type = 'progress';
        break;
      case 'Resolved':
        title = 'Complaint Resolved';
        message = 'Your "$issueType" complaint has been marked as resolved.';
        type = 'resolved';
        break;
      default:
        title = 'Status Update';
        message = 'Your "$issueType" complaint status changed to $newStatus.';
        type = 'progress';
    }

    await createNotification(
      userId: userId,
      title: title,
      message: message,
      type: type,
      complainId: complainId,
    );
  }
}

