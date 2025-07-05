import 'package:flutter/material.dart';
import 'create_roommate_profile_screen.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  Map<String, dynamic>? _myProfile;
  List<Map<String, dynamic>> _roommatePosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyProfileAndPosts();
  }

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
    if (myProfiles == null || myProfiles.isEmpty) {
      // Redirect to create profile if none exists
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CreateRoommateProfileScreen()),
        );
      });
      return;
    }
    _myProfile = myProfiles[0];
    // Fetch roommate posts (excluding current user's own post)
    final posts = await Supabase.instance.client
        .from('roommate_profiles')
        .select()
        .neq('user_id', user.id);
    setState(() {
      _roommatePosts = List<Map<String, dynamic>>.from(posts);
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
          // TODO: Implement roommate ad posting
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post roommate ad coming soon!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMyProfileCard(Map<String, dynamic> profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? const Color(0xFF23262F) : Colors.indigo[50],
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
          child: Icon(Icons.person, size: 40, color: isDark ? Colors.white : Colors.indigo),
        ),
        title: Text(
          profile['name'] ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(profile['location'] ?? '', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
            Text(' 24${profile['budget']?.toStringAsFixed(0) ?? ''}/month', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
            Text(profile['personal_bio'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
          ],
        ),
        trailing: AppButton(
          label: 'Edit',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CreateRoommateProfileScreen()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoommateCard(Map<String, dynamic> post) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? const Color(0xFF23262F) : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
          child: Icon(Icons.person, size: 40, color: isDark ? Colors.white : Colors.grey),
        ),
        title: Text(
          post['name'] ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post['location'] ?? '', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
            Text(' 24${post['budget']?.toStringAsFixed(0) ?? ''}/month', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
            Text(post['personal_bio'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
          ],
        ),
        trailing: AppButton(
          label: '',
          icon: Icons.message_outlined,
          onPressed: () {
            // TODO: Implement chat functionality
          },
        ),
        onTap: () {
          // TODO: Navigate to detailed profile
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[100],
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
            decoration: const InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
            ),
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
              Text('Max Budget:  24${_maxBudget.toInt()}'),
              Slider(
                value: _maxBudget,
                min: 500,
                max: 5000,
                divisions: 45,
                label: ' 24${_maxBudget.toInt()}',
                onChanged: (value) {
                  setState(() {
                    _maxBudget = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 