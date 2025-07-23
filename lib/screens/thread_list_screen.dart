import 'package:flutter/material.dart';
import '../models/channel.dart';
import '../services/channel_service.dart';
import 'thread_view_screen.dart';

class ThreadListScreen extends StatefulWidget {
  final Channel channel;
  final ChannelService channelService;
  final String? userId;
  const ThreadListScreen({super.key, required this.channel, required this.channelService, this.userId});

  @override
  State<ThreadListScreen> createState() => _ThreadListScreenState();
}

class _ThreadListScreenState extends State<ThreadListScreen> {
  late Future<List<Thread>> _threadsFuture;

  @override
  void initState() {
    super.initState();
    _refreshThreads();
  }

  void _refreshThreads() {
    setState(() {
      _threadsFuture = widget.channelService.fetchThreads(widget.channel.id);
    });
  }

  Future<void> _showCreateThreadDialog() async {
    final titleController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Thread'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Thread Title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isEmpty) return;
              await widget.channelService.createThread(
                Thread(
                  id: '',
                  channelId: widget.channel.id,
                  title: title,
                  createdBy: widget.userId ?? '',
                  createdAt: DateTime.now(),
                ),
              );
              Navigator.pop(context, true);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (result == true) _refreshThreads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.channel.name)),
      body: FutureBuilder<List<Thread>>(
        future: _threadsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          final threads = snapshot.data ?? [];
          if (threads.isEmpty) {
            return const Center(child: Text('No threads yet.'));
          }
          return ListView.builder(
            itemCount: threads.length,
            itemBuilder: (context, index) {
              final thread = threads[index];
              return ListTile(
                title: Text(thread.title),
                subtitle: Text('By: \\${thread.createdBy}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ThreadViewScreen(
                        thread: thread,
                        channelService: widget.channelService,
                        userId: widget.userId ?? '',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateThreadDialog,
        child: const Icon(Icons.add_comment),
        tooltip: 'Create Thread',
      ),
    );
  }
} 