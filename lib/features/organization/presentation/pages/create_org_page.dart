import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../../core/services/organization_service.dart';

enum OrgType { personal, gym, nutritionist, coach }

class CreateOrgPage extends ConsumerStatefulWidget {
  const CreateOrgPage({super.key});

  @override
  ConsumerState<CreateOrgPage> createState() => _CreateOrgPageState();
}

class _CreateOrgPageState extends ConsumerState<CreateOrgPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  int _currentStep = 0;
  OrgType? _selectedType;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isCreating = false;
  File? _selectedLogo;
  final _imagePicker = ImagePicker();

  static const _totalSteps = 4;

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
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    switch (_currentStep) {
      case 0:
        return _selectedType != null;
      case 1:
        return _nameController.text.trim().isNotEmpty;
      case 2:
        return true; // Logo is optional
      case 3:
        return true;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (!_canContinue) return;
    HapticFeedback.lightImpact();
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      _createOrganization();
    }
  }

  void _previousStep() {
    HapticFeedback.lightImpact();
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  Future<void> _createOrganization() async {
    setState(() => _isCreating = true);

    try {
      final orgService = OrganizationService();

      final typeMap = {
        OrgType.personal: 'personal',
        OrgType.gym: 'gym',
        OrgType.nutritionist: 'nutritionist',
        OrgType.coach: 'clinic',  // Backend uses 'clinic' for coach/other
      };

      await orgService.createOrganization(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        type: typeMap[_selectedType],
      );

      ref.invalidate(membershipsProvider);

      if (mounted) {
        setState(() => _isCreating = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Organização criada com sucesso!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.success,
          ),
        );

        // Wait a bit for the invalidation to take effect
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          context.go(RouteNames.orgSelector);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreating = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao criar organização: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    }
  }

  void _showImagePickerOptions(bool isDark) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecionar Logo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildImageOption(
                      isDark,
                      LucideIcons.camera,
                      'Câmera',
                      AppColors.primary,
                      () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildImageOption(
                      isDark,
                      LucideIcons.image,
                      'Galeria',
                      AppColors.secondary,
                      () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageOption(
    bool isDark,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.mutedDark.withAlpha(150)
              : AppColors.muted.withAlpha(200),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedLogo = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
          icon: Icon(
            LucideIcons.x,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        title: Text(
          'Nova Organização',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(isDark),

            // Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildStepContent(isDark),
              ),
            ),

            // Navigation
            _buildNavigation(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 8 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? AppColors.primary
                        : (isDark ? AppColors.mutedDark : AppColors.muted),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            _getStepTitle(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Passo 1 de $_totalSteps · Tipo';
      case 1:
        return 'Passo 2 de $_totalSteps · Informações';
      case 2:
        return 'Passo 3 de $_totalSteps · Logo';
      case 3:
        return 'Passo 4 de $_totalSteps · Confirmação';
      default:
        return '';
    }
  }

  Widget _buildStepContent(bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildStepType(isDark);
      case 1:
        return _buildStepInfo(isDark);
      case 2:
        return _buildStepLogo(isDark);
      case 3:
        return _buildStepConfirm(isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStepType(bool isDark) {
    final types = [
      (OrgType.personal, 'Personal Trainer', 'Atendimento individual', LucideIcons.user),
      (OrgType.gym, 'Academia', 'Espaço físico com equipamentos', LucideIcons.building2),
      (OrgType.nutritionist, 'Nutricionista', 'Acompanhamento nutricional', LucideIcons.apple),
      (OrgType.coach, 'Coach', 'Mentoria e desenvolvimento', LucideIcons.trophy),
    ];

    return SingleChildScrollView(
      key: const ValueKey('step-type'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Qual tipo de organização?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecione o tipo que melhor descreve seu negócio',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 32),
          ...types.map((type) {
            final (orgType, title, subtitle, icon) = type;
            final isSelected = _selectedType == orgType;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedType = orgType);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withAlpha(15)
                        : (isDark ? AppColors.cardDark : AppColors.card),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.borderDark : AppColors.border),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withAlpha(25)
                              : (isDark ? AppColors.mutedDark : AppColors.muted),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          size: 24,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(LucideIcons.checkCircle2, size: 24, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStepInfo(bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey('step-info'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações básicas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Como sua organização será identificada',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 32),

          // Name field
          Text(
            'Nome *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _nameController.text.isNotEmpty
                    ? AppColors.primary.withAlpha(100)
                    : (isDark ? AppColors.borderDark : AppColors.border),
              ),
            ),
            child: TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
              decoration: InputDecoration(
                hintText: 'Ex: Academia FitPro',
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground).withAlpha(150),
                ),
                prefixIcon: Icon(
                  LucideIcons.building2,
                  size: 20,
                  color: _nameController.text.isNotEmpty
                      ? AppColors.primary
                      : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                ),
                suffixIcon: _nameController.text.isNotEmpty
                    ? Icon(LucideIcons.checkCircle2, size: 20, color: AppColors.success)
                    : null,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Description field
          Row(
            children: [
              Text(
                'Descrição',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.mutedDark : AppColors.muted,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Opcional',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            child: TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
              decoration: InputDecoration(
                hintText: 'Descreva brevemente sua organização...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground).withAlpha(150),
                ),
                filled: false,
                contentPadding: const EdgeInsets.all(16),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLogo(bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey('step-logo'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adicionar logo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Personalize sua organização com um logo',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 32),

          if (_selectedLogo != null) ...[
            // Logo selected
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary, width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.file(_selectedLogo!, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () => _showImagePickerOptions(isDark),
                        icon: Icon(LucideIcons.refreshCw, size: 16, color: AppColors.primary),
                        label: Text(
                          'Alterar',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => setState(() => _selectedLogo = null),
                        icon: Icon(LucideIcons.trash2, size: 16, color: AppColors.destructive),
                        label: Text(
                          'Remover',
                          style: TextStyle(color: AppColors.destructive),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            // No logo selected
            GestureDetector(
              onTap: () => _showImagePickerOptions(isDark),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 48),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        LucideIcons.imagePlus,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Toque para adicionar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Câmera ou galeria',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: _nextStep,
                child: Text(
                  'Pular esta etapa',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepConfirm(bool isDark) {
    final typeNames = {
      OrgType.personal: 'Personal Trainer',
      OrgType.gym: 'Academia',
      OrgType.nutritionist: 'Nutricionista',
      OrgType.coach: 'Coach',
    };

    final typeIcons = {
      OrgType.personal: LucideIcons.user,
      OrgType.gym: LucideIcons.building2,
      OrgType.nutritionist: LucideIcons.apple,
      OrgType.coach: LucideIcons.trophy,
    };

    return SingleChildScrollView(
      key: const ValueKey('step-confirm'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirmar dados',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Revise as informações antes de criar',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 32),

          // Preview card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            child: Column(
              children: [
                // Logo or placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _selectedLogo != null
                        ? null
                        : AppColors.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withAlpha(50),
                      width: 2,
                    ),
                  ),
                  child: _selectedLogo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(_selectedLogo!, fit: BoxFit.cover),
                        )
                      : Icon(
                          typeIcons[_selectedType],
                          size: 36,
                          color: AppColors.primary,
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  _nameController.text,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    typeNames[_selectedType] ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (_descriptionController.text.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    _descriptionController.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Edit buttons
          Row(
            children: [
              Expanded(
                child: _buildEditButton(
                  isDark,
                  'Tipo',
                  typeNames[_selectedType] ?? '',
                  () => setState(() => _currentStep = 0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEditButton(
                  isDark,
                  'Info',
                  _nameController.text,
                  () => setState(() => _currentStep = 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton(bool isDark, String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.mutedDark.withAlpha(100) : AppColors.muted.withAlpha(100),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.pencil,
              size: 14,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigation(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Back button
            TextButton(
              onPressed: _previousStep,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.chevronLeft,
                    size: 18,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _currentStep == 0 ? 'Cancelar' : 'Voltar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Continue button
            ElevatedButton(
              onPressed: _canContinue && !_isCreating ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: isDark ? AppColors.mutedDark : AppColors.muted,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isCreating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentStep == _totalSteps - 1 ? 'Criar' : 'Continuar',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _currentStep == _totalSteps - 1 ? LucideIcons.check : LucideIcons.chevronRight,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
