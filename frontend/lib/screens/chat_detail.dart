import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models/conversation_model.dart';
import '../core/models/message_model.dart';
import '../core/providers/chat_provider.dart';
import '../core/providers/challenge_provider.dart';
import '../widgets/switch/message_bubble.dart';
import '../widgets/switch/message_input.dart';

class ChatDetail extends StatefulWidget {
  final Conversation conversation;
  final bool isEmbedded;
  final String? targetUserId;
  
  const ChatDetail({
    super.key,
    required this.conversation,
    this.isEmbedded = false,
    this.targetUserId,
  });

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  late String _conversationId;

  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversation.id;
    // Load messages when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      if (_conversationId.isNotEmpty) {
        chatProvider.loadMessages(_conversationId);
      }
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  String? _resolveTargetUserId(
    ChatProvider chatProvider,
    List<Message> messages,
  ) {
    if (widget.targetUserId != null && widget.targetUserId!.isNotEmpty) {
      return widget.targetUserId;
    }

    final otherParticipant =
        widget.conversation.getOtherParticipant(chatProvider.currentUsername);
    if (otherParticipant != null && otherParticipant.id.isNotEmpty) {
      return otherParticipant.id;
    }

    final currentUserId = chatProvider.currentUserId;
    if (currentUserId.isEmpty) {
      return null;
    }

    for (final message in messages) {
      if (message.senderId.isNotEmpty && message.senderId != currentUserId) {
        return message.senderId;
      }
    }

    return null;
  }

  Future<void> _sendChallenge(String targetUserId) async {
    try {
      final challengeProvider =
          Provider.of<ChallengeProvider>(context, listen: false);
      await challengeProvider.sendChallenge(targetUserId);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loi: ${error.toString()}')),
      );
    }
  }

  String _resolveAvatarUrlForMessage(
    Message message,
    ChatProvider chatProvider,
  ) {
    for (final participant in widget.conversation.participantDetails) {
      if (participant.id.isNotEmpty && participant.id == message.senderId) {
        return participant.avatarUrl;
      }
    }

    for (final participant in widget.conversation.participantDetails) {
      if (participant.username == message.senderUsername) {
        return participant.avatarUrl;
      }
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final otherParticipant =
      widget.conversation.getOtherParticipant(chatProvider.currentUsername);
    final otherUser = otherParticipant?.username ??
      widget.conversation.getOtherUser(chatProvider.currentUsername);
    final avatarUrl = otherParticipant?.avatarUrl ?? '';
    final messages = _conversationId.isEmpty
      ? <Message>[]
      : chatProvider.getMessages(_conversationId);
    final isOtherUserTyping = _conversationId.isEmpty
        ? false
        : chatProvider.isTyping(_conversationId);
    final targetUserId = _resolveTargetUserId(chatProvider, messages);

    // Auto-scroll when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (messages.isNotEmpty) {
        _scrollToBottom();
      }
    });

    Widget content = Column(
      children: [
        // Header for embedded mode
        if (widget.isEmbedded)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl.isNotEmpty
                      ? null
                      : _buildDefaultAvatar(otherUser),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherUser,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Thach dau',
                  onPressed: targetUserId == null
                      ? null
                      : () => _sendChallenge(targetUserId),
                  icon: const Icon(Icons.sports_esports),
                ),
                // IconButton(
                //   icon: const Icon(Icons.more_vert),
                //   onPressed: () {},
                // ),
              ],
            ),
          ),
        // Messages list
        Expanded(
          child: messages.isEmpty
              ? const Center(
                  child: Text(
                    'Chưa có tin nhắn nào',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: messages.length + (isOtherUserTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length && isOtherUserTyping) {
                      return _buildTypingIndicator();
                    }
                    final message = messages[index];
                    final isMe = message.senderUsername == chatProvider.currentUsername;
                    bool showAvatar = true;
                    if (index < messages.length - 1) {
                      final nextMessage = messages[index + 1];
                      showAvatar = nextMessage.senderUsername != message.senderUsername;
                    }
                    return MessageBubble(
                      message: message,
                      isMe: isMe,
                      showAvatar: showAvatar,
                      avatarUrl:
                          _resolveAvatarUrlForMessage(message, chatProvider),
                    );
                  },
                ),
        ),
        // Message input
        MessageInput(
          onSendMessage: (content) async {
            if (_conversationId.isEmpty && widget.targetUserId != null) {
              final newId = await chatProvider.sendMessageToUser(
                widget.targetUserId!,
                otherUser,
                content,
              );
              if (mounted) {
                setState(() {
                  _conversationId = newId;
                });
              }
              chatProvider.loadMessages(newId);
              return;
            }
            if (_conversationId.isNotEmpty) {
              chatProvider.sendMessage(_conversationId, content);
            }
          },
          onTypingChanged: (isTyping) {
            if (_conversationId.isNotEmpty && _isTyping != isTyping) {
              _isTyping = isTyping;
              chatProvider.setTyping(_conversationId, isTyping);
            }
          },
        ),
      ],
    );

    if (widget.isEmbedded) {
      return Container(
        color: Colors.white,
        child: content,
      );
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              child: avatarUrl.isNotEmpty
                  ? null
                  : _buildDefaultAvatar(otherUser),
            ),
            const SizedBox(width: 12),
            
            // Name and status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUser,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Thach dau',
            onPressed: targetUserId == null
                ? null
                : () => _sendChallenge(targetUserId),
            icon: const Icon(Icons.sports_esports),
          ),
        ],
      ),
      body: content,
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(200),
                const SizedBox(width: 4),
                _buildTypingDot(400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[400]!.withValues(alpha: 0.5 + (value * 0.5)),
            shape: BoxShape.circle,
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }
}
