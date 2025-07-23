import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'edit_profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/post_card.dart';

/// User Profile Screen
/// Shows the current user's profile and their posts. Allows editing profile and viewing followers.
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _authService = AuthService();
  final _profileService = ProfileService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// Loads the current user's profile from Supabase.
  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      if (user == null) throw 'User not authenticated';
      final profile = await _profileService.getProfile(user.id);
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profile',
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
                if (updated == true) {
                  _loadProfile();
                }
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person, semanticLabel: 'Profile Tab'), text: 'Profile'),
              Tab(icon: Icon(Icons.article, semanticLabel: 'My Posts Tab'), text: 'My Posts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Profile Tab
            _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1500),
                          builder: (context, value, child) {
                            return Transform.rotate(
                              angle: value * 2 * 3.14159,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.indigo,
                                    width: 3,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.indigo,
                                    size: 24,
                                  ),
                                ),
                              ),
                            );
                          },
                          onEnd: () {
                            if (_isLoading) {
                              setState(() {});
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Loading profile...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.indigo,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : _profile == null
                    ? const Center(child: Text('Profile not found.'))
                    : SingleChildScrollView(
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
                                    child: Hero(
                                      tag: 'profile_${_profile!['id'] ?? _profile!['user_id']}',
                                      child: Semantics(
                                        label: 'Profile picture',
                                        image: true,
                                      child: CircleAvatar(
                                        radius: 48,
                                        backgroundImage: _profile!['profile_picture_url'] != null
                                            ? NetworkImage('${_profile!['profile_picture_url']}?v=${DateTime.now().millisecondsSinceEpoch}')
                                            : null,
                                        child: _profile!['profile_picture_url'] == null
                                            ? const Icon(Icons.person, size: 48)
                                            : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Semantics(
                                    label: 'Name',
                                    child: Text(
                                    '${_profile!['first_name']} ${_profile!['last_name']}',
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Semantics(
                                    label: 'Email',
                                    child: Text(
                                    _profile!['email'] ?? '',
                                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.phone, size: 18, color: Colors.indigo),
                                      const SizedBox(width: 6),
                                      Semantics(
                                        label: 'Phone',
                                        child: Text(_profile!['phone'] ?? '', style: const TextStyle(fontSize: 15)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.business, size: 18, color: Colors.indigo),
                                      const SizedBox(width: 6),
                                      Semantics(
                                        label: 'Company',
                                        child: Text(_profile!['company'] ?? '', style: const TextStyle(fontSize: 15)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.location_on, size: 18, color: Colors.indigo),
                                      const SizedBox(width: 6),
                                      Semantics(
                                        label: 'Location',
                                        child: Text(_profile!['location'] ?? '', style: const TextStyle(fontSize: 15)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  if ((_profile!['bio'] ?? '').toString().isNotEmpty)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness == Brightness.dark 
                                            ? Colors.white.withValues(alpha: 0.1)
                                            : Colors.black.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Semantics(
                                        label: 'Bio',
                                      child: Text(
                                        _profile!['bio'] ?? '',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Theme.of(context).brightness == Brightness.dark 
                                                ? Colors.white 
                                                : Colors.black,
                                          ),
                                        textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 18),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.people),
                                    label: const Text('Followers'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigo,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () async {
                                      final user = _authService.currentUser;
                                      if (user == null) return;
                                      showModalBottomSheet(
                                        context: context,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                                        ),
                                        builder: (context) {
                                          return FutureBuilder<List<Map<String, dynamic>>>(
                                            future: Supabase.instance.client
                                                .from('connections')
                                                .select('follower_id, profiles!follower_id(id, first_name, last_name, profile_picture_url)')
                                                .eq('following_id', user.id),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return const Padding(
                                                  padding: EdgeInsets.all(32),
                                                  child: Center(child: CircularProgressIndicator()),
                                                );
                                              }
                                              final followers = snapshot.data?.map((e) => e['profiles']).toList() ?? [];
                                              if (followers.isEmpty) {
                                                return const Padding(
                                                  padding: EdgeInsets.all(32),
                                                  child: Center(child: Text('No followers yet.')),
                                                );
                                              }
                                              return ListView.separated(
                                                padding: const EdgeInsets.all(16),
                                                itemCount: followers.length,
                                                separatorBuilder: (_, __) => const Divider(height: 1),
                                                itemBuilder: (context, index) {
                                                  final f = followers[index];
                                                  return ListTile(
                                                    leading: f['profile_picture_url'] != null && f['profile_picture_url'].toString().isNotEmpty
                                                        ? Semantics(
                                                            label: 'Follower profile picture',
                                                            image: true,
                                                            child: CircleAvatar(
                                                            backgroundImage: NetworkImage('${f['profile_picture_url']}?v=${DateTime.now().millisecondsSinceEpoch}'),
                                                            ),
                                                          )
                                                        : Semantics(
                                                            label: 'Follower profile icon',
                                                            child: CircleAvatar(child: Icon(Icons.person)),
                                                          ),
                                                    title: Semantics(
                                                      label: 'Follower name',
                                                      child: Text('${f['first_name'] ?? ''} ${f['last_name'] ?? ''}'),
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
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
            // My Posts Tab
            _buildMyPostsTab(),
          ],
        ),
      ),
    );
  }

  /// Builds the tab for displaying the user's posts.
  Widget _buildMyPostsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchMyPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final posts = snapshot.data ?? [];
        if (posts.isEmpty) {
          return const Center(child: Text('No posts yet.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final profile = _profile ?? {};
            return PostCard(post: post, profile: profile, index: index);
          },
        );
      },
    );
  }

  /// Fetches the current user's posts from Supabase.
  Future<List<Map<String, dynamic>>> _fetchMyPosts() async {
    final user = _authService.currentUser;
    if (user == null) return [];
    final response = await Supabase.instance.client
        .from('posts')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
} 