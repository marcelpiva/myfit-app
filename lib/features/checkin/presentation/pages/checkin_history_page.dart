import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../domain/models/check_in.dart';
import '../providers/checkin_provider.dart';

class CheckinHistoryPage extends ConsumerStatefulWidget {
  const CheckinHistoryPage({super.key});

  @override
  ConsumerState<CheckinHistoryPage> createState() => _CheckinHistoryPageState();
}

class _CheckinHistoryPageState extends ConsumerState<CheckinHistoryPage> {
  String _selectedFilter = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final history = ref.watch(checkInHistoryProvider);
    final filteredHistory = _filterHistory(history);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withAlpha(isDark ? 15 : 10),
              AppColors.secondary.withAlpha(isDark ? 12 : 8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, isDark),

              // Filters
              _buildFilters(context, isDark),

              // Stats summary
              _buildStatsSummary(isDark, filteredHistory),

              // History list
              Expanded(
                child: filteredHistory.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredHistory.length,
                        itemBuilder: (context, index) {
                          final checkIn = filteredHistory[index];
                          final showDateHeader = index == 0 ||
                              !_isSameDay(
                                filteredHistory[index - 1].timestamp,
                                checkIn.timestamp,
                              );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showDateHeader) ...[
                                if (index != 0) const SizedBox(height: 16),
                                _buildDateHeader(isDark, checkIn.timestamp),
                                const SizedBox(height: 12),
                              ],
                              _buildHistoryTile(isDark, checkIn),
                              const SizedBox(height: 8),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<CheckIn> _filterHistory(List<CheckIn> history) {
    var filtered = history;

    // Filter by type
    if (_selectedFilter != 'all') {
      filtered = filtered.where((c) {
        switch (_selectedFilter) {
          case 'qr':
            return c.method == CheckInMethod.qrCode;
          case 'code':
            return c.method == CheckInMethod.manualCode;
          case 'location':
            return c.method == CheckInMethod.location;
          case 'request':
            return c.method == CheckInMethod.request;
          default:
            return true;
        }
      }).toList();
    }

    // Filter by date range
    if (_startDate != null) {
      filtered = filtered.where((c) => c.timestamp.isAfter(_startDate!)).toList();
    }
    if (_endDate != null) {
      filtered = filtered
          .where((c) => c.timestamp.isBefore(_endDate!.add(const Duration(days: 1))))
          .toList();
    }

    return filtered;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              context.pop();
            },
            child: Container(
              width: 44,
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
              child: Icon(
                LucideIcons.arrowLeft,
                size: 20,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Histórico de Check-ins',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                Text(
                  'Todos os seus registros de presença',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          // Calendar filter
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              _showDateRangePicker(context, isDark);
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _startDate != null || _endDate != null
                    ? AppColors.primary.withAlpha(25)
                    : (isDark
                        ? AppColors.cardDark.withAlpha(150)
                        : AppColors.card.withAlpha(200)),
                border: Border.all(
                  color: _startDate != null || _endDate != null
                      ? AppColors.primary
                      : (isDark ? AppColors.borderDark : AppColors.border),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.calendar,
                size: 20,
                color: _startDate != null || _endDate != null
                    ? AppColors.primary
                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, bool isDark) {
    final filters = [
      {'id': 'all', 'label': 'Todos', 'icon': LucideIcons.list},
      {'id': 'qr', 'label': 'QR Code', 'icon': LucideIcons.scanLine},
      {'id': 'code', 'label': 'Código', 'icon': LucideIcons.hash},
      {'id': 'location', 'label': 'GPS', 'icon': LucideIcons.mapPin},
      {'id': 'request', 'label': 'Solicitação', 'icon': LucideIcons.send},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticUtils.selectionClick();
                setState(() => _selectedFilter = filter['id'] as String);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.cardDark.withAlpha(150)
                          : AppColors.card.withAlpha(200)),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.borderDark : AppColors.border),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      filter['icon'] as IconData,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      filter['label'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.foregroundDark : AppColors.foreground),
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

  Widget _buildStatsSummary(bool isDark, List<CheckIn> history) {
    final thisMonth = history.where((c) {
      final now = DateTime.now();
      return c.timestamp.year == now.year && c.timestamp.month == now.month;
    }).length;

    final thisWeek = history.where((c) {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      return c.timestamp.isAfter(weekStart);
    }).length;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
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
                children: [
                  Text(
                    '$thisWeek',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Esta semana',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
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
                children: [
                  Text(
                    '$thisMonth',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                  Text(
                    'Este mês',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
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
                children: [
                  Text(
                    '${history.length}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
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

  Widget _buildDateHeader(bool isDark, DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    String label;

    if (_isSameDay(date, now)) {
      label = 'Hoje';
    } else if (_isSameDay(date, yesterday)) {
      label = 'Ontem';
    } else {
      final months = [
        'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
        'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
      ];
      label = '${date.day} de ${months[date.month - 1]}';
    }

    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
      ),
    );
  }

  Widget _buildHistoryTile(bool isDark, CheckIn checkIn) {
    final methodInfo = _getMethodInfo(checkIn.method);

    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
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
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (methodInfo['color'] as Color).withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                methodInfo['icon'] as IconData,
                size: 20,
                color: methodInfo['color'] as Color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    checkIn.organizationName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        methodInfo['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: methodInfo['color'] as Color,
                        ),
                      ),
                      Text(
                        ' - ',
                        style: TextStyle(
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                      Text(
                        _formatTime(checkIn.timestamp),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (checkIn.pointsEarned != null && checkIn.pointsEarned! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.zap, size: 12, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      '+${checkIn.pointsEarned}',
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
      ),
    );
  }

  Map<String, dynamic> _getMethodInfo(CheckInMethod method) {
    switch (method) {
      case CheckInMethod.qrCode:
        return {
          'icon': LucideIcons.scanLine,
          'label': 'QR Code',
          'color': AppColors.primary,
        };
      case CheckInMethod.manualCode:
        return {
          'icon': LucideIcons.hash,
          'label': 'Código',
          'color': AppColors.secondary,
        };
      case CheckInMethod.location:
        return {
          'icon': LucideIcons.mapPin,
          'label': 'Localização',
          'color': AppColors.accent,
        };
      case CheckInMethod.request:
        return {
          'icon': LucideIcons.send,
          'label': 'Solicitação',
          'color': AppColors.success,
        };
      case CheckInMethod.nfc:
        return {
          'icon': LucideIcons.nfc,
          'label': 'NFC',
          'color': AppColors.info,
        };
      case CheckInMethod.scheduled:
        return {
          'icon': LucideIcons.calendar,
          'label': 'Agendado',
          'color': AppColors.warning,
        };
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.calendarX,
                size: 32,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum check-in encontrado',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente ajustar os filtros ou faça seu primeiro check-in',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context, bool isDark) async {
    HapticUtils.lightImpact();
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }
}
