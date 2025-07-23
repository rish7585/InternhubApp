import 'package:flutter/material.dart';
import '../models/channel.dart';
import '../services/channel_service.dart';
import 'thread_list_screen.dart';

class ChannelListScreen extends StatefulWidget {
  final ChannelService channelService;
  final String? userId;
  const ChannelListScreen({super.key, required this.channelService, this.userId});

  @override
  State<ChannelListScreen> createState() => _ChannelListScreenState();
}

class _ChannelListScreenState extends State<ChannelListScreen> {
  late Future<List<Channel>> _channelsFuture;

  @override
  void initState() {
    super.initState();
    _refreshChannels();
  }

  void _refreshChannels() {
    setState(() {
      _channelsFuture = widget.channelService.fetchChannels();
    });
  }

  Future<void> _showCreateChannelDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Channel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Channel Name'),
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
              await widget.channelService.client.from('channels').insert({
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
    if (result == true) _refreshChannels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Channels')),
      body: FutureBuilder<List<Channel>>(
        future: _channelsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          final channels = snapshot.data ?? [];
          if (channels.isEmpty) {
            return const Center(child: Text('No channels yet.'));
          }
          return ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];
              return FutureBuilder<int>(
                future: widget.userId != null
                    ? widget.channelService.getChannelUnreadCount(channel.id, widget.userId!)
                    : Future.value(0),
                builder: (context, snapshot) {
                  final unreadCount = snapshot.data ?? 0;
                  return ListTile(
                    title: Text(channel.name),
                    subtitle: Text(channel.description ?? ''),
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
                      if (widget.userId != null) {
                        await widget.channelService.markChannelRead(channel.id, widget.userId!);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ThreadListScreen(
                            channel: channel,
                            channelService: widget.channelService,
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
        onPressed: _showCreateChannelDialog,
        child: const Icon(Icons.add),
        tooltip: 'Create Channel',
      ),
    );
  }
} 