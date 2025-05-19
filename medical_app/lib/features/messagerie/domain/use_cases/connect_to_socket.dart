import 'package:dartz/dartz.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/core/usecases/usecase.dart';
import 'package:medical_app/features/messagerie/domain/repositories/conversation_repository.dart';

class ConnectToSocket implements UseCase<bool, NoParams> {
  final ConversationRepository repository;

  ConnectToSocket(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return repository.connectToSocket();
  }
}
