import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/marketplace_provider.dart';

class MyPurchasesPage extends ConsumerWidget {
  const MyPurchasesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesState = ref.watch(purchasesNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Compras'),
      ),
      body: purchasesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : purchasesState.error != null
              ? _buildErrorState(context, ref, purchasesState.error!, colorScheme)
              : purchasesState.purchases.isEmpty
                  ? _buildEmptyState(context, colorScheme)
                  : _buildPurchasesList(context, purchasesState.purchases, colorScheme),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => ref.read(purchasesNotifierProvider.notifier).refresh(),
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma compra ainda',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore o marketplace para encontrar planos de treino e dietas.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Explorar Marketplace'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchasesList(BuildContext context, List<TemplatePurchase> purchases, ColorScheme colorScheme) {
    // Group by status
    final completed = purchases.where((p) => p.isCompleted).toList();
    final pending = purchases.where((p) => !p.isCompleted).toList();

    return RefreshIndicator(
      onRefresh: () async {
        // Will be handled by the provider
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (pending.isNotEmpty) ...[
            _buildSectionHeader(context, 'Pendentes', colorScheme),
            ...pending.map((purchase) => _buildPurchaseCard(context, purchase, colorScheme)),
            const SizedBox(height: 24),
          ],
          if (completed.isNotEmpty) ...[
            _buildSectionHeader(context, 'Concluídas', colorScheme),
            ...completed.map((purchase) => _buildPurchaseCard(context, purchase, colorScheme)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildPurchaseCard(BuildContext context, TemplatePurchase purchase, ColorScheme colorScheme) {
    final isWorkout = purchase.templateType == 'workout';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _handlePurchaseTap(context, purchase),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Type Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isWorkout ? colorScheme.primary : colorScheme.tertiary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isWorkout ? Icons.fitness_center : Icons.restaurant_menu,
                  color: isWorkout ? colorScheme.primary : colorScheme.tertiary,
                ),
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      purchase.templateTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStatusBadge(context, purchase.status, colorScheme),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(purchase.createdAt),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    purchase.priceCents == 0
                        ? 'Grátis'
                        : 'R\$ ${(purchase.priceCents / 100).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: purchase.priceCents == 0 ? Colors.green : colorScheme.primary,
                    ),
                  ),
                  if (purchase.isCompleted)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status, ColorScheme colorScheme) {
    Color color;
    String label;

    switch (status) {
      case 'completed':
        color = Colors.green;
        label = 'Concluída';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'Pendente';
        break;
      case 'failed':
        color = Colors.red;
        label = 'Falhou';
        break;
      case 'refunded':
        color = Colors.grey;
        label = 'Reembolsado';
        break;
      default:
        color = colorScheme.primary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _handlePurchaseTap(BuildContext context, TemplatePurchase purchase) {
    if (!purchase.isCompleted) {
      // Show pending message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aguardando confirmação do pagamento'),
        ),
      );
      return;
    }

    // Navigate to the workout or diet plan
    if (purchase.templateType == 'workout' && purchase.duplicatedWorkoutId != null) {
      // TODO: Navigate to workout detail
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Abrindo treino...')),
      );
    } else if (purchase.templateType == 'diet_plan' && purchase.duplicatedDietPlanId != null) {
      // TODO: Navigate to diet plan detail
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Abrindo plano alimentar...')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
