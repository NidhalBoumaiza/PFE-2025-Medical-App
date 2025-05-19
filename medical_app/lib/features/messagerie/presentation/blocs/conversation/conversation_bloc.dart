import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/core/usecases/usecase.dart';
import 'package:medical_app/features/auth/domain/entities/user_entity.dart';
import 'package:medical_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:medical_app/features/messagerie/domain/entities/conversation_entity.dart';
import 'package:medical_app/features/messagerie/domain/use_cases/get_conversations.dart';

part 'conversation_event.dart';
part 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final GetConversations getConversations;
  final GetCurrentUser getCurrentUser;

  late UserEntity _currentUser;
  bool _isCurrentUserDoctor = false;

  UserEntity get currentUser => _currentUser;
  String get currentUserId => _currentUser.id ?? '';
  bool get isCurrentUserDoctor => _isCurrentUserDoctor;

  ConversationBloc({
    required this.getConversations,
    required this.getCurrentUser,
  }) : super(ConversationInitial()) {
    on<FetchConversationsEvent>(_onFetchConversations);
    on<InitializeConversationBloc>(_onInitialize);

    // Initialize automatically
    add(InitializeConversationBloc());
  }

  Future<void> _onInitialize(
    InitializeConversationBloc event,
    Emitter<ConversationState> emit,
  ) async {
    final userResult = await getCurrentUser();

    userResult.fold(
      (failure) {
        emit(ConversationError(message: 'Authentication error'));
      },
      (user) {
        _currentUser = user;
        _isCurrentUserDoctor = user.role == 'medecin';
        add(FetchConversationsEvent());
      },
    );
  }

  Future<void> _onFetchConversations(
    FetchConversationsEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(ConversationLoading());

    final result = await getConversations(NoParams());

    result.fold(
      (failure) {
        String message = 'Failed to load conversations';
        if (failure is ServerFailure) {
          message = 'Server error';
        } else if (failure is NetworkFailure) {
          message = 'Network error';
        }
        emit(ConversationError(message: message));
      },
      (conversations) {
        emit(ConversationsLoaded(conversations: conversations));
      },
    );
  }
}
