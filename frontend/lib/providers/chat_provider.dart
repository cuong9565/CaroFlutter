import 'package:flutter/foundation.dart';
import '../models/UserModel.dart';
import '../services/socket_service.dart';

class ChatProvider with ChangeNotifier {
  final SocketService _socketService = SocketService();
  
  List<Conversation> _conversations = [];
  Map<String, List<Message>> _conversationMessages = {};
  Map<String, bool> _typingStatus = {};
  bool _isConnected = false;
  String _currentUserId = '';

  List<Conversation> get conversations => _conversations;
  bool get isConnected => _isConnected;
  String get currentUserId => _currentUserId;

  ChatProvider() { 
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socketService.onMessageReceived = _handleNewMessage;
    _socketService.onTyping = _handleTyping;
    _socketService.onUserStatusChanged = _handleUserStatusChanged;
    _socketService.onConnectionChanged = (connected) {
      _isConnected = connected;
      notifyListeners();
    };
  }

  void connect(String serverUrl, String userId) {
    _currentUserId = userId;
    _socketService.connect(serverUrl, userId);
  }

  void disconnect() {
    _socketService.disconnect();
    _isConnected = false;
    notifyListeners();
  }

  // Get messages for a specific conversation
  List<Message> getMessages(String conversationId) {
    return _conversationMessages[conversationId] ?? [];
  }

  // Check if user is typing in a conversation
  bool isTyping(String conversationId) {
    return _typingStatus[conversationId] ?? false;
  }

  // Load conversations (mock data for now)
  void loadConversations() {
    // In a real app, this would fetch from an API
    _conversations = _generateMockConversations();
    notifyListeners();
  }

  // Load messages for a conversation (mock data for now)
  void loadMessages(String conversationId) {
    if (!_conversationMessages.containsKey(conversationId)) {
      _conversationMessages[conversationId] = _generateMockMessages(conversationId);
      notifyListeners();
    }
    _socketService.joinConversation(conversationId);
  }

  // Send a message
  void sendMessage(String conversationId, String content) {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      sender: User(id: _currentUserId, name: 'You'),
      content: content,
      timestamp: DateTime.now(),
      isSent: false,
    );

    // Add to local messages
    if (!_conversationMessages.containsKey(conversationId)) {
      _conversationMessages[conversationId] = [];
    }
    _conversationMessages[conversationId]!.add(message);
    
    // Update conversation's last message
    final convIndex = _conversations.indexWhere((c) => c.id == conversationId);
    if (convIndex != -1) {
      // Note: In a real app, you'd create a new Conversation object with updated lastMessage
    }
    
    notifyListeners();

    // Send via socket
    _socketService.sendMessage(message);
  }

  // Handle typing indicator
  void setTyping(String conversationId, bool isTyping) {
    _socketService.sendTyping(conversationId, _currentUserId, isTyping);
  }

  // Mark message as read
  void markAsRead(String conversationId, String messageId) {
    _socketService.markAsRead(conversationId, messageId);
    
    // Update local message
    final messages = _conversationMessages[conversationId];
    if (messages != null) {
      final index = messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(isRead: true);
        notifyListeners();
      }
    }
  }

  void _handleNewMessage(Message message) {
    // Add message to conversation
    if (!_conversationMessages.containsKey(message.conversationId)) {
      _conversationMessages[message.conversationId] = [];
    }
    _conversationMessages[message.conversationId]!.add(message);
    
    // Update conversation's last message and move to top
    final convIndex = _conversations.indexWhere((c) => c.id == message.conversationId);
    if (convIndex != -1) {
      final conv = _conversations[convIndex];
      _conversations.removeAt(convIndex);
      // Note: In a real app, create new Conversation with updated lastMessage
      _conversations.insert(0, conv);
    }
    
    notifyListeners();
  }

  void _handleTyping(String conversationId, String userId) {
    if (userId != _currentUserId) {
      _typingStatus[conversationId] = true;
      notifyListeners();
      
      // Clear typing status after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        _typingStatus[conversationId] = false;
        notifyListeners();
      });
    }
  }

  void _handleUserStatusChanged(String userId, bool isOnline) {
    // Update user status in conversations
    for (var conv in _conversations) {
      for (var participant in conv.participants) {
        if (participant.id == userId) {
          // Note: In a real app, you'd update the User object
          notifyListeners();
          break;
        }
      }
    }
  }

  // Mock data generators
  List<Conversation> _generateMockConversations() {
    return [
      Conversation(
        id: '1',
        participants: [
          User(id: _currentUserId, name: 'You'),
          User(id: '2', name: 'Nguyễn Văn A', isOnline: true),
        ],
        lastMessage: Message(
          id: '1',
          conversationId: '1',
          sender: User(id: '2', name: 'Nguyễn Văn A'),
          content: 'Chào bạn! Chơi cờ caro không?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        unreadCount: 2,
        updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Conversation(
        id: '2',
        participants: [
          User(id: _currentUserId, name: 'You'),
          User(id: '3', name: 'Trần Thị B', isOnline: false),
        ],
        lastMessage: Message(
          id: '2',
          conversationId: '2',
          sender: User(id: _currentUserId, name: 'You'),
          content: 'Ok, hẹn gặp lại!',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        unreadCount: 0,
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  List<Message> _generateMockMessages(String conversationId) {
    final otherUser = User(id: '2', name: 'Nguyễn Văn A', isOnline: true);
    final now = DateTime.now();
    
    return [
      Message(
        id: '1',
        conversationId: conversationId,
        sender: otherUser,
        content: 'Chào bạn!',
        timestamp: now.subtract(const Duration(minutes: 10)),
        isRead: true,
      ),
      Message(
        id: '2',
        conversationId: conversationId,
        sender: User(id: _currentUserId, name: 'You'),
        content: 'Chào! Bạn khỏe không?',
        timestamp: now.subtract(const Duration(minutes: 9)),
        isRead: true,
      ),
      Message(
        id: '3',
        conversationId: conversationId,
        sender: otherUser,
        content: 'Mình khỏe. Chơi cờ caro không?',
        timestamp: now.subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
    ];
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
