import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/channel.dart';
import '../models/message_reaction.dart';

class ChannelService {
  final SupabaseClient client;
  ChannelService({required this.client});

  // Fetch all channels (optionally filter by city/interest)
  Future<List<Channel>> fetchChannels({String? city, String? interest}) async {
    var query = client.from('channels').select();
    if (city != null) query = query.eq('city', city);
    if (interest != null) query = query.eq('interest', interest);
    final response = await query;
    return (response as List).map((e) => Channel.fromJson(e)).toList();
  }

  // Fetch channel messages (with pagination)
  Future<List<ChannelMessage>> fetchChannelMessages(String channelId, {int limit = 50}) async {
    final response = await client
        .from('channel_messages')
        .select()
        .eq('channel_id', channelId)
        .order('created_at', ascending: false)
        .limit(limit);
    return (response as List).map((e) => ChannelMessage.fromJson(e)).toList();
  }

  // Send a channel message
  Future<void> sendChannelMessage(ChannelMessage message) async {
    await client.from('channel_messages').insert(message.toJson());
    // Fetch channel name
    final channelRes = await client.from('channels').select('name').eq('id', message.channelId).maybeSingle();
    final channelName = channelRes != null ? channelRes['name'] ?? 'Channel' : 'Channel';
    // Fetch sender name
    final profileRes = await client.from('profiles').select('first_name, last_name').eq('id', message.userId).maybeSingle();
    final senderName = profileRes != null
        ? ((profileRes['first_name'] ?? '') + ' ' + (profileRes['last_name'] ?? '')).trim()
        : 'Someone';
    // Call Edge Function for push notification
    await client.functions.invoke('send-push-notification', body: {
      'type': 'channel',
      'channel_id': message.channelId,
      'sender_id': message.userId,
      'message': {
        'title': 'New message in $channelName',
        'body': '$senderName: ${message.content}',
        'data': {
          'channel_id': message.channelId,
          'message_id': message.id,
        }
      }
    });
  }

  // Listen for new channel messages in real-time
  Stream<ChannelMessage> onNewChannelMessage(String channelId) {
    return client
        .from('channel_messages:channel_id=eq.$channelId')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((event) => event.map((e) => ChannelMessage.fromJson(e)))
        .expand((x) => x);
  }

  // Fetch threads in a channel
  Future<List<Thread>> fetchThreads(String channelId) async {
    final response = await client
        .from('threads')
        .select()
        .eq('channel_id', channelId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => Thread.fromJson(e)).toList();
  }

  // Create a new thread
  Future<void> createThread(Thread thread) async {
    await client.from('threads').insert(thread.toJson());
  }

  // Fetch thread messages
  Future<List<ThreadMessage>> fetchThreadMessages(String threadId, {int limit = 50}) async {
    final response = await client
        .from('thread_messages')
        .select()
        .eq('thread_id', threadId)
        .order('created_at', ascending: false)
        .limit(limit);
    return (response as List).map((e) => ThreadMessage.fromJson(e)).toList();
  }

  // Send a thread message
  Future<void> sendThreadMessage(ThreadMessage message) async {
    await client.from('thread_messages').insert(message.toJson());
    // Fetch thread title
    final threadRes = await client.from('threads').select('title').eq('id', message.threadId).maybeSingle();
    final threadTitle = threadRes != null ? threadRes['title'] ?? 'Thread' : 'Thread';
    // Fetch sender name
    final profileRes = await client.from('profiles').select('first_name, last_name').eq('id', message.userId).maybeSingle();
    final senderName = profileRes != null
        ? ((profileRes['first_name'] ?? '') + ' ' + (profileRes['last_name'] ?? '')).trim()
        : 'Someone';
    // Call Edge Function for push notification
    await client.functions.invoke('send-push-notification', body: {
      'type': 'thread',
      'thread_id': message.threadId,
      'sender_id': message.userId,
      'message': {
        'title': 'New reply in $threadTitle',
        'body': '$senderName: ${message.content}',
        'data': {
          'thread_id': message.threadId,
          'message_id': message.id,
        }
      }
    });
  }

  // Listen for new thread messages in real-time
  Stream<ThreadMessage> onNewThreadMessage(String threadId) {
    return client
        .from('thread_messages:thread_id=eq.$threadId')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((event) => event.map((e) => ThreadMessage.fromJson(e)))
        .expand((x) => x);
  }

  // Mark channel as read (update last_read_at)
  Future<void> markChannelRead(String channelId, String userId) async {
    await client.from('channel_message_reads').upsert({
      'user_id': userId,
      'channel_id': channelId,
      'last_read_at': DateTime.now().toIso8601String(),
    });
  }

  // Get unread count for a channel
  Future<int> getChannelUnreadCount(String channelId, String userId) async {
    // Get last_read_at
    final readRow = await client
        .from('channel_message_reads')
        .select('last_read_at')
        .eq('user_id', userId)
        .eq('channel_id', channelId)
        .maybeSingle();
    final lastRead = readRow != null ? DateTime.parse(readRow['last_read_at']) : DateTime.fromMillisecondsSinceEpoch(0);
    // Fetch messages after last_read_at and count in Dart
    final response = await client
        .from('channel_messages')
        .select()
        .eq('channel_id', channelId)
        .gt('created_at', lastRead.toIso8601String());
    return (response as List).length;
  }

  // --- Thread message admin stubs ---
  Future<void> deleteThreadMessage(String messageId) async {
    // TODO: Implement actual delete logic
    await client.from('thread_messages').delete().eq('id', messageId);
  }

  Future<void> editThreadMessage(String messageId, String newContent) async {
    // TODO: Implement actual edit logic
    await client.from('thread_messages').update({'content': newContent}).eq('id', messageId);
  }

  Future<ThreadMessage?> fetchThreadMessageById(String messageId) async {
    final response = await client
        .from('thread_messages')
        .select()
        .eq('id', messageId)
        .maybeSingle();
    if (response == null) return null;
    return ThreadMessage.fromJson(response);
  }

  Future<void> addReaction(String messageId, String userId, String reaction) async {
    // TODO: Implement actual reaction logic
    await client.from('thread_message_reactions').upsert({
      'message_id': messageId,
      'user_id': userId,
      'reaction': reaction,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<MessageReaction>> getReactions(String messageId) {
    return client
        .from('thread_message_reactions:message_id=eq.$messageId')
        .stream(primaryKey: ['id'])
        .map((event) => event.map((e) => MessageReaction.fromJson(e)).toList());
  }
} 