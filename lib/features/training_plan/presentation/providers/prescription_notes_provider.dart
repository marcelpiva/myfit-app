import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/services/workout_service.dart';
import '../../domain/models/prescription_note.dart';

part 'prescription_notes_provider.freezed.dart';

/// State for prescription notes
@freezed
sealed class PrescriptionNotesState with _$PrescriptionNotesState {
  const factory PrescriptionNotesState({
    @Default([]) List<PrescriptionNote> notes,
    @Default(0) int unreadCount,
    @Default(false) bool isLoading,
    @Default(false) bool isCreating,
    String? error,
  }) = _PrescriptionNotesState;
}

/// Provider for prescription notes by context
class PrescriptionNotesNotifier extends StateNotifier<PrescriptionNotesState> {
  final WorkoutService _workoutService;
  final NoteContextType contextType;
  final String contextId;
  final String? organizationId;

  PrescriptionNotesNotifier({
    required WorkoutService workoutService,
    required this.contextType,
    required this.contextId,
    this.organizationId,
  })  : _workoutService = workoutService,
        super(const PrescriptionNotesState()) {
    loadNotes();
  }

  /// Load notes from API
  Future<void> loadNotes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _workoutService.getPrescriptionNotes(
        contextType: contextType.name,
        contextId: contextId,
        organizationId: organizationId,
      );

      final notesJson = response['notes'] as List<dynamic>? ?? [];
      final notes = notesJson
          .map((json) => PrescriptionNote.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        notes: notes,
        unreadCount: response['unread_count'] as int? ?? 0,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Create a new note
  Future<bool> createNote({
    required String content,
    bool isPinned = false,
  }) async {
    state = state.copyWith(isCreating: true, error: null);

    try {
      final response = await _workoutService.createPrescriptionNote(
        contextType: contextType.name,
        contextId: contextId,
        content: content,
        isPinned: isPinned,
        organizationId: organizationId,
      );

      final newNote = PrescriptionNote.fromJson(response);

      // Add to beginning of list (most recent first)
      state = state.copyWith(
        notes: [newNote, ...state.notes],
        isCreating: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Update a note
  Future<bool> updateNote({
    required String noteId,
    String? content,
    bool? isPinned,
  }) async {
    try {
      final response = await _workoutService.updatePrescriptionNote(
        noteId,
        content: content,
        isPinned: isPinned,
      );

      final updatedNote = PrescriptionNote.fromJson(response);

      // Update in list
      final updatedNotes = state.notes.map((note) {
        if (note.id == noteId) {
          return updatedNote;
        }
        return note;
      }).toList();

      // Re-sort to put pinned notes first
      updatedNotes.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

      state = state.copyWith(notes: updatedNotes);

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Mark a note as read
  Future<void> markAsRead(String noteId) async {
    try {
      await _workoutService.markPrescriptionNoteAsRead(noteId);

      // Update in list
      final updatedNotes = state.notes.map((note) {
        if (note.id == noteId && !note.isRead) {
          return PrescriptionNote(
            id: note.id,
            contextType: note.contextType,
            contextId: note.contextId,
            authorId: note.authorId,
            authorRole: note.authorRole,
            authorName: note.authorName,
            content: note.content,
            isPinned: note.isPinned,
            readAt: DateTime.now(),
            readById: note.readById,
            organizationId: note.organizationId,
            createdAt: note.createdAt,
            updatedAt: note.updatedAt,
          );
        }
        return note;
      }).toList();

      state = state.copyWith(
        notes: updatedNotes,
        unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
      );
    } catch (e) {
      // Silent fail for read marking
    }
  }

  /// Delete a note
  Future<bool> deleteNote(String noteId) async {
    try {
      await _workoutService.deletePrescriptionNote(noteId);

      // Remove from list
      final updatedNotes = state.notes.where((note) => note.id != noteId).toList();

      state = state.copyWith(notes: updatedNotes);

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

/// Provider family for prescription notes by context
final prescriptionNotesProvider = StateNotifierProvider.autoDispose
    .family<PrescriptionNotesNotifier, PrescriptionNotesState, ({NoteContextType contextType, String contextId, String? organizationId})>(
  (ref, params) => PrescriptionNotesNotifier(
    workoutService: WorkoutService(),
    contextType: params.contextType,
    contextId: params.contextId,
    organizationId: params.organizationId,
  ),
);
