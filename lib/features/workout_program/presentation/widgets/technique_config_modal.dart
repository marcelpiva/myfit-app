import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/exercise_theme.dart';
import '../../domain/models/workout_program.dart';

/// Configuration data for technique-specific parameters
class TechniqueConfigData {
  final int? dropCount; // For drop sets
  final int? restBetweenDrops; // For drop sets
  final int? pauseDuration; // For rest-pause/cluster
  final int? miniSetCount; // For cluster
  final String? executionInstructions;

  const TechniqueConfigData({
    this.dropCount,
    this.restBetweenDrops,
    this.pauseDuration,
    this.miniSetCount,
    this.executionInstructions,
  });

  /// Default configuration for a technique type
  factory TechniqueConfigData.defaultFor(TechniqueType technique) {
    return switch (technique) {
      TechniqueType.dropset => const TechniqueConfigData(
          dropCount: 3,
          restBetweenDrops: 0,
        ),
      TechniqueType.restPause => const TechniqueConfigData(
          pauseDuration: 15,
        ),
      TechniqueType.cluster => const TechniqueConfigData(
          miniSetCount: 4,
          pauseDuration: 10,
        ),
      _ => const TechniqueConfigData(),
    };
  }

  TechniqueConfigData copyWith({
    int? dropCount,
    int? restBetweenDrops,
    int? pauseDuration,
    int? miniSetCount,
    String? executionInstructions,
  }) {
    return TechniqueConfigData(
      dropCount: dropCount ?? this.dropCount,
      restBetweenDrops: restBetweenDrops ?? this.restBetweenDrops,
      pauseDuration: pauseDuration ?? this.pauseDuration,
      miniSetCount: miniSetCount ?? this.miniSetCount,
      executionInstructions: executionInstructions ?? this.executionInstructions,
    );
  }
}

/// Modal for configuring technique-specific parameters
class TechniqueConfigModal extends StatefulWidget {
  final TechniqueType technique;
  final Function(TechniqueConfigData) onConfirm;
  final TechniqueConfigData? initialConfig;

  const TechniqueConfigModal({
    super.key,
    required this.technique,
    required this.onConfirm,
    this.initialConfig,
  });

  @override
  State<TechniqueConfigModal> createState() => _TechniqueConfigModalState();
}

