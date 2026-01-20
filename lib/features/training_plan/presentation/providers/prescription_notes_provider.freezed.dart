// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prescription_notes_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PrescriptionNotesState {

 List<PrescriptionNote> get notes; int get unreadCount; bool get isLoading; bool get isCreating; String? get error;
/// Create a copy of PrescriptionNotesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrescriptionNotesStateCopyWith<PrescriptionNotesState> get copyWith => _$PrescriptionNotesStateCopyWithImpl<PrescriptionNotesState>(this as PrescriptionNotesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrescriptionNotesState&&const DeepCollectionEquality().equals(other.notes, notes)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isCreating, isCreating) || other.isCreating == isCreating)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(notes),unreadCount,isLoading,isCreating,error);

@override
String toString() {
  return 'PrescriptionNotesState(notes: $notes, unreadCount: $unreadCount, isLoading: $isLoading, isCreating: $isCreating, error: $error)';
}


}

/// @nodoc
abstract mixin class $PrescriptionNotesStateCopyWith<$Res>  {
  factory $PrescriptionNotesStateCopyWith(PrescriptionNotesState value, $Res Function(PrescriptionNotesState) _then) = _$PrescriptionNotesStateCopyWithImpl;
@useResult
$Res call({
 List<PrescriptionNote> notes, int unreadCount, bool isLoading, bool isCreating, String? error
});




}
/// @nodoc
class _$PrescriptionNotesStateCopyWithImpl<$Res>
    implements $PrescriptionNotesStateCopyWith<$Res> {
  _$PrescriptionNotesStateCopyWithImpl(this._self, this._then);

  final PrescriptionNotesState _self;
  final $Res Function(PrescriptionNotesState) _then;

/// Create a copy of PrescriptionNotesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? notes = null,Object? unreadCount = null,Object? isLoading = null,Object? isCreating = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as List<PrescriptionNote>,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isCreating: null == isCreating ? _self.isCreating : isCreating // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PrescriptionNotesState].
extension PrescriptionNotesStatePatterns on PrescriptionNotesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrescriptionNotesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrescriptionNotesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrescriptionNotesState value)  $default,){
final _that = this;
switch (_that) {
case _PrescriptionNotesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrescriptionNotesState value)?  $default,){
final _that = this;
switch (_that) {
case _PrescriptionNotesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PrescriptionNote> notes,  int unreadCount,  bool isLoading,  bool isCreating,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrescriptionNotesState() when $default != null:
return $default(_that.notes,_that.unreadCount,_that.isLoading,_that.isCreating,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PrescriptionNote> notes,  int unreadCount,  bool isLoading,  bool isCreating,  String? error)  $default,) {final _that = this;
switch (_that) {
case _PrescriptionNotesState():
return $default(_that.notes,_that.unreadCount,_that.isLoading,_that.isCreating,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PrescriptionNote> notes,  int unreadCount,  bool isLoading,  bool isCreating,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _PrescriptionNotesState() when $default != null:
return $default(_that.notes,_that.unreadCount,_that.isLoading,_that.isCreating,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _PrescriptionNotesState implements PrescriptionNotesState {
  const _PrescriptionNotesState({final  List<PrescriptionNote> notes = const [], this.unreadCount = 0, this.isLoading = false, this.isCreating = false, this.error}): _notes = notes;
  

 final  List<PrescriptionNote> _notes;
@override@JsonKey() List<PrescriptionNote> get notes {
  if (_notes is EqualUnmodifiableListView) return _notes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notes);
}

@override@JsonKey() final  int unreadCount;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isCreating;
@override final  String? error;

/// Create a copy of PrescriptionNotesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrescriptionNotesStateCopyWith<_PrescriptionNotesState> get copyWith => __$PrescriptionNotesStateCopyWithImpl<_PrescriptionNotesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrescriptionNotesState&&const DeepCollectionEquality().equals(other._notes, _notes)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isCreating, isCreating) || other.isCreating == isCreating)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_notes),unreadCount,isLoading,isCreating,error);

@override
String toString() {
  return 'PrescriptionNotesState(notes: $notes, unreadCount: $unreadCount, isLoading: $isLoading, isCreating: $isCreating, error: $error)';
}


}

/// @nodoc
abstract mixin class _$PrescriptionNotesStateCopyWith<$Res> implements $PrescriptionNotesStateCopyWith<$Res> {
  factory _$PrescriptionNotesStateCopyWith(_PrescriptionNotesState value, $Res Function(_PrescriptionNotesState) _then) = __$PrescriptionNotesStateCopyWithImpl;
@override @useResult
$Res call({
 List<PrescriptionNote> notes, int unreadCount, bool isLoading, bool isCreating, String? error
});




}
/// @nodoc
class __$PrescriptionNotesStateCopyWithImpl<$Res>
    implements _$PrescriptionNotesStateCopyWith<$Res> {
  __$PrescriptionNotesStateCopyWithImpl(this._self, this._then);

  final _PrescriptionNotesState _self;
  final $Res Function(_PrescriptionNotesState) _then;

/// Create a copy of PrescriptionNotesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? notes = null,Object? unreadCount = null,Object? isLoading = null,Object? isCreating = null,Object? error = freezed,}) {
  return _then(_PrescriptionNotesState(
notes: null == notes ? _self._notes : notes // ignore: cast_nullable_to_non_nullable
as List<PrescriptionNote>,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isCreating: null == isCreating ? _self.isCreating : isCreating // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
