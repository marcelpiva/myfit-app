// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prescription_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrescriptionNote {

 String get id; NoteContextType get contextType; String get contextId; String get authorId; NoteAuthorRole get authorRole; String? get authorName; String get content; bool get isPinned; DateTime? get readAt; String? get readById; String? get organizationId; DateTime get createdAt; DateTime? get updatedAt;
/// Create a copy of PrescriptionNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrescriptionNoteCopyWith<PrescriptionNote> get copyWith => _$PrescriptionNoteCopyWithImpl<PrescriptionNote>(this as PrescriptionNote, _$identity);

  /// Serializes this PrescriptionNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrescriptionNote&&(identical(other.id, id) || other.id == id)&&(identical(other.contextType, contextType) || other.contextType == contextType)&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorRole, authorRole) || other.authorRole == authorRole)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.content, content) || other.content == content)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.readById, readById) || other.readById == readById)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,contextType,contextId,authorId,authorRole,authorName,content,isPinned,readAt,readById,organizationId,createdAt,updatedAt);

@override
String toString() {
  return 'PrescriptionNote(id: $id, contextType: $contextType, contextId: $contextId, authorId: $authorId, authorRole: $authorRole, authorName: $authorName, content: $content, isPinned: $isPinned, readAt: $readAt, readById: $readById, organizationId: $organizationId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PrescriptionNoteCopyWith<$Res>  {
  factory $PrescriptionNoteCopyWith(PrescriptionNote value, $Res Function(PrescriptionNote) _then) = _$PrescriptionNoteCopyWithImpl;
@useResult
$Res call({
 String id, NoteContextType contextType, String contextId, String authorId, NoteAuthorRole authorRole, String? authorName, String content, bool isPinned, DateTime? readAt, String? readById, String? organizationId, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$PrescriptionNoteCopyWithImpl<$Res>
    implements $PrescriptionNoteCopyWith<$Res> {
  _$PrescriptionNoteCopyWithImpl(this._self, this._then);

  final PrescriptionNote _self;
  final $Res Function(PrescriptionNote) _then;

/// Create a copy of PrescriptionNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? contextType = null,Object? contextId = null,Object? authorId = null,Object? authorRole = null,Object? authorName = freezed,Object? content = null,Object? isPinned = null,Object? readAt = freezed,Object? readById = freezed,Object? organizationId = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,contextType: null == contextType ? _self.contextType : contextType // ignore: cast_nullable_to_non_nullable
as NoteContextType,contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,authorRole: null == authorRole ? _self.authorRole : authorRole // ignore: cast_nullable_to_non_nullable
as NoteAuthorRole,authorName: freezed == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,readById: freezed == readById ? _self.readById : readById // ignore: cast_nullable_to_non_nullable
as String?,organizationId: freezed == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PrescriptionNote].
extension PrescriptionNotePatterns on PrescriptionNote {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrescriptionNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrescriptionNote() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrescriptionNote value)  $default,){
final _that = this;
switch (_that) {
case _PrescriptionNote():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrescriptionNote value)?  $default,){
final _that = this;
switch (_that) {
case _PrescriptionNote() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  NoteContextType contextType,  String contextId,  String authorId,  NoteAuthorRole authorRole,  String? authorName,  String content,  bool isPinned,  DateTime? readAt,  String? readById,  String? organizationId,  DateTime createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrescriptionNote() when $default != null:
return $default(_that.id,_that.contextType,_that.contextId,_that.authorId,_that.authorRole,_that.authorName,_that.content,_that.isPinned,_that.readAt,_that.readById,_that.organizationId,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  NoteContextType contextType,  String contextId,  String authorId,  NoteAuthorRole authorRole,  String? authorName,  String content,  bool isPinned,  DateTime? readAt,  String? readById,  String? organizationId,  DateTime createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PrescriptionNote():
return $default(_that.id,_that.contextType,_that.contextId,_that.authorId,_that.authorRole,_that.authorName,_that.content,_that.isPinned,_that.readAt,_that.readById,_that.organizationId,_that.createdAt,_that.updatedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  NoteContextType contextType,  String contextId,  String authorId,  NoteAuthorRole authorRole,  String? authorName,  String content,  bool isPinned,  DateTime? readAt,  String? readById,  String? organizationId,  DateTime createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PrescriptionNote() when $default != null:
return $default(_that.id,_that.contextType,_that.contextId,_that.authorId,_that.authorRole,_that.authorName,_that.content,_that.isPinned,_that.readAt,_that.readById,_that.organizationId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrescriptionNote extends PrescriptionNote {
  const _PrescriptionNote({required this.id, required this.contextType, required this.contextId, required this.authorId, required this.authorRole, this.authorName, required this.content, this.isPinned = false, this.readAt, this.readById, this.organizationId, required this.createdAt, this.updatedAt}): super._();
  factory _PrescriptionNote.fromJson(Map<String, dynamic> json) => _$PrescriptionNoteFromJson(json);

@override final  String id;
@override final  NoteContextType contextType;
@override final  String contextId;
@override final  String authorId;
@override final  NoteAuthorRole authorRole;
@override final  String? authorName;
@override final  String content;
@override@JsonKey() final  bool isPinned;
@override final  DateTime? readAt;
@override final  String? readById;
@override final  String? organizationId;
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of PrescriptionNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrescriptionNoteCopyWith<_PrescriptionNote> get copyWith => __$PrescriptionNoteCopyWithImpl<_PrescriptionNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrescriptionNoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrescriptionNote&&(identical(other.id, id) || other.id == id)&&(identical(other.contextType, contextType) || other.contextType == contextType)&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorRole, authorRole) || other.authorRole == authorRole)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.content, content) || other.content == content)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.readById, readById) || other.readById == readById)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,contextType,contextId,authorId,authorRole,authorName,content,isPinned,readAt,readById,organizationId,createdAt,updatedAt);

@override
String toString() {
  return 'PrescriptionNote(id: $id, contextType: $contextType, contextId: $contextId, authorId: $authorId, authorRole: $authorRole, authorName: $authorName, content: $content, isPinned: $isPinned, readAt: $readAt, readById: $readById, organizationId: $organizationId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PrescriptionNoteCopyWith<$Res> implements $PrescriptionNoteCopyWith<$Res> {
  factory _$PrescriptionNoteCopyWith(_PrescriptionNote value, $Res Function(_PrescriptionNote) _then) = __$PrescriptionNoteCopyWithImpl;
@override @useResult
$Res call({
 String id, NoteContextType contextType, String contextId, String authorId, NoteAuthorRole authorRole, String? authorName, String content, bool isPinned, DateTime? readAt, String? readById, String? organizationId, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$PrescriptionNoteCopyWithImpl<$Res>
    implements _$PrescriptionNoteCopyWith<$Res> {
  __$PrescriptionNoteCopyWithImpl(this._self, this._then);

  final _PrescriptionNote _self;
  final $Res Function(_PrescriptionNote) _then;

/// Create a copy of PrescriptionNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? contextType = null,Object? contextId = null,Object? authorId = null,Object? authorRole = null,Object? authorName = freezed,Object? content = null,Object? isPinned = null,Object? readAt = freezed,Object? readById = freezed,Object? organizationId = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_PrescriptionNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,contextType: null == contextType ? _self.contextType : contextType // ignore: cast_nullable_to_non_nullable
as NoteContextType,contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,authorRole: null == authorRole ? _self.authorRole : authorRole // ignore: cast_nullable_to_non_nullable
as NoteAuthorRole,authorName: freezed == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,readById: freezed == readById ? _self.readById : readById // ignore: cast_nullable_to_non_nullable
as String?,organizationId: freezed == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$PrescriptionNoteList {

 List<PrescriptionNote> get notes; int get total; int get unreadCount;
/// Create a copy of PrescriptionNoteList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrescriptionNoteListCopyWith<PrescriptionNoteList> get copyWith => _$PrescriptionNoteListCopyWithImpl<PrescriptionNoteList>(this as PrescriptionNoteList, _$identity);

  /// Serializes this PrescriptionNoteList to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrescriptionNoteList&&const DeepCollectionEquality().equals(other.notes, notes)&&(identical(other.total, total) || other.total == total)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(notes),total,unreadCount);

@override
String toString() {
  return 'PrescriptionNoteList(notes: $notes, total: $total, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class $PrescriptionNoteListCopyWith<$Res>  {
  factory $PrescriptionNoteListCopyWith(PrescriptionNoteList value, $Res Function(PrescriptionNoteList) _then) = _$PrescriptionNoteListCopyWithImpl;
@useResult
$Res call({
 List<PrescriptionNote> notes, int total, int unreadCount
});




}
/// @nodoc
class _$PrescriptionNoteListCopyWithImpl<$Res>
    implements $PrescriptionNoteListCopyWith<$Res> {
  _$PrescriptionNoteListCopyWithImpl(this._self, this._then);

  final PrescriptionNoteList _self;
  final $Res Function(PrescriptionNoteList) _then;

/// Create a copy of PrescriptionNoteList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? notes = null,Object? total = null,Object? unreadCount = null,}) {
  return _then(_self.copyWith(
notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as List<PrescriptionNote>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PrescriptionNoteList].
extension PrescriptionNoteListPatterns on PrescriptionNoteList {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrescriptionNoteList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrescriptionNoteList() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrescriptionNoteList value)  $default,){
final _that = this;
switch (_that) {
case _PrescriptionNoteList():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrescriptionNoteList value)?  $default,){
final _that = this;
switch (_that) {
case _PrescriptionNoteList() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PrescriptionNote> notes,  int total,  int unreadCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrescriptionNoteList() when $default != null:
return $default(_that.notes,_that.total,_that.unreadCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PrescriptionNote> notes,  int total,  int unreadCount)  $default,) {final _that = this;
switch (_that) {
case _PrescriptionNoteList():
return $default(_that.notes,_that.total,_that.unreadCount);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PrescriptionNote> notes,  int total,  int unreadCount)?  $default,) {final _that = this;
switch (_that) {
case _PrescriptionNoteList() when $default != null:
return $default(_that.notes,_that.total,_that.unreadCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrescriptionNoteList implements PrescriptionNoteList {
  const _PrescriptionNoteList({required final  List<PrescriptionNote> notes, required this.total, this.unreadCount = 0}): _notes = notes;
  factory _PrescriptionNoteList.fromJson(Map<String, dynamic> json) => _$PrescriptionNoteListFromJson(json);

 final  List<PrescriptionNote> _notes;
@override List<PrescriptionNote> get notes {
  if (_notes is EqualUnmodifiableListView) return _notes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notes);
}

@override final  int total;
@override@JsonKey() final  int unreadCount;

/// Create a copy of PrescriptionNoteList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrescriptionNoteListCopyWith<_PrescriptionNoteList> get copyWith => __$PrescriptionNoteListCopyWithImpl<_PrescriptionNoteList>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrescriptionNoteListToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrescriptionNoteList&&const DeepCollectionEquality().equals(other._notes, _notes)&&(identical(other.total, total) || other.total == total)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_notes),total,unreadCount);

@override
String toString() {
  return 'PrescriptionNoteList(notes: $notes, total: $total, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class _$PrescriptionNoteListCopyWith<$Res> implements $PrescriptionNoteListCopyWith<$Res> {
  factory _$PrescriptionNoteListCopyWith(_PrescriptionNoteList value, $Res Function(_PrescriptionNoteList) _then) = __$PrescriptionNoteListCopyWithImpl;
@override @useResult
$Res call({
 List<PrescriptionNote> notes, int total, int unreadCount
});




}
/// @nodoc
class __$PrescriptionNoteListCopyWithImpl<$Res>
    implements _$PrescriptionNoteListCopyWith<$Res> {
  __$PrescriptionNoteListCopyWithImpl(this._self, this._then);

  final _PrescriptionNoteList _self;
  final $Res Function(_PrescriptionNoteList) _then;

/// Create a copy of PrescriptionNoteList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? notes = null,Object? total = null,Object? unreadCount = null,}) {
  return _then(_PrescriptionNoteList(
notes: null == notes ? _self._notes : notes // ignore: cast_nullable_to_non_nullable
as List<PrescriptionNote>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PrescriptionNoteCreate {

 NoteContextType get contextType; String get contextId; String get content; bool get isPinned; String? get organizationId;
/// Create a copy of PrescriptionNoteCreate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrescriptionNoteCreateCopyWith<PrescriptionNoteCreate> get copyWith => _$PrescriptionNoteCreateCopyWithImpl<PrescriptionNoteCreate>(this as PrescriptionNoteCreate, _$identity);

  /// Serializes this PrescriptionNoteCreate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrescriptionNoteCreate&&(identical(other.contextType, contextType) || other.contextType == contextType)&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.content, content) || other.content == content)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contextType,contextId,content,isPinned,organizationId);

@override
String toString() {
  return 'PrescriptionNoteCreate(contextType: $contextType, contextId: $contextId, content: $content, isPinned: $isPinned, organizationId: $organizationId)';
}


}

/// @nodoc
abstract mixin class $PrescriptionNoteCreateCopyWith<$Res>  {
  factory $PrescriptionNoteCreateCopyWith(PrescriptionNoteCreate value, $Res Function(PrescriptionNoteCreate) _then) = _$PrescriptionNoteCreateCopyWithImpl;
@useResult
$Res call({
 NoteContextType contextType, String contextId, String content, bool isPinned, String? organizationId
});




}
/// @nodoc
class _$PrescriptionNoteCreateCopyWithImpl<$Res>
    implements $PrescriptionNoteCreateCopyWith<$Res> {
  _$PrescriptionNoteCreateCopyWithImpl(this._self, this._then);

  final PrescriptionNoteCreate _self;
  final $Res Function(PrescriptionNoteCreate) _then;

/// Create a copy of PrescriptionNoteCreate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contextType = null,Object? contextId = null,Object? content = null,Object? isPinned = null,Object? organizationId = freezed,}) {
  return _then(_self.copyWith(
contextType: null == contextType ? _self.contextType : contextType // ignore: cast_nullable_to_non_nullable
as NoteContextType,contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,organizationId: freezed == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PrescriptionNoteCreate].
extension PrescriptionNoteCreatePatterns on PrescriptionNoteCreate {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrescriptionNoteCreate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrescriptionNoteCreate() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrescriptionNoteCreate value)  $default,){
final _that = this;
switch (_that) {
case _PrescriptionNoteCreate():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrescriptionNoteCreate value)?  $default,){
final _that = this;
switch (_that) {
case _PrescriptionNoteCreate() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NoteContextType contextType,  String contextId,  String content,  bool isPinned,  String? organizationId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrescriptionNoteCreate() when $default != null:
return $default(_that.contextType,_that.contextId,_that.content,_that.isPinned,_that.organizationId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NoteContextType contextType,  String contextId,  String content,  bool isPinned,  String? organizationId)  $default,) {final _that = this;
switch (_that) {
case _PrescriptionNoteCreate():
return $default(_that.contextType,_that.contextId,_that.content,_that.isPinned,_that.organizationId);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NoteContextType contextType,  String contextId,  String content,  bool isPinned,  String? organizationId)?  $default,) {final _that = this;
switch (_that) {
case _PrescriptionNoteCreate() when $default != null:
return $default(_that.contextType,_that.contextId,_that.content,_that.isPinned,_that.organizationId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrescriptionNoteCreate implements PrescriptionNoteCreate {
  const _PrescriptionNoteCreate({required this.contextType, required this.contextId, required this.content, this.isPinned = false, this.organizationId});
  factory _PrescriptionNoteCreate.fromJson(Map<String, dynamic> json) => _$PrescriptionNoteCreateFromJson(json);

@override final  NoteContextType contextType;
@override final  String contextId;
@override final  String content;
@override@JsonKey() final  bool isPinned;
@override final  String? organizationId;

/// Create a copy of PrescriptionNoteCreate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrescriptionNoteCreateCopyWith<_PrescriptionNoteCreate> get copyWith => __$PrescriptionNoteCreateCopyWithImpl<_PrescriptionNoteCreate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrescriptionNoteCreateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrescriptionNoteCreate&&(identical(other.contextType, contextType) || other.contextType == contextType)&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.content, content) || other.content == content)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contextType,contextId,content,isPinned,organizationId);

@override
String toString() {
  return 'PrescriptionNoteCreate(contextType: $contextType, contextId: $contextId, content: $content, isPinned: $isPinned, organizationId: $organizationId)';
}


}

/// @nodoc
abstract mixin class _$PrescriptionNoteCreateCopyWith<$Res> implements $PrescriptionNoteCreateCopyWith<$Res> {
  factory _$PrescriptionNoteCreateCopyWith(_PrescriptionNoteCreate value, $Res Function(_PrescriptionNoteCreate) _then) = __$PrescriptionNoteCreateCopyWithImpl;
@override @useResult
$Res call({
 NoteContextType contextType, String contextId, String content, bool isPinned, String? organizationId
});




}
/// @nodoc
class __$PrescriptionNoteCreateCopyWithImpl<$Res>
    implements _$PrescriptionNoteCreateCopyWith<$Res> {
  __$PrescriptionNoteCreateCopyWithImpl(this._self, this._then);

  final _PrescriptionNoteCreate _self;
  final $Res Function(_PrescriptionNoteCreate) _then;

/// Create a copy of PrescriptionNoteCreate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contextType = null,Object? contextId = null,Object? content = null,Object? isPinned = null,Object? organizationId = freezed,}) {
  return _then(_PrescriptionNoteCreate(
contextType: null == contextType ? _self.contextType : contextType // ignore: cast_nullable_to_non_nullable
as NoteContextType,contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,organizationId: freezed == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PrescriptionNoteUpdate {

 String? get content; bool? get isPinned;
/// Create a copy of PrescriptionNoteUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrescriptionNoteUpdateCopyWith<PrescriptionNoteUpdate> get copyWith => _$PrescriptionNoteUpdateCopyWithImpl<PrescriptionNoteUpdate>(this as PrescriptionNoteUpdate, _$identity);

  /// Serializes this PrescriptionNoteUpdate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrescriptionNoteUpdate&&(identical(other.content, content) || other.content == content)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content,isPinned);

@override
String toString() {
  return 'PrescriptionNoteUpdate(content: $content, isPinned: $isPinned)';
}


}

/// @nodoc
abstract mixin class $PrescriptionNoteUpdateCopyWith<$Res>  {
  factory $PrescriptionNoteUpdateCopyWith(PrescriptionNoteUpdate value, $Res Function(PrescriptionNoteUpdate) _then) = _$PrescriptionNoteUpdateCopyWithImpl;
@useResult
$Res call({
 String? content, bool? isPinned
});




}
/// @nodoc
class _$PrescriptionNoteUpdateCopyWithImpl<$Res>
    implements $PrescriptionNoteUpdateCopyWith<$Res> {
  _$PrescriptionNoteUpdateCopyWithImpl(this._self, this._then);

  final PrescriptionNoteUpdate _self;
  final $Res Function(PrescriptionNoteUpdate) _then;

/// Create a copy of PrescriptionNoteUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? content = freezed,Object? isPinned = freezed,}) {
  return _then(_self.copyWith(
content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,isPinned: freezed == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [PrescriptionNoteUpdate].
extension PrescriptionNoteUpdatePatterns on PrescriptionNoteUpdate {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrescriptionNoteUpdate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrescriptionNoteUpdate() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrescriptionNoteUpdate value)  $default,){
final _that = this;
switch (_that) {
case _PrescriptionNoteUpdate():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrescriptionNoteUpdate value)?  $default,){
final _that = this;
switch (_that) {
case _PrescriptionNoteUpdate() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? content,  bool? isPinned)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrescriptionNoteUpdate() when $default != null:
return $default(_that.content,_that.isPinned);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? content,  bool? isPinned)  $default,) {final _that = this;
switch (_that) {
case _PrescriptionNoteUpdate():
return $default(_that.content,_that.isPinned);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? content,  bool? isPinned)?  $default,) {final _that = this;
switch (_that) {
case _PrescriptionNoteUpdate() when $default != null:
return $default(_that.content,_that.isPinned);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrescriptionNoteUpdate implements PrescriptionNoteUpdate {
  const _PrescriptionNoteUpdate({this.content, this.isPinned});
  factory _PrescriptionNoteUpdate.fromJson(Map<String, dynamic> json) => _$PrescriptionNoteUpdateFromJson(json);

@override final  String? content;
@override final  bool? isPinned;

/// Create a copy of PrescriptionNoteUpdate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrescriptionNoteUpdateCopyWith<_PrescriptionNoteUpdate> get copyWith => __$PrescriptionNoteUpdateCopyWithImpl<_PrescriptionNoteUpdate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrescriptionNoteUpdateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrescriptionNoteUpdate&&(identical(other.content, content) || other.content == content)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content,isPinned);

@override
String toString() {
  return 'PrescriptionNoteUpdate(content: $content, isPinned: $isPinned)';
}


}

/// @nodoc
abstract mixin class _$PrescriptionNoteUpdateCopyWith<$Res> implements $PrescriptionNoteUpdateCopyWith<$Res> {
  factory _$PrescriptionNoteUpdateCopyWith(_PrescriptionNoteUpdate value, $Res Function(_PrescriptionNoteUpdate) _then) = __$PrescriptionNoteUpdateCopyWithImpl;
@override @useResult
$Res call({
 String? content, bool? isPinned
});




}
/// @nodoc
class __$PrescriptionNoteUpdateCopyWithImpl<$Res>
    implements _$PrescriptionNoteUpdateCopyWith<$Res> {
  __$PrescriptionNoteUpdateCopyWithImpl(this._self, this._then);

  final _PrescriptionNoteUpdate _self;
  final $Res Function(_PrescriptionNoteUpdate) _then;

/// Create a copy of PrescriptionNoteUpdate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? content = freezed,Object? isPinned = freezed,}) {
  return _then(_PrescriptionNoteUpdate(
content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,isPinned: freezed == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