class _TechniqueConfigModalState extends State<TechniqueConfigModal> {
  late TechniqueConfigData _config;
  final _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig ?? TechniqueConfigData.defaultFor(widget.technique);
    _instructionsController.text = _config.executionInstructions ?? '';
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  Color get _techniqueColor => ExerciseTheme.getColor(widget.technique);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _techniqueColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getIcon(),
                        color: _techniqueColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configurar ${widget.technique.displayName}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            widget.technique.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.x),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Technique-specific configuration
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Build configuration fields based on technique
                    ..._buildConfigFields(theme, isDark),

                    const SizedBox(height: 16),

                    // Execution instructions
                    Text(
                      'Instruções de Execução (opcional)',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _instructionsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Ex: Manter tensão constante...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? theme.colorScheme.surfaceContainerLow
                            : theme.colorScheme.surfaceContainerLowest,
                      ),
                      onChanged: (value) {
                        _config = _config.copyWith(executionInstructions: value);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Confirm button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          HapticUtils.mediumImpact();
                          Navigator.pop(context);
                          widget.onConfirm(_config);
                        },
                        icon: const Icon(LucideIcons.check, size: 18),
                        label: const Text('Confirmar e Selecionar Exercício'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: _techniqueColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() => ExerciseTheme.getIcon(widget.technique);

  List<Widget> _buildConfigFields(ThemeData theme, bool isDark) {
    return switch (widget.technique) {
      TechniqueType.dropset => _buildDropsetFields(theme, isDark),
      TechniqueType.restPause => _buildRestPauseFields(theme, isDark),
      TechniqueType.cluster => _buildClusterFields(theme, isDark),
      _ => [],
    };
  }

  List<Widget> _buildDropsetFields(ThemeData theme, bool isDark) {
    return [
      _buildSectionTitle(theme, 'Número de Drops'),
      const SizedBox(height: 8),
      _buildChipSelector(
        values: [2, 3, 4, 5],
        selectedValue: _config.dropCount ?? 3,
        onSelected: (value) {
          setState(() {
            _config = _config.copyWith(dropCount: value);
          });
        },
        labelBuilder: (value) => '$value drops',
        theme: theme,
        isDark: isDark,
      ),
      const SizedBox(height: 16),
      _buildSectionTitle(theme, 'Descanso entre Drops'),
      const SizedBox(height: 8),
      _buildChipSelector(
        values: [0, 5, 10, 15],
        selectedValue: _config.restBetweenDrops ?? 0,
        onSelected: (value) {
          setState(() {
            _config = _config.copyWith(restBetweenDrops: value);
          });
        },
        labelBuilder: (value) => value == 0 ? 'Sem descanso' : '${value}s',
        theme: theme,
        isDark: isDark,
      ),
    ];
  }

  List<Widget> _buildRestPauseFields(ThemeData theme, bool isDark) {
    return [
      _buildSectionTitle(theme, 'Duração da Pausa'),
      const SizedBox(height: 8),
      _buildChipSelector(
        values: [10, 15, 20, 30],
        selectedValue: _config.pauseDuration ?? 15,
        onSelected: (value) {
          setState(() {
            _config = _config.copyWith(pauseDuration: value);
          });
        },
        labelBuilder: (value) => '${value}s',
        theme: theme,
        isDark: isDark,
      ),
      const SizedBox(height: 12),
      _buildInfoCard(
        theme,
        isDark,
        LucideIcons.info,
        'Faça o máximo de repetições, descanse brevemente, e continue até a falha.',
      ),
    ];
  }

  List<Widget> _buildClusterFields(ThemeData theme, bool isDark) {
    return [
      _buildSectionTitle(theme, 'Mini-Séries por Set'),
      const SizedBox(height: 8),
      _buildChipSelector(
        values: [3, 4, 5, 6],
        selectedValue: _config.miniSetCount ?? 4,
        onSelected: (value) {
          setState(() {
            _config = _config.copyWith(miniSetCount: value);
          });
        },
        labelBuilder: (value) => '$value mini-sets',
        theme: theme,
        isDark: isDark,
      ),
      const SizedBox(height: 16),
      _buildSectionTitle(theme, 'Pausa entre Mini-Séries'),
      const SizedBox(height: 8),
      _buildChipSelector(
        values: [10, 15, 20, 30],
        selectedValue: _config.pauseDuration ?? 10,
        onSelected: (value) {
          setState(() {
            _config = _config.copyWith(pauseDuration: value);
          });
        },
        labelBuilder: (value) => '${value}s',
        theme: theme,
        isDark: isDark,
      ),
      const SizedBox(height: 12),
      _buildInfoCard(
        theme,
        isDark,
        LucideIcons.info,
        'Cluster sets permitem mais volume com cargas pesadas através de micro-pausas.',
      ),
    ];
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildChipSelector<T>({
    required List<T> values,
    required T selectedValue,
    required Function(T) onSelected,
    required String Function(T) labelBuilder,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((value) {
        final isSelected = value == selectedValue;
        return ChoiceChip(
          label: Text(labelBuilder(value)),
          selected: isSelected,
          onSelected: (_) {
            HapticUtils.selectionClick();
            onSelected(value);
          },
          selectedColor: _techniqueColor.withValues(alpha: 0.2),
          checkmarkColor: _techniqueColor,
          labelStyle: TextStyle(
            color: isSelected ? _techniqueColor : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoCard(
    ThemeData theme,
    bool isDark,
    IconData icon,
    String message,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _techniqueColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _techniqueColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: _techniqueColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
