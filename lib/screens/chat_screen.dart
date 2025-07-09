/// Chat Screen
/// Displays a chat conversation between the current user and another user.
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../widgets/chat_bubble.dart';

/// The main screen for chatting with another user.
class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? otherUserProfilePic;
  const ChatScreen({Key? key, required this.otherUserId, required this.otherUserName, this.otherUserProfilePic}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  final TextEditingController _controller = TextEditingController();
  List<dynamic> messages = [];
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  /// Fetches all messages between the current user and the other user.
  Future<void> fetchMessages() async {
    if (userId == null) return;
    final response = await Supabase.instance.client
        .from('messages')
        .select()
        .or('and(sender_id.eq.$userId,receiver_id.eq.${widget.otherUserId}),and(sender_id.eq.${widget.otherUserId},receiver_id.eq.$userId)')
        .order('created_at', ascending: true);
    setState(() {
      messages = response;
      isLoading = false;
    });
  }

  /// Sends a new message to the other user.
  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || userId == null) return;
    await Supabase.instance.client.from('messages').insert({
      'sender_id': userId,
      'receiver_id': widget.otherUserId,
      'content': text,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    _controller.clear();
    fetchMessages();
  }

  /// Scrolls to the bottom of the chat list.
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Semantics(
              label: 'Profile picture of ${widget.otherUserName}',
              image: true,
              child: widget.otherUserProfilePic != null && widget.otherUserProfilePic!.isNotEmpty
                  ? CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage('${widget.otherUserProfilePic}?v=${DateTime.now().millisecondsSinceEpoch}'),
                    )
                  : CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey.shade700 
                          : Colors.grey.shade300,
                      child: Icon(
                        Icons.person,
                        size: 18,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white 
                            : Colors.grey.shade600,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.otherUserName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? Center(
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
                                'No Messages Yet',
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
                                'Start the conversation by sending a message',
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
                      )
                    : Semantics(
                        label: 'Chat messages',
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final msg = messages[index];
                            final isMe = msg['sender_id'] == userId;
                            return ChatBubble(
                              content: msg['content'],
                              timestamp: timeago.format(DateTime.parse(msg['created_at'])),
                              isMe: isMe,
                            );
                          },
                        ),
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _controller,
                    label: 'Type a message...',
                    hint: 'Type a message...',
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Send message',
                  child: AppButton(
                    label: '',
                    icon: Icons.send,
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 