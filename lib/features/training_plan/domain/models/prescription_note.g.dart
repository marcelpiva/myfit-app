// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prescription_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrescriptionNote _$PrescriptionNoteFromJson(Map<String, dynamic> json) =>
    _PrescriptionNote(
      id: json['id'] as String,
      contextType: $enumDecode(_$NoteContextTypeEnumMap, json['contextType']),
      contextId: json['contextId'] as String,
      authorId: json['authorId'] as String,
      authorRole: $enumDecode(_$NoteAuthorRoleEnumMap, json['authorRole']),
      authorName: json['authorName'] as String?,
      content: json['content'] as String,
      isPinned: json['isPinned'] as bool? ?? false,
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      readById: json['readById'] as String?,
      organizationId: json['organizationId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PrescriptionNoteToJson(_PrescriptionNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contextType': _$NoteContextTypeEnumMap[instance.contextType]!,
      'contextId': instance.contextId,
      'authorId': instance.authorId,
      'authorRole': _$NoteAuthorRoleEnumMap[instance.authorRole]!,
      'authorName': instance.authorName,
      'content': instance.content,
      'isPinned': instance.isPinned,
      'readAt': instance.readAt?.toIso8601String(),
      'readById': instance.readById,
      'organizationId': instance.organizationId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$NoteContextTypeEnumMap = {
  NoteContextType.plan: 'plan',
  NoteContextType.workout: 'workout',
  NoteContextType.exercise: 'exercise',
  NoteContextType.session: 'session',
};

const _$NoteAuthorRoleEnumMap = {
  NoteAuthorRole.trainer: 'trainer',
  NoteAuthorRole.student: 'student',
};

_PrescriptionNoteList _$PrescriptionNoteListFromJson(
  Map<String, dynamic> json,
) => _PrescriptionNoteList(
  notes: (json['notes'] as List<dynamic>)
      .map((e) => PrescriptionNote.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PrescriptionNoteListToJson(
  _PrescriptionNoteList instance,
) => <String, dynamic>{
  'notes': instance.notes,
  'total': instance.total,
  'unreadCount': instance.unreadCount,
};

_PrescriptionNoteCreate _$PrescriptionNoteCreateFromJson(
  Map<String, dynamic> json,
) => _PrescriptionNoteCreate(
  contextType: $enumDecode(_$NoteContextTypeEnumMap, json['contextType']),
  contextId: json['contextId'] as String,
  content: json['content'] as String,
  isPinned: json['isPinned'] as bool? ?? false,
  organizationId: json['organizationId'] as String?,
);

Map<String, dynamic> _$PrescriptionNoteCreateToJson(
  _PrescriptionNoteCreate instance,
) => <String, dynamic>{
  'contextType': _$NoteContextTypeEnumMap[instance.contextType]!,
  'contextId': instance.contextId,
  'content': instance.content,
  'isPinned': instance.isPinned,
  'organizationId': instance.organizationId,
};

_PrescriptionNoteUpdate _$PrescriptionNoteUpdateFromJson(
  Map<String, dynamic> json,
) => _PrescriptionNoteUpdate(
  content: json['content'] as String?,
  isPinned: json['isPinned'] as bool?,
);

Map<String, dynamic> _$PrescriptionNoteUpdateToJson(
  _PrescriptionNoteUpdate instance,
) => <String, dynamic>{
  'content': instance.content,
  'isPinned': instance.isPinned,
};
