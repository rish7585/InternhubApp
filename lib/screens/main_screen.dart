import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'post_screen.dart';
import 'messages_screen.dart';
import 'roommate_finder_screen.dart';
import 'group_chat_list_screen.dart';
import 'channel_list_screen.dart';
import '../core/service_locator.dart';
import '../utils/page_transitions.dart';
import '../utils/offline_handler.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin {
  late int _selectedIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _selectedIndex);
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final List<Widget> screens = [
      const HomeScreen(),
      const SearchScreen(),
      const PostScreen(),
      const MessagesScreen(),
      const RoommateFinderScreen(),
      GroupChatListScreen(
        groupChatService: serviceLocator.groupChatService,
        userId: userId,
      ),
      ChannelListScreen(
        channelService: serviceLocator.channelService,
        // userId not needed here, but can be added if required
      ),
    ];
    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.search),
        label: 'Search',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.add_circle_outline),
        label: 'Post',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.message),
        label: 'Message',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.people),
        label: 'Roommate',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.groups),
        label: 'Groups',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.forum),
        label: 'Channels',
      ),
    ];
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: screens,
      ),
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 4
          ? FloatingActionButton(
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          elevation: 0,
          items: items,
        ),
      ),
    );
  }
} 