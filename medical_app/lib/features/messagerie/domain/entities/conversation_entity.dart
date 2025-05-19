import 'package:equatable/equatable.dart';

class ConversationEntity extends Equatable {
  final String? id;
  final String patientId;
  final String doctorId;
  final String patientName;
  final String doctorName;
  final String lastMessage;
  final String lastMessageType;
  final DateTime lastMessageTime;
  final String? lastMessageSenderId;
  final List<String> lastMessageReadBy;
  final String? lastMessageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ConversationEntity({
    this.id,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.doctorName,
    this.lastMessage = '',
    this.lastMessageType = 'text',
    required this.lastMessageTime,
    this.lastMessageSenderId,
    this.lastMessageReadBy = const [],
    this.lastMessageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConversationEntity.create({
    String? id,
    required String patientId,
    required String doctorId,
    required String patientName,
    required String doctorName,
    String lastMessage = '',
    String lastMessageType = 'text',
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    List<String>? lastMessageReadBy,
    String? lastMessageUrl,
    bool isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return ConversationEntity(
      id: id,
      patientId: patientId,
      doctorId: doctorId,
      patientName: patientName,
      doctorName: doctorName,
      lastMessage: lastMessage,
      lastMessageType: lastMessageType,
      lastMessageTime: lastMessageTime ?? now,
      lastMessageSenderId: lastMessageSenderId,
      lastMessageReadBy: lastMessageReadBy ?? [],
      lastMessageUrl: lastMessageUrl,
      isActive: isActive,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  @override
  List<Object?> get props => [
    id,
    patientId,
    doctorId,
    patientName,
    doctorName,
    lastMessage,
    lastMessageType,
    lastMessageTime,
    lastMessageSenderId,
    lastMessageReadBy,
    lastMessageUrl,
    isActive,
    createdAt,
    updatedAt,
  ];
}
