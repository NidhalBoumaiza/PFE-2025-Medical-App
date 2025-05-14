import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medical_app/core/error/exceptions.dart';
import 'package:medical_app/features/notifications/data/models/notification_model.dart';
import 'package:medical_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:medical_app/features/notifications/utils/notification_utils.dart';

abstract class NotificationRemoteDataSource {
  /// Get all notifications for a specific user
  Future<List<NotificationModel>> getNotifications(String userId);

  /// Send a notification
  Future<Unit> sendNotification({
    required String title,
    required String body,
    required String senderId,
    required String recipientId,
    required NotificationType type,
    String? appointmentId,
    String? prescriptionId,
    String? ratingId,
    Map<String, dynamic>? data,
  });

  /// Mark a notification as read
  Future<Unit> markNotificationAsRead(String notificationId);

  /// Mark all notifications as read for a specific user
  Future<Unit> markAllNotificationsAsRead(String userId);

  /// Delete a notification
  Future<Unit> deleteNotification(String notificationId);

  /// Get unread notifications count
  Future<int> getUnreadNotificationsCount(String userId);

  /// Setup FCM to receive notifications
  Future<String?> setupFCM();

  /// Save FCM token to the server
  Future<Unit> saveFCMToken(String userId, String token);

  /// Stream of notifications for a specific user
  Stream<List<NotificationModel>> notificationsStream(String userId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseMessaging firebaseMessaging;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseMessaging,
    required this.flutterLocalNotificationsPlugin,
  });

  @override
  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final notificationsQuery =
          await firestore
              .collection('notifications')
              .where('recipientId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      return notificationsQuery.docs
          .map(
            (doc) => NotificationModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch notifications: $e');
    }
  }

  @override
  Future<Unit> sendNotification({
    required String title,
    required String body,
    required String senderId,
    required String recipientId,
    required NotificationType type,
    String? appointmentId,
    String? prescriptionId,
    String? ratingId,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('Sending notification to $recipientId from $senderId');

      // Get sender info to include name in notification
      String senderName = '';
      try {
        final senderDoc =
            await firestore.collection('users').doc(senderId).get();
        if (senderDoc.exists) {
          senderName =
              '${senderDoc.data()?['name'] ?? ''} ${senderDoc.data()?['lastName'] ?? ''}'
                  .trim();
        }

        if (senderName.isEmpty && data != null) {
          senderName = data['doctorName'] ?? data['patientName'] ?? '';
        }

        print('Sender name: $senderName');
      } catch (e) {
        print('Error getting sender info: $e');
      }

      // Create notification model
      final notification = NotificationModel(
        id: '', // Firestore will generate ID
        title: title,
        body: body,
        senderId: senderId,
        recipientId: recipientId,
        type: type,
        appointmentId: appointmentId,
        prescriptionId: prescriptionId,
        ratingId: ratingId,
        createdAt: DateTime.now(),
        isRead: false,
        data:
            data != null
                ? {...data, 'senderName': senderName}
                : {'senderName': senderName},
      );

      // Save notification to Firestore
      final docRef = await firestore.collection('notifications').add({
        'title': notification.title,
        'body': notification.body,
        'senderId': notification.senderId,
        'recipientId': notification.recipientId,
        'type': NotificationUtils.notificationTypeToString(notification.type),
        'appointmentId': notification.appointmentId,
        'prescriptionId': notification.prescriptionId,
        'ratingId': notification.ratingId,
        'createdAt': notification.createdAt.toIso8601String(),
        'isRead': notification.isRead,
        'data': notification.data,
      });

      print('Notification saved to Firestore with ID: ${docRef.id}');

      // Get recipient FCM token
      final userDoc =
          await firestore.collection('users').doc(recipientId).get();

      if (userDoc.exists && userDoc.data()?['fcmToken'] != null) {
        final fcmToken = userDoc.data()?['fcmToken'];
        print('Found FCM token for recipient: $fcmToken');

        // Create payload with enhanced data
        final payload = {
          'notification': {'title': title, 'body': body},
          'data': {
            'notificationId': docRef.id,
            'type': NotificationUtils.notificationTypeToString(type),
            'senderId': senderId,
            'recipientId': recipientId,
            'senderName': senderName,
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
        };

        if (appointmentId != null) {
          payload['data'] = {
            ...payload['data'] as Map<String, dynamic>,
            'appointmentId': appointmentId,
          };
        }
        if (prescriptionId != null) {
          payload['data'] = {
            ...payload['data'] as Map<String, dynamic>,
            'prescriptionId': prescriptionId,
          };
        }
        if (ratingId != null) {
          payload['data'] = {
            ...payload['data'] as Map<String, dynamic>,
            'ratingId': ratingId,
          };
        }

        // Add any additional data
        if (data != null) {
          payload['data'] = {
            ...payload['data'] as Map<String, dynamic>,
            ...data,
          };
        }

        // Send FCM payload through Cloud Functions
        await firestore.collection('fcm_requests').add({
          'token': fcmToken,
          'payload': payload,
          'timestamp': FieldValue.serverTimestamp(),
        });

        print('FCM request added to queue');
      } else {
        print('No FCM token found for recipient: $recipientId');
      }

      return unit;
    } catch (e) {
      print('Error sending notification: $e');
      throw ServerException('Failed to send notification: $e');
    }
  }

  @override
  Future<Unit> markNotificationAsRead(String notificationId) async {
    try {
      await firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
      return unit;
    } catch (e) {
      throw ServerException('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<Unit> markAllNotificationsAsRead(String userId) async {
    try {
      final batch = firestore.batch();
      final notificationsQuery =
          await firestore
              .collection('notifications')
              .where('recipientId', isEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .get();

      for (var doc in notificationsQuery.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      return unit;
    } catch (e) {
      throw ServerException('Failed to mark all notifications as read: $e');
    }
  }

  @override
  Future<Unit> deleteNotification(String notificationId) async {
    try {
      await firestore.collection('notifications').doc(notificationId).delete();
      return unit;
    } catch (e) {
      throw ServerException('Failed to delete notification: $e');
    }
  }

  @override
  Future<int> getUnreadNotificationsCount(String userId) async {
    try {
      final notificationsQuery =
          await firestore
              .collection('notifications')
              .where('recipientId', isEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .count()
              .get();

      return notificationsQuery.count ?? 0;
    } catch (e) {
      throw ServerException('Failed to get unread notifications count: $e');
    }
  }

  @override
  Future<String?> setupFCM() async {
    try {
      // Request permission
      final settings = await firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token
        final token = await firebaseMessaging.getToken();

        // Initialize local notifications
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          description: 'This channel is used for important notifications.',
          importance: Importance.high,
        );

        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(channel);

        return token;
      } else {
        throw ServerException('FCM permissions denied');
      }
    } catch (e) {
      throw ServerException('Failed to setup FCM: $e');
    }
  }

  @override
  Future<Unit> saveFCMToken(String userId, String token) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'fcmToken': token,
      });
      return unit;
    } catch (e) {
      throw ServerException('Failed to save FCM token: $e');
    }
  }

  @override
  Stream<List<NotificationModel>> notificationsStream(String userId) {
    try {
      return firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map(
                      (doc) => NotificationModel.fromJson({
                        'id': doc.id,
                        ...doc.data(),
                      }),
                    )
                    .toList(),
          );
    } catch (e) {
      throw ServerException('Failed to get notifications stream: $e');
    }
  }
}
