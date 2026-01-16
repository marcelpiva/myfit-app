import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/error/api_exceptions.dart';
import '../../../../core/services/marketplace_service.dart';
import '../providers/marketplace_provider.dart';

class TemplateCheckoutPage extends ConsumerStatefulWidget {
  final MarketplaceTemplate template;

  const TemplateCheckoutPage({
    super.key,
    required this.template,
  });

  @override
  ConsumerState<TemplateCheckoutPage> createState() => _TemplateCheckoutPageState();
}

class _TemplateCheckoutPageState extends ConsumerState<TemplateCheckoutPage> {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _checkoutData;
  Timer? _statusTimer;
  String _paymentStatus = 'pending';

  @override
  void initState() {
    super.initState();
    if (widget.template.isFree) {
      _processFreeTemplate();
    } else {
      _initiateCheckout();
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _processFreeTemplate() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ref.read(marketplaceServiceProvider);
      final result = await service.checkout(widget.template.id, paymentProvider: 'free');

      setState(() {
        _isLoading = false;
        _paymentStatus = 'completed';
        _checkoutData = result;
      });

      // Refresh purchases
      ref.read(purchasesNotifierProvider.notifier).refresh();

      // Show success and navigate
      if (mounted) {
        _showSuccessDialog();
      }
    } on ApiException catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Erro ao processar. Tente novamente.';
      });
    }
  }

  Future<void> _initiateCheckout() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ref.read(marketplaceServiceProvider);
      final result = await service.checkout(widget.template.id, paymentProvider: 'pix');

      setState(() {
        _isLoading = false;
        _checkoutData = result;
      });

      // Start polling for payment status
      _startStatusPolling(result['purchase_id'] ?? '');
    } on ApiException catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Erro ao iniciar pagamento. Tente novamente.';
      });
    }
  }

  void _startStatusPolling(String purchaseId) {
    if (purchaseId.isEmpty) return;

    _statusTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final service = ref.read(marketplaceServiceProvider);
        final status = await service.getPurchaseStatus(purchaseId);
        final newStatus = status['status'] ?? 'pending';

        if (newStatus != _paymentStatus) {
          setState(() => _paymentStatus = newStatus);

          if (newStatus == 'completed') {
            _statusTimer?.cancel();
            ref.read(purchasesNotifierProvider.notifier).refresh();
            if (mounted) {
              _showSuccessDialog();
            }
          } else if (newStatus == 'failed') {
            _statusTimer?.cancel();
            if (mounted) {
              _showErrorDialog('Pagamento falhou. Tente novamente.');
            }
          }
        }
      } catch (_) {
        // Ignore polling errors
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Compra Realizada!'),
        content: Text(
          widget.template.templateType == 'workout'
              ? 'O treino foi adicionado à sua lista de treinos.'
              : 'O plano alimentar foi adicionado à sua lista.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Ver Meus Planos'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error, color: Colors.red, size: 48),
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState(colorScheme)
              : widget.template.isFree
                  ? _buildProcessingFree(colorScheme)
                  : _buildPixPayment(colorScheme),
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme) {
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
              _error!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: widget.template.isFree ? _processFreeTemplate : _initiateCheckout,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingFree(ColorScheme colorScheme) {
    if (_paymentStatus == 'completed') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Template adicionado com sucesso!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Processando...'),
        ],
      ),
    );
  }

  Widget _buildPixPayment(ColorScheme colorScheme) {
    final pixCode = _checkoutData?['pix_code'] ?? '';
    final pixQrData = _checkoutData?['pix_qr_data'] ?? pixCode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Order Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumo do Pedido',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.template.title,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        widget.template.priceDisplay,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.template.priceDisplay,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Payment Status
          _buildPaymentStatus(colorScheme),

          const SizedBox(height: 24),

          // QR Code
          if (pixQrData.isNotEmpty && _paymentStatus == 'pending') ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: pixQrData,
                version: QrVersions.auto,
                size: 200,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Escaneie o QR Code com o app do seu banco',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Pix Copy Paste
            if (pixCode.isNotEmpty) ...[
              Text(
                'Ou copie o código PIX:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        pixCode.length > 50 ? '${pixCode.substring(0, 50)}...' : pixCode,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: pixCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Código PIX copiado!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],

          const SizedBox(height: 24),

          // Instructions
          Card(
            color: colorScheme.primaryContainer.withOpacity(0.5),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Como pagar',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInstruction('1', 'Abra o app do seu banco'),
                  _buildInstruction('2', 'Escolha pagar com PIX'),
                  _buildInstruction('3', 'Escaneie o QR Code ou cole o código'),
                  _buildInstruction('4', 'Confirme o pagamento'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatus(ColorScheme colorScheme) {
    IconData icon;
    Color color;
    String text;

    switch (_paymentStatus) {
      case 'completed':
        icon = Icons.check_circle;
        color = Colors.green;
        text = 'Pagamento confirmado!';
        break;
      case 'failed':
        icon = Icons.error;
        color = Colors.red;
        text = 'Pagamento falhou';
        break;
      default:
        icon = Icons.schedule;
        color = Colors.orange;
        text = 'Aguardando pagamento...';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_paymentStatus == 'pending')
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            )
          else
            Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }
}
