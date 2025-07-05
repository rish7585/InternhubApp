import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_button.dart';

class ViewProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const ViewProfileScreen({Key? key, required this.profile}) : super(key: key);

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  List<Map<String, dynamic>> followers = [];
  bool isLoadingFollowers = true;
  bool isFollowing = false;
  bool isLoadingFollow = false;

  @override
  void initState() {
    super.initState();
    fetchFollowers();
    checkIfFollowing();
  }

  Future<void> fetchFollowers() async {
    final response = await Supabase.instance.client
        .from('connections')
        .select('follower_id, profiles!follower_id(id, first_name, last_name, profile_picture_url)')
        .eq('following_id', widget.profile['id']);
    setState(() {
      followers = List<Map<String, dynamic>>.from(response.map((e) => e['profiles']));
      isLoadingFollowers = false;
    });
  }

  Future<void> checkIfFollowing() async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null || currentUserId == widget.profile['id']) return;
    final response = await Supabase.instance.client
        .from('connections')
        .select()
        .eq('follower_id', currentUserId)
        .eq('following_id', widget.profile['id']);
    setState(() {
      isFollowing = response.isNotEmpty;
    });
  }

  Future<void> followUser() async {
    setState(() { isLoadingFollow = true; });
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) return;
    try {
      await Supabase.instance.client.from('connections').insert({
        'follower_id': currentUserId,
        'following_id': widget.profile['id'],
      });
      setState(() {
        isFollowing = true;
        isLoadingFollow = false;
      });
      await fetchFollowers(); // ensure followers list updates after following
    } catch (e) {
      setState(() {
        isLoadingFollow = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to follow: '
              + (e.toString().isNotEmpty ? e.toString() : 'Unknown error'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isCurrentUser = profile['id'] == currentUserId;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: profile['profile_picture_url'] != null
                          ? NetworkImage('${profile['profile_picture_url']}?v=${DateTime.now().millisecondsSinceEpoch}')
                          : null,
                      child: profile['profile_picture_url'] == null
                          ? const Icon(Icons.person, size: 48)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${profile['first_name']} ${profile['last_name']}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile['email'] ?? '',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone, size: 18, color: Colors.indigo),
                      const SizedBox(width: 6),
                      Text(profile['phone'] ?? '', style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.business, size: 18, color: Colors.indigo),
                      const SizedBox(width: 6),
                      Text(profile['company'] ?? '', style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 18, color: Colors.indigo),
                      const SizedBox(width: 6),
                      Text(profile['location'] ?? '', style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if ((profile['bio'] ?? '').toString().isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        profile['bio'] ?? '',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Message',
                    icon: Icons.message,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            otherUserId: profile['id'],
                            otherUserName: '${profile['first_name']} ${profile['last_name']}',
                            otherUserProfilePic: profile['profile_picture_url'],
                          ),
                        ),
                      );
                    },
                  ),
                  if (!isCurrentUser)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: AppButton(
                        label: isFollowing ? 'Following' : 'Follow',
                        icon: isFollowing ? Icons.check : Icons.person_add,
                        isLoading: isLoadingFollow,
                        color: isFollowing ? Colors.grey : Colors.indigo,
                        onPressed: isFollowing || isLoadingFollow ? null : followUser,
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 