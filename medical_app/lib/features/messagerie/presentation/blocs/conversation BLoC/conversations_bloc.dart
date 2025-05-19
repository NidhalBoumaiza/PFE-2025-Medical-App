import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/core/utils/map_failure_to_message.dart';
import 'package:medical_app/features/messagerie/domain/entities/conversation_entity.dart';
import 'package:medical_app/features/messagerie/domain/use_cases/get_conversations_use_case.dart';
import 'package:medical_app/core/usecases/usecase.dart';
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
    on<MarkAllConversationsReadEvent>(_onMarkAllConversationsRead);
  }

  Future<void> _onFetchConversations(
    FetchConversationsEvent event,
    Emitter<ConversationsState> emit,
  ) async {
    emit(ConversationsLoading(conversations: _currentConversations));
    final failureOrConversations = await getConversationsUseCase(NoParams());
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

      // Since the repository doesn't support streams directly, we'll implement
      // a polling mechanism for now
      _conversationsSubscription = Stream.periodic(const Duration(seconds: 10))
          .asyncMap((_) async {
            final result = await getConversationsUseCase(NoParams());
            return result.fold(
              (failure) => throw Exception(mapFailureToMessage(failure)),
              (conversations) => conversations,
            );
          })
          .listen(
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
    // Update conversations list
    _currentConversations = event.conversations;
    emit(ConversationsLoaded(conversations: _currentConversations));
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

  // Marks all conversations as read for a user
  Future<void> _onMarkAllConversationsRead(
    MarkAllConversationsReadEvent event,
    Emitter<ConversationsState> emit,
  ) async {
    try {
      print('Marking all conversations as read for user: ${event.userId}');

      // Since we don't have a lastMessageRead field, we'll work with Firestore directly
      // Update Firestore
      final firestore = FirebaseFirestore.instance;

      // Find conversations where this user is either patient or doctor
      final patientConversations =
          await firestore
              .collection('conversations')
              .where('patientId', isEqualTo: event.userId)
              .get();

      final doctorConversations =
          await firestore
              .collection('conversations')
              .where('doctorId', isEqualTo: event.userId)
              .get();

      // Only proceed with batch update if there are conversations to update
      final allDocs = [
        ...patientConversations.docs,
        ...doctorConversations.docs,
      ];
      if (allDocs.isNotEmpty) {
        final batch = firestore.batch();

        // Mark all as read in batch by adding user to lastMessageReadBy array
        for (final doc in allDocs) {
          final data = doc.data();
          if (data.containsKey('lastMessageReadBy') &&
              data['lastMessageReadBy'] is List) {
            List<String> readBy = List<String>.from(data['lastMessageReadBy']);
            if (!readBy.contains(event.userId)) {
              readBy.add(event.userId);
              batch.update(doc.reference, {'lastMessageReadBy': readBy});
            }
          } else {
            batch.update(doc.reference, {
              'lastMessageReadBy': [event.userId],
            });
          }
        }

        await batch.commit();
        print(
          'Successfully marked ${allDocs.length} conversations as read in Firestore',
        );

        // Refresh conversations
        add(FetchConversationsEvent(userId: event.userId, isDoctor: false));
      } else {
        print('No conversations found to mark as read');
      }
    } catch (e) {
      print('Error marking conversations as read: $e');
      emit(
        ConversationsError(
          message: 'Failed to mark conversations as read: $e',
          conversations: _currentConversations,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _conversationsSubscription?.cancel();
    return super.close();
  }
}
