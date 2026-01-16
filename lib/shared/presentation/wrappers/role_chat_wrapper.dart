import 'package:flutter/material.dart';

import '../../../core/domain/entities/user_role.dart';
import '../../../features/chat/presentation/pages/chat_page.dart';
import '../components/role_bottom_navigation.dart';

/// Wrapper for ChatPage that includes role-specific bottom navigation
class RoleChatWrapper extends StatelessWidget {
  final UserRole role;
  final int navIndex;

  const RoleChatWrapper({
    super.key,
    required this.role,
    this.navIndex = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(child: ChatPage()),
        RoleBottomNavigation(
          role: role,
          currentIndex: navIndex,
        ),
      ],
    );
  }
}
