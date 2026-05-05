class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderUsername;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final bool isSent;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderUsername,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.isSent = true,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderUsername: _parseSenderUsername(json['sender']),
      content: json['content'] ?? '',
      timestamp: _parseTimestamp(json['timestamp']),
      isRead: json['isRead'] ?? false,
      isSent: json['isSent'] ?? true,
    );
  }

  static String _parseSenderUsername(dynamic sender) {
    if (sender is String) {
      return sender;
    }

    if (sender is Map && sender['username'] is String) {
      return sender['username'] as String;
    }

    return '';
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is DateTime) {
      return value.toLocal();
    }

    if (value is String && value.isNotEmpty) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed.toLocal();
      }
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value).toLocal();
    }

    return DateTime.now().toLocal();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'sender': senderUsername,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'isSent': isSent,
    };
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderUsername,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    bool? isSent,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderUsername: senderUsername ?? this.senderUsername,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isSent: isSent ?? this.isSent,
    );
  }
}