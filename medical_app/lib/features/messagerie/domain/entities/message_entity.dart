import 'package:equatable/equatable.dart';
import '../../data/models/message_model.dart';

enum MessageStatus { sent, delivered, read }

enum MessageType { text, image, file }

abstract class MessageEntity extends Equatable {
  final String? id;
  final String conversationId;
  final String sender;
  final String content;
  final String type;
  final DateTime timestamp;
  final List<String> readBy;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? fileMimeType;
  final String status;

  const MessageEntity({
    this.id,
    required this.conversationId,
    required this.sender,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.readBy,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.fileMimeType,
    required this.status,
  });

  MessageEntity copyWith({
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
  });

  @override
  List<Object?> get props => [
    id,
    conversationId,
    sender,
    content,
    type,
    timestamp,
    readBy,
    fileUrl,
    fileName,
    fileSize,
    fileMimeType,
    status,
  ];

  static MessageEntity create({
    required String conversationId,
    required String sender,
    required String content,
    required String type,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? fileMimeType,
  }) {
    return MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      sender: sender,
      content: content,
      type: type,
      timestamp: DateTime.now(),
      readBy: [sender], // Sender has read their own message
      fileUrl: fileUrl,
      fileName: fileName,
      fileSize: fileSize,
      fileMimeType: fileMimeType,
      status: 'sent',
    );
  }
}
