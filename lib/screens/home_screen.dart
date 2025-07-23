import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../widgets/post_card.dart';
import 'settings_screen.dart';
import 'user_profile_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

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
  String? _userProfilePicture;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadPosts();
  }

  Future<void> _loadUserInfo() async {
    final user = _authService.currentUser;
    if (user == null) {
      setState(() {});
      return;
    }
    final profile = await _profileService.getProfile(user.id);
    if (profile == null) {
      setState(() {});
      return;
    }
    setState(() {
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
        // _errorMessage = e.toString(); // This line was removed
      });
    }
  }

  Widget _buildFeed() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      color: isDark ? const Color(0xFF181A20) : Colors.grey.shade50,
      child: Stack(
        children: [
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
                                  color: const Color(0xFF2563EB),
                                  width: 3,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.home,
                                  color: Color(0xFF2563EB),
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
                        'Loading your feed...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await _loadUserInfo();
                    await _loadPosts();
                  },
                  child: _posts.isEmpty
                      ? Center(
                          child: Semantics(
                            label: 'No posts available',
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.feed_outlined,
                                  size: 64,
                                  color: isDark ? Colors.white24 : Colors.grey.shade400,
                                  semanticLabel: 'Empty feed icon',
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No posts yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Be the first to share something!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.white54 : Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : AnimationLimiter(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            itemCount: _posts.length + 2,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: Semantics(
                                        header: true,
                                        label: 'Feed header with post count',
                                        child: Container(
                                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Feed',
                                                style: TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark ? Colors.white : Colors.grey.shade900,
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
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              if (index == _posts.length + 1) {
                                return const SizedBox(height: 32);
                              }
                              final post = _posts[index - 1];
                              final profile = post['profiles'] ?? {};
                              return PostCard(
                                post: post, 
                                profile: profile,
                                index: index,
                              );
                            },
                          ),
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
          tooltip: 'Settings',
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          },
        ),
        title: const Text('Home'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _userProfilePicture != null
                ? Semantics(
                    label: 'User profile picture',
                    child: CircleAvatar(
                      backgroundImage: NetworkImage('$_userProfilePicture?v=${DateTime.now().millisecondsSinceEpoch}'),
                    ),
                  )
                : Semantics(
                    label: 'User profile icon',
                    child: Icon(Icons.person),
                  ),
            tooltip: 'View profile',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileScreen()));
            },
          ),
        ],
      ),
      body: _buildFeed(),
    );
  }
} 