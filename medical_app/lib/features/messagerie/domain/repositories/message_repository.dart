import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/features/messagerie/data/models/message_model.dart';
import 'package:medical_app/features/messagerie/domain/entities/conversation_entity.dart';
import 'package:medical_app/features/messagerie/domain/entities/message_entity.dart';

abstract class MessagingRepository {
  Future<Either<Failure, List<ConversationEntity>>> getConversations();
  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String conversationId,
  );
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    required String type,
  });
  Stream<List<MessageEntity>> getMessagesStream(String conversationId);

  // Added method for conversations stream
  Stream<List<ConversationEntity>> getConversationsStream({
    required String userId,
    required bool isDoctor,
  });
}
