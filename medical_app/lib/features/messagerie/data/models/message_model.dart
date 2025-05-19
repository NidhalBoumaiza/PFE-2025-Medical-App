import 'package:medical_app/features/messagerie/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    String? id,
    required String conversationId,
    required String sender,
    required String content,
    required String type,
    required DateTime timestamp,
    required List<String> readBy,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? fileMimeType,
    required String status,
  }) : super(
         id: id,
         conversationId: conversationId,
         sender: sender,
         content: content,
         type: type,
         timestamp: timestamp,
         readBy: readBy,
         fileUrl: fileUrl,
         fileName: fileName,
         fileSize: fileSize,
         fileMimeType: fileMimeType,
         status: status,
       );

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] as String?,
      conversationId: json['conversation'] as String? ?? '',
      sender: json['sender'] as String? ?? '',
      content: json['content'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      timestamp: parseDateTime(json['timestamp']),
      readBy:
          json['readBy'] != null
              ? List<String>.from(json['readBy'] as List)
              : [],
      fileUrl: json['fileUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      fileMimeType: json['fileMimeType'] as String?,
      status: json['status'] as String? ?? 'sent',
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
      'conversation': conversationId,
      'sender': sender,
      'content': content,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'readBy': readBy,
      'status': status,
    };

    if (id != null) {
      data['_id'] = id!;
    }
    if (fileUrl != null) {
      data['fileUrl'] = fileUrl!;
    }
    if (fileName != null) {
      data['fileName'] = fileName!;
    }
    if (fileSize != null) {
      data['fileSize'] = fileSize!;
    }
    if (fileMimeType != null) {
      data['fileMimeType'] = fileMimeType!;
    }

    return data;
  }

  @override
  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? sender,
    String? content,
    String? type,
    DateTime? timestamp,
    List<String>? readBy,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? fileMimeType,
    String? status,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      readBy: readBy ?? this.readBy,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      fileMimeType: fileMimeType ?? this.fileMimeType,
      status: status ?? this.status,
    );
  }
}
