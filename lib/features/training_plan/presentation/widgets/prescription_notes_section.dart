import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/models/prescription_note.dart';
import '../providers/prescription_notes_provider.dart';
import 'prescription_note_card.dart';
import 'prescription_note_dialog.dart';

/// Section widget to display prescription notes for a specific context
class PrescriptionNotesSection extends ConsumerWidget {
  final NoteContextType contextType;
  final String contextId;
  final String? organizationId;
  final String currentUserId;
  final bool isTrainer;
  final String title;
  final bool collapsible;
  final bool initiallyExpanded;

  const PrescriptionNotesSection({
    super.key,
    required this.contextType,
    required this.contextId,
    this.organizationId,
    required this.currentUserId,
    this.isTrainer = false,
    this.title = 'Notas',
    this.collapsible = true,
    this.initiallyExpanded = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final notesState = ref.watch(prescriptionNotesProvider((
      contextType: contextType,
      contextId: contextId,
      organizationId: organizationId,
    )));

    final notesNotifier = ref.read(prescriptionNotesProvider((
      contextType: contextType,
      contextId: contextId,
      organizationId: organizationId,
    )).notifier);

    return _NotesContent(
      theme: theme,
      isDark: isDark,
      notesState: notesState,
      notesNotifier: notesNotifier,
      contextType: contextType,
      contextId: contextId,
      organizationId: organizationId,
      currentUserId: currentUserId,
      isTrainer: isTrainer,
      title: title,
      collapsible: collapsible,
      initiallyExpanded: initiallyExpanded,
    );
  }
}

class _NotesContent extends StatefulWidget {
  final ThemeData theme;
  final bool isDark;
  final PrescriptionNotesState notesState;
  final PrescriptionNotesNotifier notesNotifier;
  final NoteContextType contextType;
  final String contextId;
  final String? organizationId;
  final String currentUserId;
  final bool isTrainer;
  final String title;
  final bool collapsible;
  final bool initiallyExpanded;

  const _NotesContent({
    required this.theme,
    required this.isDark,
    required this.notesState,
    required this.notesNotifier,
    required this.contextType,
    required this.contextId,
    this.organizationId,
    required this.currentUserId,
    required this.isTrainer,
    required this.title,
    required this.collapsible,
    required this.initiallyExpanded,
  });

  @override
  State<_NotesContent> createState() => _NotesContentState();
}

class _NotesContentState extends State<_NotesContent> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _showAddNoteDialog() {
    HapticUtils.lightImpact();
    showDialog(
      context: context,
      builder: (context) => PrescriptionNoteDialog(
        onSave: (content, isPinned) async {
          final success = await widget.notesNotifier.createNote(
            content: content,
            isPinned: isPinned,
          );
          return success;
        },
      ),
    );
  }

  void _showEditNoteDialog(PrescriptionNote note) {
    HapticUtils.lightImpact();
    showDialog(
      context: context,
      builder: (context) => PrescriptionNoteDialog(
        initialContent: note.content,
        initialPinned: note.isPinned,
        isEditing: true,
        onSave: (content, isPinned) async {
          final success = await widget.notesNotifier.updateNote(
            noteId: note.id,
            content: content,
            isPinned: isPinned,
          );
          return success;
        },
      ),
    );
  }

  void _confirmDeleteNote(PrescriptionNote note) {
    HapticUtils.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir nota?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.notesNotifier.deleteNote(note.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.destructive,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasNotes = widget.notesState.notes.isNotEmpty;
    final unreadCount = widget.notesState.unreadCount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: widget.collapsible
                ? () {
                    HapticUtils.selectionClick();
                    setState(() => _isExpanded = !_isExpanded);
                  }
                : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.stickyNote,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          widget.title,
                          style: widget.theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (hasNotes) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: widget.isDark
                                  ? AppColors.mutedDark
                                  : AppColors.muted,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${widget.notesState.notes.length}',
                              style: widget.theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                        if (unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$unreadCount nova${unreadCount > 1 ? 's' : ''}',
                              style: widget.theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Add button
                  IconButton(
                    onPressed: _showAddNoteDialog,
                    icon: Icon(
                      LucideIcons.plus,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Adicionar nota',
                  ),

                  // Expand/collapse
                  if (widget.collapsible)
                    Icon(
                      _isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                      size: 20,
                      color: widget.isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                ],
              ),
            ),
          ),

          // Content
          if (_isExpanded) ...[
            Divider(
              height: 1,
              color: widget.isDark ? AppColors.borderDark : AppColors.border,
            ),
            if (widget.notesState.isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (widget.notesState.error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.alertCircle,
                      color: AppColors.destructive,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Erro ao carregar notas',
                      style: widget.theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.destructive,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: widget.notesNotifier.loadNotes,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              )
            else if (!hasNotes)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        LucideIcons.messageSquare,
                        size: 40,
                        color: widget.isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhuma nota ainda',
                        style: widget.theme.textTheme.bodyMedium?.copyWith(
                          color: widget.isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.isTrainer
                            ? 'Adicione instruções ou observações para o aluno'
                            : 'Seu personal pode adicionar orientações aqui',
                        style: widget.theme.textTheme.bodySmall?.copyWith(
                          color: widget.isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: widget.notesState.notes.map((note) {
                    final isAuthor = note.authorId == widget.currentUserId;

                    // Mark as read if from other user
                    if (!isAuthor && !note.isRead) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        widget.notesNotifier.markAsRead(note.id);
                      });
                    }

                    return PrescriptionNoteCard(
                      note: note,
                      isCurrentUserAuthor: isAuthor,
                      onEdit: isAuthor ? () => _showEditNoteDialog(note) : null,
                      onDelete: isAuthor ? () => _confirmDeleteNote(note) : null,
                      onPin: isAuthor
                          ? () => widget.notesNotifier.updateNote(
                                noteId: note.id,
                                isPinned: !note.isPinned,
                              )
                          : null,
                    );
                  }).toList(),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
