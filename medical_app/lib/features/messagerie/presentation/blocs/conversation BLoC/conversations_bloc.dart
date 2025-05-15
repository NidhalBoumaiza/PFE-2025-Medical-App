import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:medical_app/core/utils/map_failure_to_message.dart';
import 'package:medical_app/features/messagerie/domain/entities/conversation_entity.dart';
import 'package:medical_app/features/messagerie/domain/use_cases/get_conversations.dart';
import 'conversations_event.dart';
import 'conversations_state.dart';

class ConversationsBloc extends Bloc<ConversationsEvent, ConversationsState> {
  final GetConversationsUseCase getConversationsUseCase;
  List<ConversationEntity> _currentConversations = [];
  StreamSubscription<List<ConversationEntity>>? _conversationsSubscription;

  ConversationsBloc({required this.getConversationsUseCase})
    : super(const ConversationsInitial()) {
    on<FetchConversationsEvent>(_onFetchConversations);
    on<SubscribeToConversationsEvent>(_onSubscribeToConversations);
    on<ConversationsUpdatedEvent>(_onConversationsUpdated);
    on<ConversationsStreamErrorEvent>(_onConversationsStreamError);
  }

  Future<void> _onFetchConversations(
    FetchConversationsEvent event,
    Emitter<ConversationsState> emit,
  ) async {
    emit(ConversationsLoading(conversations: _currentConversations));
    final failureOrConversations = await getConversationsUseCase(
      userId: event.userId,
      isDoctor: event.isDoctor,
    );
    failureOrConversations.fold(
      (failure) => emit(
        ConversationsError(
          message: mapFailureToMessage(failure),
          conversations: _currentConversations,
        ),
      ),
      (conversations) {
        _currentConversations = conversations;
        emit(ConversationsLoaded(conversations: conversations));
      },
    );
  }

  Future<void> _onSubscribeToConversations(
    SubscribeToConversationsEvent event,
    Emitter<ConversationsState> emit,
  ) async {
    emit(ConversationsLoading(conversations: _currentConversations));
    try {
      await _conversationsSubscription?.cancel();
      final stream = getConversationsUseCase.getConversationsStream(
        userId: event.userId,
        isDoctor: event.isDoctor,
      );
      _conversationsSubscription = stream.listen(
        (conversations) {
          add(ConversationsUpdatedEvent(conversations: conversations));
        },
        onError: (error) {
          add(ConversationsStreamErrorEvent(error: error.toString()));
        },
      );
    } catch (e) {
      emit(
        ConversationsError(
          message: 'Failed to subscribe to conversations: $e',
          conversations: _currentConversations,
        ),
      );
    }
  }

  void _onConversationsUpdated(
    ConversationsUpdatedEvent event,
    Emitter<ConversationsState> emit,
  ) {
    // Handle read status updates more intelligently
    final updatedConversations =
        event.conversations.map((serverConversation) {
          // Try to find the same conversation in our current list
          final existingConversation = _currentConversations.firstWhere(
            (c) => c.id == serverConversation.id,
            orElse: () => serverConversation,
          );

          // If this is an existing conversation and the only thing that changed is the read status,
          // prioritize the local version if the local version shows it as read
          if (existingConversation.id == serverConversation.id &&
              existingConversation.lastMessageRead &&
              !serverConversation.lastMessageRead) {
            print(
              'Preserving local read status for conversation ${serverConversation.id}',
            );
            return existingConversation;
          }

          // Otherwise use the server version
          return serverConversation;
        }).toList();

    _currentConversations = updatedConversations;
    emit(ConversationsLoaded(conversations: updatedConversations));
  }

  void _onConversationsStreamError(
    ConversationsStreamErrorEvent event,
    Emitter<ConversationsState> emit,
  ) {
    emit(
      ConversationsError(
        message: 'Stream error: ${event.error}',
        conversations: _currentConversations,
      ),
    );
  }

  @override
  Future<void> close() {
    _conversationsSubscription?.cancel();
    return super.close();
  }
}
