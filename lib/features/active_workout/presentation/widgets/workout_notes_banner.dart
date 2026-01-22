import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../training_plan/domain/models/prescription_note.dart';
import '../../../training_plan/presentation/providers/prescription_notes_provider.dart';

/// Banner that shows prescription notes during active workout
class WorkoutNotesBanner extends ConsumerStatefulWidget {
  final String workoutId;
  final String? organizationId;
  final bool isDark;

  const WorkoutNotesBanner({
    super.key,
    required this.workoutId,
    this.organizationId,
    this.isDark = false,
  });

  @override
  ConsumerState<WorkoutNotesBanner> createState() => _WorkoutNotesBannerState();
}

class _WorkoutNotesBannerState extends ConsumerState<WorkoutNotesBanner> {
  bool _isExpanded = false;
  final Set<String> _dismissedNotes = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final notesState = ref.watch(prescriptionNotesProvider((
      contextType: NoteContextType.workout,
      contextId: widget.workoutId,
      organizationId: widget.organizationId,
    )));

    // Filter to show only trainer notes that are pinned or unread
    final relevantNotes = notesState.notes.where((note) {
      if (_dismissedNotes.contains(note.id)) return false;
      if (!note.isFromTrainer) return false;
      return note.isPinned || !note.isRead;
    }).toList();

    if (relevantNotes.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show single note banner or expandable list
    if (relevantNotes.length == 1) {
      return _SingleNoteBanner(
        note: relevantNotes.first,
        onDismiss: () => _dismissNote(relevantNotes.first.id),
        onMarkAsRead: () => _markAsRead(relevantNotes.first.id),
        isDark: widget.isDark,
      );
    }

    return _MultipleNotesBanner(
      notes: relevantNotes,
      isExpanded: _isExpanded,
      onToggleExpand: () {
        HapticUtils.selectionClick();
        setState(() => _isExpanded = !_isExpanded);
      },
      onDismissNote: _dismissNote,
      onMarkAllAsRead: _markAllAsRead,
      isDark: widget.isDark,
    );
  }

  void _dismissNote(String noteId) {
    HapticUtils.lightImpact();
    setState(() => _dismissedNotes.add(noteId));
  }

  void _markAsRead(String noteId) {
    ref.read(prescriptionNotesProvider((
      contextType: NoteContextType.workout,
      contextId: widget.workoutId,
      organizationId: widget.organizationId,
    )).notifier).markAsRead(noteId);
  }

  void _markAllAsRead() {
    final notesState = ref.read(prescriptionNotesProvider((
      contextType: NoteContextType.workout,
      contextId: widget.workoutId,
      organizationId: widget.organizationId,
    )));

    for (final note in notesState.notes) {
      if (!note.isRead && note.isFromTrainer) {
        _markAsRead(note.id);
      }
    }
  }
}

/// Single note banner - compact display
class _SingleNoteBanner extends StatelessWidget {
  final PrescriptionNote note;
  final VoidCallback onDismiss;
  final VoidCallback onMarkAsRead;
  final bool isDark;

  const _SingleNoteBanner({
    required this.note,
    required this.onDismiss,
    required this.onMarkAsRead,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: note.isPinned
            ? AppColors.warning.withAlpha(isDark ? 30 : 20)
            : AppColors.info.withAlpha(isDark ? 30 : 20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: note.isPinned
              ? AppColors.warning.withAlpha(80)
              : AppColors.info.withAlpha(80),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: note.isPinned
                  ? AppColors.warning.withAlpha(40)
                  : AppColors.info.withAlpha(40),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              note.isPinned ? LucideIcons.pin : LucideIcons.messageSquare,
              size: 16,
              color: note.isPinned ? AppColors.warning : AppColors.info,
            ),
          ),

          const SizedBox(width: 10),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      note.isPinned ? 'Nota Fixada' : 'Nota do Personal',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: note.isPinned ? AppColors.warning : AppColors.info,
                      ),
                    ),
                    if (!note.isRead) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Nova',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  note.content,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.foregroundDark
                        : AppColors.foreground,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Dismiss button
          GestureDetector(
            onTap: () {
              onMarkAsRead();
              onDismiss();
            },
            child: Icon(
              LucideIcons.x,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Multiple notes banner - expandable display
class _MultipleNotesBanner extends StatelessWidget {
  final List<PrescriptionNote> notes;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final ValueChanged<String> onDismissNote;
  final VoidCallback onMarkAllAsRead;
  final bool isDark;

  const _MultipleNotesBanner({
    required this.notes,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onDismissNote,
    required this.onMarkAllAsRead,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unreadCount = notes.where((n) => !n.isRead).length;
    final pinnedCount = notes.where((n) => n.isPinned).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.info.withAlpha(isDark ? 30 : 20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withAlpha(80),
        ),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: onToggleExpand,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.info.withAlpha(40),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.stickyNote,
                      size: 16,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${notes.length} Notas do Personal',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (unreadCount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$unreadCount nova${unreadCount > 1 ? 's' : ''}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (pinnedCount > 0)
                          Text(
                            '$pinnedCount fixada${pinnedCount > 1 ? 's' : ''}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.warning,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (isExpanded) ...[
            Divider(
              height: 1,
              color: AppColors.info.withAlpha(50),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  ...notes.map((note) => _NoteItem(
                    note: note,
                    onDismiss: () => onDismissNote(note.id),
                    isDark: isDark,
                  )),
                  if (unreadCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton(
                        onPressed: onMarkAllAsRead,
                        child: const Text('Marcar todas como lidas'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Individual note item in expanded list
class _NoteItem extends StatelessWidget {
  final PrescriptionNote note;
  final VoidCallback onDismiss;
  final bool isDark;

  const _NoteItem({
    required this.note,
    required this.onDismiss,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(100)
            : AppColors.card.withAlpha(150),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (note.isPinned)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                LucideIcons.pin,
                size: 14,
                color: AppColors.warning,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!note.isRead)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Nova',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Text(
                  note.content,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(
              LucideIcons.x,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }
}
