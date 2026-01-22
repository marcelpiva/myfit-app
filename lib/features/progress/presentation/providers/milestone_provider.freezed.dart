// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'milestone_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MilestoneState {

 List<Milestone> get milestones; List<AIInsight> get insights; MilestoneStats? get stats; bool get isLoading; bool get isLoadingInsights; String? get error;
/// Create a copy of MilestoneState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MilestoneStateCopyWith<MilestoneState> get copyWith => _$MilestoneStateCopyWithImpl<MilestoneState>(this as MilestoneState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MilestoneState&&const DeepCollectionEquality().equals(other.milestones, milestones)&&const DeepCollectionEquality().equals(other.insights, insights)&&(identical(other.stats, stats) || other.stats == stats)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoadingInsights, isLoadingInsights) || other.isLoadingInsights == isLoadingInsights)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(milestones),const DeepCollectionEquality().hash(insights),stats,isLoading,isLoadingInsights,error);

@override
String toString() {
  return 'MilestoneState(milestones: $milestones, insights: $insights, stats: $stats, isLoading: $isLoading, isLoadingInsights: $isLoadingInsights, error: $error)';
}


}

/// @nodoc
abstract mixin class $MilestoneStateCopyWith<$Res>  {
  factory $MilestoneStateCopyWith(MilestoneState value, $Res Function(MilestoneState) _then) = _$MilestoneStateCopyWithImpl;
@useResult
$Res call({
 List<Milestone> milestones, List<AIInsight> insights, MilestoneStats? stats, bool isLoading, bool isLoadingInsights, String? error
});


$MilestoneStatsCopyWith<$Res>? get stats;

}
/// @nodoc
class _$MilestoneStateCopyWithImpl<$Res>
    implements $MilestoneStateCopyWith<$Res> {
  _$MilestoneStateCopyWithImpl(this._self, this._then);

  final MilestoneState _self;
  final $Res Function(MilestoneState) _then;

/// Create a copy of MilestoneState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? milestones = null,Object? insights = null,Object? stats = freezed,Object? isLoading = null,Object? isLoadingInsights = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
milestones: null == milestones ? _self.milestones : milestones // ignore: cast_nullable_to_non_nullable
as List<Milestone>,insights: null == insights ? _self.insights : insights // ignore: cast_nullable_to_non_nullable
as List<AIInsight>,stats: freezed == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as MilestoneStats?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingInsights: null == isLoadingInsights ? _self.isLoadingInsights : isLoadingInsights // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of MilestoneState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MilestoneStatsCopyWith<$Res>? get stats {
    if (_self.stats == null) {
    return null;
  }

  return $MilestoneStatsCopyWith<$Res>(_self.stats!, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// Adds pattern-matching-related methods to [MilestoneState].
extension MilestoneStatePatterns on MilestoneState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MilestoneState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MilestoneState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MilestoneState value)  $default,){
final _that = this;
switch (_that) {
case _MilestoneState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MilestoneState value)?  $default,){
final _that = this;
switch (_that) {
case _MilestoneState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Milestone> milestones,  List<AIInsight> insights,  MilestoneStats? stats,  bool isLoading,  bool isLoadingInsights,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MilestoneState() when $default != null:
return $default(_that.milestones,_that.insights,_that.stats,_that.isLoading,_that.isLoadingInsights,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Milestone> milestones,  List<AIInsight> insights,  MilestoneStats? stats,  bool isLoading,  bool isLoadingInsights,  String? error)  $default,) {final _that = this;
switch (_that) {
case _MilestoneState():
return $default(_that.milestones,_that.insights,_that.stats,_that.isLoading,_that.isLoadingInsights,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Milestone> milestones,  List<AIInsight> insights,  MilestoneStats? stats,  bool isLoading,  bool isLoadingInsights,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _MilestoneState() when $default != null:
return $default(_that.milestones,_that.insights,_that.stats,_that.isLoading,_that.isLoadingInsights,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _MilestoneState extends MilestoneState {
  const _MilestoneState({final  List<Milestone> milestones = const [], final  List<AIInsight> insights = const [], this.stats, this.isLoading = false, this.isLoadingInsights = false, this.error}): _milestones = milestones,_insights = insights,super._();
  

 final  List<Milestone> _milestones;
@override@JsonKey() List<Milestone> get milestones {
  if (_milestones is EqualUnmodifiableListView) return _milestones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_milestones);
}

 final  List<AIInsight> _insights;
@override@JsonKey() List<AIInsight> get insights {
  if (_insights is EqualUnmodifiableListView) return _insights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_insights);
}

@override final  MilestoneStats? stats;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isLoadingInsights;
@override final  String? error;

/// Create a copy of MilestoneState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MilestoneStateCopyWith<_MilestoneState> get copyWith => __$MilestoneStateCopyWithImpl<_MilestoneState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MilestoneState&&const DeepCollectionEquality().equals(other._milestones, _milestones)&&const DeepCollectionEquality().equals(other._insights, _insights)&&(identical(other.stats, stats) || other.stats == stats)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoadingInsights, isLoadingInsights) || other.isLoadingInsights == isLoadingInsights)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_milestones),const DeepCollectionEquality().hash(_insights),stats,isLoading,isLoadingInsights,error);

@override
String toString() {
  return 'MilestoneState(milestones: $milestones, insights: $insights, stats: $stats, isLoading: $isLoading, isLoadingInsights: $isLoadingInsights, error: $error)';
}


}

/// @nodoc
abstract mixin class _$MilestoneStateCopyWith<$Res> implements $MilestoneStateCopyWith<$Res> {
  factory _$MilestoneStateCopyWith(_MilestoneState value, $Res Function(_MilestoneState) _then) = __$MilestoneStateCopyWithImpl;
@override @useResult
$Res call({
 List<Milestone> milestones, List<AIInsight> insights, MilestoneStats? stats, bool isLoading, bool isLoadingInsights, String? error
});


@override $MilestoneStatsCopyWith<$Res>? get stats;

}
/// @nodoc
class __$MilestoneStateCopyWithImpl<$Res>
    implements _$MilestoneStateCopyWith<$Res> {
  __$MilestoneStateCopyWithImpl(this._self, this._then);

  final _MilestoneState _self;
  final $Res Function(_MilestoneState) _then;

/// Create a copy of MilestoneState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? milestones = null,Object? insights = null,Object? stats = freezed,Object? isLoading = null,Object? isLoadingInsights = null,Object? error = freezed,}) {
  return _then(_MilestoneState(
milestones: null == milestones ? _self._milestones : milestones // ignore: cast_nullable_to_non_nullable
as List<Milestone>,insights: null == insights ? _self._insights : insights // ignore: cast_nullable_to_non_nullable
as List<AIInsight>,stats: freezed == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as MilestoneStats?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingInsights: null == isLoadingInsights ? _self.isLoadingInsights : isLoadingInsights // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of MilestoneState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MilestoneStatsCopyWith<$Res>? get stats {
    if (_self.stats == null) {
    return null;
  }

  return $MilestoneStatsCopyWith<$Res>(_self.stats!, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}

// dart format on
