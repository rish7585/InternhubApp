class Group {
  final String id;
  final String name;
  final String? description;
  final String? city;
  final String? company;
  final String createdBy;
  final DateTime createdAt;

  Group({
    required this.id,
    required this.name,
    this.description,
    this.city,
    this.company,
    required this.createdBy,
    required this.createdAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        city: json['city'],
        company: json['company'],
        createdBy: json['created_by'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'city': city,
        'company': company,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
      };
}

class GroupMember {
  final String groupId;
  final String userId;
  final DateTime joinedAt;
  final String role;

  GroupMember({
    required this.groupId,
    required this.userId,
    required this.joinedAt,
    this.role = 'member',
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) => GroupMember(
        groupId: json['group_id'],
        userId: json['user_id'],
        joinedAt: DateTime.parse(json['joined_at']),
        role: json['role'] ?? 'member',
      );

  Map<String, dynamic> toJson() => {
        'group_id': groupId,
        'user_id': userId,
        'joined_at': joinedAt.toIso8601String(),
        'role': role,
      };
}

class GroupMessage {
  final String id;
  final String groupId;
  final String userId;
  final String content;
  final String type;
  final DateTime createdAt;
  final String? replyToMessageId;
  final bool? pinned;

  GroupMessage({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.content,
    this.type = 'text',
    required this.createdAt,
    this.replyToMessageId,
    this.pinned,
  });

  factory GroupMessage.fromJson(Map<String, dynamic> json) => GroupMessage(
        id: json['id'],
        groupId: json['group_id'],
        userId: json['user_id'],
        content: json['content'],
        type: json['type'] ?? 'text',
        createdAt: DateTime.parse(json['created_at']),
        replyToMessageId: json['reply_to_message_id'],
        pinned: json['pinned'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'group_id': groupId,
        'user_id': userId,
        'content': content,
        'type': type,
        'created_at': createdAt.toIso8601String(),
        'reply_to_message_id': replyToMessageId,
        'pinned': pinned,
      };
} 