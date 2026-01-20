import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';

/// Full screen photo gallery for progress photos
class ProgressPhotoGallery extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> photos;
  final int initialIndex;
  final String studentName;

  const ProgressPhotoGallery({
    super.key,
    required this.photos,
    this.initialIndex = 0,
    required this.studentName,
  });

  @override
  ConsumerState<ProgressPhotoGallery> createState() => _ProgressPhotoGalleryState();
}

class _ProgressPhotoGalleryState extends ConsumerState<ProgressPhotoGallery> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showInfo = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Photo viewer
          GestureDetector(
            onTap: () => setState(() => _showInfo = !_showInfo),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.photos.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                final photo = widget.photos[index];
                final url = photo['photo_url'] as String?;

                if (url == null) {
                  return Center(
                    child: Icon(
                      LucideIcons.imageOff,
                      size: 64,
                      color: Colors.white38,
                    ),
                  );
                }

                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.white,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stack) => Center(
                        child: Icon(
                          LucideIcons.imageOff,
                          size: 64,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Top bar
          AnimatedOpacity(
            opacity: _showInfo ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(180),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.x, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.studentName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${_currentIndex + 1} de ${widget.photos.length}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        HapticUtils.lightImpact();
                        _showCompareSheet(context);
                      },
                      icon: const Icon(LucideIcons.columns, color: Colors.white),
                      tooltip: 'Comparar',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom info
          AnimatedOpacity(
            opacity: _showInfo ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                  top: 24,
                  left: 16,
                  right: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withAlpha(180),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: _buildPhotoInfo(widget.photos[_currentIndex]),
              ),
            ),
          ),

          // Thumbnails
          AnimatedOpacity(
            opacity: _showInfo ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 100,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: widget.photos.length,
                  itemBuilder: (context, index) {
                    final photo = widget.photos[index];
                    final url = photo['photo_url'] as String?;
                    final isSelected = index == _currentIndex;

                    return GestureDetector(
                      onTap: () {
                        HapticUtils.selectionClick();
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 50,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                          image: url != null
                              ? DecorationImage(
                                  image: NetworkImage(url),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: url == null
                            ? const Center(
                                child: Icon(
                                  LucideIcons.image,
                                  color: Colors.white38,
                                  size: 20,
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoInfo(Map<String, dynamic> photo) {
    final angle = photo['angle'] as String?;
    final dateStr = photo['logged_at'] as String?;
    final notes = photo['notes'] as String?;
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (angle != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _translateAngle(angle),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            if (date != null)
              Text(
                _formatDate(date),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
          ],
        ),
        if (notes != null && notes.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            notes,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  void _showCompareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => PhotoCompareSheet(
        photos: widget.photos,
        initialPhoto: widget.photos[_currentIndex],
        studentName: widget.studentName,
      ),
    );
  }

  String _translateAngle(String angle) {
    switch (angle.toLowerCase()) {
      case 'front':
        return 'Frente';
      case 'back':
        return 'Costas';
      case 'side':
        return 'Lateral';
      case 'left':
        return 'Esquerda';
      case 'right':
        return 'Direita';
      default:
        return angle;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'Janeiro', 'Fevereiro', 'Março', 'Abril',
      'Maio', 'Junho', 'Julho', 'Agosto',
      'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return '${date.day} de ${months[date.month]} de ${date.year}';
  }
}

/// Sheet for comparing two photos side by side
class PhotoCompareSheet extends StatefulWidget {
  final List<Map<String, dynamic>> photos;
  final Map<String, dynamic> initialPhoto;
  final String studentName;

  const PhotoCompareSheet({
    super.key,
    required this.photos,
    required this.initialPhoto,
    required this.studentName,
  });

  @override
  State<PhotoCompareSheet> createState() => _PhotoCompareSheetState();
}

class _PhotoCompareSheetState extends State<PhotoCompareSheet> {
  late Map<String, dynamic> _leftPhoto;
  Map<String, dynamic>? _rightPhoto;
  bool _selectingRight = false;

  @override
  void initState() {
    super.initState();
    _leftPhoto = widget.initialPhoto;
    // Auto-select a comparison photo if available (preferably oldest)
    if (widget.photos.length > 1) {
      _rightPhoto = widget.photos.last != widget.initialPhoto
          ? widget.photos.last
          : widget.photos.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  LucideIcons.columns,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Comparar Fotos',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
          ),

          // Comparison view
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Left photo
                  Expanded(
                    child: _buildPhotoColumn(
                      theme,
                      isDark,
                      _leftPhoto,
                      'Antes',
                      !_selectingRight,
                      () => setState(() => _selectingRight = false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Right photo
                  Expanded(
                    child: _rightPhoto != null
                        ? _buildPhotoColumn(
                            theme,
                            isDark,
                            _rightPhoto!,
                            'Depois',
                            _selectingRight,
                            () => setState(() => _selectingRight = true),
                          )
                        : _buildEmptyColumn(theme, isDark),
                  ),
                ],
              ),
            ),
          ),

          // Photo selector
          Container(
            height: 100,
            padding: EdgeInsets.only(bottom: bottomPadding + 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _selectingRight
                        ? 'Selecione a foto "Depois"'
                        : 'Selecione a foto "Antes"',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widget.photos.length,
                    itemBuilder: (context, index) {
                      final photo = widget.photos[index];
                      final url = photo['photo_url'] as String?;
                      final isLeftSelected = photo == _leftPhoto;
                      final isRightSelected = photo == _rightPhoto;

                      return GestureDetector(
                        onTap: () {
                          HapticUtils.selectionClick();
                          setState(() {
                            if (_selectingRight) {
                              _rightPhoto = photo;
                            } else {
                              _leftPhoto = photo;
                            }
                          });
                        },
                        child: Container(
                          width: 50,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isLeftSelected
                                  ? AppColors.info
                                  : (isRightSelected
                                      ? AppColors.success
                                      : Colors.transparent),
                              width: 2,
                            ),
                            image: url != null
                                ? DecorationImage(
                                    image: NetworkImage(url),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: url == null
                              ? Center(
                                  child: Icon(
                                    LucideIcons.image,
                                    color: isDark
                                        ? AppColors.mutedForegroundDark
                                        : AppColors.mutedForeground,
                                    size: 20,
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoColumn(
    ThemeData theme,
    bool isDark,
    Map<String, dynamic> photo,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final url = photo['photo_url'] as String?;
    final dateStr = photo['logged_at'] as String?;
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Label
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: label == 'Antes'
                    ? AppColors.info.withAlpha(isDark ? 30 : 20)
                    : AppColors.success.withAlpha(isDark ? 30 : 20),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: label == 'Antes' ? AppColors.info : AppColors.success,
                  ),
                ),
              ),
            ),
            // Photo
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.mutedDark : AppColors.muted,
                  image: url != null
                      ? DecorationImage(
                          image: NetworkImage(url),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: url == null
                    ? Center(
                        child: Icon(
                          LucideIcons.image,
                          size: 40,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      )
                    : null,
              ),
            ),
            // Date
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.card,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
              child: Center(
                child: Text(
                  date != null ? _formatShortDate(date) : 'Sem data',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyColumn(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.imagePlus,
              size: 40,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
            const SizedBox(height: 12),
            Text(
              'Selecione uma foto',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatShortDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
