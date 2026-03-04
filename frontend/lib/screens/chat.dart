import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';
import '../models/UserModel.dart';
import 'chat_detail.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Conversation? _selectedConversation;

  @override
  void initState() {
    super.initState();
    // Load conversations when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.loadConversations();
      
      // Connect to socket (replace with your server URL)
      // chatProvider.connect('http://localhost:3000', 'user123');
    });
  }

              
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tin nhắn',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Implement menu
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          
          return Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              if (chatProvider.conversations.isEmpty) {
                return _buildEmptyState();
              }

              final conversationsList = Column(
                children: [
                  // Connection status indicator
                  if (!chatProvider.isConnected)
                    _buildConnectionStatus(),
                  
                  // Conversations list
                  Expanded(
                    child: ListView.builder(
                      itemCount: chatProvider.conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = chatProvider.conversations[index];
                        return _buildConversationItem(
                          context, 
                          conversation, 
                          chatProvider,
                          isWide,
                        );
                      },
                    ),
                  ),
                ],
              );

              if (isWide) {
                return Row(
                  children: [
                    // Left Column: Conversations List
                    SizedBox(
                      width: 350,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(right: BorderSide(color: Colors.grey[200]!)),
                        ),
                        child: conversationsList,
                      ),
                    ),
                    
                    // Right Column: Chat Detail
                    Expanded(
                      child: _selectedConversation != null
                          ? ChatDetail(
                              key: ValueKey(_selectedConversation!.id),
                              conversation: _selectedConversation!,
                              isEmbedded: true,
                            )
                          : const Center(
                              child: Text(
                                'Chọn một cuộc trò chuyện để bắt đầu',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                    ),
                  ],
                );
              }

              return conversationsList;
            },
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // TODO: Navigate to new chat screen
      //   },
      //   child: const Icon(Icons.edit),
      // ),
    );
  }

  Widget _buildConversationItem(
    BuildContext context,
    Conversation conversation,
    ChatProvider chatProvider,
    bool isWide,
  ) {
    final otherUser = conversation.getOtherUser(chatProvider.currentUserId);
    final hasUnread = conversation.unreadCount > 0;
    final isSelected = _selectedConversation?.id == conversation.id;

    return InkWell(
      onTap: () {
        if (isWide) {
          setState(() {
            _selectedConversation = conversation;
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetail(conversation: conversation),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected && isWide ? Colors.blue[50] : null,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[300],
                  child: otherUser?.avatar != null
                      ? ClipOval(
                          child: Image.network(
                            otherUser!.avatar!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar(otherUser.name);
                            },
                          ),
                        )
                      : _buildDefaultAvatar(otherUser?.name ?? '?'),
                ),
                if (otherUser?.isOnline ?? false)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            
            // Conversation info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.getOtherUserName(chatProvider.currentUserId),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(conversation.updatedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: hasUnread ? Theme.of(context).primaryColor : Colors.grey[600],
                          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage?.content ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: hasUnread ? const Color.fromARGB(221, 59, 13, 13) : Colors.grey[600],
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            conversation.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Chưa có cuộc trò chuyện nào',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.orange[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 16, color: Colors.orange[800]),
          const SizedBox(width: 8),
          Text(
            'Đang kết nối...',
            style: TextStyle(
              color: Colors.orange[800],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE', 'vi').format(time);
    } else {
      return DateFormat('dd/MM').format(time);
    }
  }
    } 