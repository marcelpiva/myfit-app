import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../providers/progress_provider.dart';

class ProgressPage extends ConsumerStatefulWidget {
  const ProgressPage({super.key});

  @override
  ConsumerState<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends ConsumerState<ProgressPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _selectedTab = 0;

  final _tabs = ['Peso', 'Medidas', 'Fotos'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.entrance,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(isDark ? 15 : 10),
              (isDark ? AppColors.secondaryDark : AppColors.secondary).withAlpha(isDark ? 12 : 8),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Progresso',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            HapticUtils.lightImpact();
                            _showAddProgressOptions(context, isDark);
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              LucideIcons.plus,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark.withAlpha(150)
                            : AppColors.card.withAlpha(200),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: _tabs.asMap().entries.map((entry) {
                          final isSelected = entry.key == _selectedTab;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticUtils.selectionClick();
                                setState(() => _selectedTab = entry.key);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark ? AppColors.foregroundDark : AppColors.foreground)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? (isDark ? AppColors.backgroundDark : AppColors.background)
                                          : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Content based on selected tab
                  if (_selectedTab == 0) ...[
                    // Weight summary card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _WeightSummary(isDark: isDark),
                    ),

                    const SizedBox(height: 24),

                    // Chart placeholder
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _WeightChart(isDark: isDark),
                    ),

                    const SizedBox(height: 24),

                    // Recent entries
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Registros Recentes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticUtils.selectionClick();
                              _showAllWeightEntriesModal(context, isDark);
                            },
                            child: Text(
                              'Ver todos',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.primaryDark : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Entries list from API
                    _WeightEntriesList(isDark: isDark),
                  ] else if (_selectedTab == 1) ...[
                    // Medidas tab
                    _MeasurementsTab(isDark: isDark),
                  ] else ...[
                    // Fotos tab
                    _PhotosTab(isDark: isDark),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddProgressOptions(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adicionar Registro',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 20),
              _buildAddOption(
                ctx,
                isDark,
                LucideIcons.scale,
                'Registrar Peso',
                'Adicione seu peso atual',
                AppColors.primary,
                () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  context.push('/progress/weight');
                },
              ),
              const SizedBox(height: 12),
              _buildAddOption(
                ctx,
                isDark,
                LucideIcons.ruler,
                'Registrar Medidas',
                'Atualize suas medidas corporais',
                AppColors.secondary,
                () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  context.push(RouteNames.measurements);
                },
              ),
              const SizedBox(height: 12),
              _buildAddOption(
                ctx,
                isDark,
                LucideIcons.camera,
                'Adicionar Fotos',
                'Registre seu progresso visual',
                AppColors.accent,
                () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  _showAddPhotoDialog(context, isDark);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddOption(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.mutedDark.withAlpha(150)
              : AppColors.muted.withAlpha(200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWeightDialog(BuildContext context, bool isDark) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Row(
          children: [
            Icon(LucideIcons.scale, size: 24, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              'Registrar Peso',
              style: TextStyle(
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Peso (kg)',
                hintText: 'Ex: 75.5',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixText: 'kg',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              Navigator.pop(ctx);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticUtils.mediumImpact();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Peso registrado com sucesso!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showAddMeasurementsDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Row(
          children: [
            Icon(LucideIcons.ruler, size: 24, color: AppColors.secondary),
            const SizedBox(width: 12),
            Text(
              'Registrar Medidas',
              style: TextStyle(
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMeasurementField('Peito', 'cm'),
              const SizedBox(height: 12),
              _buildMeasurementField('Cintura', 'cm'),
              const SizedBox(height: 12),
              _buildMeasurementField('Quadril', 'cm'),
              const SizedBox(height: 12),
              _buildMeasurementField('Braco', 'cm'),
              const SizedBox(height: 12),
              _buildMeasurementField('Coxa', 'cm'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              Navigator.pop(ctx);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticUtils.mediumImpact();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Medidas registradas com sucesso!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementField(String label, String suffix) {
    return TextField(
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixText: suffix,
        isDense: true,
      ),
    );
  }

  void _showAddPhotoDialog(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adicionar Foto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Abrindo camera...'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.mutedDark.withAlpha(150)
                              : AppColors.muted.withAlpha(200),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(LucideIcons.camera, size: 32, color: AppColors.primary),
                            const SizedBox(height: 8),
                            Text(
                              'Câmera',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Abrindo galeria...'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.mutedDark.withAlpha(150)
                              : AppColors.muted.withAlpha(200),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(LucideIcons.image, size: 32, color: AppColors.secondary),
                            const SizedBox(height: 8),
                            Text(
                              'Galeria',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatWeightDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final logDate = DateTime(date.year, date.month, date.day);

      final timeStr = DateFormat('HH:mm').format(date);

      if (logDate == today) {
        return 'Hoje, $timeStr';
      } else if (logDate == yesterday) {
        return 'Ontem, $timeStr';
      } else {
        return '${DateFormat('dd MMM', 'pt_BR').format(date)}, $timeStr';
      }
    } catch (_) {
      return isoDate;
    }
  }

  double _calculateWeightChange(List<Map<String, dynamic>> logs, int index) {
    if (index >= logs.length - 1) return 0.0;
    final current = (logs[index]['weight_kg'] as num?)?.toDouble() ?? 0;
    final previous = (logs[index + 1]['weight_kg'] as num?)?.toDouble() ?? 0;
    return current - previous;
  }

  void _showAllWeightEntriesModal(BuildContext context, bool isDark) {
    // Read weight logs from provider
    final weightState = ref.read(weightLogsNotifierProvider);
    final logs = weightState.logs;

    // Convert API data to display format
    final entries = logs.asMap().entries.map((e) {
      final index = e.key;
      final log = e.value;
      return {
        'weight': (log['weight_kg'] as num?)?.toDouble() ?? 0,
        'date': _formatWeightDate(log['logged_at'] as String?),
        'change': _calculateWeightChange(logs, index),
        'id': log['id'],
        'notes': log['notes'],
      };
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Todos os Registros',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.mutedDark : AppColors.muted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.x,
                        size: 18,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Entries list
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum registro de peso',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                    )
                  : ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return GestureDetector(
                    onTap: () {
                      HapticUtils.selectionClick();
                      Navigator.pop(ctx);
                      _showWeightEntryDetailsModal(context, isDark, entry);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.mutedDark.withAlpha(150)
                            : AppColors.muted.withAlpha(200),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: (entry['change'] as double) < 0
                                  ? AppColors.success.withAlpha(25)
                                  : AppColors.warning.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              (entry['change'] as double) < 0
                                  ? LucideIcons.trendingDown
                                  : LucideIcons.trendingUp,
                              size: 18,
                              color: (entry['change'] as double) < 0
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${entry['weight']} kg',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.foregroundDark
                                        : AppColors.foreground,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  entry['date'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.mutedForegroundDark
                                        : AppColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (entry['change'] as double) < 0
                                  ? AppColors.success.withAlpha(25)
                                  : AppColors.warning.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${(entry['change'] as double) > 0 ? '+' : ''}${entry['change']} kg',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: (entry['change'] as double) < 0
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWeightEntryDetailsModal(BuildContext context, bool isDark, Map<String, dynamic> entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detalhes do Registro',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.mutedDark : AppColors.muted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.x,
                        size: 18,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Weight display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.mutedDark.withAlpha(150)
                      : AppColors.muted.withAlpha(200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.scale,
                      size: 32,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${entry['weight']} kg',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (entry['change'] as double) < 0
                            ? AppColors.success.withAlpha(25)
                            : AppColors.warning.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            (entry['change'] as double) < 0
                                ? LucideIcons.trendingDown
                                : LucideIcons.trendingUp,
                            size: 16,
                            color: (entry['change'] as double) < 0
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${(entry['change'] as double) > 0 ? '+' : ''}${entry['change']} kg',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: (entry['change'] as double) < 0
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Date info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.calendar,
                      size: 20,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      entry['date'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Função de edição em desenvolvimento'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(LucideIcons.pencil, size: 18, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Editar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Registro excluído'),
                            backgroundColor: AppColors.destructive,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.destructive),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.trash2, size: 18, color: AppColors.destructive),
                            const SizedBox(width: 8),
                            Text(
                              'Excluir',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.destructive,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeightSummary extends StatelessWidget {
  final bool isDark;

  const _WeightSummary({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Current weight
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peso Atual',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '75.2',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        ' kg',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _MiniStat(
                label: 'Meta',
                value: '72.0 kg',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _MiniStat(
                label: 'Faltam',
                value: '-3.2 kg',
                color: AppColors.success,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isDark;

  const _MiniStat({
    required this.label,
    required this.value,
    this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (color ?? AppColors.primary).withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color ??
                  (isDark ? AppColors.primaryDark : AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeightChart extends StatelessWidget {
  final bool isDark;

  const _WeightChart({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final values = [79.5, 78.2, 77.8, 76.5, 76.0, 75.2];
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'];
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Evolução',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.foregroundDark
                      : AppColors.foreground,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.trendingDown,
                      size: 14,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '-4.3 kg',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Chart
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: values.asMap().entries.map((entry) {
                final normalizedHeight = range > 0
                    ? ((entry.value - minVal) / range) * 80 + 30
                    : 80.0;
                final isLast = entry.key == values.length - 1;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${entry.value}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isLast
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: normalizedHeight,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: isLast
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.borderDark
                                  : AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        months[entry.key],
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final bool isDark;

  const _EntryCard({required this.entry, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticUtils.selectionClick();
        _showEntryDetailsModal(context, isDark, entry);
      },
      child: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withAlpha(150)
              : AppColors.card.withAlpha(200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (entry['change'] as double) < 0
                    ? AppColors.success.withAlpha(25)
                    : AppColors.warning.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                (entry['change'] as double) < 0
                    ? LucideIcons.trendingDown
                    : LucideIcons.trendingUp,
                size: 18,
                color: (entry['change'] as double) < 0
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ),

            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry['weight']} kg',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry['date'],
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),

            // Change
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (entry['change'] as double) < 0
                    ? AppColors.success.withAlpha(25)
                    : AppColors.warning.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(entry['change'] as double) > 0 ? '+' : ''}${entry['change']} kg',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: (entry['change'] as double) < 0
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEntryDetailsModal(BuildContext context, bool isDark, Map<String, dynamic> entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detalhes do Registro',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.mutedDark : AppColors.muted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.x,
                        size: 18,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Weight display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.mutedDark.withAlpha(150)
                      : AppColors.muted.withAlpha(200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.scale,
                      size: 32,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${entry['weight']} kg',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (entry['change'] as double) < 0
                            ? AppColors.success.withAlpha(25)
                            : AppColors.warning.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            (entry['change'] as double) < 0
                                ? LucideIcons.trendingDown
                                : LucideIcons.trendingUp,
                            size: 16,
                            color: (entry['change'] as double) < 0
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${(entry['change'] as double) > 0 ? '+' : ''}${entry['change']} kg',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: (entry['change'] as double) < 0
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Date info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.calendar,
                      size: 20,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      entry['date'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Função de edição em desenvolvimento'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(LucideIcons.pencil, size: 18, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Editar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Registro excluído'),
                            backgroundColor: AppColors.destructive,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.destructive),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.trash2, size: 18, color: AppColors.destructive),
                            const SizedBox(width: 8),
                            Text(
                              'Excluir',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.destructive,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Weight Entries List (uses API)
class _WeightEntriesList extends ConsumerWidget {
  final bool isDark;

  const _WeightEntriesList({required this.isDark});

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final logDate = DateTime(date.year, date.month, date.day);

      final timeStr = DateFormat('HH:mm').format(date);

      if (logDate == today) {
        return 'Hoje, $timeStr';
      } else if (logDate == yesterday) {
        return 'Ontem, $timeStr';
      } else {
        return '${DateFormat('dd MMM', 'pt_BR').format(date)}, $timeStr';
      }
    } catch (_) {
      return isoDate;
    }
  }

  double _calculateChange(List<Map<String, dynamic>> logs, int index) {
    if (index >= logs.length - 1) return 0.0;
    final current = (logs[index]['weight_kg'] as num?)?.toDouble() ?? 0;
    final previous = (logs[index + 1]['weight_kg'] as num?)?.toDouble() ?? 0;
    return current - previous;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightState = ref.watch(weightLogsNotifierProvider);

    if (weightState.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (weightState.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.destructive.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.alertCircle, color: AppColors.destructive),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  weightState.error!,
                  style: TextStyle(color: AppColors.destructive),
                ),
              ),
              GestureDetector(
                onTap: () => ref.read(weightLogsNotifierProvider.notifier).refresh(),
                child: Icon(LucideIcons.refreshCw, color: AppColors.destructive),
              ),
            ],
          ),
        ),
      );
    }

    if (weightState.logs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.cardDark.withAlpha(150)
                : AppColors.card.withAlpha(200),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                LucideIcons.scale,
                size: 48,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhum registro de peso',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Adicione seu primeiro registro',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show only first 4 entries
    final recentLogs = weightState.logs.take(4).toList();

    return Column(
      children: recentLogs.asMap().entries.map((mapEntry) {
        final index = mapEntry.key;
        final log = mapEntry.value;
        final change = _calculateChange(weightState.logs, index);
        final entry = {
          'weight': (log['weight_kg'] as num?)?.toDouble() ?? 0,
          'date': _formatDate(log['logged_at'] as String?),
          'change': change,
          'id': log['id'],
          'notes': log['notes'],
        };
        return _EntryCard(entry: entry, isDark: isDark);
      }).toList(),
    );
  }
}

// Measurements Tab
class _MeasurementsTab extends ConsumerWidget {
  final bool isDark;

  const _MeasurementsTab({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurementState = ref.watch(measurementLogsNotifierProvider);
    final latest = measurementState.latest;

    if (measurementState.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (measurementState.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.destructive.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.alertCircle, color: AppColors.destructive),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  measurementState.error!,
                  style: TextStyle(color: AppColors.destructive),
                ),
              ),
              GestureDetector(
                onTap: () => ref.read(measurementLogsNotifierProvider.notifier).refresh(),
                child: Icon(LucideIcons.refreshCw, color: AppColors.destructive),
              ),
            ],
          ),
        ),
      );
    }

    // Get values from latest measurement or use defaults
    final chest = (latest?['chest_cm'] as num?)?.toStringAsFixed(0) ?? '-';
    final waist = (latest?['waist_cm'] as num?)?.toStringAsFixed(0) ?? '-';
    final hips = (latest?['hips_cm'] as num?)?.toStringAsFixed(0) ?? '-';
    final biceps = (latest?['biceps_cm'] as num?)?.toStringAsFixed(0) ?? '-';
    final thigh = (latest?['thigh_cm'] as num?)?.toStringAsFixed(0) ?? '-';
    final calf = (latest?['calf_cm'] as num?)?.toStringAsFixed(0) ?? '-';

    // Calculate changes from logs if we have more than one entry
    final logs = measurementState.logs;
    double chestChange = 0, waistChange = 0, hipsChange = 0;
    double bicepsChange = 0, thighChange = 0, calfChange = 0;

    if (logs.length >= 2) {
      final current = logs[0];
      final previous = logs[1];
      chestChange = (((current['chest_cm'] as num?) ?? 0) - ((previous['chest_cm'] as num?) ?? 0)).toDouble();
      waistChange = (((current['waist_cm'] as num?) ?? 0) - ((previous['waist_cm'] as num?) ?? 0)).toDouble();
      hipsChange = (((current['hips_cm'] as num?) ?? 0) - ((previous['hips_cm'] as num?) ?? 0)).toDouble();
      bicepsChange = (((current['biceps_cm'] as num?) ?? 0) - ((previous['biceps_cm'] as num?) ?? 0)).toDouble();
      thighChange = (((current['thigh_cm'] as num?) ?? 0) - ((previous['thigh_cm'] as num?) ?? 0)).toDouble();
      calfChange = (((current['calf_cm'] as num?) ?? 0) - ((previous['calf_cm'] as num?) ?? 0)).toDouble();
    }

    String lastUpdated = 'Sem registros';
    if (latest != null && latest['logged_at'] != null) {
      try {
        final date = DateTime.parse(latest['logged_at'] as String);
        final diff = DateTime.now().difference(date);
        if (diff.inDays == 0) {
          lastUpdated = 'Atualizado hoje';
        } else if (diff.inDays == 1) {
          lastUpdated = 'Atualizado ontem';
        } else {
          lastUpdated = 'Atualizado há ${diff.inDays} dias';
        }
      } catch (_) {
        lastUpdated = 'Atualizado recentemente';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.cardDark.withAlpha(150)
                  : AppColors.card.withAlpha(200),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Últimas Medidas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lastUpdated,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Measurements grid
          Row(
            children: [
              Expanded(child: _buildMeasurement(context, isDark, 'Peito', chest, 'cm', chestChange)),
              const SizedBox(width: 12),
              Expanded(child: _buildMeasurement(context, isDark, 'Cintura', waist, 'cm', waistChange)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMeasurement(context, isDark, 'Quadril', hips, 'cm', hipsChange)),
              const SizedBox(width: 12),
              Expanded(child: _buildMeasurement(context, isDark, 'Braço', biceps, 'cm', bicepsChange)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMeasurement(context, isDark, 'Coxa', thigh, 'cm', thighChange)),
              const SizedBox(width: 12),
              Expanded(child: _buildMeasurement(context, isDark, 'Panturrilha', calf, 'cm', calfChange)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurement(BuildContext context, bool isDark, String label, String value, String unit, double change) {
    final isPositive = change > 0;
    final changeColor = label == 'Cintura' || label == 'Quadril'
        ? (isPositive ? AppColors.warning : AppColors.success)
        : (isPositive ? AppColors.success : AppColors.warning);

    return GestureDetector(
      onTap: () {
        HapticUtils.selectionClick();
        _showMeasurementHistoryModal(context, isDark, label, value, unit, change);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withAlpha(150)
              : AppColors.card.withAlpha(200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    ' $unit',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: changeColor.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${isPositive ? '+' : ''}${change.toStringAsFixed(1)} $unit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: changeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMeasurementHistoryModal(BuildContext context, bool isDark, String label, String value, String unit, double change) {
    final isPositive = change > 0;
    final changeColor = label == 'Cintura' || label == 'Quadril'
        ? (isPositive ? AppColors.warning : AppColors.success)
        : (isPositive ? AppColors.success : AppColors.warning);

    // Mock history data for the measurement
    final mockHistory = [
      {'date': 'Hoje', 'value': value, 'change': change},
      {'date': 'Há 1 semana', 'value': (double.parse(value) - change).toStringAsFixed(0), 'change': -1.0},
      {'date': 'Há 2 semanas', 'value': (double.parse(value) - change + 1).toStringAsFixed(0), 'change': -0.5},
      {'date': 'Há 1 mês', 'value': (double.parse(value) - change + 1.5).toStringAsFixed(0), 'change': -1.5},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Histórico - $label',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '$value $unit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: changeColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${isPositive ? '+' : ''}${change.toStringAsFixed(1)} $unit',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: changeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.mutedDark : AppColors.muted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.x,
                        size: 18,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // History list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: mockHistory.length,
                itemBuilder: (context, index) {
                  final item = mockHistory[index];
                  final itemChange = item['change'] as double;
                  final itemChangeColor = label == 'Cintura' || label == 'Quadril'
                      ? (itemChange > 0 ? AppColors.warning : AppColors.success)
                      : (itemChange > 0 ? AppColors.success : AppColors.warning);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.mutedDark.withAlpha(150)
                          : AppColors.muted.withAlpha(200),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            LucideIcons.ruler,
                            size: 18,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item['value']} $unit',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.foregroundDark
                                      : AppColors.foreground,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['date'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.mutedForegroundDark
                                      : AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: itemChangeColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${itemChange > 0 ? '+' : ''}${itemChange.toStringAsFixed(1)} $unit',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: itemChangeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Edit button
            Padding(
              padding: const EdgeInsets.all(24),
              child: GestureDetector(
                onTap: () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Editar medida de $label', style: const TextStyle(color: Colors.white)),
                      backgroundColor: AppColors.secondary,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(LucideIcons.pencil, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Atualizar Medida',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Photos Tab
class _PhotosTab extends ConsumerWidget {
  final bool isDark;

  const _PhotosTab({required this.isDark});

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy', 'pt_BR').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosState = ref.watch(progressPhotosNotifierProvider);

    if (photosState.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (photosState.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.destructive.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.alertCircle, color: AppColors.destructive),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  photosState.error!,
                  style: TextStyle(color: AppColors.destructive),
                ),
              ),
              GestureDetector(
                onTap: () => ref.read(progressPhotosNotifierProvider.notifier).refresh(),
                child: Icon(LucideIcons.refreshCw, color: AppColors.destructive),
              ),
            ],
          ),
        ),
      );
    }

    final photos = photosState.photos;
    final photoCount = photos.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.cardDark.withAlpha(150)
                  : AppColors.card.withAlpha(200),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.camera, size: 24, color: AppColors.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registro Visual',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      Text(
                        '$photoCount foto${photoCount != 1 ? 's' : ''} registrada${photoCount != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Photo grid
          Text(
            'Linha do Tempo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 16),
          // Photo entries from API
          if (photos.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    LucideIcons.camera,
                    size: 48,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma foto de progresso',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Adicione fotos para acompanhar sua evolução',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...photos.map((photo) {
              final formattedPhoto = {
                'date': _formatDate(photo['logged_at'] as String?),
                'weight': photo['weight_kg'] != null ? '${photo['weight_kg']} kg' : null,
                'note': photo['notes'],
                'photo_url': photo['photo_url'],
                'angle': photo['angle'],
              };
              return _buildPhotoEntry(context, isDark, formattedPhoto);
            }),
        ],
      ),
    );
  }

  Widget _buildPhotoEntry(BuildContext context, bool isDark, Map<String, dynamic> photo) {
    return GestureDetector(
      onTap: () {
        HapticUtils.selectionClick();
        _showPhotoViewerModal(context, isDark, photo);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withAlpha(150)
              : AppColors.card.withAlpha(200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Photo placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  LucideIcons.image,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photo['date'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    photo['weight'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                  if (photo['note'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      photo['note'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoViewerModal(BuildContext context, bool isDark, Map<String, dynamic> photo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        photo['date'] as String,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        photo['weight'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.mutedDark : AppColors.muted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.x,
                        size: 18,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Photo viewer (placeholder)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.mutedDark.withAlpha(150)
                      : AppColors.muted.withAlpha(200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.image,
                        size: 80,
                        color: AppColors.primary.withAlpha(100),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Foto de Progresso',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        photo['date'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Note section
            if (photo['note'] != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    border: Border.all(color: AppColors.primary.withAlpha(50)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.messageSquare,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          photo['note'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Actions
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Compartilhando foto...'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(LucideIcons.share2, size: 18, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Compartilhar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Foto excluída'),
                            backgroundColor: AppColors.destructive,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.destructive),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.trash2, size: 18, color: AppColors.destructive),
                            const SizedBox(width: 8),
                            Text(
                              'Excluir',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.destructive,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
