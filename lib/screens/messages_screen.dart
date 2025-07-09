import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_screen.dart';

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
  bool isLoading = true;
  String? errorMessage;
  String? profileId;

  @override
  void initState() {
    super.initState();
    fetchProfileAndConversations();
  }

  /// Fetches the current user's profile and all conversations.
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
        body: const Center(
          child: CircularProgressIndicator(),
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
    
    if (conversationUsers.isEmpty) {
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
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey.shade400 
                      : Colors.grey.shade600,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Conversations Yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start a conversation by connecting with other users',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white70 
                        : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: ListView.builder(
        itemCount: conversationUsers.length,
        itemBuilder: (context, index) {
          final user = conversationUsers[index];
          final userName = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
          final displayName = userName.isNotEmpty ? userName : 'Unknown User';
          
          return Semantics(
            label: 'Conversation with $displayName',
            child: ListTile(
              leading: Semantics(
                label: 'Profile picture of $displayName',
                image: true,
                child: user['profile_picture_url'] != null && user['profile_picture_url'].toString().isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage('${user['profile_picture_url']}?v=${DateTime.now().millisecondsSinceEpoch}'),
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
        },
      ),
    );
  }
} 