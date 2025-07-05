import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  List<Map<String, dynamic>> conversationUsers = [];
  bool isLoading = true;
  String? errorMessage;
  String? profileId;

  @override
  void initState() {
    super.initState();
    fetchProfileAndConversations();
  }

  Future<void> fetchProfileAndConversations() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'User not authenticated.';
      });
      return;
    }
    // Fetch the current user's profile to get the user_id
    final profiles = await Supabase.instance.client
        .from('profiles')
        .select('user_id')
        .eq('user_id', user.id)
        .limit(1);
    print('DEBUG: profiles query result:');
    print(profiles);
    if (profiles == null || profiles.isEmpty) {
      setState(() {
        conversationUsers = [];
        isLoading = false;
        errorMessage = 'No profile found for this user. Please complete your profile.';
      });
      return;
    }
    profileId = profiles[0]['user_id'] as String?;
    await fetchConversations();
  }

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
    setState(() {
      conversationUsers = List<Map<String, dynamic>>.from(profiles);
      isLoading = false;
    });
  }

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
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (conversationUsers.isEmpty) {
      return const Center(child: Text('No conversations yet.'));
    }
    return ListView.builder(
      itemCount: conversationUsers.length,
      itemBuilder: (context, index) {
        final user = conversationUsers[index];
        return ListTile(
          leading: user['profile_picture_url'] != null && user['profile_picture_url'].toString().isNotEmpty
              ? CircleAvatar(
                  backgroundImage: NetworkImage('${user['profile_picture_url']}?v=${DateTime.now().millisecondsSinceEpoch}'),
                )
              : const CircleAvatar(child: Icon(Icons.person)),
          title: Text('${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'),
          onTap: () => openChatWithUser(user),
        );
      },
    );
  }
} 