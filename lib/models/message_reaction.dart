class MessageReaction {
  final String id;
  final String messageId;
  final String userId;
  final String reaction;
  final DateTime createdAt;

  MessageReaction({
    required this.id,
    required this.messageId,
    required this.userId,
    required this.reaction,
    required this.createdAt,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) => MessageReaction(
        id: json['id'],
        messageId: json['message_id'],
        userId: json['user_id'],
        reaction: json['reaction'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'message_id': messageId,
        'user_id': userId,
        'reaction': reaction,
        'created_at': createdAt.toIso8601String(),
      };
} 