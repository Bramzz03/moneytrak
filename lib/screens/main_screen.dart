import 'package:flutter/material.dart';
import '../theme.dart';
import 'dashboard_screen.dart';
import 'input_screen.dart';
import 'ask_ai_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    DashboardScreen(),
    InputScreen(),
    AskAIScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: KeyedSubtree(
        key: ValueKey(_currentIndex),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      _NavItem(icon: Icons.home_rounded, label: 'Dashboard', index: 0),
      _NavItem(icon: Icons.add_circle_outline_rounded, label: 'Input', index: 1),
      _NavItem(icon: Icons.auto_awesome, label: 'Tanya AI', index: 2),
      _NavItem(icon: Icons.receipt_long_outlined, label: 'Riwayat', index: 3),
      _NavItem(icon: Icons.settings_outlined, label: 'Pengaturan', index: 4),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.navBg,
        border: const Border(top: BorderSide(color: AppColors.cardBorder, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) => _buildNavItem(item)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item) {
    final isActive = _currentIndex == item.index;
    final isAI = item.index == 2;

    if (isAI) {
      return GestureDetector(
        onTap: () => setState(() => _currentIndex = item.index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(
                        colors: [AppColors.accent, Color(0xFF9B59B6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isActive ? null : AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive ? Colors.transparent : AppColors.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                item.icon,
                color: isActive ? Colors.white : AppColors.accent,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: isActive ? AppColors.accent : AppColors.textMuted,
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = item.index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isActive ? AppColors.primary : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textMuted,
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int index;

  const _NavItem({required this.icon, required this.label, required this.index});
}
