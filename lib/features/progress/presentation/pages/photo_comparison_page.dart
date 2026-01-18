import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';

class PhotoComparisonPage extends ConsumerStatefulWidget {
  const PhotoComparisonPage({super.key});

  @override
  ConsumerState<PhotoComparisonPage> createState() => _PhotoComparisonPageState();
}

class _PhotoComparisonPageState extends ConsumerState<PhotoComparisonPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  String _selectedAngle = 'front';
  int _beforeIndex = 0;
  int _afterIndex = 0;

  // Mock photos organized by angle
  final Map<String, List<Map<String, dynamic>>> _photosByAngle = {
    'front': [
      {'id': '1', 'date': DateTime(2024, 1, 15), 'weight': 75.2},
      {'id': '2', 'date': DateTime(2024, 1, 1), 'weight': 76.5},
      {'id': '3', 'date': DateTime(2023, 12, 15), 'weight': 78.0},
      {'id': '4', 'date': DateTime(2023, 12, 1), 'weight': 79.5},
      {'id': '5', 'date': DateTime(2023, 11, 15), 'weight': 80.2},
    ],
    'side': [
      {'id': '6', 'date': DateTime(2024, 1, 15), 'weight': 75.2},
      {'id': '7', 'date': DateTime(2024, 1, 1), 'weight': 76.5},
      {'id': '8', 'date': DateTime(2023, 12, 1), 'weight': 79.5},
    ],
    'back': [
      {'id': '9', 'date': DateTime(2024, 1, 15), 'weight': 75.2},
      {'id': '10', 'date': DateTime(2023, 12, 1), 'weight': 79.5},
    ],
  };

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

    // Set initial after index to most recent
    _afterIndex = 0;
    // Set initial before index to oldest
    _beforeIndex = _currentPhotos.length - 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _currentPhotos =>
      _photosByAngle[_selectedAngle] ?? [];

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _swapPhotos() {
    HapticUtils.mediumImpact();
    setState(() {
      final temp = _beforeIndex;
      _beforeIndex = _afterIndex;
      _afterIndex = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticUtils.lightImpact();
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isDark ? AppColors.cardDark : AppColors.card,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.border,
                            ),
                          ),
                          child: Icon(
                            LucideIcons.arrowLeft,
                            size: 18,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Comparar Fotos',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          HapticUtils.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Compartilhando comparacao...'),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isDark ? AppColors.cardDark : AppColors.card,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.border,
                            ),
                          ),
                          child: Icon(
                            LucideIcons.share2,
                            size: 18,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Angle selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildAngleSelector(isDark),
                ),

                const SizedBox(height: 20),

                // Photo comparison area
                Expanded(
                  child: _currentPhotos.length >= 2
                      ? _buildComparisonView(isDark)
                      : _buildNoPhotosView(isDark),
                ),

                // Weight difference badge
                if (_currentPhotos.length >= 2) ...[
                  _buildWeightDifferenceBadge(isDark),
                  const SizedBox(height: 16),
                ],

                // Photo selectors
                if (_currentPhotos.length >= 2) ...[
                  _buildPhotoSelectors(isDark),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAngleSelector(bool isDark) {
    final angles = [
      {'value': 'front', 'label': 'Frente', 'icon': LucideIcons.user},
      {'value': 'side', 'label': 'Lateral', 'icon': LucideIcons.userCircle},
      {'value': 'back', 'label': 'Costas', 'icon': LucideIcons.userCircle2},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        children: angles.map((angle) {
          final isSelected = _selectedAngle == angle['value'];
          final photoCount = _photosByAngle[angle['value']]?.length ?? 0;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
                setState(() {
                  _selectedAngle = angle['value'] as String;
                  _beforeIndex = _currentPhotos.length - 1;
                  _afterIndex = 0;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.primaryDark : AppColors.primary)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      angle['icon'] as IconData,
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${angle['label']} ($photoCount)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildComparisonView(bool isDark) {
    final beforePhoto = _currentPhotos[_beforeIndex];
    final afterPhoto = _currentPhotos[_afterIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Before photo
          Expanded(
            child: _buildPhotoCard(
              beforePhoto,
              'ANTES',
              isDark,
              AppColors.mutedForeground,
            ),
          ),

          // Swap button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: _swapPhotos,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                child: Icon(
                  LucideIcons.arrowLeftRight,
                  size: 20,
                  color: isDark
                      ? AppColors.foregroundDark
                      : AppColors.foreground,
                ),
              ),
            ),
          ),

          // After photo
          Expanded(
            child: _buildPhotoCard(
              afterPhoto,
              'DEPOIS',
              isDark,
              AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(
    Map<String, dynamic> photo,
    String label,
    bool isDark,
    Color labelColor,
  ) {
    return Column(
      children: [
        // Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: labelColor.withAlpha(20),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: labelColor,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Photo
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.mutedDark.withAlpha(150)
                  : AppColors.muted.withAlpha(200),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: labelColor.withAlpha(50),
                width: 2,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.image,
                    size: 48,
                    color: labelColor.withAlpha(100),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Foto',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Date and weight
        Text(
          _formatDate(photo['date'] as DateTime),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        Text(
          '${photo['weight']} kg',
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildNoPhotosView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.camera,
                size: 48,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Fotos insuficientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.foregroundDark
                    : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Voce precisa de pelo menos 2 fotos\nno mesmo angulo para comparar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                HapticUtils.lightImpact();
                Navigator.pop(context);
              },
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Adicionar Foto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.primaryDark
                    : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightDifferenceBadge(bool isDark) {
    final beforeWeight = _currentPhotos[_beforeIndex]['weight'] as double;
    final afterWeight = _currentPhotos[_afterIndex]['weight'] as double;
    final diff = afterWeight - beforeWeight;
    final isLoss = diff < 0;

    final beforeDate = _currentPhotos[_beforeIndex]['date'] as DateTime;
    final afterDate = _currentPhotos[_afterIndex]['date'] as DateTime;
    final daysDiff = afterDate.difference(beforeDate).inDays.abs();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (isLoss ? AppColors.success : AppColors.destructive).withAlpha(isDark ? 40 : 25),
            (isLoss ? AppColors.success : AppColors.destructive).withAlpha(isDark ? 20 : 10),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isLoss ? AppColors.success : AppColors.destructive).withAlpha(50),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDiffStat(
            '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)} kg',
            'Diferenca',
            isLoss ? AppColors.success : AppColors.destructive,
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          _buildDiffStat(
            '$daysDiff dias',
            'Periodo',
            isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ],
      ),
    );
  }

  Widget _buildDiffStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withAlpha(180),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSelectors(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildPhotoDropdown(
              'Antes',
              _beforeIndex,
              (index) => setState(() => _beforeIndex = index),
              isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPhotoDropdown(
              'Depois',
              _afterIndex,
              (index) => setState(() => _afterIndex = index),
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoDropdown(
    String label,
    int selectedIndex,
    Function(int) onChanged,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          child: DropdownButton<int>(
            value: selectedIndex,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: isDark ? AppColors.cardDark : AppColors.card,
            items: List.generate(_currentPhotos.length, (index) {
              final photo = _currentPhotos[index];
              return DropdownMenuItem(
                value: index,
                child: Text(
                  '${_formatDate(photo['date'] as DateTime)} - ${photo['weight']}kg',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.foregroundDark
                        : AppColors.foreground,
                  ),
                ),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                HapticUtils.lightImpact();
                onChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }
}
