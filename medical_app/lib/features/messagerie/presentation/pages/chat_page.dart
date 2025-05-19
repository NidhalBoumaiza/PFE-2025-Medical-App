import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/core/utils/constants.dart';
import 'package:medical_app/features/auth/domain/entities/user_entity.dart';
import 'package:medical_app/features/messagerie/domain/entities/conversation_entity.dart';
import 'package:medical_app/features/messagerie/domain/entities/message_entity.dart';
import 'package:medical_app/features/messagerie/presentation/blocs/message/message_bloc.dart';

class ChatPage extends StatefulWidget {
  final ConversationEntity conversation;

  const ChatPage({Key? key, required this.conversation}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _sendingImage = false;

  String get otherUserId {
    final isCurrentUserDoctor = context.read<MessageBloc>().isCurrentUserDoctor;
    return isCurrentUserDoctor
        ? widget.conversation.patientId
        : widget.conversation.doctorId;
  }

  String get otherUserName {
    final isCurrentUserDoctor = context.read<MessageBloc>().isCurrentUserDoctor;
    return isCurrentUserDoctor
        ? widget.conversation.patientName
        : widget.conversation.doctorName;
  }

  @override
  void initState() {
    super.initState();
    // Fetch messages
    context.read<MessageBloc>().add(
      FetchMessagesEvent(conversationId: widget.conversation.id!),
    );

    // Mark messages as read
    context.read<MessageBloc>().add(
      MarkMessagesAsReadEvent(conversationId: widget.conversation.id!),
    );
  }

  @override
  void dispose() {
    // Send typing stopped indicator before leaving
    if (_isTyping) {
      context.read<MessageBloc>().add(
        SendTypingEvent(
          recipientId: otherUserId,
          conversationId: widget.conversation.id!,
          isTyping: false,
        ),
      );
    }
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedImage != null) {
        setState(() {
          _selectedImage = File(pickedImage.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();

    if (message.isEmpty && _selectedImage == null) return;

    if (_selectedImage != null) {
      setState(() {
        _sendingImage = true;
      });

      // Send image message
      context.read<MessageBloc>().add(
        SendMessageEvent(
          conversationId: widget.conversation.id!,
          content: message, // Caption can be empty
          type: 'image',
          file: _selectedImage,
        ),
      );

      setState(() {
        _selectedImage = null;
      });
    } else {
      // Send text message
      context.read<MessageBloc>().add(
        SendMessageEvent(
          conversationId: widget.conversation.id!,
          content: message,
          type: 'text',
        ),
      );
    }

    // Reset typing indicator
    if (_isTyping) {
      context.read<MessageBloc>().add(
        SendTypingEvent(
          recipientId: otherUserId,
          conversationId: widget.conversation.id!,
          isTyping: false,
        ),
      );
      _isTyping = false;
    }

    _messageController.clear();
  }

  void _onTextChanged(String text) {
    // Send typing indicator if needed
    if (text.isNotEmpty && !_isTyping) {
      context.read<MessageBloc>().add(
        SendTypingEvent(
          recipientId: otherUserId,
          conversationId: widget.conversation.id!,
          isTyping: true,
        ),
      );
      _isTyping = true;
    } else if (text.isEmpty && _isTyping) {
      context.read<MessageBloc>().add(
        SendTypingEvent(
          recipientId: otherUserId,
          conversationId: widget.conversation.id!,
          isTyping: false,
        ),
      );
      _isTyping = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(otherUserName, style: const TextStyle(fontSize: 16)),
            BlocBuilder<MessageBloc, MessageState>(
              builder: (context, state) {
                if (state is MessageLoaded && state.isTyping) {
                  return const Text(
                    'typing...',
                    style: TextStyle(fontSize: 12),
                  );
                }
                return Container();
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<MessageBloc>().add(
                FetchMessagesEvent(conversationId: widget.conversation.id!),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: BlocConsumer<MessageBloc, MessageState>(
              listener: (context, state) {
                if (state is MessageLoaded) {
                  // Scroll to bottom when new messages arrive
                  Future.delayed(
                    const Duration(milliseconds: 100),
                    _scrollToBottom,
                  );
                }
              },
              builder: (context, state) {
                if (state is MessageLoading && state.isInitialLoad) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MessageError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<MessageBloc>().add(
                              FetchMessagesEvent(
                                conversationId: widget.conversation.id!,
                              ),
                            );
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                } else if (state is MessageLoaded) {
                  final messages = state.messages;
                  if (messages.isEmpty) {
                    return const Center(
                      child: Text('No messages yet. Start the conversation!'),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 20,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _buildMessageItem(message);
                    },
                  );
                }

                return const Center(child: Text('Start a conversation'));
              },
            ),
          ),

          // Image preview
          if (_selectedImage != null)
            Container(
              padding: const EdgeInsets.all(8),
              height: 100,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 2,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo),
                    onPressed: _pickImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: _onTextChanged,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      maxLines: 5,
                    ),
                  ),
                  BlocBuilder<MessageBloc, MessageState>(
                    builder: (context, state) {
                      final isSending =
                          state is MessageLoading && !state.isInitialLoad;
                      return IconButton(
                        icon:
                            isSending
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.send),
                        onPressed: isSending ? null : _sendMessage,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(MessageEntity message) {
    final currentUserId = context.read<MessageBloc>().currentUser.id;
    final isSentByMe = message.sender == currentUserId;

    final time = DateFormat('HH:mm').format(message.timestamp);

    final backgroundColor = isSentByMe ? kPrimaryColor : Colors.grey.shade200;

    final textColor = isSentByMe ? Colors.white : Colors.black;

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 10,
          left: isSentByMe ? 50 : 0,
          right: isSentByMe ? 0 : 50,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (message.type == 'image' && message.fileUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  message.fileUrl!,
                  width: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 150,
                      color: Colors.grey.shade300,
                      child: const Center(child: Icon(Icons.error)),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 200,
                      height: 150,
                      color: Colors.grey.shade300,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),

            if (message.type == 'file' && message.fileUrl != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.attach_file),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        message.fileName ?? 'File',
                        style: TextStyle(color: textColor),
                      ),
                    ),
                  ],
                ),
              ),

            if (message.content.isNotEmpty)
              Text(message.content, style: TextStyle(color: textColor)),

            const SizedBox(height: 5),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
                if (isSentByMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      message.status == 'read' ? Icons.done_all : Icons.done,
                      size: 12,
                      color:
                          message.status == 'read'
                              ? Colors.blue
                              : textColor.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
