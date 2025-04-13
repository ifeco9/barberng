import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavBarItem> items;
  final bool isBarber;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.isBarber = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _buildNavItem(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = items[index];
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: AppTheme.bodyText2.copyWith(
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavBarItem {
  final IconData icon;
  final String label;

  const BottomNavBarItem({
    required this.icon,
    required this.label,
  });
}

class CustomerBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomerBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomBottomNavBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavBarItem(icon: Icons.home, label: 'Home'),
        BottomNavBarItem(icon: Icons.search, label: 'Search'),
        BottomNavBarItem(icon: Icons.calendar_today, label: 'Appointments'),
        BottomNavBarItem(icon: Icons.person, label: 'Profile'),
      ],
    );
  }
}

class BarberBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BarberBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomBottomNavBar(
      currentIndex: currentIndex,
      onTap: onTap,
      isBarber: true,
      items: const [
        BottomNavBarItem(icon: Icons.dashboard, label: 'Dashboard'),
        BottomNavBarItem(icon: Icons.calendar_today, label: 'Schedule'),
        BottomNavBarItem(icon: Icons.people, label: 'Clients'),
        BottomNavBarItem(icon: Icons.person, label: 'Profile'),
      ],
    );
  }
} 