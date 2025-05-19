part of 'conversation_bloc.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object> get props => [];
}

class InitializeConversationBloc extends ConversationEvent {}

class FetchConversationsEvent extends ConversationEvent {}

class UpdateConversationsEvent extends ConversationEvent {
  final List<ConversationEntity> conversations;

  const UpdateConversationsEvent({required this.conversations});

  @override
  List<Object> get props => [conversations];
}
