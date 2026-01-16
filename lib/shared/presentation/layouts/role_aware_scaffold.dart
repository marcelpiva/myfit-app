import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/domain/entities/navigation_config.dart';
import '../../../core/domain/entities/user_role.dart';
import '../../../core/providers/context_provider.dart';

/// Role-aware scaffold that shows different navigation based on user role
class RoleAwareScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const RoleAwareScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeContext = ref.watch(activeContextProvider);
    final role = activeContext?.membership.role ?? UserRole.student;
    final destinations = NavigationConfig.getDestinations(role);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withAlpha(50),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex.clamp(0, destinations.length - 1),
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          destinations: destinations.map((dest) {
            return NavigationDestination(
              icon: Icon(dest.icon),
              label: dest.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}
