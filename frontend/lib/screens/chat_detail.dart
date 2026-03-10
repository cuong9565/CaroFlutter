import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models/user_model.dart';
import '../core/models/conversation_model.dart';
import '../core/models/message_model.dart';
import '../core/providers/chat_provider.dart';
import '../widgets/switch/message_bubble.dart';
import '../widgets/switch/message_input.dart';

class ChatDetail extends StatefulWidget {
  final Conversation conversation;
  final bool isEmbedded;
  
  const ChatDetail({
    super.key,
    required this.conversation,
    this.isEmbedded = false,
  });

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Load messages when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.loadMessages(widget.conversation.id);
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

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final otherUser = widget.conversation.getOtherUser(chatProvider.currentUserId);
    final messages = chatProvider.getMessages(widget.conversation.id);
    final isOtherUserTyping = chatProvider.isTyping(widget.conversation.id);

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
                  child: otherUser?.avartarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            otherUser!.avartarUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar(otherUser.username);
                            },
                          ),
                        )
                      : _buildDefaultAvatar(otherUser?.username ?? '?'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.conversation.getOtherUserName(chatProvider.currentUserId),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (otherUser?.isOnline ?? false)
                        const Text(
                          'Đang hoạt động',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
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
                    final isMe = message.sender.id == chatProvider.currentUserId;
                    bool showAvatar = true;
                    if (index < messages.length - 1) {
                      final nextMessage = messages[index + 1];
                      showAvatar = nextMessage.sender.id != message.sender.id;
                    }
                    return MessageBubble(
                      message: message,
                      isMe: isMe,
                      showAvatar: showAvatar,
                    );
                  },
                ),
        ),
        // Message input
        MessageInput(
          onSendMessage: (content) {
            chatProvider.sendMessage(widget.conversation.id, content);
          },
          onTypingChanged: (isTyping) {
            if (_isTyping != isTyping) {
              _isTyping = isTyping;
              chatProvider.setTyping(widget.conversation.id, isTyping);
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
              child: otherUser?.avartarUrl != null
                  ? ClipOval(
                      child: Image.network(
                        otherUser!.avartarUrl!,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar(otherUser.username);
                        },
                      ),
                    )
                  : _buildDefaultAvatar(otherUser?.username ?? '?'),
            ),
            const SizedBox(width: 12),
            
            // Name and status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation.getOtherUserName(chatProvider.currentUserId),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (otherUser?.isOnline ?? false)
                    const Text(
                      'Đang hoạt động',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Implement menu
            },
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
            color: Colors.grey[400]!.withOpacity(0.5 + (value * 0.5)),
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
