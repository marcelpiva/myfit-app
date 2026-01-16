import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/marketplace_provider.dart';

class TemplateCard extends StatelessWidget {
  final MarketplaceTemplate template;
  final VoidCallback? onTap;
  final bool showCreator;

  const TemplateCard({
    super.key,
    required this.template,
    this.onTap,
    this.showCreator = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (template.coverImageUrl != null)
                    CachedNetworkImage(
                      imageUrl: template.coverImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildPlaceholder(colorScheme),
                    )
                  else
                    _buildPlaceholder(colorScheme),

                  // Type Badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTypeColor(colorScheme),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getTypeLabel(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Featured Badge
                  if (template.isFeatured)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'Destaque',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      template.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Description
                    if (template.shortDescription != null)
                      Expanded(
                        child: Text(
                          template.shortDescription!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    const Spacer(),

                    // Rating and Difficulty
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (template.ratingAverage != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber.shade700,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                template.ratingAverage!.toStringAsFixed(1),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                ' (${template.ratingCount})',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(colorScheme).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getDifficultyLabel(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _getDifficultyColor(colorScheme),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Creator and Price
                    Row(
                      children: [
                        if (showCreator) ...[
                          Expanded(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundImage: template.creatorAvatarUrl != null
                                      ? CachedNetworkImageProvider(template.creatorAvatarUrl!)
                                      : null,
                                  child: template.creatorAvatarUrl == null
                                      ? Text(
                                          template.creatorName.isNotEmpty
                                              ? template.creatorName[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(fontSize: 10),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    template.creatorName,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        PriceBadge(
                          priceDisplay: template.priceDisplay,
                          isFree: template.isFree,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          template.templateType == 'workout' ? Icons.fitness_center : Icons.restaurant_menu,
          size: 40,
          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
      ),
    );
  }

  Color _getTypeColor(ColorScheme colorScheme) {
    return template.templateType == 'workout'
        ? colorScheme.primary
        : colorScheme.tertiary;
  }

  String _getTypeLabel() {
    return template.templateType == 'workout' ? 'Treino' : 'Dieta';
  }

  Color _getDifficultyColor(ColorScheme colorScheme) {
    switch (template.difficulty) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return colorScheme.primary;
    }
  }

  String _getDifficultyLabel() {
    switch (template.difficulty) {
      case 'beginner':
        return 'Iniciante';
      case 'intermediate':
        return 'Intermediário';
      case 'advanced':
        return 'Avançado';
      default:
        return template.difficulty;
    }
  }
}

class PriceBadge extends StatelessWidget {
  final String priceDisplay;
  final bool isFree;

  const PriceBadge({
    super.key,
    required this.priceDisplay,
    required this.isFree,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isFree) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Grátis',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.green.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priceDisplay,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
