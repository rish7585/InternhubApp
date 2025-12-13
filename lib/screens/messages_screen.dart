import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_screen.dart';
import '../services/group_chat_service.dart';
import '../services/channel_service.dart';
import '../models/group.dart';
import '../models/channel.dart';
import '../widgets/empty_state.dart';
import 'group_chat_screen.dart';
import 'thread_list_screen.dart';

/// Messages Screen
/// Shows a list of users the current user has messaged with. Tapping opens a chat.
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  List<Map<String, dynamic>> conversationUsers = [];
  List<Group> userGroups = [];
  List<Channel> userChannels = [];
  bool isLoading = true;
  String? errorMessage;
  String? profileId;
  final groupChatService = GroupChatService(client: Supabase.instance.client);
  final channelService = ChannelService(client: Supabase.instance.client);

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    await fetchProfileAndConversations();
    await fetchGroupsAndChannels();
    setState(() { isLoading = false; });
  }

  /// Fetches the current user's profile and all conversations.
  Future<void> fetchProfileAndConversations() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'User not authenticated.';
      });
      return;
    }
    // Fetch the current user's profile - profiles.id matches auth.users.id
    final profiles = await Supabase.instance.client
        .from('profiles')
        .select('id, user_id')
        .eq('id', user.id)
        .limit(1);
    print('DEBUG: profiles query result:');
    print(profiles);
    if (profiles == null || profiles.isEmpty) {
      if (!mounted) return;
      setState(() {
        conversationUsers = [];
        isLoading = false;
        errorMessage = 'No profile found for this user. Please complete your profile.';
      });
      return;
    }
    profileId = profiles[0]['id'] as String?;
    await fetchConversations();
  }

  /// Fetches all conversations for the current user.
  Future<void> fetchConversations() async {
    if (userId == null) return;
    final response = await Supabase.instance.client
        .from('messages')
        .select('sender_id, receiver_id')
        .or('sender_id.eq.$userId,receiver_id.eq.$userId')
        .order('created_at', ascending: false);

    final Set<String> userIds = {};
    for (var msg in response) {
      if (msg['sender_id'] != userId) userIds.add(msg['sender_id']);
      if (msg['receiver_id'] != userId) userIds.add(msg['receiver_id']);
    }
    if (userIds.isEmpty) {
      if (!mounted) return;
      setState(() {
        conversationUsers = [];
        isLoading = false;
      });
      return;
    }
    // Fetch user profiles for all conversation user IDs
    final profiles = await Supabase.instance.client
        .from('profiles')
        .select('id, first_name, last_name, profile_picture_url')
        .inFilter('id', userIds.toList());
    if (!mounted) return;
    setState(() {
      conversationUsers = List<Map<String, dynamic>>.from(profiles);
      isLoading = false;
    });
  }

  Future<void> fetchGroupsAndChannels() async {
    if (userId == null) return;
    userGroups = await groupChatService.fetchUserGroups(userId!);
    userChannels = await channelService.fetchChannels();
    // Optionally filter channels by membership if you have a channel_members table
    if (!mounted) return;
    setState(() {});
  }

  /// Opens the chat screen with the selected user.
  Future<void> openChatWithUser(Map<String, dynamic> user) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          otherUserId: user['id'],
          otherUserName: '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}',
          otherUserProfilePic: user['profile_picture_url'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading messages...',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.red.shade300 
                      : Colors.red.shade600,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.red.shade300 
                        : Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white70 
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    if (conversationUsers.isEmpty && userGroups.isEmpty && userChannels.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
        ),
        body: EmptyState(
          icon: Icons.chat_bubble_outline,
          title: 'No Conversations Yet',
          message: 'Start a conversation by connecting with other users or joining groups and channels.',
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: ListView(
        children: [
          if (conversationUsers.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Direct Messages', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ...conversationUsers.map((user) {
              final userName = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
              final displayName = userName.isNotEmpty ? userName : 'Unknown User';
              return Semantics(
                label: 'Conversation with $displayName',
                child: ListTile(
                  leading: Semantics(
                    label: 'Profile picture of $displayName',
                    image: true,
                    child: user['profile_picture_url'] != null && user['profile_picture_url'].toString().isNotEmpty
                        ? Hero(
                            tag: 'profile_${user['id']}',
                            child: CircleAvatar(
                              backgroundImage: NetworkImage('${user['profile_picture_url']}?v=${DateTime.now().millisecondsSinceEpoch}'),
                            ),
                          )
                        : CircleAvatar(
                            backgroundColor: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.grey.shade700 
                                : Colors.grey.shade300,
                            child: Icon(
                              Icons.person,
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.white 
                                  : Colors.grey.shade600,
                            ),
                          ),
                  ),
                  title: Text(
                    displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Tap to open conversation',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white60 
                          : Colors.black54,
                    ),
                  ),
                  onTap: () => openChatWithUser(user),
                ),
              );
            }).toList(),
          ],
          if (userGroups.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Groups', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ...userGroups.map((group) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.group)),
                  title: Text(group.name),
                  subtitle: Text(group.description ?? ''),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupChatScreen(
                        group: group,
                        groupChatService: groupChatService,
                        userId: userId ?? '',
                      ),
                    ),
                  ),
                )),
          ],
          if (userChannels.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Channels', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ...userChannels.map((channel) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.forum)),
                  title: Text(channel.name),
                  subtitle: Text(channel.description ?? ''),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ThreadListScreen(
                        channel: channel,
                        channelService: channelService,
                        userId: userId,
                      ),
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }
} 