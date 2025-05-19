import 'package:dartz/dartz.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/core/usecases/usecase.dart';
import 'package:medical_app/features/messagerie/domain/entities/conversation_entity.dart';
import 'package:medical_app/features/messagerie/domain/repositories/conversation_repository.dart';

class GetConversations implements UseCase<List<ConversationEntity>, NoParams> {
  final ConversationRepository repository;

  GetConversations(this.repository);

  @override
  Future<Either<Failure, List<ConversationEntity>>> call(NoParams params) {
    return repository.getConversations();
  }

  Stream<List<ConversationEntity>> getConversationsStream({
    required String userId,
    required bool isDoctor,
  }) {
    return repository.getConversationsStream(
      userId: userId,
      isDoctor: isDoctor,
    );
  }
}
