import 'package:medical_app/features/notifications/domain/entities/notification_entity.dart';

class NotificationUtils {
  /// Convert a string to NotificationType enum
  static NotificationType stringToNotificationType(String type) {
    switch (type) {
      case 'general':
        return NotificationType.general;
      case 'appointment':
        return NotificationType.appointment;
      case 'prescription':
        return NotificationType.prescription;
      case 'message':
        return NotificationType.message;
      case 'medical_record':
        return NotificationType.medical_record;
      default:
        return NotificationType.general;
    }
  }

  /// Convert NotificationType enum to string
  static String notificationTypeToString(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return 'general';
      case NotificationType.appointment:
        return 'appointment';
      case NotificationType.prescription:
        return 'prescription';
      case NotificationType.message:
        return 'message';
      case NotificationType.medical_record:
        return 'medical_record';
    }
  }

  /// Get notification title based on type
  static String getNotificationTitle(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return 'Notification';
      case NotificationType.appointment:
        return 'Appointment';
      case NotificationType.prescription:
        return 'Prescription';
      case NotificationType.message:
        return 'New Message';
      case NotificationType.medical_record:
        return 'Medical Record';
    }
  }
}
