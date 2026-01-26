/// Screenshots para Google Play Store.
///
/// Gera screenshots de marketing em alta qualidade para publicação.
/// Execute com: flutter test test/screenshots/playstore_screenshots_test.dart --update-goldens
library;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Configurações de dispositivo para Play Store
// Google Play requer: 16:9 ou 9:16, min 320px, max 3840px
// Recomendado: 1080x1920 (9:16) para telefones
class PlayStoreDevice {
  const PlayStoreDevice({
    required this.name,
    required this.size,
    this.devicePixelRatio = 3.0,
  });

  final String name;
  final Size size;
  final double devicePixelRatio;

  String get safeFileName => name.toLowerCase().replaceAll(' ', '_');
}

class PlayStoreDevices {
  PlayStoreDevices._();

  // Dispositivo principal para screenshots (1080x1920 em 3x = 360x640 lógicos)
  static const phone = PlayStoreDevice(
    name: 'phone',
    size: Size(360, 640),
    devicePixelRatio: 3.0,
  );

  // Tablet 7" (1200x1920 em 2x = 600x960 lógicos)
  static const tablet7 = PlayStoreDevice(
    name: 'tablet_7',
    size: Size(600, 960),
    devicePixelRatio: 2.0,
  );

  // Tablet 10" (1600x2560 em 2x = 800x1280 lógicos)
  static const tablet10 = PlayStoreDevice(
    name: 'tablet_10',
    size: Size(800, 1280),
    devicePixelRatio: 2.0,
  );
}

// Tema do app
ThemeData _appTheme({bool isDark = false}) {
  return ThemeData(
    useMaterial3: true,
    brightness: isDark ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1), // Indigo primary
      brightness: isDark ? Brightness.dark : Brightness.light,
    ),
    fontFamily: 'Roboto',
  );
}

// Wrapper para screenshots
class ScreenshotWrapper extends StatelessWidget {
  const ScreenshotWrapper({
    super.key,
    required this.child,
    this.isDark = false,
  });

  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _appTheme(isDark: isDark),
      home: child,
    );
  }
}

void main() {
  group('Play Store Screenshots - Phone', () {
    final device = PlayStoreDevices.phone;

    // 1. Tela de Boas-vindas
    goldenTest(
      '01_welcome',
      fileName: 'playstore/phone/01_welcome',
      constraints: BoxConstraints.tight(device.size),
      builder: () => ScreenshotWrapper(
        child: _WelcomeScreen(),
      ),
    );

    // 2. Dashboard do Aluno
    goldenTest(
      '02_student_dashboard',
      fileName: 'playstore/phone/02_student_dashboard',
      constraints: BoxConstraints.tight(device.size),
      builder: () => ScreenshotWrapper(
        child: _StudentDashboard(),
      ),
    );

    // 3. Detalhe do Treino
    goldenTest(
      '03_workout_detail',
      fileName: 'playstore/phone/03_workout_detail',
      constraints: BoxConstraints.tight(device.size),
      builder: () => ScreenshotWrapper(
        child: _WorkoutDetail(),
      ),
    );

    // 4. Treino em Execução
    goldenTest(
      '04_active_workout',
      fileName: 'playstore/phone/04_active_workout',
      constraints: BoxConstraints.tight(device.size),
      builder: () => ScreenshotWrapper(
        child: _ActiveWorkout(),
      ),
    );

    // 5. Chat com Personal
    goldenTest(
      '05_chat',
      fileName: 'playstore/phone/05_chat',
      constraints: BoxConstraints.tight(device.size),
      builder: () => ScreenshotWrapper(
        child: _ChatScreen(),
      ),
    );

    // 6. Progresso e Evolução
    goldenTest(
      '06_progress',
      fileName: 'playstore/phone/06_progress',
      constraints: BoxConstraints.tight(device.size),
      builder: () => ScreenshotWrapper(
        child: _ProgressScreen(),
      ),
    );

    // 7. Dashboard do Personal Trainer
    goldenTest(
      '07_trainer_dashboard',
      fileName: 'playstore/phone/07_trainer_dashboard',
      constraints: BoxConstraints.tight(device.size),
      builder: () => ScreenshotWrapper(
        child: _TrainerDashboard(),
      ),
    );

    // 8. Nutrição
    goldenTest(
      '08_nutrition',
      fileName: 'playstore/phone/08_nutrition',
      constraints: BoxConstraints.tight(device.size),
      builder: () => ScreenshotWrapper(
        child: _NutritionScreen(),
      ),
    );
  });
}

