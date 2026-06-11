// Tabs will not be the same for each user
import 'package:darb_al_hoda_app/core/constants/app_colors.dart';
import 'package:darb_al_hoda_app/core/constants/app_text_styles.dart';
import 'package:darb_al_hoda_app/features/auth/presentation/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NavTab { home, students, circles, attendance, admin, recitation, settings }

class BottomNavBar extends ConsumerWidget {
  final NavTab currentTab;
  final Function(NavTab) onTabSelected; // as a callback fun

  const BottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRole = ref.watch(authProvider).activeRole;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildTabsForRole(activeRole),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTabsForRole(String? role) {
    final tabs = <Widget>[
      _buildTab(NavTab.home, Icons.dashboard_outlined, 'الرئيسية'),
    ];

    if (role == 'circle_sheikh' || role == 'recitation_sheikh') {
      tabs.add(_buildTab(NavTab.circles, Icons.groups_outlined, 'الحلقة'));
      tabs.add(
        _buildTab(NavTab.recitation, Icons.menu_book_outlined, 'التسميع'),
      );
      tabs.add(_buildTab(NavTab.students, Icons.people_outline, 'الطلاب'));
      tabs.add(
        _buildTab(NavTab.attendance, Icons.calendar_today_outlined, 'الحضور'),
      );
    } else if (role == 'admin') {
      tabs.add(_buildTab(NavTab.admin, Icons.settings_outlined, 'المدير'));
    }

    // Settings for all users
    tabs.add(_buildTab(NavTab.settings, Icons.tune_outlined, 'الإعدادات'));

    return tabs;
  }

  Widget _buildTab(NavTab tab, IconData icon, String label) {
    // check if the passed tab is the current active one to give it special styles
    final isSelected = currentTab == tab;

    return GestureDetector(
      onTap: () => onTabSelected(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          // if selected - light green bg
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              // if selected green if not then grey
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? AppColors.primary : Colors.grey.shade400,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
