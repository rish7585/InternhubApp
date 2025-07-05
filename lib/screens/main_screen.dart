import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'post_screen.dart';
import 'messages_screen.dart';
import 'roommate_finder_screen.dart';

final List<Widget> _screens = [
  const HomeScreen(),
  const SearchScreen(),
  const PostScreen(),
  const MessagesScreen(),
  const RoommateFinderScreen(),
];

final List<BottomNavigationBarItem> _items = [
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
];

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _items,
      ),
    );
  }
} 