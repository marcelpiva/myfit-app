import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../providers/nutrition_provider.dart';

class BarcodeScannerPage extends ConsumerStatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  ConsumerState<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends ConsumerState<BarcodeScannerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isScanning = true;
  Map<String, dynamic>? _foundFood;

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

  Future<void> _simulateScan() async {
    HapticFeedback.mediumImpact();

    // In a real implementation, the barcode would come from camera scan
    // For now, simulate with a test barcode
    const testBarcode = '7891234567890';

    setState(() {
      _isScanning = false;
    });

    final food = await ref.read(foodSearchNotifierProvider.notifier).getFoodByBarcode(testBarcode);

    if (mounted) {
      if (food != null) {
        setState(() {
          _foundFood = food;
        });
      } else {
        // Food not found in database - show placeholder
        setState(() {
          _foundFood = {
            'name': 'Alimento não encontrado',
            'portion': '-',
            'calories': 0,
            'protein': 0,
            'carbs': 0,
            'fat': 0,
            'barcode': testBarcode,
          };
        });
      }
    }
  }

  void _addToMeal() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_foundFood!['name']} adicionado a refeicao', style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  void _scanAgain() {
    HapticFeedback.lightImpact();
    setState(() {
      _isScanning = true;
      _foundFood = null;
    });
  }

  void _openManualEntry() {
    HapticFeedback.lightImpact();
    // Navigate to food search page for manual entry
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abrindo busca manual...', style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.info,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.pop();
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.card,
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.arrowLeft,
                          size: 20,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Escanear Codigo de Barras',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _isScanning
                    ? _buildScannerView(isDark)
                    : _buildResultView(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerView(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Camera preview placeholder
          Expanded(
            child: GestureDetector(
              onTap: _simulateScan,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.cardDark.withAlpha(150)
                      : AppColors.card.withAlpha(200),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background pattern
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            (isDark ? AppColors.backgroundDark : AppColors.background)
                                .withAlpha(200),
                            (isDark ? AppColors.cardDark : AppColors.card)
                                .withAlpha(150),
                          ],
                        ),
                      ),
                    ),

                    // Scan frame
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            children: [
                              // Corner decorations
                              Positioned(
                                top: -1,
                                left: -1,
                                child: _CornerDecoration(isTop: true, isLeft: true),
                              ),
                              Positioned(
                                top: -1,
                                right: -1,
                                child: _CornerDecoration(isTop: true, isLeft: false),
                              ),
                              Positioned(
                                bottom: -1,
                                left: -1,
                                child: _CornerDecoration(isTop: false, isLeft: true),
                              ),
                              Positioned(
                                bottom: -1,
                                right: -1,
                                child: _CornerDecoration(isTop: false, isLeft: false),
                              ),
                              // Scanner icon
                              Center(
                                child: Icon(
                                  LucideIcons.scanLine,
                                  size: 48,
                                  color: AppColors.primary.withAlpha(150),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Aponte a camera para o codigo de barras',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Toque para simular scan',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Instructions card
          Container(
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
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.info.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.info,
                    size: 22,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dica',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mantenha o codigo dentro da area marcada para melhor leitura',
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
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Manual entry button
          GestureDetector(
            onTap: _openManualEntry,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.pencil,
                    size: 18,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Digitar manualmente',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
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

  Widget _buildResultView(bool isDark) {
    final food = _foundFood!;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Success icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.check,
              size: 40,
              color: AppColors.success,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Produto Encontrado!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),

          const SizedBox(height: 32),

          // Food card
          Container(
            width: double.infinity,
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
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.package,
                        size: 28,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food['name'] as String,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            food['brand'] as String,
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
                  ],
                ),

                const SizedBox(height: 20),

                // Divider
                Container(
                  height: 1,
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),

                const SizedBox(height: 20),

                // Nutrition info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NutritionItem(
                      label: 'Calorias',
                      value: '${food['calories']}',
                      unit: 'kcal',
                      isDark: isDark,
                    ),
                    _NutritionItem(
                      label: 'Proteina',
                      value: '${food['protein']}',
                      unit: 'g',
                      isDark: isDark,
                    ),
                    _NutritionItem(
                      label: 'Carbs',
                      value: '${food['carbs']}',
                      unit: 'g',
                      isDark: isDark,
                    ),
                    _NutritionItem(
                      label: 'Gordura',
                      value: '${food['fat']}',
                      unit: 'g',
                      isDark: isDark,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  'Porcao: ${food['portion']}',
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

          const Spacer(),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _scanAgain,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.scanLine,
                          size: 18,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Escanear outro',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
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
                  onTap: _addToMeal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.plus,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Adicionar',
                          style: TextStyle(
                            fontSize: 15,
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
        ],
      ),
    );
  }
}

class _CornerDecoration extends StatelessWidget {
  final bool isTop;
  final bool isLeft;

  const _CornerDecoration({
    required this.isTop,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? BorderSide(color: AppColors.primary, width: 4)
              : BorderSide.none,
          bottom: !isTop
              ? BorderSide(color: AppColors.primary, width: 4)
              : BorderSide.none,
          left: isLeft
              ? BorderSide(color: AppColors.primary, width: 4)
              : BorderSide.none,
          right: !isLeft
              ? BorderSide(color: AppColors.primary, width: 4)
              : BorderSide.none,
        ),
      ),
    );
  }
}

class _NutritionItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final bool isDark;

  const _NutritionItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
