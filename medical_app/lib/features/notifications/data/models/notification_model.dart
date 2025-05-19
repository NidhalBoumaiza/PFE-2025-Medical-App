import 'package:medical_app/features/notifications/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required String id,
    required String title,
    required String body,
    required String senderId,
    required String recipientId,
    required NotificationType type,
    String? appointmentId,
    String? prescriptionId,
    required DateTime createdAt,
    bool isRead = false,
    Map<String, dynamic>? data,
  }) : super(
         id: id,
         title: title,
         body: body,
         senderId: senderId,
         recipientId: recipientId,
         type: type,
         appointmentId: appointmentId,
         prescriptionId: prescriptionId,
         createdAt: createdAt,
         isRead: isRead,
         data: data,
       );

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] as String? ?? json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      senderId: json['senderId'] as String,
      recipientId: json['recipientId'] as String,
      type: _parseNotificationType(json['type'] as String),
      appointmentId: json['appointmentId'] as String?,
      prescriptionId: json['prescriptionId'] as String?,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      data:
          json['data'] != null
              ? Map<String, dynamic>.from(json['data'] as Map)
              : null,
    );
  }

  static NotificationType _parseNotificationType(String type) {
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
      case 'newAppointment':
        return NotificationType.newAppointment;
      case 'appointmentAccepted':
        return NotificationType.appointmentAccepted;
      case 'appointmentRejected':
        return NotificationType.appointmentRejected;
      case 'rating':
        return NotificationType.rating;
      default:
        return NotificationType.general;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'body': body,
      'senderId': senderId,
      'recipientId': recipientId,
      'type': type.toString().split('.').last,
      'isRead': isRead,
    };

    if (id.isNotEmpty) {
      data['_id'] = id;
    }

    if (appointmentId != null) {
      data['appointmentId'] = appointmentId;
    }

    if (prescriptionId != null) {
      data['prescriptionId'] = prescriptionId;
    }

    if (this.data != null) {
      data['data'] = this.data;
    }

    return data;
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? senderId,
    String? recipientId,
    NotificationType? type,
    String? appointmentId,
    String? prescriptionId,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      type: type ?? this.type,
      appointmentId: appointmentId ?? this.appointmentId,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}
