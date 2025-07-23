import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group.dart';
import '../models/presence_and_read.dart';
import '../models/message_reaction.dart';

class GroupChatService {
  final SupabaseClient client;
  GroupChatService({required this.client});

  // Fetch all groups the user is a member of
  Future<List<Group>> fetchUserGroups(String userId) async {
    final response = await client
        .from('group_members')
        .select('groups(*)')
        .eq('user_id', userId);
    return (response as List)
        .map((e) => Group.fromJson(e['groups']))
        .toList();
  }

  // Fetch group messages (with pagination)
  Future<List<GroupMessage>> fetchGroupMessages(String groupId, {int limit = 50}) async {
    final response = await client
        .from('group_messages')
        .select()
        .eq('group_id', groupId)
        .order('created_at', ascending: false)
        .limit(limit);
    return (response as List)
        .map((e) => GroupMessage.fromJson(e))
        .toList();
  }

  // Send a group message
  Future<void> sendGroupMessage(GroupMessage message) async {
    await client.from('group_messages').insert(message.toJson());
    // Fetch group name
    final groupRes = await client.from('groups').select('name').eq('id', message.groupId).maybeSingle();
    final groupName = groupRes != null ? groupRes['name'] ?? 'Group' : 'Group';
    // Fetch sender name
    final profileRes = await client.from('profiles').select('first_name, last_name').eq('id', message.userId).maybeSingle();
    final senderName = profileRes != null
        ? ((profileRes['first_name'] ?? '') + ' ' + (profileRes['last_name'] ?? '')).trim()
        : 'Someone';
    // Call Edge Function for push notification
    await client.functions.invoke('send-push-notification', body: {
      'type': 'group',
      'group_id': message.groupId,
      'sender_id': message.userId,
      'message': {
        'title': 'New message in $groupName',
        'body': '$senderName: ${message.content}',
        'data': {
          'group_id': message.groupId,
          'message_id': message.id,
        }
      }
    });
  }

  // Listen for new group messages in real-time
  Stream<GroupMessage> onNewGroupMessage(String groupId) {
    return client
        .from('group_messages:group_id=eq.$groupId')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((event) => event.map((e) => GroupMessage.fromJson(e)))
        .expand((x) => x);
  }

  // Typing indicator: update presence
  Future<void> setTyping(String userId, String groupId, bool isTyping) async {
    await client.from('user_presence').upsert({
      'user_id': userId,
      'chat_id': groupId,
      'is_typing': isTyping,
      'last_active': DateTime.now().toIso8601String(),
    });
  }

  // Listen for typing indicators
  Stream<TypingIndicator> onTyping(String groupId) {
    return client
        .from('user_presence:chat_id=eq.$groupId')
        .stream(primaryKey: ['user_id', 'chat_id'])
        .map((event) => event.map((e) => TypingIndicator.fromJson(e)))
        .expand((x) => x);
  }

  // Mark message as read
  Future<void> markMessageRead(String messageId, String userId) async {
    await client.from('message_reads').upsert({
      'message_id': messageId,
      'user_id': userId,
      'read_at': DateTime.now().toIso8601String(),
    });
  }

  // Listen for read receipts
  Stream<MessageRead> onMessageRead(String groupId) {
    // Join group_messages and message_reads for this group
    return client
        .from('message_reads')
        .stream(primaryKey: ['message_id', 'user_id'])
        .map((event) => event.map((e) => MessageRead.fromJson(e)))
        .expand((x) => x);
  }

  // Add a reaction to a message
  Future<void> addReaction(String messageId, String userId, String reaction) async {
    await client.from('message_reactions').upsert({
      'message_id': messageId,
      'user_id': userId,
      'reaction': reaction,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Stream reactions for a message
  Stream<List<MessageReaction>> getReactions(String messageId) {
    return client
        .from('message_reactions:message_id=eq.$messageId')
        .stream(primaryKey: ['id'])
        .map((event) => event.map((e) => MessageReaction.fromJson(e)).toList());
  }

  // Fetch a single group message by ID (for reply UI)
  Future<GroupMessage?> fetchGroupMessageById(String messageId) async {
    final response = await client
        .from('group_messages')
        .select()
        .eq('id', messageId)
        .maybeSingle();
    if (response == null) return null;
    return GroupMessage.fromJson(response);
  }

  // Edit a group message (only by the sender)
  Future<void> editGroupMessage(String messageId, String newContent) async {
    await client.from('group_messages').update({'content': newContent}).eq('id', messageId);
  }

  // Delete a group message (only by the sender)
  Future<void> deleteGroupMessage(String messageId) async {
    await client.from('group_messages').delete().eq('id', messageId);
  }

  // Pin a group message (admin only)
  Future<void> pinGroupMessage(String messageId) async {
    await client.from('group_messages').update({'pinned': true}).eq('id', messageId);
  }

  // Unpin a group message
  Future<void> unpinGroupMessage(String messageId) async {
    await client.from('group_messages').update({'pinned': false}).eq('id', messageId);
  }

  // Fetch all pinned messages for a group
  Future<List<GroupMessage>> fetchPinnedMessages(String groupId) async {
    final response = await client
        .from('group_messages')
        .select()
        .eq('group_id', groupId)
        .eq('pinned', true)
        .order('created_at', ascending: true);
    return (response as List).map((e) => GroupMessage.fromJson(e)).toList();
  }

  // Mark group as read (update last_read_at)
  Future<void> markGroupRead(String groupId, String userId) async {
    await client.from('group_message_reads').upsert({
      'user_id': userId,
      'group_id': groupId,
      'last_read_at': DateTime.now().toIso8601String(),
    });
  }

  // Get unread count for a group
  Future<int> getGroupUnreadCount(String groupId, String userId) async {
    // Get last_read_at
    final readRow = await client
        .from('group_message_reads')
        .select('last_read_at')
        .eq('user_id', userId)
        .eq('group_id', groupId)
        .maybeSingle();
    final lastRead = readRow != null ? DateTime.parse(readRow['last_read_at']) : DateTime.fromMillisecondsSinceEpoch(0);
    // Fetch messages after last_read_at and count in Dart
    final response = await client
        .from('group_messages')
        .select()
        .eq('group_id', groupId)
        .gt('created_at', lastRead.toIso8601String());
    return (response as List).length;
  }
} 