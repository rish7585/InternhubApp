import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../widgets/chat_bubble.dart';

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
            if (widget.otherUserProfilePic != null && widget.otherUserProfilePic!.isNotEmpty)
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage('${widget.otherUserProfilePic}?v=${DateTime.now().millisecondsSinceEpoch}'),
              )
            else
              const CircleAvatar(
                radius: 18,
                child: Icon(Icons.person),
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
                    ? const Center(child: Text('No messages yet.', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
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
                AppButton(
                  label: '',
                  icon: Icons.send,
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 