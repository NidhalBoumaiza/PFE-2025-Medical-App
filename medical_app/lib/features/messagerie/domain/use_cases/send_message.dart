import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/core/usecases/usecase.dart';
import 'package:medical_app/features/messagerie/domain/entities/message_entity.dart';
import 'package:medical_app/features/messagerie/domain/repositories/conversation_repository.dart';

class SendMessage implements UseCase<MessageEntity, SendMessageParams> {
  final ConversationRepository repository;

  SendMessage(this.repository);

  @override
  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) {
    return repository.sendMessage(
      conversationId: params.conversationId,
      content: params.content,
      type: params.type,
      fileUrl: params.fileUrl,
      fileName: params.fileName,
      fileSize: params.fileSize,
      fileMimeType: params.fileMimeType,
    );
  }
}

class SendMessageParams extends Equatable {
  final String conversationId;
  final String content;
  final String type;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? fileMimeType;

  const SendMessageParams({
    required this.conversationId,
    required this.content,
    required this.type,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.fileMimeType,
  });

  @override
  List<Object?> get props => [
    conversationId,
    content,
    type,
    fileUrl,
    fileName,
    fileSize,
    fileMimeType,
  ];
}
