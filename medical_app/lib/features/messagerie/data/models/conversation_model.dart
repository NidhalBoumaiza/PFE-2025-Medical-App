import 'package:medical_app/features/messagerie/domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  ConversationModel({
    String? id,
    required String patientId,
    required String doctorId,
    required String patientName,
    required String doctorName,
    String lastMessage = '',
    String lastMessageType = 'text',
    required DateTime lastMessageTime,
    String? lastMessageSenderId,
    List<String>? lastMessageReadBy,
    String? lastMessageUrl,
    bool isActive = true,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
         id: id,
         patientId: patientId,
         doctorId: doctorId,
         patientName: patientName,
         doctorName: doctorName,
         lastMessage: lastMessage,
         lastMessageType: lastMessageType,
         lastMessageTime: lastMessageTime,
         lastMessageSenderId: lastMessageSenderId,
         lastMessageReadBy: lastMessageReadBy ?? [],
         lastMessageUrl: lastMessageUrl,
         isActive: isActive,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['_id'] as String?,
      patientId: json['patientId'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      patientName: json['patientName'] as String? ?? 'Unknown Patient',
      doctorName: json['doctorName'] as String? ?? 'Unknown Doctor',
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageType: json['lastMessageType'] as String? ?? 'text',
      lastMessageTime: parseDateTime(json['lastMessageTime']),
      lastMessageSenderId: json['lastMessageSenderId'] as String?,
      lastMessageReadBy:
          json['lastMessageReadBy'] != null
              ? List<String>.from(json['lastMessageReadBy'] as List)
              : [],
      lastMessageUrl: json['lastMessageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
    );
  }

  static DateTime parseDateTime(dynamic dateValue) {
    if (dateValue == null) {
      return DateTime.now();
    }

    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    } else if (dateValue is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    final data = {
      'patientId': patientId,
      'doctorId': doctorId,
      'patientName': patientName,
      'doctorName': doctorName,
      'lastMessage': lastMessage,
      'lastMessageType': lastMessageType,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'lastMessageReadBy': lastMessageReadBy,
      'isActive': isActive,
    };

    if (id != null) {
      data['_id'] = id!;
    }
    if (lastMessageSenderId != null) {
      data['lastMessageSenderId'] = lastMessageSenderId!;
    }
    if (lastMessageUrl != null) {
      data['lastMessageUrl'] = lastMessageUrl!;
    }

    return data;
  }
}
