import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:medical_app/core/utils/map_failure_to_message.dart';
import 'package:medical_app/features/messagerie/data/models/message_model.dart';
import 'package:medical_app/features/messagerie/domain/entities/message_entity.dart';
import 'package:medical_app/features/messagerie/domain/use_cases/get_message.dart';
import 'package:medical_app/features/messagerie/domain/use_cases/get_messages_stream_usecase.dart';
import 'package:medical_app/features/messagerie/domain/use_cases/send_message_use_case.dart';
import 'messagerie_event.dart';
import 'messagerie_state.dart';

// MessagerieBloc manages the state of messages in a conversation
class MessagerieBloc extends Bloc<MessagerieEvent, MessagerieState> {
  final SendMessageUseCase
  sendMessageUseCase; // Use case to send messages to Firestore
  final GetMessagesUseCase
  getMessagesUseCase; // Use case to fetch initial messages
  final GetMessagesStreamUseCase
  getMessagesStreamUseCase; // Use case for real-time message stream
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance for direct updates

  StreamSubscription<List<MessageEntity>>?
  _messagesSubscription; // Subscription to Firestore stream
  List<MessageModel> _currentMessages = []; // Local cache of messages
  String? _currentConversationId; // ID of the active conversation
  int _stateId = 0; // Unique ID to force UI rebuilds

  MessagerieBloc({
    required this.sendMessageUseCase,
    required this.getMessagesUseCase,
    required this.getMessagesStreamUseCase,
  }) : super(const MessagerieInitial()) {
    // Register event handlers
    print('Initializing MessagerieBloc with event handlers');
    on<SendMessageEvent>(_onSendMessage);
    on<FetchMessagesEvent>(_onFetchMessages);
    on<SubscribeToMessagesEvent>(_onSubscribeToMessages);
    on<AddLocalMessageEvent>(_onAddLocalMessage);
    on<UpdateMessageStatusEvent>(_onUpdateMessageStatus);
    on<MessagesUpdatedEvent>(_onMessagesUpdated);
    //  on<MessagesStreamErrorEvent>(_onMessagesStreamError);
  }

  // Increments stateId to ensure UI rebuilds on state changes
  int _nextStateId() {
    _stateId++;
    print('Generating new stateId: $_stateId');
    return _stateId;
  }

  // Create SendMessageParams from a MessageModel
  SendMessageParams _createSendMessageParams(MessageModel message) {
    // The explicit casts here help resolve any typing issues
    final String safeConversationId = message.conversationId;
    final String safeSenderId = message.sender;
    final String safeContent = message.content;
    final String safeType = message.type;

    return SendMessageParams(
      conversationId: safeConversationId,
      sender: safeSenderId,
      content: safeContent,
      type: safeType,
    );
  }

