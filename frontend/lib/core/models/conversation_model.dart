import 'user_model.dart';
import 'message_model.dart';

class Conversation {
  final String id;
  final List<UserModel> participants;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      participants: (json['participants'] as List<dynamic>?)
              ?.map((p) => UserModel.fromJson(p))
              .toList() ??
          [],
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants.map((p) => p.toJson()).toList(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String getOtherUserName(String currentUserId) {
    final otherUser = participants.firstWhere(
      (user) => user.id != currentUserId,
      orElse: () => participants.first,
    );
    return otherUser.username;
  }

  UserModel? getOtherUser(String currentUserId) {
    return participants.firstWhere(
      (user) => user.id != currentUserId,
      orElse: () => participants.first,
    );
  }
}