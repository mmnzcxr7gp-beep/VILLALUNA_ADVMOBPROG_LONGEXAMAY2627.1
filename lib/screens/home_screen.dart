import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/user.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_dialogs.dart';
import '../widgets/custom_font.dart';
import 'newsfeed_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final User? currentUser;

  const HomeScreen({super.key, this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      NewsfeedScreen(currentUser: widget.currentUser),
      NotificationScreen(currentUser: widget.currentUser),
      ProfileScreen(currentUser: widget.currentUser),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 14,
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/owl.jpg',
                width: 30,
                height: 30,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Icon(
                  Icons.school,
                  size: 24,
                  color: AppColors.nuBlue,
                ),
              ),
            ),
            const SizedBox(width: 8),
            CustomFont.klavika(
              text: 'SYNERTECH',
              fontSize: 21,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: isDark ? AppColors.textPrimaryDark : AppColors.nuDarkBlue,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? AppColors.nuGold : AppColors.nuDarkBlue,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      SettingsScreen(currentUser: widget.currentUser),
                ),
              );
            },
            tooltip: 'Settings & Preferences',
          ),
          IconButton(
            icon: Icon(
              Icons.search,
              color: isDark ? Colors.white : AppColors.nuDarkBlue,
            ),
            onPressed: () {
              CustomDialogs.showSnackBar(
                context,
                message: 'Search SYNERTECH posts, members, and updates',
              );
            },
            tooltip: 'Search',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.feed_outlined),
              activeIcon: Icon(Icons.feed),
              label: 'Newsfeed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
