import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/haptic_utils.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/app_colors.dart';
import '../../../core/domain/entities/navigation_config.dart';
import '../../../core/domain/entities/user_role.dart';
import '../../../features/home/presentation/providers/student_home_provider.dart';

/// Bottom navigation bar for role-based navigation
class RoleBottomNavigation extends ConsumerWidget {
  final UserRole role;
  final int currentIndex;

  const RoleBottomNavigation({
    super.key,
    required this.role,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final destinations = NavigationConfig.getDestinations(role);

    // Get badge counts for student role
    final newPlansCount = role == UserRole.student
        ? ref.watch(studentNewPlansProvider).newPlans.length
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(destinations.length, (index) {
              final destination = destinations[index];
              final isSelected = currentIndex == index;

              // Show badge on "Treinos" tab (index 1) for students
              final badgeCount = (role == UserRole.student && index == 1)
                  ? newPlansCount
                  : 0;

              return _NavBarItem(
                icon: destination.icon,
                label: destination.label,
                isSelected: isSelected,
                isDark: isDark,
                badgeCount: badgeCount,
                onTap: () {
                  HapticUtils.selectionClick();
                  context.go(destination.route);
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isDark ? AppColors.primaryDark : AppColors.primary;
    final mutedColor = widget.isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? primaryColor.withAlpha(widget.isDark ? 30 : 20)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      widget.icon,
                      size: widget.isSelected ? 24 : 22,
                      color: widget.isSelected ? primaryColor : mutedColor,
                    ),
                  ),
                  if (widget.badgeCount > 0)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.destructive,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          widget.badgeCount > 9 ? '9+' : '${widget.badgeCount}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: widget.isSelected ? primaryColor : mutedColor,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
