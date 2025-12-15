import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/roommate_profile.dart';
import '../utils/error_handler.dart';
import '../utils/page_transitions.dart';
import '../widgets/swipeable_card.dart';
import 'chat_screen.dart';
import '../constants/app_spacing.dart';

class RoommateSwipeScreen extends StatefulWidget {
  const RoommateSwipeScreen({super.key});

  @override
  State<RoommateSwipeScreen> createState() => _RoommateSwipeScreenState();
}

class _RoommateSwipeScreenState extends State<RoommateSwipeScreen> {
  List<RoommateProfile> _roommates = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoommates();
  }

  Future<void> _loadRoommates() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('roommate_profiles')
          .select()
          .neq('user_id', user.id);

      setState(() {
        _roommates = List<Map<String, dynamic>>.from(response)
            .map((json) => RoommateProfile.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      ErrorHandler.showError(context, e);
      setState(() => _isLoading = false);
    }
  }

  void _onSwipeLeft() {
    // User swiped left (pass)
    if (_currentIndex < _roommates.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _onSwipeRight() {
    // User swiped right (like/connect)
    if (_currentIndex < _roommates.length - 1) {
      setState(() {
        _currentIndex++;
      });
      // TODO: Save match/connection to database
      ErrorHandler.showSuccess(context, 'Connected with ${_roommates[_currentIndex - 1].name}!');
    }
  }

  void _onSwipeTop() {
    // User swiped up (super like)
    if (_currentIndex < _roommates.length - 1) {
      setState(() {
        _currentIndex++;
      });
      // TODO: Save super like to database
      ErrorHandler.showSuccess(context, 'Super liked ${_roommates[_currentIndex - 1].name}!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Find Roommates')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_roommates.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Find Roommates')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: isDark ? Colors.white24 : Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No roommates found',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for new roommate profiles',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentIndex >= _roommates.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Find Roommates')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                "You've seen everyone!",
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for new profiles',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                  _loadRoommates();
                },
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    final currentRoommate = _roommates[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentIndex + 1} / ${_roommates.length}'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _currentIndex < _roommates.length
                    ? SwipeableCard(
                        onSwipeLeft: _onSwipeLeft,
                        onSwipeRight: _onSwipeRight,
                        onSwipeUp: _onSwipeTop,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: _buildRoommateCard(_roommates[_currentIndex], isDark),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            // Action buttons
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Pass button
                  _buildActionButton(
                    icon: Icons.close,
                    color: Colors.red,
                    onPressed: _onSwipeLeft,
                    tooltip: 'Pass',
                  ),
                  // Super like button
                  _buildActionButton(
                    icon: Icons.star,
                    color: Colors.blue,
                    onPressed: _onSwipeTop,
                    tooltip: 'Super Like',
                  ),
                  // Like button
                  _buildActionButton(
                    icon: Icons.favorite,
                    color: Colors.green,
                    onPressed: _onSwipeRight,
                    tooltip: 'Like',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoommateCard(RoommateProfile roommate, bool isDark) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile image placeholder
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 100,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and age
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            roommate.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Badge for shared school/company
                        if (roommate.school.isNotEmpty)
                          Chip(
                            label: Text(roommate.school),
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                            labelStyle: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          roommate.location,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    
                    // Budget
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '\$${roommate.budget.toStringAsFixed(0)}/month',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Bio
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          roommate.personalBio,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    
                    // Interests
                    if (roommate.interests.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: roommate.interests.take(5).map((interest) {
                          return Chip(
                            label: Text(
                              interest,
                              style: const TextStyle(fontSize: 11),
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}

