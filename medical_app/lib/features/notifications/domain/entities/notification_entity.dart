import 'package:equatable/equatable.dart';

enum NotificationType {
  general,
  appointment,
  prescription,
  message,
  medical_record,
  newAppointment,
  appointmentAccepted,
  appointmentRejected,
  rating,
  newPrescription,
}

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final String senderId;
  final String recipientId;
  final NotificationType type;
  final String? appointmentId;
  final String? prescriptionId;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.senderId,
    required this.recipientId,
    required this.type,
    this.appointmentId,
    this.prescriptionId,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  NotificationEntity copyWith({
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
    return NotificationEntity(
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

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    senderId,
    recipientId,
    type,
    appointmentId,
    prescriptionId,
    createdAt,
    isRead,
    data,
  ];
}
