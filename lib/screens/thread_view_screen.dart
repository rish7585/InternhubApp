import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import '../models/channel.dart';
import '../models/message_reaction.dart';
import '../services/channel_service.dart';
import '../services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ThreadViewScreen extends StatefulWidget {
  final Thread thread;
  final ChannelService channelService;
  final String userId;
  const ThreadViewScreen({super.key, required this.thread, required this.channelService, required this.userId});

  @override
  State<ThreadViewScreen> createState() => _ThreadViewScreenState();
}

class _ThreadViewScreenState extends State<ThreadViewScreen> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ProfileService _profileService = ProfileService();
  final Map<String, Map<String, dynamic>?> _profileCache = {};
  final List<String> _emojis = ['👍', '❤️', '😂', '🎉', '😮', '😢'];
  bool _isUploading = false;
  ThreadMessage? _replyTo;
  ThreadMessage? _editingMessage;

  Future<Map<String, dynamic>?> _getProfile(String userId) async {
    if (_profileCache.containsKey(userId)) {
      return _profileCache[userId];
    }
    final profile = await _profileService.getProfile(userId);
    _profileCache[userId] = profile;
    return profile;
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) {
      return DateFormat('h:mm a').format(dt);
    } else {
      return DateFormat('MMM d, h:mm a').format(dt);
    }
  }

  void _showMessageOptions(ThreadMessage message) async {
    final isOwn = message.userId == widget.userId;
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () => Navigator.pop(context, 'reply'),
            ),
            if (isOwn)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () => Navigator.pop(context, 'edit'),
              ),
            if (isOwn)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
          ],
        ),
      ),
    );
    if (result == 'reply') {
      setState(() => _replyTo = message);
    } else if (result == 'edit') {
      setState(() {
        _editingMessage = message;
        _controller.text = message.content;
      });
    } else if (result == 'delete') {
      await widget.channelService.deleteThreadMessage(message.id);
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _replyTo == null && _editingMessage == null) return;
    if (_editingMessage != null) {
      await widget.channelService.editThreadMessage(_editingMessage!.id, text);
      setState(() => _editingMessage = null);
      _controller.clear();
      return;
    }
    await widget.channelService.sendThreadMessage(
      ThreadMessage(
        id: '',
        threadId: widget.thread.id,
        userId: widget.userId,
        content: text,
        type: 'text',
        createdAt: DateTime.now(),
        replyToMessageId: _replyTo?.id,
      ),
    );
    _controller.clear();
    setState(() => _replyTo = null);
  }

  Future<void> _pickAndSendImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (picked == null) return;
    setState(() => _isUploading = true);
    try {
      final bytes = await picked.readAsBytes();
      final fileName = '${widget.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'thread_images/${widget.thread.id}/$fileName';
      final storage = Supabase.instance.client.storage.from('chat-media');
      await storage.uploadBinary(
        storagePath,
        bytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg'),
      );
      final imageUrl = storage.getPublicUrl(storagePath);
      await widget.channelService.sendThreadMessage(
        ThreadMessage(
          id: '',
          threadId: widget.thread.id,
          userId: widget.userId,
          content: imageUrl,
          type: 'image',
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.thread.title)),
      body: Column(
        children: [
          // TODO: Pinned messages (if supported for threads)
          Expanded(
            child: StreamBuilder<ThreadMessage>(
              stream: widget.channelService.onNewThreadMessage(widget.thread.id),
              builder: (context, snapshot) {
                // Accumulate messages in a local list
                List<ThreadMessage> messages = [];
                if (snapshot.hasData) {
                  messages.add(snapshot.data!);
                }
                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    final isOwn = message.userId == widget.userId;
                    return GestureDetector(
                      onLongPress: () => _showMessageOptions(message),
                      child: Align(
                        alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
                        child: FutureBuilder<Map<String, dynamic>?>(
                          future: _getProfile(message.userId),
                          builder: (context, profileSnapshot) {
                            final profile = profileSnapshot.data;
                            final profilePic = profile?['profile_picture_url'];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isOwn ? Colors.blue[100] : Colors.grey[200],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isOwn ? const Radius.circular(16) : const Radius.circular(4),
                                  bottomRight: isOwn ? const Radius.circular(4) : const Radius.circular(16),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.grey[400],
                                        backgroundImage: (profilePic != null && profilePic.isNotEmpty)
                                            ? NetworkImage(profilePic)
                                            : null,
                                        child: (profilePic == null || profilePic.isEmpty)
                                            ? Text(message.userId.substring(0, 2).toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.white))
                                            : null,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (message.replyToMessageId != null)
                                              FutureBuilder<ThreadMessage?>(
                                                future: widget.channelService.fetchThreadMessageById(message.replyToMessageId!),
                                                builder: (context, replySnapshot) {
                                                  if (!replySnapshot.hasData) return const SizedBox.shrink();
                                                  final replyMsg = replySnapshot.data!;
                                                  return Container(
                                                    margin: const EdgeInsets.only(bottom: 4),
                                                    padding: const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text('Reply: ${replyMsg.content}', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                                                  );
                                                },
                                              ),
                                            if (message.type == 'image')
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Image.network(message.content, height: 180, fit: BoxFit.cover),
                                              )
                                            else
                                              Text(message.content, style: const TextStyle(fontSize: 16)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(_formatTimestamp(message.createdAt), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                  // Emoji bar
                                  Row(
                                    children: _emojis.map((emoji) {
                                      return IconButton(
                                        icon: Text(emoji, style: const TextStyle(fontSize: 18)),
                                        onPressed: () {
                                          widget.channelService.addReaction(
                                            message.id,
                                            widget.userId,
                                            emoji,
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  // Real-time reaction summary
                                  StreamBuilder<List<MessageReaction>>(
                                    stream: widget.channelService.getReactions(message.id),
                                    builder: (context, reactionSnapshot) {
                                      if (!reactionSnapshot.hasData || reactionSnapshot.data!.isEmpty) {
                                        return const SizedBox.shrink();
                                      }
                                      final reactions = reactionSnapshot.data!;
                                      final summary = <String, int>{};
                                      for (final r in reactions) {
                                        summary[r.reaction] = (summary[r.reaction] ?? 0) + 1;
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 4, bottom: 2),
                                        child: Row(
                                          children: summary.entries.map((e) =>
                                            Padding(
                                              padding: const EdgeInsets.only(right: 6),
                                              child: Chip(
                                                label: Text('${e.key} ${e.value}'),
                                                backgroundColor: Colors.grey[100],
                                                visualDensity: VisualDensity.compact,
                                              ),
                                            ),
                                          ).toList(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          // TODO: Typing avatars (if supported for threads)
          if (_replyTo != null)
            Container(
              color: Colors.blue[50],
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Text('Replying to: ${_replyTo!.content}', style: const TextStyle(fontStyle: FontStyle.italic))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _replyTo = null)),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickAndSendImage,
                  tooltip: 'Send Image',
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Reply...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 