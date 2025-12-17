import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'post_screen.dart';
import 'messages_screen.dart';
import 'roommate_finder_screen.dart';
import 'user_profile_screen.dart';
import '../utils/page_transitions.dart';
import '../utils/offline_handler.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  final PageStorageBucket _bucket = PageStorageBucket();
  late final List<Widget> _screens;
  late final List<BottomNavigationBarItem> _items;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _screens = const [
      HomeScreen(key: PageStorageKey('home')),
      RoommateFinderScreen(key: PageStorageKey('roommates')),
      PostScreen(key: PageStorageKey('post')),
      MessagesScreen(key: PageStorageKey('messages')),
      UserProfileScreen(key: PageStorageKey('profile')),
    ];
    _items = const [
      BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.house),
        activeIcon: Icon(CupertinoIcons.house_fill),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.person_2),
        activeIcon: Icon(CupertinoIcons.person_2_fill),
        label: 'Roommates',
      ),
      BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.add_circled),
        activeIcon: Icon(CupertinoIcons.add_circled_solid),
        label: 'Post',
      ),
      BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.bubble_left),
        activeIcon: Icon(CupertinoIcons.bubble_left_fill),
        label: 'Chat',
      ),
      BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.person_crop_circle),
        activeIcon: Icon(CupertinoIcons.person_crop_circle_fill),
        label: 'Profile',
      ),
    ];
    _checkOfflineStatus();
  }

  void _checkOfflineStatus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        OfflineHandler.showOfflineBanner(context);
      }
    });
    OfflineHandler.addListener(() {
      if (mounted) {
        OfflineHandler.showOfflineBanner(context);
      }
    });
  }

  @override
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: PageStorage(
          bucket: _bucket,
          child: IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              heroTag: 'home_fab',
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransitions.slideUp(page: const PostScreen()),
                ).then((_) {
                  // Refresh home feed if returning from post creation
                  if (_selectedIndex == 0 && mounted) {
                    // Trigger refresh in HomeScreen if needed
                  }
                });
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
              tooltip: 'Create Post',
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.24 : 0.08,
                ),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: theme.colorScheme.surface,
              selectedItemColor: theme.colorScheme.primary,
              unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
              selectedLabelStyle: theme.textTheme.labelLarge,
              unselectedLabelStyle: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              elevation: 0,
              items: _items,
              showUnselectedLabels: true,
            ),
          ),
        ),
      ),
    );
  }
} 