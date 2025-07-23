class Channel {
  final String id;
  final String name;
  final String? description;
  final String? city;
  final String? interest;
  final String createdBy;
  final DateTime createdAt;

  Channel({
    required this.id,
    required this.name,
    this.description,
    this.city,
    this.interest,
    required this.createdBy,
    required this.createdAt,
  });

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        city: json['city'],
        interest: json['interest'],
        createdBy: json['created_by'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'city': city,
        'interest': interest,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
      };
}

class ChannelMessage {
  final String id;
  final String channelId;
  final String userId;
  final String content;
  final String type;
  final DateTime createdAt;

  ChannelMessage({
    required this.id,
    required this.channelId,
    required this.userId,
    required this.content,
    this.type = 'text',
    required this.createdAt,
  });

  factory ChannelMessage.fromJson(Map<String, dynamic> json) => ChannelMessage(
        id: json['id'],
        channelId: json['channel_id'],
        userId: json['user_id'],
        content: json['content'],
        type: json['type'] ?? 'text',
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'channel_id': channelId,
        'user_id': userId,
        'content': content,
        'type': type,
        'created_at': createdAt.toIso8601String(),
      };
}

class Thread {
  final String id;
  final String channelId;
  final String title;
  final String createdBy;
  final DateTime createdAt;

  Thread({
    required this.id,
    required this.channelId,
    required this.title,
    required this.createdBy,
    required this.createdAt,
  });

  factory Thread.fromJson(Map<String, dynamic> json) => Thread(
        id: json['id'],
        channelId: json['channel_id'],
        title: json['title'],
        createdBy: json['created_by'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'channel_id': channelId,
        'title': title,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
      };
}

class ThreadMessage {
  final String id;
  final String threadId;
  final String userId;
  final String content;
  final String type;
  final DateTime createdAt;
  final String? replyToMessageId;

  ThreadMessage({
    required this.id,
    required this.threadId,
    required this.userId,
    required this.content,
    this.type = 'text',
    required this.createdAt,
    this.replyToMessageId,
  });

  factory ThreadMessage.fromJson(Map<String, dynamic> json) => ThreadMessage(
        id: json['id'],
        threadId: json['thread_id'],
        userId: json['user_id'],
        content: json['content'],
        type: json['type'] ?? 'text',
        createdAt: DateTime.parse(json['created_at']),
        replyToMessageId: json['reply_to_message_id'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'thread_id': threadId,
        'user_id': userId,
        'content': content,
        'type': type,
        'created_at': createdAt.toIso8601String(),
        'reply_to_message_id': replyToMessageId,
      };
} 