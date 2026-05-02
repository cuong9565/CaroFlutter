import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../services/socket_service.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/service.dart';

class ChatProvider with ChangeNotifier {
 
  final String _apiUrl = Service.apiUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<Conversation> _conversations = [];
  final Map<String, List<Message>> _conversationMessages = {};
  final Map<String, bool> _typingStatus = {};
  bool _isConnected = false;
  String _currentUserId = '';
  String _currentUsername = '';
  bool _isInitialized = false;

  List<Conversation> get conversations => _conversations;
  bool get isConnected => _isConnected;
  String get currentUserId => _currentUserId;
  String get currentUsername => _currentUsername;
  bool get isInitialized => _isInitialized;

  ChatProvider() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      // Đọc userId từ FlutterSecureStorage
      final uid = await _storage.read(key: 'uid');
      print('ChatProvider: Read uid from storage: $uid');
      if (uid != null && uid.isNotEmpty) {
        _currentUserId = uid;
        await _loadCurrentUser();
        SocketService.init(_currentUserId);
        _setupSocketListeners();
        _isInitialized = true;
        print('ChatProvider: Initialized with userId: $_currentUserId');
        notifyListeners();
      } else {
        print('ChatProvider: No user ID found in storage');
        _isInitialized = true; // Đánh dấu đã init xong dù không có userId
        notifyListeners();
      }
    } catch (e) {
      print('ChatProvider: Error initializing user: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Gọi method này khi user đăng nhập mới để reinitialize với userId mới
  Future<void> reinitialize() async {
    // Disconnect socket cũ nếu có
    if (_isInitialized) {
      SocketService.disconnect();
    }
    
    // Reset state
    _conversations = [];
    _conversationMessages.clear();
    _typingStatus.clear();
    _isConnected = false;
    _currentUserId = '';
    _currentUsername = '';
    _isInitialized = false;
    
    // Khởi tạo lại với userId mới từ storage
    await _initializeUser();
  }

  void _setupSocketListeners() {
    // onNewMessage và onConversationHistory đã tự động clear listener cũ
    SocketService.onNewMessage(_handleNewMessage);
    SocketService.onConversationHistory(_handleConversationHistory);
  }

  /// Chờ cho đến khi userId được khởi tạo (tối đa 5 giây)
  Future<void> _waitForInitialization() async {
    int attempts = 0;
    const maxAttempts = 50; // 50 * 100ms = 5 seconds
    while (!_isInitialized && attempts < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
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
    // Đảm bảo userId đã được khởi tạo
    if (_currentUserId.isEmpty) {
      print('ChatProvider: Cannot load conversations - userId is empty. Waiting for initialization...');
      // Chờ khởi tạo nếu chưa có userId
      await _waitForInitialization();
      if (_currentUserId.isEmpty) {
        print('ChatProvider: Still no userId after waiting');
        return;
      }
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/chat/conversations?userId=$_currentUserId'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final conversationsData = data['conversations'] as List;
        print('Loaded ${data['count']} conversations from server');
        final newConversations = conversationsData
            .map((c) => Conversation.fromJson(c as Map<String, dynamic>))
            .toList();
        newConversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        print('Parsed ${newConversations.length} conversations');
        // Populate messages cache
        for (final conv in newConversations) {
          final sortedMessages = conv.messages
              .map((m) => Message.fromJson(m))
              .toList()
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
          _conversationMessages[conv.id] = sortedMessages;
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
        final sortedMessages = data
            .map((m) => Message.fromJson(m as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
        _conversationMessages[conversationId] = sortedMessages;
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
      final updatedConv = _conversations[convIndex].copyWith(
        lastMessage: {
          'content': content,
          'sender': _currentUsername,
          'timestamp': message.timestamp.toIso8601String(),
        },
        updatedAt: message.timestamp,
      );
      _conversations[convIndex] = updatedConv;
      // Di chuyển conversation lên đầu danh sách
      _conversations.removeAt(convIndex);
      _conversations.insert(0, updatedConv);
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
    // Không thêm message của chính mình (đã được thêm local khi gửi)
    if (message.senderUsername == _currentUsername) {
      // Cập nhật message local với ID từ server nếu cần
      final messages = _conversationMessages[message.conversationId];
      if (messages != null) {
        // Tìm message pending có cùng content và timestamp gần đúng
        final pendingIndex = messages.indexWhere((m) => 
          m.senderUsername == _currentUsername && 
          m.content == message.content &&
          !m.isSent
        );
        if (pendingIndex != -1) {
          // Cập nhật với message từ server (có ID thực)
          messages[pendingIndex] = message;
          notifyListeners();
        }
      }
      return;
    }
    
    // Add message to conversation (chỉ với message từ người khác)
    if (!_conversationMessages.containsKey(message.conversationId)) {
      _conversationMessages[message.conversationId] = [];
    }
    _conversationMessages[message.conversationId]!.add(message);
    _conversationMessages[message.conversationId]!
        .sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Cập nhật lastMessage và di chuyển conversation lên đầu
    final convIndex = _conversations.indexWhere((c) => c.id == message.conversationId);
    if (convIndex != -1) {
      final updatedConv = _conversations[convIndex].copyWith(
        lastMessage: {
          'content': message.content,
          'sender': message.senderUsername,
          'timestamp': message.timestamp.toIso8601String(),
        },
        updatedAt: message.timestamp,
      );
      _conversations.removeAt(convIndex);
      _conversations.insert(0, updatedConv);
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
