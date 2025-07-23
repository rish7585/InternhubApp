import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'post_screen.dart';
import 'messages_screen.dart';
import 'roommate_finder_screen.dart';
import 'group_chat_list_screen.dart';
import 'channel_list_screen.dart';
import '../services/group_chat_service.dart';
import '../services/channel_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
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
        groupChatService: GroupChatService(client: Supabase.instance.client),
        userId: userId,
      ),
      ChannelListScreen(
        channelService: ChannelService(client: Supabase.instance.client),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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