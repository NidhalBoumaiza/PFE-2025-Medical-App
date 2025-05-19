import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/features/auth/domain/entities/user_entity.dart';
import 'package:medical_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:medical_app/features/messagerie/domain/entities/message_entity.dart';
import 'package:medical_app/features/messagerie/domain/use_cases/get_messages.dart';
import 'package:medical_app/features/messagerie/domain/use_cases/mark_messages_as_read.dart';
import 'package:medical_app/features/messagerie/domain/use_cases/send_message.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final GetMessages getMessages;
  final SendMessage sendMessage;
  final MarkMessagesAsRead markMessagesAsRead;
  final GetCurrentUser getCurrentUser;

  late UserEntity _currentUser;
  bool _isCurrentUserDoctor = false;
  StreamSubscription? _messageStreamSubscription;
  StreamSubscription? _typingStreamSubscription;

  UserEntity get currentUser => _currentUser;
  bool get isCurrentUserDoctor => _isCurrentUserDoctor;

  MessageBloc({
    required this.getMessages,
    required this.sendMessage,
    required this.markMessagesAsRead,
    required this.getCurrentUser,
  }) : super(const MessageInitial()) {
    on<InitializeMessageBloc>(_onInitialize);
    on<FetchMessagesEvent>(_onFetchMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<MarkMessagesAsReadEvent>(_onMarkMessagesAsRead);
    on<MessageReceivedEvent>(_onMessageReceived);
    on<SendTypingEvent>(_onSendTyping);
    on<TypingIndicatorEvent>(_onTypingIndicator);

    // Initialize automatically
    add(InitializeMessageBloc());
  }

  Future<void> _onInitialize(
    InitializeMessageBloc event,
    Emitter<MessageState> emit,
  ) async {
    final userResult = await getCurrentUser();

    userResult.fold(
      (failure) {
        emit(const MessageError(message: 'Authentication error'));
      },
      (user) {
        _currentUser = user;
        _isCurrentUserDoctor = user.role == 'medecin';
      },
    );
  }

  Future<void> _onFetchMessages(
    FetchMessagesEvent event,
    Emitter<MessageState> emit,
  ) async {
    // Show loading only for initial load, not for refreshes
    final currentState = state;
    final isInitialLoad =
        currentState is MessageInitial ||
        (currentState is MessageError && event.forceReload);

    if (isInitialLoad) {
      emit(const MessageLoading(isInitialLoad: true));
    }

    final result = await getMessages(
      GetMessagesParams(conversationId: event.conversationId),
    );

    result.fold(
      (failure) {
        String message = 'Failed to load messages';
        if (failure is ServerFailure) {
          message = 'Server error';
        } else if (failure is NetworkFailure) {
          message = 'Network error';
        }
        emit(MessageError(message: message));
      },
      (messages) {
        if (currentState is MessageLoaded) {
          // Keep typing indicator state when refreshing messages
          emit(
            MessageLoaded(messages: messages, isTyping: currentState.isTyping),
          );
        } else {
          emit(MessageLoaded(messages: messages));
        }
      },
    );
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<MessageState> emit,
  ) async {
    final currentState = state;
    if (currentState is MessageLoaded) {
      // Show loading state but keep current messages
      emit(
        MessageLoading(isInitialLoad: false, messages: currentState.messages),
      );

      final result = await sendMessage(
        SendMessageParams(
          conversationId: event.conversationId,
          content: event.content,
          type: event.type,
          fileUrl: event.file?.path,
          fileName: event.file?.path.split('/').last,
          fileSize: event.file?.lengthSync(),
        ),
      );

      result.fold(
        (failure) {
          String message = 'Failed to send message';
          if (failure is ServerFailure) {
            message = 'Server error';
          } else if (failure is NetworkFailure) {
            message = 'Network connection error';
          }
          // Restore previous state with error message
          emit(
            MessageLoaded(
              messages: currentState.messages,
              errorMessage: message,
              isTyping: currentState.isTyping,
            ),
          );
        },
        (sentMessage) {
          // Add new message to the list
          final updatedMessages = List<MessageEntity>.from(
            currentState.messages,
          )..insert(0, sentMessage); // Add to beginning as list is reversed

          emit(
            MessageLoaded(
              messages: updatedMessages,
              isTyping: currentState.isTyping,
            ),
          );
        },
      );
    }
  }

  Future<void> _onMarkMessagesAsRead(
    MarkMessagesAsReadEvent event,
    Emitter<MessageState> emit,
  ) async {
    await markMessagesAsRead(
      MarkMessagesAsReadParams(conversationId: event.conversationId),
    );

    // No state change needed as this just updates the server
  }

  void _onMessageReceived(
    MessageReceivedEvent event,
    Emitter<MessageState> emit,
  ) {
    final currentState = state;
    if (currentState is MessageLoaded) {
      final currentMessages = currentState.messages;

      // Check if message is already in the list to avoid duplicates
      if (!currentMessages.any((m) => m.id == event.message.id)) {
        final updatedMessages = List<MessageEntity>.from(currentMessages)
          ..insert(0, event.message); // Add to beginning as list is reversed

        emit(
          MessageLoaded(
            messages: updatedMessages,
            isTyping: currentState.isTyping,
          ),
        );

        // Mark the message as read since user is already in the chat
        add(
          MarkMessagesAsReadEvent(conversationId: event.message.conversationId),
        );
      }
    }
  }

  void _onSendTyping(SendTypingEvent event, Emitter<MessageState> emit) {
    // This event is handled by the socket service via repository
    // No state change needed here
  }

  void _onTypingIndicator(
    TypingIndicatorEvent event,
    Emitter<MessageState> emit,
  ) {
    final currentState = state;
    if (currentState is MessageLoaded) {
      emit(
        MessageLoaded(
          messages: currentState.messages,
          isTyping: event.isTyping,
          errorMessage: currentState.errorMessage,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _messageStreamSubscription?.cancel();
    _typingStreamSubscription?.cancel();
    return super.close();
  }
}
