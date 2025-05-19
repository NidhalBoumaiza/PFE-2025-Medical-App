import 'package:dartz/dartz.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  /// Get all notifications for the current user
  Future<Either<Failure, List<NotificationEntity>>> getNotifications();

  /// Send a notification
  Future<Either<Failure, Unit>> sendNotification({
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
  Future<Either<Failure, Unit>> markNotificationAsRead(String notificationId);

  /// Mark all notifications as read for the current user
  Future<Either<Failure, Unit>> markAllNotificationsAsRead();

  /// Delete a notification
  Future<Either<Failure, Unit>> deleteNotification(String notificationId);

  /// Get unread notifications count
  Future<Either<Failure, int>> getUnreadNotificationsCount();

  /// Initialize OneSignal
  Future<Either<Failure, Unit>> initializeOneSignal();

  /// Set external user ID for OneSignal
  Future<Either<Failure, Unit>> setExternalUserId(String userId);

  /// Get OneSignal player ID
  Future<Either<Failure, String?>> getOneSignalPlayerId();

  /// Save OneSignal player ID to the backend
  Future<Either<Failure, Unit>> saveOneSignalPlayerId(String userId);

  /// Clear OneSignal user data for logout
  Future<Either<Failure, Unit>> logout();
}
