class Conversation {
  final String id;
  final List<String> participants;
  final Map<String, dynamic>? lastMessage;
  final List<Map<String, dynamic>> messages;
  final int unreadCount;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.participants,
    this.lastMessage,
    required this.messages,
    this.unreadCount = 0,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      participants: (json['participants'] as List<dynamic>?)
              ?.map((p) => p as String)
              .toList() ??
          [],
      lastMessage: json['lastMessage'] as Map<String, dynamic>?,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => m as Map<String, dynamic>)
              .toList() ??
          [],
      unreadCount: json['unreadCount'] ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
      'lastMessage': lastMessage,
      'messages': messages,
      'unreadCount': unreadCount,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String getOtherUser(String currentUsername) {
    return participants.firstWhere(
      (p) => p != currentUsername,
      orElse: () => 'Unknown',
    );
  }

  Conversation copyWith({
    String? id,
    List<String>? participants,
    Map<String, dynamic>? lastMessage,
    List<Map<String, dynamic>>? messages,
    int? unreadCount,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      messages: messages ?? this.messages,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}