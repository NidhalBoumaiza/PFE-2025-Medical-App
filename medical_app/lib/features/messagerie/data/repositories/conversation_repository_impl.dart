import 'package:dartz/dartz.dart';
import 'package:medical_app/core/error/exceptions.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/core/network/network_info.dart';
import 'package:medical_app/features/messagerie/data/data_sources/conversation_api_data_source.dart';
import 'package:medical_app/features/messagerie/data/data_sources/socket_service.dart';
import 'package:medical_app/features/messagerie/domain/entities/conversation_entity.dart';
import 'package:medical_app/features/messagerie/domain/entities/message_entity.dart';
import 'package:medical_app/features/messagerie/domain/repositories/conversation_repository.dart';
import 'dart:io';

class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationApiDataSource apiDataSource;
  final SocketService socketService;
  final NetworkInfo networkInfo;

  ConversationRepositoryImpl({
    required this.apiDataSource,
    required this.socketService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ConversationEntity>>> getConversations() async {
    if (await networkInfo.isConnected) {
      try {
        final conversations = await apiDataSource.getConversations();
        return Right(conversations);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> getConversation(
    String conversationId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final conversation = await apiDataSource.getConversation(
          conversationId,
        );
        return Right(conversation);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String conversationId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final messages = await apiDataSource.getMessages(conversationId);
        return Right(messages);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> createConversation({
    required String patientId,
    required String doctorId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final conversation = await apiDataSource.createConversation(
          patientId: patientId,
          doctorId: doctorId,
        );
        return Right(conversation);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String conversationId,
    required String content,
    required String type,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? fileMimeType,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // For file messages, check if the file path is provided
        File? file;
        if (fileUrl != null && fileUrl.startsWith('/')) {
          // Local file path
          file = File(fileUrl);
        }

        // Send message via API
        final message = await apiDataSource.sendMessage(
          conversationId: conversationId,
          content: content,
          type: type,
          file: file,
        );

        return Right(message);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> markMessagesAsRead(
    String conversationId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await apiDataSource.markMessagesAsRead(conversationId);
        return const Right(true);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  // Socket-related methods

  @override
  Future<Either<Failure, bool>> connectToSocket() async {
    try {
      await socketService.connect();
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> disconnectFromSocket() async {
    try {
      socketService.disconnect();
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<MessageEntity> get messageStream => socketService.messageStream;

  @override
  Stream<Map<String, dynamic>> get typingStream => socketService.typingStream;

  @override
  Stream<Map<String, dynamic>> get readReceiptStream =>
      socketService.readReceiptStream;

  @override
  Future<Either<Failure, bool>> sendTypingIndicator({
    required String recipientId,
    required String conversationId,
    required bool isTyping,
  }) async {
    try {
      socketService.sendTypingIndicator(
        recipientId: recipientId,
        conversationId: conversationId,
        isTyping: isTyping,
      );
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<List<ConversationEntity>> getConversationsStream({
    required String userId,
    required bool isDoctor,
  }) {
    try {
      // This method is expected to work without connectivity checks
      // as the stream itself will handle reconnections
      return apiDataSource.getConversationsStream(userId, isDoctor);
    } catch (e) {
      // Return an empty stream on error
      return Stream.value([]);
    }
  }
}
