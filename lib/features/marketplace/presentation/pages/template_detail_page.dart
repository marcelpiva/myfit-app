import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/error/api_exceptions.dart';
import '../../../../core/services/marketplace_service.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/template_card.dart';
import 'template_checkout_page.dart';

// Provider for template details
final templateDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, templateId) async {
  final service = ref.watch(marketplaceServiceProvider);
  return service.getTemplate(templateId);
});

// Provider for template reviews
final templateReviewsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, templateId) async {
  final service = ref.watch(marketplaceServiceProvider);
  return service.getTemplateReviews(templateId);
});

class TemplateDetailPage extends ConsumerStatefulWidget {
  final MarketplaceTemplate template;

  const TemplateDetailPage({
    super.key,
    required this.template,
  });

  @override
  ConsumerState<TemplateDetailPage> createState() => _TemplateDetailPageState();
}

class _TemplateDetailPageState extends ConsumerState<TemplateDetailPage> {
  final PageController _imageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final template = widget.template;

    final detailAsync = ref.watch(templateDetailProvider(template.id));
    final reviewsAsync = ref.watch(templateReviewsProvider(template.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageCarousel(colorScheme),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareTemplate,
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type and Difficulty
                  Row(
                    children: [
                      _buildTypeBadge(colorScheme),
                      const SizedBox(width: 8),
                      _buildDifficultyBadge(colorScheme),
                      const Spacer(),
                      if (template.isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                              const SizedBox(width: 4),
                              Text(
                                'Destaque',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.amber.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    template.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Rating and Stats
                  Row(
                    children: [
                      if (template.ratingAverage != null) ...[
                        Icon(Icons.star, size: 18, color: Colors.amber.shade700),
                        const SizedBox(width: 4),
                        Text(
                          template.ratingAverage!.toStringAsFixed(1),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' (${template.ratingCount} avaliações)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Icon(
                        Icons.people_outline,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${template.purchaseCount} compras',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Creator Card
                  _buildCreatorCard(colorScheme),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Descrição',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  detailAsync.when(
                    data: (detail) => Text(
                      detail['full_description'] ?? template.shortDescription ?? 'Sem descrição disponível.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => Text(
                      template.shortDescription ?? 'Sem descrição disponível.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // What's Included
                  _buildIncludedSection(detailAsync, colorScheme),

                  const SizedBox(height: 24),

                  // Reviews Section
                  _buildReviewsSection(reviewsAsync, colorScheme),

                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(colorScheme),
    );
  }

  Widget _buildImageCarousel(ColorScheme colorScheme) {
    final images = <String>[];
    if (widget.template.coverImageUrl != null) {
      images.add(widget.template.coverImageUrl!);
    }

    if (images.isEmpty) {
      return Container(
        color: colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            widget.template.templateType == 'workout'
                ? Icons.fitness_center
                : Icons.restaurant_menu,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _imageController,
          itemCount: images.length,
          onPageChanged: (index) => setState(() => _currentImageIndex = index),
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: colorScheme.surfaceContainerHighest,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.broken_image, size: 64),
              ),
            );
          },
        ),
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentImageIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTypeBadge(ColorScheme colorScheme) {
    final isWorkout = widget.template.templateType == 'workout';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isWorkout ? colorScheme.primary : colorScheme.tertiary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isWorkout ? Icons.fitness_center : Icons.restaurant_menu,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            isWorkout ? 'Treino' : 'Plano Alimentar',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge(ColorScheme colorScheme) {
    final difficulty = widget.template.difficulty;
    Color color;
    String label;

    switch (difficulty) {
      case 'beginner':
        color = Colors.green;
        label = 'Iniciante';
        break;
      case 'intermediate':
        color = Colors.orange;
        label = 'Intermediário';
        break;
      case 'advanced':
        color = Colors.red;
        label = 'Avançado';
        break;
      default:
        color = colorScheme.primary;
        label = difficulty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCreatorCard(ColorScheme colorScheme) {
    final template = widget.template;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: template.creatorAvatarUrl != null
                  ? CachedNetworkImageProvider(template.creatorAvatarUrl!)
                  : null,
              child: template.creatorAvatarUrl == null
                  ? Text(
                      template.creatorName.isNotEmpty
                          ? template.creatorName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontSize: 20),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Criado por',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    template.creatorName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to creator profile
              },
              child: const Text('Ver perfil'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncludedSection(AsyncValue<Map<String, dynamic>> detailAsync, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'O que está incluído',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        detailAsync.when(
          data: (detail) {
            final isWorkout = widget.template.templateType == 'workout';
            if (isWorkout) {
              return _buildWorkoutPreview(detail, colorScheme);
            } else {
              return _buildDietPreview(detail, colorScheme);
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _buildGenericPreview(colorScheme),
        ),
      ],
    );
  }

  Widget _buildWorkoutPreview(Map<String, dynamic> detail, ColorScheme colorScheme) {
    final exercises = detail['exercises'] as List? ?? [];
    final daysPerWeek = detail['days_per_week'] ?? 0;
    final duration = detail['duration_weeks'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildIncludedItem(
              Icons.calendar_today,
              '$daysPerWeek dias por semana',
              colorScheme,
            ),
            const SizedBox(height: 12),
            _buildIncludedItem(
              Icons.timer,
              '$duration semanas de duração',
              colorScheme,
            ),
            const SizedBox(height: 12),
            _buildIncludedItem(
              Icons.fitness_center,
              '${exercises.length} exercícios',
              colorScheme,
            ),
            const SizedBox(height: 12),
            _buildIncludedItem(
              Icons.play_circle_outline,
              'Vídeos demonstrativos',
              colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietPreview(Map<String, dynamic> detail, ColorScheme colorScheme) {
    final meals = detail['meals'] as List? ?? [];
    final calories = detail['daily_calories'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildIncludedItem(
              Icons.restaurant_menu,
              '${meals.length} refeições por dia',
              colorScheme,
            ),
            const SizedBox(height: 12),
            _buildIncludedItem(
              Icons.local_fire_department,
              '$calories kcal/dia',
              colorScheme,
            ),
            const SizedBox(height: 12),
            _buildIncludedItem(
              Icons.shopping_cart,
              'Lista de compras',
              colorScheme,
            ),
            const SizedBox(height: 12),
            _buildIncludedItem(
              Icons.swap_horiz,
              'Substituições permitidas',
              colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenericPreview(ColorScheme colorScheme) {
    final isWorkout = widget.template.templateType == 'workout';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildIncludedItem(
              isWorkout ? Icons.fitness_center : Icons.restaurant_menu,
              isWorkout ? 'Plano de treino completo' : 'Plano alimentar completo',
              colorScheme,
            ),
            const SizedBox(height: 12),
            _buildIncludedItem(
              Icons.edit,
              'Totalmente personalizável',
              colorScheme,
            ),
            const SizedBox(height: 12),
            _buildIncludedItem(
              Icons.support,
              'Suporte incluído',
              colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncludedItem(IconData icon, String text, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildReviewsSection(AsyncValue<Map<String, dynamic>> reviewsAsync, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Avaliações',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.template.ratingCount > 0)
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all reviews
                },
                child: const Text('Ver todas'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        reviewsAsync.when(
          data: (data) {
            final reviews = data['reviews'] as List? ?? [];
            if (reviews.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Nenhuma avaliação ainda',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: reviews.take(3).map((review) => _buildReviewCard(review, colorScheme)).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Erro ao carregar avaliações',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review, ColorScheme colorScheme) {
    final rating = review['rating'] ?? 0;
    final comment = review['comment'] ?? '';
    final reviewerName = review['reviewer_name'] ?? 'Usuário';
    final createdAt = review['created_at'] != null
        ? DateTime.tryParse(review['created_at'])
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ...List.generate(5, (index) => Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  size: 16,
                  color: Colors.amber.shade700,
                )),
                const Spacer(),
                if (createdAt != null)
                  Text(
                    _formatDate(createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comment,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              reviewerName,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preço',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (widget.template.isFree)
                    Text(
                      'Grátis',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    Text(
                      widget.template.priceDisplay,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _handlePurchase,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.template.isFree ? 'Obter Grátis' : 'Comprar Agora',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePurchase() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateCheckoutPage(template: widget.template),
      ),
    );
  }

  void _shareTemplate() {
    // TODO: Implement share functionality
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hoje';
    } else if (diff.inDays == 1) {
      return 'Ontem';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} dias atrás';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} semanas atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
