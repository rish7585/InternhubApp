class TypingIndicator {
  final String userId;
  final String chatId; // Can be groupId or direct chat id
  final bool isTyping;
  final DateTime lastActive;

  TypingIndicator({
    required this.userId,
    required this.chatId,
    required this.isTyping,
    required this.lastActive,
  });

  factory TypingIndicator.fromJson(Map<String, dynamic> json) => TypingIndicator(
        userId: json['user_id'],
        chatId: json['chat_id'],
        isTyping: json['is_typing'] ?? false,
        lastActive: DateTime.parse(json['last_active']),
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'chat_id': chatId,
        'is_typing': isTyping,
        'last_active': lastActive.toIso8601String(),
      };
}

class MessageRead {
  final String messageId;
  final String userId;
  final DateTime readAt;

  MessageRead({
    required this.messageId,
    required this.userId,
    required this.readAt,
  });

  factory MessageRead.fromJson(Map<String, dynamic> json) => MessageRead(
        messageId: json['message_id'],
        userId: json['user_id'],
        readAt: DateTime.parse(json['read_at']),
      );

  Map<String, dynamic> toJson() => {
        'message_id': messageId,
        'user_id': userId,
        'read_at': readAt.toIso8601String(),
      };
} 