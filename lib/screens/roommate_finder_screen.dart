/// Roommate Finder Screen
/// Shows the current user's roommate profile and a list of other roommate posts.
/// Allows searching, filtering, and (soon) posting roommate ads.
import 'package:flutter/material.dart';
import 'create_roommate_profile_screen.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/roommate_profile.dart';
import 'chat_screen.dart'; // Added import for ChatScreen

/// The main screen for finding roommates.
class RoommateFinderScreen extends StatefulWidget {
  const RoommateFinderScreen({Key? key}) : super(key: key);

  @override
  State<RoommateFinderScreen> createState() => _RoommateFinderScreenState();
}

class _RoommateFinderScreenState extends State<RoommateFinderScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedLocation = 'Any';
  double _maxBudget = 2000;
  bool _showFilters = false;
  RoommateProfile? _myProfile;
  List<RoommateProfile> _roommatePosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyProfileAndPosts();
  }

  /// Fetches the current user's roommate profile and all other roommate posts.
  Future<void> _fetchMyProfileAndPosts() async {
    setState(() => _isLoading = true);
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    // Fetch current user's roommate profile
    final myProfiles = await Supabase.instance.client
        .from('roommate_profiles')
        .select()
        .eq('user_id', user.id)
        .limit(1);
    if (myProfiles.isEmpty) {
      // Redirect to create profile if none exists
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CreateRoommateProfileScreen()),
        );
      });
      return;
    }
    _myProfile = RoommateProfile.fromJson(myProfiles[0]);
    // Fetch roommate posts (excluding current user's own post)
    final posts = await Supabase.instance.client
        .from('roommate_profiles')
        .select()
        .neq('user_id', user.id);
    setState(() {
      _roommatePosts = List<Map<String, dynamic>>.from(posts)
          .map((json) => RoommateProfile.fromJson(json))
          .toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Roommates'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list : Icons.filter_list_outlined),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
                  child: AppTextField(
              controller: _searchController,
                    label: 'Search roommates...',
                    hint: 'Search roommates...',
                    prefixIcon: Icons.search,
            ),
          ),
          if (_showFilters) _buildFilters(),
                if (_myProfile != null) _buildMyProfileCard(_myProfile!),
                const SizedBox(height: 8),
          Expanded(
                  child: _roommatePosts.isEmpty
                      ? const Center(child: Text('No roommate posts yet.'))
                      : ListView.builder(
                          itemCount: _roommatePosts.length,
              itemBuilder: (context, index) {
                            final post = _roommatePosts[index];
                            return _buildRoommateCard(post);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create roommate profile screen for posting ads
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateRoommateProfileScreen()),
          );
        },
        tooltip: 'Post roommate ad',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Builds the card for the current user's profile.
  Widget _buildMyProfileCard(RoommateProfile profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      container: true,
      label: 'Your roommate profile card',
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isDark ? const Color(0xFF23262F) : Colors.indigo[50],
        child: ListTile(
          leading: Semantics(
            label: 'Your profile picture',
            image: true,
            child: CircleAvatar(
              radius: 30,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              child: Icon(Icons.person, size: 40, color: isDark ? Colors.white : Colors.indigo),
            ),
          ),
          title: Semantics(
            label: 'Your name',
            child: Text(
              profile.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: 'Location',
                child: Text(profile.location, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
              ),
              Semantics(
                label: 'Budget',
                child: Text(' 24${profile.budget.toStringAsFixed(0)}/month', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
              ),
              Semantics(
                label: 'Bio',
                child: Text(profile.personalBio, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
              ),
            ],
          ),
          trailing: Tooltip(
            message: 'Edit your profile',
            child: AppButton(
              label: 'Edit',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CreateRoommateProfileScreen()),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a card for another roommate's post.
  Widget _buildRoommateCard(RoommateProfile post) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      container: true,
      label: 'Roommate post card for ${post.name}',
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isDark ? const Color(0xFF23262F) : Colors.white,
        child: ListTile(
          leading: Semantics(
            label: 'Profile picture of ${post.name}',
            image: true,
            child: CircleAvatar(
              radius: 30,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              child: Icon(Icons.person, size: 40, color: isDark ? Colors.white : Colors.grey),
            ),
          ),
          title: Semantics(
            label: 'Name',
            child: Text(
              post.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: 'Location',
                child: Text(post.location, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
              ),
              Semantics(
                label: 'Budget',
                child: Text(' 24${post.budget.toStringAsFixed(0)}/month', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
              ),
              Semantics(
                label: 'Bio',
                child: Text(post.personalBio, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
              ),
            ],
          ),
          trailing: Tooltip(
            message: 'Message ${post.name}',
            child: AppButton(
              label: '',
              icon: Icons.message_outlined,
              onPressed: () {
                // Navigate to chat screen with the roommate
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      otherUserId: post.userId,
                      otherUserName: post.name,
                      otherUserProfilePic: null, // TODO: Add profile picture to roommate profile
                    ),
                  ),
                );
              },
            ),
          ),
          onTap: () {
            // Show detailed roommate profile in a dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(post.name),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Location: ${post.location}'),
                      Text('Budget: \$${post.budget.toStringAsFixed(0)}/month'),
                      Text('School: ${post.school}'),
                      Text('Company: ${post.company}'),
                      const SizedBox(height: 8),
                      const Text('Bio:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(post.personalBio),
                      if (post.interests.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text('Interests:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Wrap(
                          children: post.interests.map((interest) => 
                            Chip(label: Text(interest), labelStyle: const TextStyle(fontSize: 12))
                          ).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navigate to chat
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            otherUserId: post.userId,
                            otherUserName: post.name,
                            otherUserProfilePic: null,
                          ),
                        ),
                      );
                    },
                    child: const Text('Message'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds the filter UI.
  Widget _buildFilters() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? const Color(0xFF23262F) : Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedLocation,
              decoration: InputDecoration(
              labelText: 'Location',
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                ),
            ),
              dropdownColor: isDark ? Colors.grey[900] : Colors.white,
            items: ['Any', 'San Francisco', 'New York', 'Seattle', 'Austin']
                .map((location) => DropdownMenuItem(
                      value: location,
                      child: Text(location),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedLocation = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text('Max Budget:  24 24${_maxBudget.toInt()}',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: isDark ? Colors.indigoAccent : Colors.indigo,
                    inactiveTrackColor: isDark ? Colors.white24 : Colors.black12,
                    thumbColor: isDark ? Colors.indigoAccent : Colors.indigo,
                    overlayColor: (isDark ? Colors.indigoAccent : Colors.indigo).withAlpha(32),
                  ),
                  child: Slider(
                value: _maxBudget,
                min: 500,
                max: 5000,
                divisions: 45,
                    label: ' 24 24${_maxBudget.toInt()}',
                onChanged: (value) {
                  setState(() {
                    _maxBudget = value;
                  });
                },
              ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 