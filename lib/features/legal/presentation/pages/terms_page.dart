import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<_TermsSection> _sections = [
    _TermsSection(
      title: '1. Aceitação dos Termos',
      content: '''
Ao acessar ou usar o aplicativo My Fit, você concorda em estar vinculado a estes Termos de Uso. Se você não concordar com qualquer parte destes termos, não poderá acessar o serviço.

Estes termos se aplicam a todos os visitantes, usuários e outras pessoas que acessam ou usam o serviço.
''',
    ),
    _TermsSection(
      title: '2. Descrição do Serviço',
      content: '''
O My Fit é uma plataforma de gestão fitness que oferece:
• Criação e gestão de treinos personalizados
• Acompanhamento de progresso e métricas
• Gestão de alunos para profissionais
• Sistema de cobranças e pagamentos
• Funcionalidades de gamificação
• Chat e comunicação

O serviço pode ser modificado ou descontinuado a qualquer momento, com aviso prévio quando possível.
''',
    ),
    _TermsSection(
      title: '3. Cadastro e Conta',
      content: '''
Para usar o My Fit, você deve:
• Ter pelo menos 18 anos
• Fornecer informações precisas e completas
• Manter suas credenciais seguras
• Notificar-nos sobre uso não autorizado

Você é responsável por todas as atividades em sua conta. Reservamo-nos o direito de suspender contas que violem estes termos.
''',
    ),
    _TermsSection(
      title: '4. Uso Aceitável',
      content: '''
Você concorda em NÃO:
• Violar leis ou regulamentos
• Infringir direitos de terceiros
• Transmitir conteúdo prejudicial ou ilegal
• Tentar acessar sistemas não autorizados
• Usar o serviço para spam ou fraude
• Interferir no funcionamento do serviço
• Revender ou redistribuir o serviço

Violações podem resultar em suspensão ou encerramento da conta.
''',
    ),
    _TermsSection(
      title: '5. Conteúdo do Usuário',
      content: '''
Você mantém a propriedade do conteúdo que envia, mas nos concede licença para:
• Armazenar e processar seu conteúdo
• Exibir para usuários autorizados
• Usar para melhorar o serviço

Você é responsável pelo conteúdo que publica e garante que tem os direitos necessários para compartilhá-lo.
''',
    ),
    _TermsSection(
      title: '6. Pagamentos e Assinaturas',
      content: '''
Para recursos premium:
• Os preços são exibidos claramente antes da compra
• Pagamentos são processados por terceiros seguros
• Renovações automáticas podem ser canceladas
• Reembolsos seguem nossa política específica

Profissionais que usam o sistema de cobranças são responsáveis por suas próprias políticas com clientes.
''',
    ),
    _TermsSection(
      title: '7. Propriedade Intelectual',
      content: '''
O My Fit e seu conteúdo original são protegidos por direitos autorais e outras leis de propriedade intelectual.

Você não pode:
• Copiar ou modificar o aplicativo
• Fazer engenharia reversa
• Usar nossa marca sem permissão
• Remover avisos de direitos autorais
''',
    ),
    _TermsSection(
      title: '8. Limitação de Responsabilidade',
      content: '''
O serviço é fornecido "como está". Não garantimos que:
• O serviço será ininterrupto ou livre de erros
• Os resultados serão precisos ou confiáveis
• O serviço atenderá todas as suas necessidades

Nossa responsabilidade é limitada ao máximo permitido por lei. Não somos responsáveis por treinos ou orientações dadas por profissionais na plataforma.
''',
    ),
    _TermsSection(
      title: '9. Rescisão',
      content: '''
Você pode encerrar sua conta a qualquer momento nas configurações do aplicativo.

Podemos suspender ou encerrar sua conta por:
• Violação destes termos
• Conduta prejudicial
• Solicitação legal
• Inatividade prolongada

Após o encerramento, seu acesso será revogado e seus dados serão tratados conforme nossa Política de Privacidade.
''',
    ),
    _TermsSection(
      title: '10. Alterações nos Termos',
      content: '''
Podemos modificar estes termos periodicamente. Notificaremos sobre mudanças significativas por:
• Email
• Notificação no aplicativo
• Aviso no site

O uso continuado após alterações constitui aceitação dos novos termos.
''',
    ),
    _TermsSection(
      title: '11. Lei Aplicável',
      content: '''
Estes termos são regidos pelas leis do Brasil. Qualquer disputa será resolvida nos tribunais competentes da cidade de São Paulo.

Para questões de consumidor, aplicam-se as proteções do Código de Defesa do Consumidor.
''',
    ),
    _TermsSection(
      title: '12. Contato',
      content: '''
Para dúvidas sobre estes termos:
• Email: suporte@myfit.com
• Através do app: Configurações > Ajuda > Contato
• Site: www.myfit.com/contato
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
                          HapticFeedback.lightImpact();
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
                        'Termos de Uso',
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

  Widget _buildSection(bool isDark, _TermsSection section) {
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
            HapticFeedback.selectionClick();
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

class _TermsSection {
  final String title;
  final String content;

  _TermsSection({required this.title, required this.content});
}