// ===========================================================================
// MOCKUP SCREENS
// ===========================================================================

// 1. Tela de Boas-vindas
class _WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'MyFit',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Treinos personalizados com\nseu Personal Trainer',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem(value: '2k+', label: 'Profissionais'),
                  _StatItem(value: '50k+', label: 'Alunos'),
                  _StatItem(value: '4.9', label: 'Avaliação'),
                ],
              ),
              const Spacer(),
              // Buttons
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {},
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text('Começar Grátis'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text('Já tenho conta'),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}

// 2. Dashboard do Aluno
class _StudentDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
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
                        fontSize: 20,
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
                          'Vamos treinar hoje?',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Badge(
                      smallSize: 8,
                      child: const Icon(Icons.notifications_outlined),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Stats
              Row(
                children: [
                  Expanded(
                    child: _DashboardStat(
                      icon: Icons.local_fire_department,
                      value: '12',
                      label: 'Sequência',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DashboardStat(
                      icon: Icons.fitness_center,
                      value: '24',
                      label: 'Treinos',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DashboardStat(
                      icon: Icons.trending_up,
                      value: '78%',
                      label: 'Progresso',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Today's Workout
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
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
                        const Icon(Icons.fitness_center,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Treino de Hoje',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Treino A - Peito e Tríceps',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '6 exercícios • ~60 min',
                      style: TextStyle(color: Colors.white70),
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
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Plan Progress
              Text(
                'Meu Plano',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Plano Hipertrofia 8 Semanas',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: theme.colorScheme.primary.withAlpha(30),
                          ),
                          child: Text(
                            'Semana 3/8',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.375,
                        backgroundColor: Colors.grey[200],
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '9 de 24 treinos completos',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(
              icon: Icon(Icons.fitness_center), label: 'Treinos'),
          NavigationDestination(
              icon: Icon(Icons.restaurant_menu), label: 'Nutrição'),
          NavigationDestination(
              icon: Icon(Icons.show_chart), label: 'Progresso'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _DashboardStat extends StatelessWidget {
  const _DashboardStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// 3. Detalhe do Treino
class _WorkoutDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Treino A'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.primary.withAlpha(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _WorkoutInfo(icon: Icons.fitness_center, label: '6 exercícios'),
                _WorkoutInfo(icon: Icons.timer_outlined, label: '~60 min'),
                _WorkoutInfo(icon: Icons.local_fire_department, label: '450 kcal'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Exercícios',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _ExerciseItem(
            name: 'Supino Reto',
            sets: '4x12',
            muscle: 'Peito',
            imageIcon: Icons.fitness_center,
          ),
          _ExerciseItem(
            name: 'Supino Inclinado',
            sets: '4x10',
            muscle: 'Peito Superior',
            imageIcon: Icons.fitness_center,
          ),
          _ExerciseItem(
            name: 'Crossover',
            sets: '3x15',
            muscle: 'Peito',
            imageIcon: Icons.fitness_center,
          ),
          _ExerciseItem(
            name: 'Tríceps Pulley',
            sets: '4x12',
            muscle: 'Tríceps',
            imageIcon: Icons.fitness_center,
          ),
          _ExerciseItem(
            name: 'Tríceps Francês',
            sets: '3x12',
            muscle: 'Tríceps',
            imageIcon: Icons.fitness_center,
          ),
          _ExerciseItem(
            name: 'Mergulho',
            sets: '3x10',
            muscle: 'Tríceps',
            imageIcon: Icons.fitness_center,
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: () {},
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text('Iniciar Treino'),
          ),
        ),
      ),
    );
  }
}

class _WorkoutInfo extends StatelessWidget {
  const _WorkoutInfo({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _ExerciseItem extends StatelessWidget {
  const _ExerciseItem({
    required this.name,
    required this.sets,
    required this.muscle,
    required this.imageIcon,
  });

  final String name;
  final String sets;
  final String muscle;
  final IconData imageIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: Icon(imageIcon, color: Colors.grey[400]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '$muscle • $sets',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

// 4. Treino em Execução
class _ActiveWorkout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: const Text('Supino Reto'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Pular')),
        ],
      ),
      body: Column(
        children: [
          // Exercise image
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[100],
            child: Icon(Icons.fitness_center, size: 80, color: Colors.grey[300]),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Série 2 de 4',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(height: 32),
                  // Current set info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _SetInfo(label: 'Repetições', value: '12'),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey[300],
                      ),
                      _SetInfo(label: 'Carga', value: '40kg'),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey[300],
                      ),
                      _SetInfo(label: 'Descanso', value: '60s'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Timer
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: theme.colorScheme.primary.withAlpha(20),
                    ),
                    child: Column(
                      children: [
                        const Text('Descanso'),
                        const SizedBox(height: 8),
                        Text(
                          '00:45',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Completed sets
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SetDot(completed: true),
                      _SetDot(completed: false),
                      _SetDot(completed: false),
                      _SetDot(completed: false),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.check),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text('Completar Série'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetInfo extends StatelessWidget {
  const _SetInfo({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _SetDot extends StatelessWidget {
  const _SetDot({required this.completed});
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed
            ? Theme.of(context).colorScheme.primary
            : Colors.grey[300],
      ),
    );
  }
}

// 5. Chat
class _ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue[100],
              child: const Text('PT', style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pedro Trainer', style: TextStyle(fontSize: 16)),
                Text(
                  'Online',
                  style: TextStyle(fontSize: 12, color: Colors.green[600]),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.videocam_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ChatBubble(
                  message: 'Oi Maria! Como foi o treino de ontem?',
                  isMe: false,
                  time: '10:30',
                ),
                _ChatBubble(
                  message:
                      'Foi ótimo! Consegui aumentar a carga no supino pra 42kg! 💪',
                  isMe: true,
                  time: '10:32',
                ),
                _ChatBubble(
                  message:
                      'Muito bom! Você está evoluindo rápido. Vamos aumentar a intensidade na próxima semana.',
                  isMe: false,
                  time: '10:33',
                ),
                _ChatBubble(
                  message: 'Perfeito! Mal posso esperar 😊',
                  isMe: true,
                  time: '10:34',
                ),
                _ChatBubble(
                  message:
                      'Lembre-se de descansar bem hoje. Amanhã tem treino de pernas!',
                  isMe: false,
                  time: '10:35',
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Digite uma mensagem...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.isMe,
    required this.time,
  });

  final String message;
  final bool isMe;
  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? theme.colorScheme.primary : Colors.grey[100],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 6. Progresso
class _ProgressScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Progresso'),
        actions: [
          IconButton(icon: const Icon(Icons.add_a_photo), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weight card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.monitor_weight_outlined,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Peso',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '-2.5 kg',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '72.5',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text('kg'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Simple chart mockup
                  SizedBox(
                    height: 60,
                    child: CustomPaint(
                      size: const Size(double.infinity, 60),
                      painter: _ChartPainter(theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Photos comparison
            Text(
              'Evolução Corporal',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PhotoCard(label: 'Início', date: '01/01/2024'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PhotoCard(label: 'Atual', date: '26/01/2024'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Measurements
            Text(
              'Medidas Corporais',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _MeasurementItem(label: 'Braço', value: '36 cm', change: '+2 cm'),
            _MeasurementItem(label: 'Peito', value: '98 cm', change: '+3 cm'),
            _MeasurementItem(label: 'Cintura', value: '82 cm', change: '-4 cm'),
            _MeasurementItem(label: 'Coxa', value: '58 cm', change: '+2 cm'),
          ],
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
        size.width * 0.25, size.height * 0.6, size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.4, size.width, size.height * 0.2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.label, required this.date});
  final String label;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _MeasurementItem extends StatelessWidget {
  const _MeasurementItem({
    required this.label,
    required this.value,
    required this.change,
  });

  final String label;
  final String value;
  final String change;

  @override
  Widget build(BuildContext context) {
    final isPositive = change.startsWith('+');
    final isNegativeGood = label == 'Cintura';
    final isGood = isNegativeGood ? !isPositive : isPositive;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isGood ? Colors.green[50] : Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              change,
              style: TextStyle(
                fontSize: 11,
                color: isGood ? Colors.green[700] : Colors.orange[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 7. Dashboard do Personal Trainer
class _TrainerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
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
                    backgroundColor: Colors.blue[100],
                    child: const Text('PT',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, Pedro!',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Personal Trainer',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Badge(
                      label: const Text('3'),
                      child: const Icon(Icons.notifications_outlined),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Stats
              Row(
                children: [
                  Expanded(
                    child: _TrainerStat(
                      value: '24',
                      label: 'Alunos',
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TrainerStat(
                      value: '8',
                      label: 'Hoje',
                      icon: Icons.calendar_today,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TrainerStat(
                      value: '156',
                      label: 'Treinos/mês',
                      icon: Icons.fitness_center,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Quick actions
              Text(
                'Ações Rápidas',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.add_circle_outline,
                      label: 'Novo Treino',
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.person_add_outlined,
                      label: 'Novo Aluno',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.message_outlined,
                      label: 'Mensagens',
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Students needing attention
              Row(
                children: [
                  Text(
                    'Alunos - Atenção',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Ver todos'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _StudentAttentionCard(
                name: 'Maria Silva',
                issue: 'Não treinou há 5 dias',
                avatar: 'MS',
                color: Colors.orange,
              ),
              _StudentAttentionCard(
                name: 'João Santos',
                issue: 'Plano expira em 3 dias',
                avatar: 'JS',
                color: Colors.red,
              ),
              _StudentAttentionCard(
                name: 'Ana Costa',
                issue: 'Enviou feedback',
                avatar: 'AC',
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Alunos'),
          NavigationDestination(
              icon: Icon(Icons.fitness_center), label: 'Treinos'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Relatórios'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _TrainerStat extends StatelessWidget {
  const _TrainerStat({
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withAlpha(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StudentAttentionCard extends StatelessWidget {
  const _StudentAttentionCard({
    required this.name,
    required this.issue,
    required this.avatar,
    required this.color,
  });

  final String name;
  final String issue;
  final String avatar;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withAlpha(30),
            child: Text(
              avatar,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  issue,
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }
}

// 8. Nutrição
class _NutritionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrição'),
        actions: [
          IconButton(
              icon: const Icon(Icons.calendar_month_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calories summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withAlpha(200),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Calorias Hoje',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '1.450',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          ' / 2.200 kcal',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 0.66,
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '750 kcal restantes',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Macros
            Row(
              children: [
                Expanded(
                  child: _MacroCard(
                    label: 'Proteínas',
                    current: 95,
                    goal: 150,
                    color: Colors.red,
                    unit: 'g',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MacroCard(
                    label: 'Carboidratos',
                    current: 180,
                    goal: 250,
                    color: Colors.orange,
                    unit: 'g',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MacroCard(
                    label: 'Gorduras',
                    current: 45,
                    goal: 70,
                    color: Colors.blue,
                    unit: 'g',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Today's meals
            Row(
              children: [
                Text(
                  'Refeições de Hoje',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Adicionar'),
                  style: FilledButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MealCard(
              meal: 'Café da Manhã',
              time: '07:30',
              calories: 450,
              items: ['Ovos mexidos', 'Pão integral', 'Café'],
              icon: Icons.wb_sunny_outlined,
            ),
            _MealCard(
              meal: 'Almoço',
              time: '12:00',
              calories: 650,
              items: ['Frango grelhado', 'Arroz', 'Salada'],
              icon: Icons.restaurant,
            ),
            _MealCard(
              meal: 'Lanche',
              time: '15:30',
              calories: 350,
              items: ['Whey protein', 'Banana', 'Aveia'],
              icon: Icons.local_cafe_outlined,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  const _MacroCard({
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
    required this.unit,
  });

  final String label;
  final int current;
  final int goal;
  final Color color;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '$current$unit',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          Text(
            '/ $goal$unit',
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: current / goal,
              backgroundColor: Colors.grey[200],
              color: color,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.meal,
    required this.time,
    required this.calories,
    required this.items,
    required this.icon,
  });

  final String meal;
  final String time;
  final int calories;
  final List<String> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      meal,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  items.join(' • '),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '$calories kcal',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
