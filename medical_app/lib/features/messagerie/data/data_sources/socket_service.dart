import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/features/auth/domain/entities/user_entity.dart';
import 'package:medical_app/core/network/network_info.dart';
import 'package:medical_app/features/messagerie/domain/entities/message_entity.dart';
import 'package:medical_app/features/messagerie/data/models/message_model.dart';

class SocketService {
  final UserEntity currentUser;
  final NetworkInfo networkInfo;
  final String baseUrl;

  io.Socket? _socket;
  final StreamController<MessageEntity> _messageController =
      StreamController<MessageEntity>.broadcast();
  final StreamController<Map<String, dynamic>> _typingController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _readReceiptController =
      StreamController<Map<String, dynamic>>.broadcast();

  bool _isConnected = false;

  SocketService({
    required this.currentUser,
    required this.networkInfo,
    required this.baseUrl,
  });

  Stream<MessageEntity> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<Map<String, dynamic>> get readReceiptStream =>
      _readReceiptController.stream;
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected) return;

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      throw NetworkFailure();
    }

    try {
      if (currentUser.id == null || currentUser.token == null) {
        throw AuthFailure();
      }

      _initializeSocket();
    } catch (e) {
      debugPrint('Socket connection error: $e');
      throw ServerFailure();
    }
  }

  void _initializeSocket() {
    try {
      _socket = io.io(
        baseUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setQuery({'userId': currentUser.id})
            .setExtraHeaders({'Authorization': 'Bearer ${currentUser.token}'})
            .build(),
      );

      _socket!.connect();

      _socket!.onConnect((_) {
        _isConnected = true;
        debugPrint('Socket connected');

        // Register user as connected
        _socket!.emit('userConnected', currentUser.id);
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        debugPrint('Socket disconnected');
      });

      _socket!.onConnectError((data) {
        _isConnected = false;
        debugPrint('Socket connection error: $data');
      });

      _socket!.on('receiveMessage', (data) {
        try {
          final messageData = jsonDecode(jsonEncode(data));
          final message = MessageModel.fromJson(messageData);
          _messageController.add(message);
        } catch (e) {
          debugPrint('Error parsing received message: $e');
        }
      });

      _socket!.on('userTyping', (data) {
        try {
          final typingData = jsonDecode(jsonEncode(data));
          _typingController.add({
            'userId': typingData['userId'],
            'conversationId': typingData['conversationId'],
            'isTyping': true,
          });
        } catch (e) {
          debugPrint('Error parsing typing indicator: $e');
        }
      });

      _socket!.on('userStoppedTyping', (data) {
        try {
          final typingData = jsonDecode(jsonEncode(data));
          _typingController.add({
            'userId': typingData['userId'],
            'conversationId': typingData['conversationId'],
            'isTyping': false,
          });
        } catch (e) {
          debugPrint('Error parsing typing indicator: $e');
        }
      });

      _socket!.on('messagesRead', (data) {
        try {
          final readData = jsonDecode(jsonEncode(data));
          _readReceiptController.add({
            'userId': readData['userId'],
            'conversationId': readData['conversationId'],
          });
        } catch (e) {
          debugPrint('Error parsing read receipt: $e');
        }
      });
    } catch (e) {
      debugPrint('Socket initialization error: $e');
      throw ServerFailure();
    }
  }

  void sendMessage({
    required String recipientId,
    required String conversationId,
    required String message,
    required String type,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? fileMimeType,
  }) {
    if (!_isConnected || _socket == null) {
      throw ServerFailure();
    }

    final messageData = {
      'recipientId': recipientId,
      'conversationId': conversationId,
      'message': message,
      'type': type,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'fileMimeType': fileMimeType,
    };

    _socket!.emit('sendMessage', messageData);
  }

  void sendTypingIndicator({
    required String recipientId,
    required String conversationId,
    required bool isTyping,
  }) {
    if (!_isConnected || _socket == null) return;

    final eventName = isTyping ? 'startTyping' : 'stopTyping';
    final data = {'recipientId': recipientId, 'conversationId': conversationId};

    _socket!.emit(eventName, data);
  }

  void markMessagesAsRead({
    required String conversationId,
    required String senderId,
  }) {
    if (!_isConnected || _socket == null) return;

    final data = {'conversationId': conversationId, 'senderId': senderId};

    _socket!.emit('markMessagesAsRead', data);
  }

  void disconnect() {
    _socket?.disconnect();
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _typingController.close();
    _readReceiptController.close();
  }
}
