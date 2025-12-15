import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/service_locator.dart';
import '../widgets/post_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import '../constants/app_spacing.dart';
import 'settings_screen.dart';
import 'user_profile_screen.dart';
import 'post_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMorePosts = true;
  int _currentPage = 0;
  final int _postsPerPage = 10;
  String? _userProfilePicture;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadPosts();
  }

  Future<void> _loadUserInfo() async {
    final user = serviceLocator.authService.currentUser;
    if (user == null) {
      setState(() {});
      return;
    }
    final profile = await serviceLocator.profileService.getProfile(user.id);
    if (profile == null) {
      setState(() {});
      return;
    }
    setState(() {
      _userProfilePicture = profile['profile_picture_url'];
    });
  }

  Future<void> _loadPosts({bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingMore || !_hasMorePosts) return;
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _currentPage = 0;
        _posts = [];
        _hasMorePosts = true;
      });
    }

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
      
      // Calculate pagination
      final from = _currentPage * _postsPerPage;
      final to = from + _postsPerPage - 1;
      
      final response = await Supabase.instance.client
          .from('posts')
          .select('*, profiles!inner(id, first_name, last_name, profile_picture_url)')
          .inFilter('user_id', followingIds)
          .order('created_at', ascending: false)
          .range(from, to);
      
      final newPosts = List<Map<String, dynamic>>.from(response);
      
      setState(() {
        if (loadMore) {
          _posts.addAll(newPosts);
        } else {
          _posts = newPosts;
        }
        _hasMorePosts = newPosts.length == _postsPerPage;
        _currentPage++;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
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
              ? ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: 3,
                  itemBuilder: (context, index) => const PostCardSkeleton(),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await _loadUserInfo();
                    await _loadPosts(loadMore: false);
                  },
                  child: _posts.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: EmptyState(
                            icon: Icons.feed_outlined,
                            title: 'No posts yet',
                            message: 'Your feed is empty. Start following people or create your first post!',
                            action: Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.md),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const PostScreen()),
                                  );
                                },
                                icon: const Icon(Icons.add_circle_outline),
                                label: const Text('Create Post'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                    vertical: AppSpacing.md,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        : AnimationLimiter(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            itemCount: _posts.length + 2 + (_hasMorePosts ? 1 : 0),
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
                                // Load more trigger
                                if (_hasMorePosts && !_isLoadingMore) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    _loadPosts(loadMore: true);
                                  });
                                }
                                if (_isLoadingMore) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
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