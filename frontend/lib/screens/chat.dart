import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../core/providers/chat_provider.dart';
import '../core/models/conversation_model.dart';
import 'chat_detail.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Conversation? _selectedConversation;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  bool _didHandleDeepLink = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      // Nếu chưa có userId, reinitialize để đọc lại từ storage
      if (chatProvider.currentUserId.isEmpty) {
        await chatProvider.reinitialize();
      }
      await chatProvider.loadConversations();
      await _handleDeepLink(chatProvider);
    });
  }

  Future<void> _handleDeepLink(ChatProvider chatProvider) async {
    if (_didHandleDeepLink) {
      return;
    }
    final extra = GoRouterState.of(context).extra;
    if (extra is Map) {
      final targetUserId = extra['targetUserId']?.toString();
      final targetUsername = extra['targetUsername']?.toString();
      if (targetUserId != null && targetUserId.isNotEmpty) {
        final conversation = await chatProvider.openConversationWithUser(
          targetUserId,
          targetUsername ?? 'Khong ro',
        );
        if (!mounted) {
          return;
        }
        final isWide = MediaQuery.of(context).size.width > 700;
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
      }
    }
    _didHandleDeepLink = true;
  }

              
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tin nhắn',
          style: TextStyle(fontWeight: FontWeight.bold),      
        ),
        elevation: 4,
        backgroundColor: Colors.white12,
      ),

      body: Padding( 
        padding: const EdgeInsets.only(top: 20 , left: 10 ,right: 10),
        child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;         
          return Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              if (chatProvider.conversations.isEmpty) {
                return _buildEmptyState();
              }

              final conversationsList = Column(
                children: [
                    Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 190, 205, 230),
                      border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: _isSearching ? 40 : 0,
                            child: _isSearching
                                ? TextField(
                                    controller: _searchController,
                                    decoration: const InputDecoration(
                                      hintText: 'Tìm kiếm cuộc trò chuyện...',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (value) {
                                      
                                    },
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                        IconButton(
                          icon: Icon(_isSearching ? Icons.close : Icons.search),
                          onPressed: () {
                            setState(() {
                              _isSearching = !_isSearching;
                              if (!_isSearching) {
                                _searchController.clear();  
                                
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
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
                    SizedBox(
                      width: 350,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(right: BorderSide(color: Colors.grey[200]!)),
                        ),
                        child: conversationsList,
                      ),
                    ),
                    Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 10),  
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
    )
    );
  }

  Widget _buildConversationItem(
    BuildContext context,
    Conversation conversation,
    ChatProvider chatProvider,
    bool isWide,
  ) {
    final otherUser = conversation.getOtherUser(chatProvider.currentUsername);
    final hasUnread = conversation.unreadCount > 0;
    final isSelected = _selectedConversation?.id == conversation.id;
    final lastMessageContent = conversation.lastMessage?['content'] ?? '';

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
          color: isSelected && isWide ? const Color.fromARGB(46, 191, 197, 224) : null,
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
                  child: _buildDefaultAvatar(otherUser),
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
                          otherUser,
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
                          lastMessageContent,
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
    final localTime = time.isUtc ? time.toLocal() : time;
    final now = DateTime.now();
    final difference = now.difference(localTime);

    if (difference.isNegative) {
      return DateFormat('HH:mm').format(localTime);
    }

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(localTime);
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE').format(localTime);
    } else {
      return DateFormat('dd/MM').format(localTime);
    }
  }
}