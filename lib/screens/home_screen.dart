import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../widgets/post_card.dart';
import 'search_screen.dart';
import 'post_screen.dart';
import 'messages_screen.dart';
import 'roommate_finder_screen.dart';
import 'settings_screen.dart';
import 'user_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _profileService = ProfileService();
  
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _userName;
  String? _userProfilePicture;
  int _selectedIndex = 0;

  List<Widget> get _pages => [
    _buildFeed(),
    const SearchScreen(),
    const PostScreen(),
    const MessagesScreen(),
    const RoommateFinderScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadPosts();
  }

  Future<void> _loadUserInfo() async {
    final user = _authService.currentUser;
    if (user == null) {
      _errorMessage = 'User not authenticated';
      setState(() {});
      return;
    }
    final profile = await _profileService.getProfile(user.id);
    if (profile == null) {
      _errorMessage = 'Profile not found';
      setState(() {});
      return;
    }
    setState(() {
      _userName = '${profile['first_name']} ${profile['last_name']}';
      _userProfilePicture = profile['profile_picture_url'];
    });
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw 'User not authenticated';
      // Fetch following user IDs
      final following = await Supabase.instance.client
          .from('connections')
          .select('following_id')
          .eq('follower_id', user.id);
      final followingIds = List<String>.from(following.map((f) => f['following_id']));
      followingIds.add(user.id); // include own posts
      final response = await Supabase.instance.client
          .from('posts')
          .select('*, profiles!inner(id, first_name, last_name, profile_picture_url)')
          .inFilter('user_id', followingIds)
          .order('created_at', ascending: false);
      setState(() {
        _posts = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Widget _buildFeed() {
    return Container(
      color: Colors.grey.shade50,
      child: Stack(
        children: [
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await _loadUserInfo();
                    await _loadPosts();
                  },
                  child: _posts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.feed_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No posts yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Be the first to share something!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: _posts.length + 2,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Container(
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                                child: Row(
                                  children: [
                                    Text(
                                      'Feed',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey.shade900,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2563EB),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${_posts.length} posts',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            if (index == _posts.length + 1) {
                              return const SizedBox(height: 32);
                            }
                            final post = _posts[index - 1];
                            final profile = post['profiles'] ?? {};
                            return PostCard(post: post, profile: profile);
                          },
                        ),
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          },
        ),
        title: const Text('Home'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _userProfilePicture != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage('$_userProfilePicture?v=${DateTime.now().millisecondsSinceEpoch}'),
                  )
                : const Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileScreen()));
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
    );
  }
} 