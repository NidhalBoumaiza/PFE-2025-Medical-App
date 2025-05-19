import 'package:dartz/dartz.dart';
import 'package:medical_app/constants.dart';
import 'package:medical_app/core/error/exceptions.dart';
import 'package:medical_app/features/notifications/data/models/notification_model.dart';
import 'package:medical_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:medical_app/features/notifications/utils/notification_utils.dart';
import 'package:medical_app/features/notifications/utils/onesignal_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class NotificationRemoteDataSource {
  /// Get all notifications for a specific user
  Future<List<NotificationModel>> getNotifications();

  /// Send a notification
  Future<Unit> sendNotification({
    required String title,
    required String body,
    required String senderId,
    required String recipientId,
    required NotificationType type,
    String? appointmentId,
    String? prescriptionId,
    Map<String, dynamic>? data,
  });

  /// Mark a notification as read
  Future<Unit> markNotificationAsRead(String notificationId);

  /// Mark all notifications as read
  Future<Unit> markAllNotificationsAsRead();

  /// Delete a notification
  Future<Unit> deleteNotification(String notificationId);

  /// Get unread notifications count
  Future<int> getUnreadNotificationsCount();

  /// Initialize OneSignal
  Future<void> initializeOneSignal();

  /// Set external user ID after login
  Future<void> setExternalUserId(String userId);

  /// Get OneSignal player ID
  Future<String?> getOneSignalPlayerId();

  /// Save OneSignal player ID to the server
  Future<Unit> saveOneSignalPlayerId(String userId);

  /// Remove external user ID when logging out
  Future<void> logout();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final http.Client client;
  final OneSignalService oneSignalService;

  NotificationRemoteDataSourceImpl({
    required this.client,
    required this.oneSignalService,
  });

  // Helper method to get the auth token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('TOKEN');
  }

  @override
  Future<void> initializeOneSignal() async {
    await oneSignalService.init();
  }

  @override
  Future<void> setExternalUserId(String userId) async {
    await oneSignalService.setExternalUserId(userId);
  }

  @override
  Future<String?> getOneSignalPlayerId() async {
    return await oneSignalService.getPlayerId();
  }

  @override
  Future<Unit> saveOneSignalPlayerId(String userId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ServerException(message: 'Authentication token not found');
      }

      final playerId = await oneSignalService.getPlayerId();
      if (playerId == null) {
        throw ServerException(message: 'Failed to get OneSignal player ID');
      }

      final response = await client.patch(
        Uri.parse(AppConstants.updateOneSignalPlayerIdEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'oneSignalPlayerId': playerId}),
      );

      if (response.statusCode != 200) {
        final errorBody = json.decode(response.body);
        throw ServerException(
          message: errorBody['message'] ?? 'Failed to save OneSignal player ID',
        );
      }

      return unit;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to save OneSignal player ID: $e');
    }
  }

  @override
  Future<void> logout() async {
    await oneSignalService.logout();
  }

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ServerException(message: 'Authentication token not found');
      }

      final response = await client.get(
        Uri.parse(AppConstants.myNotificationsEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        final errorBody = json.decode(response.body);
        throw ServerException(
          message: errorBody['message'] ?? 'Failed to fetch notifications',
        );
      }

      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> notificationsData =
          responseData['data']['notifications'];

      return notificationsData.map((notificationData) {
        // Convert MongoDB notification to NotificationModel
        return NotificationModel.fromJson(notificationData);
      }).toList();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to fetch notifications: $e');
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
    Map<String, dynamic>? data,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ServerException(message: 'Authentication token not found');
      }

      // Note: The actual sending of push notifications is handled by the backend via OneSignal
      // Here we just need to create the notification in the database
      final Map<String, dynamic> requestData = {
        'title': title,
        'body': body,
        'senderId': senderId,
        'recipientId': recipientId,
        'type': NotificationUtils.notificationTypeToString(type),
      };

      if (appointmentId != null) {
        requestData['appointmentId'] = appointmentId;
      }

      if (prescriptionId != null) {
        requestData['prescriptionId'] = prescriptionId;
      }

      if (data != null) {
        requestData['data'] = data;
      }

      // This endpoint should be implemented on your backend to create a notification
      // and send it via OneSignal using the createNotification method we saw in the backend code
      final response = await client.post(
        Uri.parse(AppConstants.notificationsEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode != 201) {
        final errorBody = json.decode(response.body);
        throw ServerException(
          message: errorBody['message'] ?? 'Failed to send notification',
        );
      }

      return unit;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to send notification: $e');
    }
  }

  @override
  Future<Unit> markNotificationAsRead(String notificationId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ServerException(message: 'Authentication token not found');
      }

      final response = await client.patch(
        Uri.parse(
          '${AppConstants.markNotificationReadEndpoint}/$notificationId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        final errorBody = json.decode(response.body);
        throw ServerException(
          message:
              errorBody['message'] ?? 'Failed to mark notification as read',
        );
      }

      return unit;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to mark notification as read: $e');
    }
  }

  @override
  Future<Unit> markAllNotificationsAsRead() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ServerException(message: 'Authentication token not found');
      }

      final response = await client.patch(
        Uri.parse(AppConstants.markAllNotificationsReadEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        final errorBody = json.decode(response.body);
        throw ServerException(
          message:
              errorBody['message'] ??
              'Failed to mark all notifications as read',
        );
      }

      return unit;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to mark all notifications as read: $e',
      );
    }
  }

  @override
  Future<Unit> deleteNotification(String notificationId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ServerException(message: 'Authentication token not found');
      }

      final response = await client.delete(
        Uri.parse('${AppConstants.notificationsEndpoint}/$notificationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 204) {
        final errorBody = json.decode(response.body);
        throw ServerException(
          message: errorBody['message'] ?? 'Failed to delete notification',
        );
      }

      return unit;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to delete notification: $e');
    }
  }

  @override
  Future<int> getUnreadNotificationsCount() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ServerException(message: 'Authentication token not found');
      }

      final response = await client.get(
        Uri.parse(AppConstants.unreadNotificationsCountEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        final errorBody = json.decode(response.body);
        throw ServerException(
          message:
              errorBody['message'] ??
              'Failed to get unread notifications count',
        );
      }

      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData['data']['count'] as int;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to get unread notifications count: $e',
      );
    }
  }
}
