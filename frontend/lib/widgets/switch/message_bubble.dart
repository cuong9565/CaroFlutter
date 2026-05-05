import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showAvatar;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar) _buildAvatar(),
          if (!isMe && showAvatar) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? Theme.of(context).primaryColor
                        : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 20),
                    ),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead
                            ? Icons.done_all
                            : message.isSent
                                ? Icons.done
                                : Icons.access_time,
                        size: 14,
                        color: message.isRead ? Colors.blue : Colors.grey[600],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isMe && showAvatar) const SizedBox(width: 8),
          if (isMe && showAvatar) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.grey[300],
      child: _buildDefaultAvatar(),
    );
  }

  Widget _buildDefaultAvatar() {
    return Text(
      message.senderUsername.isNotEmpty
          ? message.senderUsername[0].toUpperCase()
          : '?',
      style: const TextStyle(
        fontSize: 14,
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
      return 'Hôm qua ${DateFormat('HH:mm').format(localTime)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE HH:mm').format(localTime);
    } else {
      return DateFormat('dd/MM/yyyy').format(localTime);
    }
  }
}
