import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/core/utils/constants.dart';
import 'package:medical_app/features/messagerie/domain/entities/conversation_entity.dart';
import 'package:medical_app/features/messagerie/presentation/blocs/conversation/conversation_bloc.dart';
import 'package:medical_app/features/messagerie/presentation/blocs/socket/socket_bloc.dart';
import 'package:medical_app/features/messagerie/presentation/pages/chat_page.dart';

class ConversationsPage extends StatefulWidget {
  static const String routeName = '/conversations';

  const ConversationsPage({Key? key}) : super(key: key);

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ConversationBloc>().add(FetchConversationsEvent());
    context.read<SocketBloc>().add(ConnectSocketEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ConversationBloc>().add(FetchConversationsEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<ConversationBloc, ConversationState>(
        builder: (context, state) {
          if (state is ConversationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ConversationError) {
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
                      context.read<ConversationBloc>().add(
                        FetchConversationsEvent(),
                      );
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else if (state is ConversationsLoaded) {
            final conversations = state.conversations;
            if (conversations.isEmpty) {
              return const Center(child: Text('No conversations yet'));
            }
            return ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _buildConversationItem(context, conversations[index]);
              },
            );
          }

          return const Center(child: Text('Start a conversation'));
        },
      ),
    );
  }

  Widget _buildConversationItem(
    BuildContext context,
    ConversationEntity conversation,
  ) {
    final isCurrentUserDoctor =
        context.read<ConversationBloc>().isCurrentUserDoctor;
    final otherName =
        isCurrentUserDoctor
            ? conversation.patientName
            : conversation.doctorName;

    final formattedDate = _formatDateTime(conversation.lastMessageTime);

    // Determine if the message is unread
    final isUnread =
        !conversation.lastMessageReadBy.contains(
          context.read<ConversationBloc>().currentUserId,
        );

    // Determine message preview based on type
    String messagePreview = conversation.lastMessage;
    if (conversation.lastMessageType == 'image') {
      messagePreview = '🖼️ Image';
    } else if (conversation.lastMessageType == 'file') {
      messagePreview = '📎 File';
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: kPrimaryColor,
        child: Text(
          otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        otherName,
        style: TextStyle(
          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        messagePreview,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: 12,
              color: isUnread ? kPrimaryColor : Colors.grey,
            ),
          ),
          if (isUnread)
            Container(
              margin: const EdgeInsets.only(top: 5),
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: kPrimaryColor,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(conversation: conversation),
          ),
        ).then((_) {
          // Refresh conversations when returning from chat
          context.read<ConversationBloc>().add(FetchConversationsEvent());
        });
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today, show time
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week, show day name
      return DateFormat('EEEE').format(dateTime);
    } else {
      // Older, show date
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }
}
