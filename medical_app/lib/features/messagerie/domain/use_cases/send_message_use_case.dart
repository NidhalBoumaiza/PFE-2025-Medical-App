import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/core/usecases/usecase.dart';
import 'package:medical_app/features/messagerie/domain/entities/message_entity.dart';
import 'package:medical_app/features/messagerie/domain/repositories/message_repository.dart';

class SendMessageUseCase implements UseCase<MessageEntity, SendMessageParams> {
  final MessagingRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) {
    return repository.sendMessage(
      conversationId: params.conversationId,
      senderId: params.senderId,
      content: params.content,
      type: params.type,
    );
  }
}

class SendMessageParams extends Equatable {
  final String conversationId;
  final String senderId;
  final String content;
  final String type;

  const SendMessageParams({
    required this.conversationId,
    required String? sender,
    required this.content,
    required this.type,
  }) : senderId = sender ?? '';

  @override
  List<Object> get props => [conversationId, senderId, content, type];
}
