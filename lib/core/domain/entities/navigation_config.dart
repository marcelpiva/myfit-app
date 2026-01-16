import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'user_role.dart';

/// Navigation destination configuration
class NavDestination {
  final String label;
  final IconData icon;
  final String route;

  const NavDestination({
    required this.label,
    required this.icon,
    required this.route,
  });
}

/// Navigation configuration based on user role
class NavigationConfig {
  /// Get navigation destinations based on user role
  static List<NavDestination> getDestinations(UserRole role) {
    switch (role) {
      case UserRole.student:
        return _studentDestinations;
      case UserRole.trainer:
      case UserRole.coach:
        return _trainerDestinations;
      case UserRole.nutritionist:
        return _nutritionistDestinations;
      case UserRole.gymOwner:
      case UserRole.gymAdmin:
        return _gymDestinations;
    }
  }

  /// Student navigation: Home, Treinos, Dieta, Progresso, Chat
  static const _studentDestinations = [
    NavDestination(
      label: 'Home',
      icon: LucideIcons.home,
      route: '/home',
    ),
    NavDestination(
      label: 'Treinos',
      icon: LucideIcons.dumbbell,
      route: '/workouts',
    ),
    NavDestination(
      label: 'Dieta',
      icon: LucideIcons.utensils,
      route: '/nutrition',
    ),
    NavDestination(
      label: 'Progresso',
      icon: LucideIcons.trendingUp,
      route: '/progress',
    ),
    NavDestination(
      label: 'Chat',
      icon: LucideIcons.messageCircle,
      route: '/chat',
    ),
  ];

  /// Trainer/Coach navigation: Dashboard, Alunos, Treinos, Agenda, Chat
  static const _trainerDestinations = [
    NavDestination(
      label: 'Dashboard',
      icon: LucideIcons.layoutDashboard,
      route: '/trainer-home',
    ),
    NavDestination(
      label: 'Alunos',
      icon: LucideIcons.users,
      route: '/students',
    ),
    NavDestination(
      label: 'Treinos',
      icon: LucideIcons.dumbbell,
      route: '/trainer-programs',  // Trainer's programs list
    ),
    NavDestination(
      label: 'Agenda',
      icon: LucideIcons.calendar,
      route: '/schedule',
    ),
    NavDestination(
      label: 'Chat',
      icon: LucideIcons.messageCircle,
      route: '/trainer-chat',  // Trainer-specific route outside shell
    ),
  ];

  /// Nutritionist navigation: Dashboard, Pacientes, Planos, Consultas, Chat
  static const _nutritionistDestinations = [
    NavDestination(
      label: 'Dashboard',
      icon: LucideIcons.layoutDashboard,
      route: '/nutritionist-home',
    ),
    NavDestination(
      label: 'Pacientes',
      icon: LucideIcons.users,
      route: '/patients',
    ),
    NavDestination(
      label: 'Planos',
      icon: LucideIcons.clipboardList,
      route: '/diet-plans',
    ),
    NavDestination(
      label: 'Consultas',
      icon: LucideIcons.calendarCheck,
      route: '/appointments',
    ),
    NavDestination(
      label: 'Chat',
      icon: LucideIcons.messageCircle,
      route: '/nutritionist-chat',  // Nutritionist-specific route outside shell
    ),
  ];

  /// Gym/Academy navigation: Dashboard, Equipe, Alunos, Financeiro, Config
  static const _gymDestinations = [
    NavDestination(
      label: 'Dashboard',
      icon: LucideIcons.layoutDashboard,
      route: '/gym-home',
    ),
    NavDestination(
      label: 'Equipe',
      icon: LucideIcons.userCog,
      route: '/staff',
    ),
    NavDestination(
      label: 'Alunos',
      icon: LucideIcons.users,
      route: '/members',
    ),
    NavDestination(
      label: 'Financeiro',
      icon: LucideIcons.dollarSign,
      route: '/billing',
    ),
    NavDestination(
      label: 'Config',
      icon: LucideIcons.settings,
      route: '/gym-settings',
    ),
  ];
}
