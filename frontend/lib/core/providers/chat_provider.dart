import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/socket_service.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/service.dart';

class ChatProvider with ChangeNotifier {
 
  final String _apiUrl = Service.apiUrl ;
  List<Conversation> _conversations = [];
  final Map<String, List<Message>> _conversationMessages = {};
  final Map<String, bool> _typingStatus = {};
  bool _isConnected = false;
  final String _currentUserId = '1a7f2c11-937d-427f-8882-3570a6f706b8';
  String _currentUsername = '';

  List<Conversation> get conversations => _conversations;
  bool get isConnected => _isConnected;
  String get currentUserId => _currentUserId;
  String get currentUsername => _currentUsername;

  ChatProvider() {
    _loadCurrentUser().then((_) {
      SocketService.init(_currentUserId);
      _setupSocketListeners();
    });
  }

  void _setupSocketListeners() {
    SocketService.onNewMessage(_handleNewMessage);
    SocketService.onConversationHistory(_handleConversationHistory);
  }

  void disconnect() {
    SocketService.disconnect();
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

  Future<void> _loadCurrentUser() async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/users/get/$_currentUserId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = UserModel.fromJson(data['user']);
        _currentUsername = user.username;
        print('Loaded current username: $_currentUsername');
      } else {
        print('Error loading current user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  // Load conversations from server
  Future<void> loadConversations() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/chat/conversations?userId=$_currentUserId'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final conversationsData = data['conversations'] as List;
        print('Loaded ${data['count']} conversations from server');
        final newConversations = conversationsData.map((c) => Conversation.fromJson(c)).toList();
        print('Parsed ${newConversations.length} conversations');
        // Populate messages cache
        for (final conv in newConversations) {
          final messagesData = conv.messages ?? [];
          _conversationMessages[conv.id] = messagesData.map((m) => Message.fromJson(m)).toList();
        }
        // Check for duplicates
        final ids = newConversations.map((c) => c.id).toSet();
        if (ids.length != newConversations.length) {
          print('Warning: Duplicate conversation IDs detected!');
          print('IDs: ${newConversations.map((c) => c.id).toList()}');
        }
        _conversations = newConversations;
        notifyListeners();
      } else {
        print('Error loading conversations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading conversations: $e');
    }
  }

  // Load messages for a conversation from server
  Future<void> loadMessages(String conversationId) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/chat/conversations/$conversationId/messages'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        _conversationMessages[conversationId] = data.map((m) => Message.fromJson(m)).toList();
        notifyListeners();
      } else {
        print('Error loading messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading messages: $e');
    }
    SocketService.joinConversation(conversationId);
  }

  // Send a message
  void sendMessage(String conversationId, String content) {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      senderUsername: _currentUsername,
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
     
    }
    
    notifyListeners();
    SocketService.sendMessage(conversationId, content, _currentUserId);
  }


  void setTyping(String conversationId, bool isTyping) {
    SocketService.sendTyping(conversationId, _currentUserId, isTyping);
  }

  // Mark message as read
  void markAsRead(String conversationId, String messageId) {

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

    final convIndex = _conversations.indexWhere((c) => c.id == message.conversationId);
    if (convIndex != -1) {
      final conv = _conversations[convIndex];
      _conversations.removeAt(convIndex);
      _conversations.insert(0, conv);
    }
    
    notifyListeners();
  }

  void _handleConversationHistory(List<Message> messages) {
  
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
