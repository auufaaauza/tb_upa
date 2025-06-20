import 'package:flutter/material.dart';
import 'package:tb_aufa/src/views/home_screen.dart';
import 'package:tb_aufa/src/views/explore_screen.dart';
import 'package:tb_aufa/src/views/saved_screen.dart';
import 'package:tb_aufa/src/views/profile_screen.dart';
import 'package:tb_aufa/src/views/search_delegate.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    SavedScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  Widget _buildAnimatedIcon(IconData icon, int index, Color color) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: Icon(
        icon,
        color: _currentIndex == index ? color : Colors.grey,
        key: ValueKey(icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OneNews"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: CustomSearchDelegate());
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () => _onItemTapped(0), // Home (Index 0)
                icon: _buildAnimatedIcon(Icons.home, 0, Colors.orange),
              ),
              IconButton(
                onPressed: () => _onItemTapped(1), // Explore (Index 1)
                icon: _buildAnimatedIcon(Icons.explore, 1, Colors.blue),
              ),
              IconButton(
                onPressed: () => _onItemTapped(2), // Saved (Index 2)
                icon: _buildAnimatedIcon(Icons.bookmark, 2, Colors.green),
              ),
              IconButton(
                onPressed: () => _onItemTapped(3), // Profile (Index 3)
                icon: _buildAnimatedIcon(Icons.person, 3, Colors.purple),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
