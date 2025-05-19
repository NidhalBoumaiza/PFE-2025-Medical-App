import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:medical_app/core/error/exceptions.dart';
import 'package:medical_app/features/messagerie/data/models/conversation_model.dart';
import 'package:medical_app/features/messagerie/data/models/message_model.dart';

abstract class ConversationApiDataSource {
  Future<List<ConversationModel>> getConversations();

  Stream<List<ConversationModel>> getConversationsStream(
    String userId,
    bool isDoctor,
  );

  Future<ConversationModel> getConversation(String conversationId);

  Future<List<MessageModel>> getMessages(String conversationId);

  Future<ConversationModel> createConversation({
    required String patientId,
    required String doctorId,
  });

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    required String type,
    File? file,
  });

  Future<void> markMessagesAsRead(String conversationId);
}

class ConversationApiDataSourceImpl implements ConversationApiDataSource {
  final http.Client client;
  final String baseUrl;
  final Map<String, String> headers;

  ConversationApiDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.headers,
  });

  @override
  Future<List<ConversationModel>> getConversations() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/v1/conversations'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> conversationsJson =
            jsonData['data']['conversations'];

        return conversationsJson
            .map((json) => ConversationModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(message: 'Failed to load conversations');
      }
    } catch (e) {
      throw ServerException(message: 'Error: ${e.toString()}');
    }
  }

  @override
  Stream<List<ConversationModel>> getConversationsStream(
    String userId,
    bool isDoctor,
  ) {
    // For real-time updates, this would typically connect to a WebSocket or SSE
    // For this implementation, we'll just emit the current conversations once
    return Stream.fromFuture(getConversations());
  }

  @override
  Future<ConversationModel> getConversation(String conversationId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/v1/conversations/$conversationId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final Map<String, dynamic> conversationJson =
            jsonData['data']['conversation'];

        return ConversationModel.fromJson(conversationJson);
      } else {
        throw ServerException(message: 'Failed to load conversation');
      }
    } catch (e) {
      throw ServerException(message: 'Error: ${e.toString()}');
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/v1/conversations/$conversationId/messages'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> messagesJson = jsonData['data']['messages'];

        return messagesJson.map((json) => MessageModel.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Failed to load messages');
      }
    } catch (e) {
      throw ServerException(message: 'Error: ${e.toString()}');
    }
  }

  @override
  Future<ConversationModel> createConversation({
    required String patientId,
    required String doctorId,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/v1/conversations'),
        headers: headers,
        body: json.encode({'patientId': patientId, 'doctorId': doctorId}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final Map<String, dynamic> conversationJson =
            jsonData['data']['conversation'];

        return ConversationModel.fromJson(conversationJson);
      } else {
        throw ServerException(message: 'Failed to create conversation');
      }
    } catch (e) {
      throw ServerException(message: 'Error: ${e.toString()}');
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    required String type,
    File? file,
  }) async {
    try {
      if (file != null) {
        // For file upload, use multipart request
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/api/v1/conversations/$conversationId/messages'),
        );

        // Add headers
        headers.forEach((key, value) {
          request.headers[key] = value;
        });

        // Add file
        request.files.add(await http.MultipartFile.fromPath('file', file.path));

        // Add other fields if content is not empty
        if (content.isNotEmpty) {
          request.fields['content'] = content;
        }

        // Send request
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 201) {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          final Map<String, dynamic> messageJson = jsonData['data']['message'];

          return MessageModel.fromJson(messageJson);
        } else {
          throw ServerException(message: 'Failed to send message');
        }
      } else {
        // For text messages, use regular POST
        final response = await client.post(
          Uri.parse('$baseUrl/api/v1/conversations/$conversationId/messages'),
          headers: headers,
          body: json.encode({'content': content, 'type': type}),
        );

        if (response.statusCode == 201) {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          final Map<String, dynamic> messageJson = jsonData['data']['message'];

          return MessageModel.fromJson(messageJson);
        } else {
          throw ServerException(message: 'Failed to send message');
        }
      }
    } catch (e) {
      throw ServerException(message: 'Error: ${e.toString()}');
    }
  }

  @override
  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      final response = await client.patch(
        Uri.parse('$baseUrl/api/v1/conversations/$conversationId/read'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to mark messages as read');
      }
    } catch (e) {
      throw ServerException(message: 'Error: ${e.toString()}');
    }
  }
}
