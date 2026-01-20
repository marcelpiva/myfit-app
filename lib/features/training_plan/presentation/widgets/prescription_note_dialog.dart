import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';

/// Dialog for creating or editing a prescription note
class PrescriptionNoteDialog extends StatefulWidget {
  final String? initialContent;
  final bool initialPinned;
  final bool isEditing;
  final Future<bool> Function(String content, bool isPinned) onSave;

  const PrescriptionNoteDialog({
    super.key,
    this.initialContent,
    this.initialPinned = false,
    this.isEditing = false,
    required this.onSave,
  });

  @override
  State<PrescriptionNoteDialog> createState() => _PrescriptionNoteDialogState();
}

class _PrescriptionNoteDialogState extends State<PrescriptionNoteDialog> {
  late TextEditingController _contentController;
  late bool _isPinned;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.initialContent);
    _isPinned = widget.initialPinned;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Digite o conteúdo da nota'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    HapticUtils.mediumImpact();

    final success = await widget.onSave(content, _isPinned);

    if (mounted) {
      setState(() => _isSaving = false);

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing ? 'Nota atualizada' : 'Nota adicionada'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao salvar nota'),
            backgroundColor: AppColors.destructive,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.isEditing ? LucideIcons.pencil : LucideIcons.messageSquarePlus,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isEditing ? 'Editar Nota' : 'Nova Nota',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Adicione instruções ou observações',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x),
                    iconSize: 20,
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text field
                    TextField(
                      controller: _contentController,
                      maxLines: 6,
                      minLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Digite sua nota aqui...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: isDark ? AppColors.backgroundDark : AppColors.background,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: 16),

                    // Pin toggle
                    InkWell(
                      onTap: () {
                        HapticUtils.selectionClick();
                        setState(() => _isPinned = !_isPinned);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _isPinned
                              ? AppColors.primary.withAlpha(20)
                              : (isDark ? AppColors.backgroundDark : AppColors.background),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isPinned
                                ? AppColors.primary.withAlpha(50)
                                : (isDark ? AppColors.borderDark : AppColors.border),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isPinned ? LucideIcons.pinOff : LucideIcons.pin,
                              size: 18,
                              color: _isPinned
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.mutedForegroundDark
                                      : AppColors.mutedForeground),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isPinned ? 'Nota fixada' : 'Fixar nota',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: _isPinned ? AppColors.primary : null,
                                    ),
                                  ),
                                  Text(
                                    'Notas fixadas aparecem no topo',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppColors.mutedForegroundDark
                                          : AppColors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isPinned,
                              onChanged: (value) {
                                HapticUtils.selectionClick();
                                setState(() => _isPinned = value);
                              },
                              activeColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Divider(
              height: 1,
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSaving ? null : _save,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(widget.isEditing ? 'Salvar' : 'Adicionar'),
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
}
