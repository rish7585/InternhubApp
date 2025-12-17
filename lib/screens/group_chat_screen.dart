import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/group.dart';
import '../models/presence_and_read.dart';
import '../models/message_reaction.dart';
import '../services/group_chat_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../services/profile_service.dart';

class GroupChatScreen extends StatefulWidget {
  final Group group;
  final GroupChatService groupChatService;
  final String userId;
  const GroupChatScreen({super.key, required this.group, required this.groupChatService, required this.userId});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;
  final List<String> _emojis = ['👍', '❤️', '😂', '🎉', '😮', '😢'];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  GroupMessage? _replyTo;
  GroupMessage? _editingMessage;
  final ProfileService _profileService = ProfileService();
  final Map<String, Map<String, dynamic>?> _profileCache = {};
  bool _isAdding = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _getProfile(String userId) async {
    if (_profileCache.containsKey(userId)) {
      return _profileCache[userId];
    }
    final profile = await _profileService.getProfile(userId);
    _profileCache[userId] = profile;
    return profile;
  }

  void _onChanged(String value) {
    final typing = value.isNotEmpty;
    if (typing != _isTyping) {
      setState(() => _isTyping = typing);
      widget.groupChatService.setTyping(widget.userId, widget.group.id, typing);
    }
  }

  void _showMessageOptions(GroupMessage message) async {
    final isOwn = message.userId == widget.userId;
    final isPinned = message.pinned == true;
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
            if (!isPinned)
              ListTile(
                leading: const Icon(Icons.push_pin),
                title: const Text('Pin'),
                onTap: () => Navigator.pop(context, 'pin'),
              ),
            if (isPinned)
              ListTile(
                leading: const Icon(Icons.push_pin_outlined),
                title: const Text('Unpin'),
                onTap: () => Navigator.pop(context, 'unpin'),
              ),
          ],
        ),
      ),
    );
    if (result == 'reply') {
      _setReplyTo(message);
    } else if (result == 'edit') {
      setState(() {
        _editingMessage = message;
        _controller.text = message.content;
      });
    } else if (result == 'delete') {
      await widget.groupChatService.deleteGroupMessage(message.id);
    } else if (result == 'pin') {
      await widget.groupChatService.pinGroupMessage(message.id);
    } else if (result == 'unpin') {
      await widget.groupChatService.unpinGroupMessage(message.id);
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _replyTo == null && _editingMessage == null) return;
    if (_editingMessage != null) {
      await widget.groupChatService.editGroupMessage(_editingMessage!.id, text);
      setState(() => _editingMessage = null);
      _controller.clear();
      return;
    }
    await widget.groupChatService.sendGroupMessage(
      GroupMessage(
        id: '',
        groupId: widget.group.id,
        userId: widget.userId,
        content: text,
        type: 'text',
        createdAt: DateTime.now(),
        replyToMessageId: _replyTo?.id,
      ),
    );
    _controller.clear();
    _onChanged('');
    setState(() => _replyTo = null);
  }

  void _setReplyTo(GroupMessage message) {
    setState(() => _replyTo = message);
  }

  void _cancelReply() {
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
      final storagePath = 'group_images/${widget.group.id}/$fileName';
      final storage = Supabase.instance.client.storage.from('chat-media');
      await storage.uploadBinary(
        storagePath,
        bytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg'),
      );
      final imageUrl = storage.getPublicUrl(storagePath);
      await widget.groupChatService.sendGroupMessage(
        GroupMessage(
          id: '',
          groupId: widget.group.id,
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

  // Helper to format timestamps
  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) {
      return DateFormat('h:mm a').format(dt);
    } else {
      return DateFormat('MMM d, h:mm a').format(dt);
    }
  }

  Widget _buildTypingAvatars(List<TypingIndicator> typingIndicators) {
    final typingUsers = typingIndicators.where((t) => t.isTyping && t.userId != widget.userId).toList();
    if (typingUsers.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          ...typingUsers.map((t) => FutureBuilder<Map<String, dynamic>?>(
                future: _getProfile(t.userId),
                builder: (context, snapshot) {
                  final profile = snapshot.data;
                  final profilePic = profile?['profile_picture_url'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.grey[400],
                      backgroundImage: (profilePic != null && profilePic.isNotEmpty)
                          ? NetworkImage(profilePic)
                          : null,
                      child: (profilePic == null || profilePic.isEmpty)
                          ? Text(t.userId.substring(0, 2).toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.white))
                          : null,
                    ),
                  );
                },
              )),
          const SizedBox(width: 8),
          Text(typingUsers.length == 1 ? 'is typing...' : 'are typing...', style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          IconButton(
            tooltip: 'Add member',
            icon: const Icon(Icons.person_add),
            onPressed: _isAdding ? null : _promptAddMember,
          ),
        ],
      ),
      body: Column(
        children: [
          // Pinned messages
          FutureBuilder<List<GroupMessage>>(
            future: widget.groupChatService.fetchPinnedMessages(widget.group.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
              final pinned = snapshot.data!;
              return Container(
                color: Colors.yellow[50],
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pinned', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ...pinned.map((msg) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(msg.content, style: const TextStyle(fontSize: 14)),
                    )),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<GroupMessage>(
              stream: widget.groupChatService.onNewGroupMessage(widget.group.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: Text('No messages yet.'));
                }
                final message = snapshot.data!;
                final isOwn = message.userId == widget.userId;
                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  children: [
                    GestureDetector(
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
                                              FutureBuilder<GroupMessage?>(
                                                future: widget.groupChatService.fetchGroupMessageById(message.replyToMessageId!),
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
                                          widget.groupChatService.addReaction(
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
                                    stream: widget.groupChatService.getReactions(message.id),
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
                    ),
                  ],
                );
              },
            ),
          ),
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          // Typing avatars
          StreamBuilder<List<TypingIndicator>>(
            stream: widget.groupChatService.client
                .from('user_presence:chat_id=eq.${widget.group.id}')
                .stream(primaryKey: ['user_id', 'chat_id'])
                .map((event) => event.map((e) => TypingIndicator.fromJson(e)).toList()),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              return _buildTypingAvatars(snapshot.data!);
            },
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
                    onChanged: _onChanged,
                    decoration: const InputDecoration(hintText: 'Type a message...'),
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

  Future<void> _promptAddMember() async {
    final emailController = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add member'),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'User email'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;
              try {
                setState(() => _isAdding = true);
                // Find profile by email
                final profile = await Supabase.instance.client
                    .from('profiles')
                    .select('id, email, first_name, last_name')
                    .eq('email', email)
                    .maybeSingle();
                if (profile == null) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No user found with that email')),
                    );
                  }
                  return;
                }
                final targetUserId = profile['id'] as String;
                await widget.groupChatService.addMemberToGroup(
                  groupId: widget.group.id,
                  userId: targetUserId,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added ${profile['first_name'] ?? 'User'} to group')),
                  );
                  Navigator.pop(ctx);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add member: $e')),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => _isAdding = false);
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
} 