  // Handles sending a new message
  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<MessagerieState> emit,
  ) async {
    // Create a copy of the message with 'sending' status for immediate display
    final sendingMessage =
        event.message.copyWith(status: 'sending') as MessageModel;
    print(
      'Adding local message ${sendingMessage.id} with status: ${sendingMessage.status}',
    );

    // Add message to local cache and emit state to show loader in UI
    _currentMessages.insert(0, sendingMessage);
    emit(
      MessagerieStreamActive(
        messages: List.from(_currentMessages),
        stateId: _nextStateId(),
      ),
    );

    try {
      // For simplicity, directly use Firestore to send the message
      print('Sending message ${sendingMessage.id}');

      // Create Firestore reference
      final messageRef = _firestore
          .collection('conversations')
          .doc(sendingMessage.conversationId)
          .collection('messages')
          .doc(sendingMessage.id);

      // Prepare message data
      final messageData = sendingMessage.toJson();

      // Save message to Firestore
      await messageRef.set(messageData);

      // If there's a file, handle it
      if (event.file != null) {
        try {
          // Upload file to Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('conversations')
              .child(sendingMessage.conversationId)
              .child(
                sendingMessage.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
              );

          final uploadTask = await storageRef.putFile(event.file!);
          final downloadUrl = await uploadTask.ref.getDownloadURL();

          // Update message with file URL
          await messageRef.update({'fileUrl': downloadUrl});

          print(
            'File uploaded successfully for message ${sendingMessage.id}: $downloadUrl',
          );
        } catch (e) {
          print('Error uploading file for message ${sendingMessage.id}: $e');
        }
      }

      // Handle success case
      print('Successfully sent message ${sendingMessage.id}');
      // Immediately update local status to 'sent' to remove loader
      final sentMessage = sendingMessage.copyWith(status: 'sent');
      final index = _currentMessages.indexWhere((m) => m.id == sentMessage.id);
      if (index != -1) {
        _currentMessages[index] = sentMessage;
        print('Updated local message ${sentMessage.id} to status: sent');
      } else {
        print('Message ${sentMessage.id} not found in _currentMessages');
      }

      // Emit MessagerieMessageSent to force UI refresh with checkmark
      emit(
        MessagerieMessageSent(
          messages: List.from(_currentMessages),
          stateId: _nextStateId(),
        ),
      );

      // Persist status to Firestore
      await _updateMessageStatus(sentMessage, emit);
    } catch (e) {
      // Handle unexpected errors
      print('Exception sending message ${sendingMessage.id}: $e');
      final failedMessage = sendingMessage.copyWith(status: 'failed');
      await _updateMessageStatus(failedMessage, emit);
      emit(
        MessagerieError(
          message: 'Failed to send message: $e',
          messages: _currentMessages,
          stateId: _nextStateId(),
        ),
      );
    }
  }

  // Updates a message's status in Firestore and local cache
  Future<void> _updateMessageStatus(
    MessageModel updatedMessage,
    Emitter<MessagerieState> emit,
  ) async {
    final index = _currentMessages.indexWhere((m) => m.id == updatedMessage.id);
    if (index != -1) {
      // Update local cache
      _currentMessages[index] = updatedMessage;
      print(
        'Updating message ${updatedMessage.id} status to ${updatedMessage.status} in Firestore',
      );
      try {
        // Persist status to Firestore
        final messagePath = _firestore
            .collection('conversations')
            .doc(updatedMessage.conversationId)
            .collection('messages')
            .doc(updatedMessage.id);

        // Get current message data to ensure we don't override fields
        final messageDoc = await messagePath.get();
        if (!messageDoc.exists) {
          print(
            'Message ${updatedMessage.id} not found in Firestore, cannot update status',
          );
          return;
        }

        // Merge current readBy with new readBy to ensure we don't lose readers
        final currentData = messageDoc.data() ?? {};
        final currentReadBy = List<String>.from(currentData['readBy'] ?? []);
        final updatedReadBy =
            [...currentReadBy, ...updatedMessage.readBy]
                .toSet() // Remove duplicates
                .toList();

        await messagePath.update({
          'status': updatedMessage.status,
          'readBy': updatedReadBy,
        });

        // Also update conversation document for read status
        if (updatedMessage.status == 'read') {
          final conversationPath = _firestore
              .collection('conversations')
              .doc(updatedMessage.conversationId);

          await conversationPath.update({'lastMessageRead': true});
        }

        print(
          'Firestore updated for message ${updatedMessage.id} with readBy: $updatedReadBy',
        );

        // Update local message with merged readBy
        final completelyUpdatedMessage = updatedMessage.copyWith(
          readBy: updatedReadBy,
        );
        _currentMessages[index] = completelyUpdatedMessage as MessageModel;
      } catch (e) {
        print('Error updating message status for ${updatedMessage.id}: $e');
      }
      // Emit updated state to reflect changes
      emit(
        MessagerieStreamActive(
          messages: List.from(_currentMessages),
          stateId: _nextStateId(),
        ),
      );
    } else {
      print('Message ${updatedMessage.id} not found in _currentMessages');
    }
  }

  // Fetches initial messages for a conversation
  Future<void> _onFetchMessages(
    FetchMessagesEvent event,
    Emitter<MessagerieState> emit,
  ) async {
    print('Fetching messages for conversationId: ${event.conversationId}');
    emit(
      MessagerieLoading(messages: _currentMessages, stateId: _nextStateId()),
    );
    final failureOrMessages = await getMessagesUseCase(
      GetMessagesParams(conversationId: event.conversationId),
    );
    failureOrMessages.fold(
      (failure) {
        print('Failed to fetch messages: ${mapFailureToMessage(failure)}');
        emit(
          MessagerieError(
            message: mapFailureToMessage(failure),
            messages: _currentMessages,
            stateId: _nextStateId(),
          ),
        );
      },
      (messages) {
        // Convert MessageEntity objects to MessageModel objects
        final convertedMessages =
            messages.map((entity) {
              if (entity is MessageModel) {
                return entity;
              } else {
                // Create a MessageModel from the MessageEntity
                return MessageModel(
                  id: entity.id,
                  conversationId: entity.conversationId,
                  sender: entity.sender,
                  content: entity.content,
                  type: entity.type,
                  timestamp: entity.timestamp,
                  readBy: entity.readBy,
                  fileUrl: entity.fileUrl,
                  fileName: entity.fileName,
                  fileSize: entity.fileSize,
                  fileMimeType: entity.fileMimeType,
                  status: entity.status,
                );
              }
            }).toList();

        _currentMessages = convertedMessages;
        print(
          'Fetched ${messages.length} messages for conversationId: ${event.conversationId}',
        );
        emit(
          MessagerieSuccess(
            messages: _currentMessages,
            stateId: _nextStateId(),
          ),
        );
      },
    );
  }

  // Subscribes to real-time message updates from Firestore
  Future<void> _onSubscribeToMessages(
    SubscribeToMessagesEvent event,
    Emitter<MessagerieState> emit,
  ) async {
    if (_currentConversationId == event.conversationId) {
      print('Already subscribed to conversationId: ${event.conversationId}');
      return;
    }
    _currentConversationId = event.conversationId;
    print(
      'Subscribing to messages for conversationId: ${event.conversationId}',
    );
    emit(
      MessagerieLoading(messages: _currentMessages, stateId: _nextStateId()),
    );
    try {
      // Cancel any existing subscription to avoid duplicate listeners
      await _messagesSubscription?.cancel();
      print(
        'Cancelled previous subscription for conversationId: $_currentConversationId',
      );
      // Subscribe to the Firestore stream
      _messagesSubscription = getMessagesStreamUseCase(
        GetMessagesStreamParams(conversationId: event.conversationId),
      ).listen(
        (messages) {
          print(
            'Received stream update for conversationId: ${event.conversationId}, ${messages.length} messages',
          );

          // Convert MessageEntity objects to MessageModel objects
          final modelMessages =
              messages.map((entity) {
                if (entity is MessageModel) {
                  return entity;
                } else {
                  // Create a MessageModel from the MessageEntity
                  return MessageModel(
                    id: entity.id,
                    conversationId: entity.conversationId,
                    sender: entity.sender,
                    content: entity.content,
                    type: entity.type,
                    timestamp: entity.timestamp,
                    readBy: entity.readBy,
                    fileUrl: entity.fileUrl,
                    fileName: entity.fileName,
                    fileSize: entity.fileSize,
                    fileMimeType: entity.fileMimeType,
                    status: entity.status,
                  );
                }
              }).toList();

          add(MessagesUpdatedEvent(messages: modelMessages));
        },
        onError: (error) {
          // Log stream error as requested
          print(
            'Stream error for conversationId: ${event.conversationId}: $error',
          );
          // add(MessagerieStreamErrorEvent(error: error.toString()));
        },
      );
      print(
        'Subscribed to messages stream for conversationId: ${event.conversationId}',
      );
    } catch (e) {
      print(
        'Failed to initialize stream for conversationId: ${event.conversationId}: $e',
      );
      emit(
        MessagerieError(
          message: 'Failed to initialize stream: $e',
          messages: _currentMessages,
          stateId: _nextStateId(),
        ),
      );
    }
  }

  // Adds a message to the local cache for immediate display
  void _onAddLocalMessage(
    AddLocalMessageEvent event,
    Emitter<MessagerieState> emit,
  ) {
    if (!_currentMessages.any((m) => m.id == event.message.id)) {
      _currentMessages.insert(0, event.message);
      print(
        'Added local message ${event.message.id} with status: ${event.message.status}',
      );
      emit(
        MessagerieStreamActive(
          messages: List.from(_currentMessages),
          stateId: _nextStateId(),
        ),
      );
    } else {
      print(
        'Warning: Attempted to add duplicate local message ${event.message.id}',
      );
    }
  }

  // Updates a message's status
  void _onUpdateMessageStatus(
    UpdateMessageStatusEvent event,
    Emitter<MessagerieState> emit,
  ) {
    print(
      'Processing UpdateMessageStatusEvent for message ${event.message.id}',
    );
    _updateMessageStatus(event.message, emit);
  }

  // Handles updates from the Firestore stream
  void _onMessagesUpdated(
    MessagesUpdatedEvent event,
    Emitter<MessagerieState> emit,
  ) {
    // Prevent stream from overwriting recent local statuses
    final now = DateTime.now();
    final updatedMessages =
        event.messages.map((serverMessage) {
          final localMessage = _currentMessages.firstWhere(
            (m) => m.id == serverMessage.id,
            orElse: () => serverMessage,
          );
          // Preserve local status if message was sent within 10 seconds
          if ((localMessage.status == 'sending' ||
                  localMessage.status == 'sent') &&
              now.difference(localMessage.timestamp).inSeconds < 10) {
            print(
              'Preserving local status for message ${serverMessage.id}: ${localMessage.status}',
            );
            return localMessage;
          }
          print(
            'Using server status for message ${serverMessage.id}: ${serverMessage.status}',
          );
          return serverMessage;
        }).toList();
    _currentMessages = updatedMessages;
    print(
      'Stream updated with ${_currentMessages.length} messages for conversationId: $_currentConversationId',
    );
    emit(
      MessagerieStreamActive(
        messages: _currentMessages,
        stateId: _nextStateId(),
      ),
    );
  }

  // Handles errors from the Firestore stream
  // void _onMessagesStreamError(MessagerieStreamErrorEvent event, Emitter<MessagerieState> emit) {
  //   print('Handling stream error: ${event.error}');
  //   emit(MessagerieError(
  //     message: 'Stream error: ${event.error}',
  //     messages: _currentMessages,
  //     stateId: _nextStateId(),
  //   ));
  //   // Attempt to resubscribe after a delay
  //   Future.delayed(Duration(seconds: 5), () {
  //     print('Retrying subscription for conversationId: $_currentConversationId');
  //     if (_currentConversationId != null) {
  //       add(SubscribeToMessagesEvent(_currentConversationId!));
  //     }
  //   });
  // }

  @override
  Future<void> close() {
    print('Closing MessagerieBloc, cancelling subscription');
    _messagesSubscription?.cancel();
    return super.close();
  }
}
