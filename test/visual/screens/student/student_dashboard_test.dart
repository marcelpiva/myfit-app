/// Visual tests for student dashboard components.
///
/// Tests dashboard cards, stats displays, and workout summaries.
library;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../config/device_profiles.dart';

// Test wrapper for component tests (no Scaffold - avoids infinite constraints)
class _ComponentTestWrapper extends StatelessWidget {
  const _ComponentTestWrapper({required this.child, this.isDark = false});
  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      home: Material(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

// Test wrapper for full screen mockups (with Scaffold)
class _ScreenTestWrapper extends StatelessWidget {
  const _ScreenTestWrapper({required this.child, this.isDark = false});
  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      home: Scaffold(
        body: child,
      ),
    );
  }
}

void main() {
  group('Student Dashboard', () {
    // Stats Cards
    goldenTest(
      'Stats cards',
      fileName: 'student_stats_cards',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 400),
        children: [
          GoldenTestScenario(
            name: 'Streak Card',
            child: _ComponentTestWrapper(
              child: _StatsCard(
                title: 'Sequência',
                value: '12',
                subtitle: 'dias seguidos',
                icon: Icons.local_fire_department,
                color: Colors.orange,
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'Workouts Card',
            child: _ComponentTestWrapper(
              child: _StatsCard(
                title: 'Treinos',
                value: '24',
                subtitle: 'este mês',
                icon: Icons.fitness_center,
                color: Colors.blue,
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'Progress Card',
            child: _ComponentTestWrapper(
              child: _StatsCard(
                title: 'Progresso',
                value: '78%',
                subtitle: 'do plano',
                icon: Icons.trending_up,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );

    // Today's Workout Card
    goldenTest(
      'Today workout card',
      fileName: 'student_today_workout',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 400),
        children: [
          GoldenTestScenario(
            name: 'With Workout',
            child: _ComponentTestWrapper(
              child: _TodayWorkoutCard(
                workoutName: 'Treino A - Peito e Tríceps',
                exerciseCount: 6,
                estimatedDuration: 60,
                isRest: false,
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'Rest Day',
            child: _ComponentTestWrapper(
              child: _TodayWorkoutCard(
                workoutName: 'Dia de Descanso',
                exerciseCount: 0,
                estimatedDuration: 0,
                isRest: true,
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'Dark Mode',
            child: _ComponentTestWrapper(
              isDark: true,
              child: _TodayWorkoutCard(
                workoutName: 'Treino B - Costas e Bíceps',
                exerciseCount: 5,
                estimatedDuration: 55,
                isRest: false,
              ),
            ),
          ),
        ],
      ),
    );

    // Recent Activity
    goldenTest(
      'Recent activity list',
      fileName: 'student_recent_activity',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 400),
        children: [
          GoldenTestScenario(
            name: 'With Activities',
            child: _ComponentTestWrapper(
              child: _RecentActivityList(
                activities: [
                  _Activity('Treino A completo', '45 min', 'hoje'),
                  _Activity('Treino B completo', '52 min', 'ontem'),
                  _Activity('Treino C completo', '48 min', '2 dias'),
                ],
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'Empty State',
            child: _ComponentTestWrapper(
              child: _RecentActivityList(activities: []),
            ),
          ),
        ],
      ),
    );

    // Plan Progress
    goldenTest(
      'Plan progress card',
      fileName: 'student_plan_progress',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 400),
        children: [
          GoldenTestScenario(
            name: 'In Progress',
            child: _ComponentTestWrapper(
              child: _PlanProgressCard(
                planName: 'Plano Hipertrofia 8 Semanas',
                currentWeek: 3,
                totalWeeks: 8,
                completedWorkouts: 9,
                totalWorkouts: 24,
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'Almost Complete',
            child: _ComponentTestWrapper(
              child: _PlanProgressCard(
                planName: 'Plano Força',
                currentWeek: 7,
                totalWeeks: 8,
                completedWorkouts: 20,
                totalWorkouts: 24,
              ),
            ),
          ),
        ],
      ),
    );

    // Full Dashboard mockup
    for (final device in DeviceProfiles.critical) {
      goldenTest(
        'Dashboard mockup on ${device.name}',
        fileName: 'student_dashboard_mockup_${device.safeFileName}',
        constraints: BoxConstraints.tight(device.size),
        builder: () => _ScreenTestWrapper(
          child: _StudentDashboardMockup(),
        ),
      );
    }
  });
}

// ===========================================================================
// Test Components
// ===========================================================================

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? Colors.grey[850] : Colors.white,
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: color.withAlpha(30),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  const _TodayWorkoutCard({
    required this.workoutName,
    required this.exerciseCount,
    required this.estimatedDuration,
    required this.isRest,
  });

  final String workoutName;
  final int exerciseCount;
  final int estimatedDuration;
  final bool isRest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isRest
            ? LinearGradient(
                colors: [Colors.grey[700]!, Colors.grey[800]!],
              )
            : LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withAlpha(200),
                ],
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isRest ? Icons.self_improvement : Icons.fitness_center,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                isRest ? 'Hoje' : 'Treino de Hoje',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            workoutName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!isRest) ...[
            const SizedBox(height: 8),
            Text(
              '$exerciseCount exercícios • ~$estimatedDuration min',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: theme.colorScheme.primary,
                ),
                child: const Text('Iniciar Treino'),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            const Text(
              'Aproveite para descansar e recuperar',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Activity {
  const _Activity(this.name, this.duration, this.timeAgo);
  final String name;
  final String duration;
  final String timeAgo;
}

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList({required this.activities});
  final List<_Activity> activities;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (activities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDark ? Colors.grey[850] : Colors.grey[100],
        ),
        child: Column(
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Nenhuma atividade recente',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? Colors.grey[850] : Colors.white,
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Atividade Recente',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...activities.map((activity) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.green.withAlpha(30),
                  ),
                  child: const Icon(Icons.check, color: Colors.green),
                ),
                title: Text(activity.name),
                subtitle: Text(activity.duration),
                trailing: Text(
                  activity.timeAgo,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              )),
        ],
      ),
    );
  }
}

class _PlanProgressCard extends StatelessWidget {
  const _PlanProgressCard({
    required this.planName,
    required this.currentWeek,
    required this.totalWeeks,
    required this.completedWorkouts,
    required this.totalWorkouts,
  });

  final String planName;
  final int currentWeek;
  final int totalWeeks;
  final int completedWorkouts;
  final int totalWorkouts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = completedWorkouts / totalWorkouts;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? Colors.grey[850] : Colors.white,
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  planName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.primary.withAlpha(30),
                ),
                child: Text(
                  'Semana $currentWeek/$totalWeeks',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$completedWorkouts de $totalWorkouts treinos completos',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentDashboardMockup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primary.withAlpha(30),
                  child: Text(
                    'M',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, Maria!',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Vamos treinar?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _MiniStatsCard(
                    value: '12',
                    label: 'Sequência',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStatsCard(
                    value: '24',
                    label: 'Treinos',
                    icon: Icons.fitness_center,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStatsCard(
                    value: '78%',
                    label: 'Progresso',
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Today's Workout
            _TodayWorkoutCard(
              workoutName: 'Treino A - Peito e Tríceps',
              exerciseCount: 6,
              estimatedDuration: 60,
              isRest: false,
            ),
            const SizedBox(height: 20),

            // Plan Progress
            _PlanProgressCard(
              planName: 'Plano Hipertrofia',
              currentWeek: 3,
              totalWeeks: 8,
              completedWorkouts: 9,
              totalWorkouts: 24,
            ),
            const SizedBox(height: 20),

            // Recent Activity
            _RecentActivityList(
              activities: [
                _Activity('Treino A', '45 min', 'ontem'),
                _Activity('Treino B', '52 min', '2 dias'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStatsCard extends StatelessWidget {
  const _MiniStatsCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? Colors.grey[850] : Colors.white,
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
