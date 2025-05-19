import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:medical_app/core/error/exceptions.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/core/network/network_info.dart';
import 'package:medical_app/features/messagerie/data/data_sources/message_remote_datasource.dart';
import 'package:medical_app/features/messagerie/data/models/message_model.dart';
import 'package:medical_app/features/messagerie/domain/entities/conversation_entity.dart';
import 'package:medical_app/features/messagerie/domain/entities/message_entity.dart';
import 'package:medical_app/features/messagerie/domain/repositories/message_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medical_app/core/utils/constants.dart';

class MessagingRepositoryImpl implements MessagingRepository {
  final MessagingRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final SharedPreferences sharedPreferences;

  MessagingRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.sharedPreferences,
  });

  @override
  Future<Either<Failure, List<ConversationEntity>>> getConversations() async {
    if (await networkInfo.isConnected) {
      try {
        final userId = sharedPreferences.getString(kUserIdKey);
        final userRole = sharedPreferences.getString(kUserRoleKey);

        if (userId == null) {
          return Left(AuthFailure("User ID not found"));
        }

        final isDoctor = userRole == 'doctor';
        final conversations = await remoteDataSource.getConversations(
          userId,
          isDoctor,
        );
        return Right(conversations);
      } on ServerException {
        return Left(ServerFailure());
      } on ServerMessageException catch (e) {
        return Left(ServerMessageFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Stream<List<ConversationEntity>> getConversationsStream({
    required String userId,
    required bool isDoctor,
  }) async* {
    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      try {
        yield* remoteDataSource.conversationsStream(userId, isDoctor);
      } on ServerException {
        throw ServerFailure();
      } on ServerMessageException catch (e) {
        throw ServerMessageFailure(e.message);
      } on AuthException catch (e) {
        throw AuthFailure(e.message);
      }
    } else {
      throw OfflineFailure();
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    required String type,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Create a message model
        final message = MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          conversationId: conversationId,
          sender: senderId,
          content: content,
          type: type,
          timestamp: DateTime.now(),
          status: 'sending',
          readBy: [senderId], // Sender has read their own message
        );

        // Send message to Firebase
        await remoteDataSource.sendMessage(message, null);

        // Return the sent message with updated status
        return Right(message.copyWith(status: 'sent'));
      } on ServerException {
        return Left(ServerFailure());
      } on ServerMessageException catch (e) {
        return Left(ServerMessageFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String conversationId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final messages = await remoteDataSource.getMessages(conversationId);
        return Right(messages);
      } on ServerException {
        return Left(ServerFailure());
      } on ServerMessageException catch (e) {
        return Left(ServerMessageFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Stream<List<MessageEntity>> getMessagesStream(String conversationId) async* {
    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      try {
        yield* remoteDataSource.getMessagesStream(conversationId);
      } on ServerException {
        throw ServerFailure();
      } on ServerMessageException catch (e) {
        throw ServerMessageFailure(e.message);
      } on AuthException catch (e) {
        throw AuthFailure(e.message);
      }
    } else {
      throw OfflineFailure();
    }
  }
}
