import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<_PrivacySection> _sections = [
    _PrivacySection(
      title: '1. Coleta de Dados',
      content: '''
Coletamos informações que você nos fornece diretamente, como:
• Nome e informações de contato
• Dados de perfil e preferências
• Informações de treino e progresso
• Dados de pagamento (processados de forma segura)

Também coletamos automaticamente:
• Dados de uso do aplicativo
• Informações do dispositivo
• Dados de localização (quando autorizado)
''',
    ),
    _PrivacySection(
      title: '2. Uso dos Dados',
      content: '''
Utilizamos suas informações para:
• Fornecer e personalizar nossos serviços
• Processar pagamentos e transações
• Enviar comunicações relevantes
• Melhorar a experiência do usuário
• Garantir segurança e prevenir fraudes
• Cumprir obrigações legais
''',
    ),
    _PrivacySection(
      title: '3. Compartilhamento',
      content: '''
Seus dados podem ser compartilhados com:
• Seu personal trainer ou academia (conforme sua escolha)
• Processadores de pagamento
• Prestadores de serviços essenciais
• Autoridades quando exigido por lei

Nunca vendemos seus dados pessoais a terceiros.
''',
    ),
    _PrivacySection(
      title: '4. Segurança',
      content: '''
Implementamos medidas de segurança incluindo:
• Criptografia de dados em trânsito e repouso
• Controles de acesso rigorosos
• Monitoramento contínuo de segurança
• Auditorias regulares de segurança
''',
    ),
    _PrivacySection(
      title: '5. Seus Direitos',
      content: '''
Você tem direito a:
• Acessar seus dados pessoais
• Corrigir informações incorretas
• Solicitar exclusão de dados
• Exportar seus dados
• Revogar consentimentos

Para exercer esses direitos, acesse Configurações > Dados ou entre em contato conosco.
''',
    ),
    _PrivacySection(
      title: '6. Cookies e Rastreamento',
      content: '''
Utilizamos cookies e tecnologias similares para:
• Manter você conectado
• Lembrar suas preferências
• Analisar uso do aplicativo
• Personalizar conteúdo

Você pode gerenciar preferências de cookies nas configurações.
''',
    ),
    _PrivacySection(
      title: '7. Retenção de Dados',
      content: '''
Mantemos seus dados enquanto sua conta estiver ativa ou conforme necessário para:
• Fornecer nossos serviços
• Cumprir obrigações legais
• Resolver disputas
• Fazer cumprir acordos

Após exclusão da conta, dados são removidos em até 30 dias, exceto quando a lei exigir retenção.
''',
    ),
    _PrivacySection(
      title: '8. Contato',
      content: '''
Para dúvidas sobre privacidade:
• Email: privacidade@myfit.com
• Através do app: Configurações > Ajuda > Contato
• Encarregado de Dados (DPO): dpo@myfit.com
''',
    ),
  ];

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
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
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.border,
                            ),
                          ),
                          child: Icon(
                            LucideIcons.arrowLeft,
                            size: 20,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Política de Privacidade',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),

                // Last updated
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        size: 14,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Última atualização: 01 de Janeiro de 2026',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Content
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _sections.length,
                    itemBuilder: (context, index) {
                      return _buildSection(isDark, _sections[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(bool isDark, _PrivacySection section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            section.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          initiallyExpanded: false,
          onExpansionChanged: (_) {
            HapticUtils.selectionClick();
          },
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                section.content.trim(),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacySection {
  final String title;
  final String content;

  _PrivacySection({required this.title, required this.content});
}
