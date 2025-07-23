import 'package:flutter/material.dart';
import '../models/group.dart';
import '../services/group_chat_service.dart';
import 'group_chat_screen.dart';

class GroupChatListScreen extends StatefulWidget {
  final GroupChatService groupChatService;
  final String userId;
  const GroupChatListScreen({super.key, required this.groupChatService, required this.userId});

  @override
  State<GroupChatListScreen> createState() => _GroupChatListScreenState();
}

class _GroupChatListScreenState extends State<GroupChatListScreen> {
  late Future<List<Group>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _refreshGroups();
  }

  void _refreshGroups() {
    setState(() {
      _groupsFuture = widget.groupChatService.fetchUserGroups(widget.userId);
    });
  }

  Future<void> _showCreateGroupDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Group Name'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              await widget.groupChatService.client.from('groups').insert({
                'name': name,
                'description': descController.text.trim(),
                'created_by': widget.userId,
              });
              Navigator.pop(context, true);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (result == true) _refreshGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Groups')),
      body: FutureBuilder<List<Group>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          final groups = snapshot.data ?? [];
          if (groups.isEmpty) {
            return const Center(child: Text('No groups yet.'));
          }
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return FutureBuilder<int>(
                future: widget.groupChatService.getGroupUnreadCount(group.id, widget.userId),
                builder: (context, snapshot) {
                  final unreadCount = snapshot.data ?? 0;
                  return ListTile(
                    title: Text(group.name),
                    subtitle: Text(group.description ?? ''),
                    trailing: unreadCount > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          )
                        : null,
                    onTap: () async {
                      await widget.groupChatService.markGroupRead(group.id, widget.userId);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupChatScreen(
                            group: group,
                            groupChatService: widget.groupChatService,
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateGroupDialog,
        child: const Icon(Icons.add),
        tooltip: 'Create Group',
      ),
    );
  }
} 