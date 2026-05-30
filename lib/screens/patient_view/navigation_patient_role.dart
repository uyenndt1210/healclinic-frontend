import 'package:flutter/material.dart';
import 'home_patient_view.dart';
import 'function_view.dart';
import 'profile_view.dart';
import 'notification_page.dart';

// ══════════════════════════════════════════
// THEME & CONSTANTS
// ══════════════════════════════════════════
class AppColors {
  static const primary = Color(0xFF1A73C8);
  static const primaryLight = Color(0xFF4A9FE8);
  static const primarySoft = Color(0xFFE8F4FF);
  static const accent = Color(0xFF00B4D8);
  static const accentLight = Color(0xFFCAF0F8);
  static const white = Color(0xFFFFFFFF);
  static const background = Color(0xFFF5F9FF);
  static const cardBg = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF1A2E44);
  static const textMedium = Color(0xFF4A6580);
  static const textLight = Color(0xFF8FACC5);
  static const gradientStart = Color(0xFF1A73C8);
  static const gradientEnd = Color(0xFF00B4D8);
  static const unread = Color(0xFFFF4B4B);
}

// ══════════════════════════════════════════
// MAIN APP
// ══════════════════════════════════════════
class HomePatientScreen extends StatelessWidget {
  const HomePatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    //   title: 'Healclinic App',
    //   debugShowCheckedModeBanner: false,
    //   theme: ThemeData(
    //     fontFamily: 'Roboto',
    //     scaffoldBackgroundColor: AppColors.background,
    //     colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    //     useMaterial3: true,
    //   ),
    //   home: const MainShell(),
    // );
    return const MainShell();
  }
}

// ══════════════════════════════════════════
// MAIN SHELL (Bottom Nav)
// ══════════════════════════════════════════
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    NotificationsPage(),
    FeaturesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, 'Trang chủ'),
              _navItemBadge(1, Icons.notifications_rounded, 'Thông báo', 5),
              _navItem(2, Icons.layers_rounded, 'Chức năng'),
              _navItem(3, Icons.person_rounded, 'Cá nhân'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textLight,
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? AppColors.primary : AppColors.textLight,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItemBadge(
      int index, IconData icon, String label, int badgeCount) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primarySoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: isActive ? AppColors.primary : AppColors.textLight,
                  size: 24,
                ),
              ),
              if (badgeCount > 0)
                Positioned(
                  top: 0,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.unread,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? AppColors.primary : AppColors.textLight,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}