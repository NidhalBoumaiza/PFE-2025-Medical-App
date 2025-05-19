import 'package:dartz/dartz.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/features/messagerie/domain/entities/conversation_entity.dart';
import 'package:medical_app/features/messagerie/domain/entities/message_entity.dart';

abstract class ConversationRepository {
  Future<Either<Failure, List<ConversationEntity>>> getConversations();

  Future<Either<Failure, ConversationEntity>> getConversation(
    String conversationId,
  );

  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String conversationId,
  );

  Future<Either<Failure, ConversationEntity>> createConversation({
    required String patientId,
    required String doctorId,
  });

  Future<Either<Failure, MessageEntity>> sendMessage({
    required String conversationId,
    required String content,
    required String type,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? fileMimeType,
  });

  Future<Either<Failure, bool>> markMessagesAsRead(String conversationId);

  // Stream methods
  Stream<List<ConversationEntity>> getConversationsStream({
    required String userId,
    required bool isDoctor,
  });

  // Socket-related methods
  Future<Either<Failure, bool>> connectToSocket();

  Future<Either<Failure, bool>> disconnectFromSocket();

  Stream<MessageEntity> get messageStream;

  Stream<Map<String, dynamic>> get typingStream;

  Stream<Map<String, dynamic>> get readReceiptStream;

  Future<Either<Failure, bool>> sendTypingIndicator({
    required String recipientId,
    required String conversationId,
    required bool isTyping,
  });
}
