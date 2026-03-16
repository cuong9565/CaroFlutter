class Message {
  final String id;
  final String conversationId;
  final String senderUsername;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final bool isSent;

  Message({
    required this.id,
    required this.conversationId,
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
      senderUsername: json['sender'] is String ? json['sender'] : json['sender']['username'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      isSent: json['isSent'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
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
    String? senderUsername,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    bool? isSent,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderUsername: senderUsername ?? this.senderUsername,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isSent: isSent ?? this.isSent,
    );
  }
}