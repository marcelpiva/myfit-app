import 'package:freezed_annotation/freezed_annotation.dart';

part 'prescription_note.freezed.dart';
part 'prescription_note.g.dart';

/// Context types for prescription notes
enum NoteContextType {
  @JsonValue('plan')
  plan,
  @JsonValue('workout')
  workout,
  @JsonValue('exercise')
  exercise,
  @JsonValue('session')
  session,
}

/// Author role for prescription notes
enum NoteAuthorRole {
  @JsonValue('trainer')
  trainer,
  @JsonValue('student')
  student,
}

/// Extension to get display name for NoteContextType
extension NoteContextTypeDisplay on NoteContextType {
  String get displayName {
    switch (this) {
      case NoteContextType.plan:
        return 'Plano';
      case NoteContextType.workout:
        return 'Treino';
      case NoteContextType.exercise:
        return 'Exercício';
      case NoteContextType.session:
        return 'Sessão';
    }
  }
}

/// Extension to get display name for NoteAuthorRole
extension NoteAuthorRoleDisplay on NoteAuthorRole {
  String get displayName {
    switch (this) {
      case NoteAuthorRole.trainer:
        return 'Personal';
      case NoteAuthorRole.student:
        return 'Aluno';
    }
  }
}

/// Prescription note model for communication between trainers and students
@freezed
sealed class PrescriptionNote with _$PrescriptionNote {
  const PrescriptionNote._();

  const factory PrescriptionNote({
    required String id,
    required NoteContextType contextType,
    required String contextId,
    required String authorId,
    required NoteAuthorRole authorRole,
    String? authorName,
    required String content,
    @Default(false) bool isPinned,
    DateTime? readAt,
    String? readById,
    String? organizationId,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _PrescriptionNote;

  factory PrescriptionNote.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionNoteFromJson(json);

  /// Check if this note has been read
  bool get isRead => readAt != null;

  /// Check if this note is from a trainer
  bool get isFromTrainer => authorRole == NoteAuthorRole.trainer;

  /// Check if this note is from a student
  bool get isFromStudent => authorRole == NoteAuthorRole.student;
}

/// Response model for listing prescription notes
@freezed
sealed class PrescriptionNoteList with _$PrescriptionNoteList {
  const factory PrescriptionNoteList({
    required List<PrescriptionNote> notes,
    required int total,
    @Default(0) int unreadCount,
  }) = _PrescriptionNoteList;

  factory PrescriptionNoteList.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionNoteListFromJson(json);
}

/// Request model for creating a prescription note
@freezed
sealed class PrescriptionNoteCreate with _$PrescriptionNoteCreate {
  const factory PrescriptionNoteCreate({
    required NoteContextType contextType,
    required String contextId,
    required String content,
    @Default(false) bool isPinned,
    String? organizationId,
  }) = _PrescriptionNoteCreate;

  factory PrescriptionNoteCreate.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionNoteCreateFromJson(json);
}

/// Request model for updating a prescription note
@freezed
sealed class PrescriptionNoteUpdate with _$PrescriptionNoteUpdate {
  const factory PrescriptionNoteUpdate({
    String? content,
    bool? isPinned,
  }) = _PrescriptionNoteUpdate;

  factory PrescriptionNoteUpdate.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionNoteUpdateFromJson(json);
}
