// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Payment {

 String get id; String get studentId; String get studentName; String? get studentAvatarUrl; double get amount; DateTime get dueDate; DateTime? get paidAt; PaymentStatus get status; PaymentMethod? get paymentMethod; String? get description; String? get receiptUrl; int? get daysOverdue;
/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentCopyWith<Payment> get copyWith => _$PaymentCopyWithImpl<Payment>(this as Payment, _$identity);

  /// Serializes this Payment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Payment&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.studentName, studentName) || other.studentName == studentName)&&(identical(other.studentAvatarUrl, studentAvatarUrl) || other.studentAvatarUrl == studentAvatarUrl)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.description, description) || other.description == description)&&(identical(other.receiptUrl, receiptUrl) || other.receiptUrl == receiptUrl)&&(identical(other.daysOverdue, daysOverdue) || other.daysOverdue == daysOverdue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,studentName,studentAvatarUrl,amount,dueDate,paidAt,status,paymentMethod,description,receiptUrl,daysOverdue);

@override
String toString() {
  return 'Payment(id: $id, studentId: $studentId, studentName: $studentName, studentAvatarUrl: $studentAvatarUrl, amount: $amount, dueDate: $dueDate, paidAt: $paidAt, status: $status, paymentMethod: $paymentMethod, description: $description, receiptUrl: $receiptUrl, daysOverdue: $daysOverdue)';
}


}

/// @nodoc
abstract mixin class $PaymentCopyWith<$Res>  {
  factory $PaymentCopyWith(Payment value, $Res Function(Payment) _then) = _$PaymentCopyWithImpl;
@useResult
$Res call({
 String id, String studentId, String studentName, String? studentAvatarUrl, double amount, DateTime dueDate, DateTime? paidAt, PaymentStatus status, PaymentMethod? paymentMethod, String? description, String? receiptUrl, int? daysOverdue
});




}
/// @nodoc
class _$PaymentCopyWithImpl<$Res>
    implements $PaymentCopyWith<$Res> {
  _$PaymentCopyWithImpl(this._self, this._then);

  final Payment _self;
  final $Res Function(Payment) _then;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? studentId = null,Object? studentName = null,Object? studentAvatarUrl = freezed,Object? amount = null,Object? dueDate = null,Object? paidAt = freezed,Object? status = null,Object? paymentMethod = freezed,Object? description = freezed,Object? receiptUrl = freezed,Object? daysOverdue = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,studentName: null == studentName ? _self.studentName : studentName // ignore: cast_nullable_to_non_nullable
as String,studentAvatarUrl: freezed == studentAvatarUrl ? _self.studentAvatarUrl : studentAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentStatus,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,receiptUrl: freezed == receiptUrl ? _self.receiptUrl : receiptUrl // ignore: cast_nullable_to_non_nullable
as String?,daysOverdue: freezed == daysOverdue ? _self.daysOverdue : daysOverdue // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Payment].
extension PaymentPatterns on Payment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Payment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Payment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Payment value)  $default,){
final _that = this;
switch (_that) {
case _Payment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Payment value)?  $default,){
final _that = this;
switch (_that) {
case _Payment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String studentId,  String studentName,  String? studentAvatarUrl,  double amount,  DateTime dueDate,  DateTime? paidAt,  PaymentStatus status,  PaymentMethod? paymentMethod,  String? description,  String? receiptUrl,  int? daysOverdue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Payment() when $default != null:
return $default(_that.id,_that.studentId,_that.studentName,_that.studentAvatarUrl,_that.amount,_that.dueDate,_that.paidAt,_that.status,_that.paymentMethod,_that.description,_that.receiptUrl,_that.daysOverdue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String studentId,  String studentName,  String? studentAvatarUrl,  double amount,  DateTime dueDate,  DateTime? paidAt,  PaymentStatus status,  PaymentMethod? paymentMethod,  String? description,  String? receiptUrl,  int? daysOverdue)  $default,) {final _that = this;
switch (_that) {
case _Payment():
return $default(_that.id,_that.studentId,_that.studentName,_that.studentAvatarUrl,_that.amount,_that.dueDate,_that.paidAt,_that.status,_that.paymentMethod,_that.description,_that.receiptUrl,_that.daysOverdue);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String studentId,  String studentName,  String? studentAvatarUrl,  double amount,  DateTime dueDate,  DateTime? paidAt,  PaymentStatus status,  PaymentMethod? paymentMethod,  String? description,  String? receiptUrl,  int? daysOverdue)?  $default,) {final _that = this;
switch (_that) {
case _Payment() when $default != null:
return $default(_that.id,_that.studentId,_that.studentName,_that.studentAvatarUrl,_that.amount,_that.dueDate,_that.paidAt,_that.status,_that.paymentMethod,_that.description,_that.receiptUrl,_that.daysOverdue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Payment extends Payment {
  const _Payment({required this.id, required this.studentId, required this.studentName, this.studentAvatarUrl, required this.amount, required this.dueDate, this.paidAt, required this.status, this.paymentMethod, this.description, this.receiptUrl, this.daysOverdue}): super._();
  factory _Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);

@override final  String id;
@override final  String studentId;
@override final  String studentName;
@override final  String? studentAvatarUrl;
@override final  double amount;
@override final  DateTime dueDate;
@override final  DateTime? paidAt;
@override final  PaymentStatus status;
@override final  PaymentMethod? paymentMethod;
@override final  String? description;
@override final  String? receiptUrl;
@override final  int? daysOverdue;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentCopyWith<_Payment> get copyWith => __$PaymentCopyWithImpl<_Payment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Payment&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.studentName, studentName) || other.studentName == studentName)&&(identical(other.studentAvatarUrl, studentAvatarUrl) || other.studentAvatarUrl == studentAvatarUrl)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.description, description) || other.description == description)&&(identical(other.receiptUrl, receiptUrl) || other.receiptUrl == receiptUrl)&&(identical(other.daysOverdue, daysOverdue) || other.daysOverdue == daysOverdue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,studentName,studentAvatarUrl,amount,dueDate,paidAt,status,paymentMethod,description,receiptUrl,daysOverdue);

@override
String toString() {
  return 'Payment(id: $id, studentId: $studentId, studentName: $studentName, studentAvatarUrl: $studentAvatarUrl, amount: $amount, dueDate: $dueDate, paidAt: $paidAt, status: $status, paymentMethod: $paymentMethod, description: $description, receiptUrl: $receiptUrl, daysOverdue: $daysOverdue)';
}


}

/// @nodoc
abstract mixin class _$PaymentCopyWith<$Res> implements $PaymentCopyWith<$Res> {
  factory _$PaymentCopyWith(_Payment value, $Res Function(_Payment) _then) = __$PaymentCopyWithImpl;
@override @useResult
$Res call({
 String id, String studentId, String studentName, String? studentAvatarUrl, double amount, DateTime dueDate, DateTime? paidAt, PaymentStatus status, PaymentMethod? paymentMethod, String? description, String? receiptUrl, int? daysOverdue
});




}
/// @nodoc
class __$PaymentCopyWithImpl<$Res>
    implements _$PaymentCopyWith<$Res> {
  __$PaymentCopyWithImpl(this._self, this._then);

  final _Payment _self;
  final $Res Function(_Payment) _then;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? studentId = null,Object? studentName = null,Object? studentAvatarUrl = freezed,Object? amount = null,Object? dueDate = null,Object? paidAt = freezed,Object? status = null,Object? paymentMethod = freezed,Object? description = freezed,Object? receiptUrl = freezed,Object? daysOverdue = freezed,}) {
  return _then(_Payment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,studentName: null == studentName ? _self.studentName : studentName // ignore: cast_nullable_to_non_nullable
as String,studentAvatarUrl: freezed == studentAvatarUrl ? _self.studentAvatarUrl : studentAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentStatus,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,receiptUrl: freezed == receiptUrl ? _self.receiptUrl : receiptUrl // ignore: cast_nullable_to_non_nullable
as String?,daysOverdue: freezed == daysOverdue ? _self.daysOverdue : daysOverdue // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$BillingSummary {

 double get totalExpected; double get totalReceived; double get totalPending; int get paidCount; int get pendingCount; int get overdueCount; double get receivedPercentage;
/// Create a copy of BillingSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingSummaryCopyWith<BillingSummary> get copyWith => _$BillingSummaryCopyWithImpl<BillingSummary>(this as BillingSummary, _$identity);

  /// Serializes this BillingSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingSummary&&(identical(other.totalExpected, totalExpected) || other.totalExpected == totalExpected)&&(identical(other.totalReceived, totalReceived) || other.totalReceived == totalReceived)&&(identical(other.totalPending, totalPending) || other.totalPending == totalPending)&&(identical(other.paidCount, paidCount) || other.paidCount == paidCount)&&(identical(other.pendingCount, pendingCount) || other.pendingCount == pendingCount)&&(identical(other.overdueCount, overdueCount) || other.overdueCount == overdueCount)&&(identical(other.receivedPercentage, receivedPercentage) || other.receivedPercentage == receivedPercentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalExpected,totalReceived,totalPending,paidCount,pendingCount,overdueCount,receivedPercentage);

@override
String toString() {
  return 'BillingSummary(totalExpected: $totalExpected, totalReceived: $totalReceived, totalPending: $totalPending, paidCount: $paidCount, pendingCount: $pendingCount, overdueCount: $overdueCount, receivedPercentage: $receivedPercentage)';
}


}

/// @nodoc
abstract mixin class $BillingSummaryCopyWith<$Res>  {
  factory $BillingSummaryCopyWith(BillingSummary value, $Res Function(BillingSummary) _then) = _$BillingSummaryCopyWithImpl;
@useResult
$Res call({
 double totalExpected, double totalReceived, double totalPending, int paidCount, int pendingCount, int overdueCount, double receivedPercentage
});




}
/// @nodoc
class _$BillingSummaryCopyWithImpl<$Res>
    implements $BillingSummaryCopyWith<$Res> {
  _$BillingSummaryCopyWithImpl(this._self, this._then);

  final BillingSummary _self;
  final $Res Function(BillingSummary) _then;

/// Create a copy of BillingSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalExpected = null,Object? totalReceived = null,Object? totalPending = null,Object? paidCount = null,Object? pendingCount = null,Object? overdueCount = null,Object? receivedPercentage = null,}) {
  return _then(_self.copyWith(
totalExpected: null == totalExpected ? _self.totalExpected : totalExpected // ignore: cast_nullable_to_non_nullable
as double,totalReceived: null == totalReceived ? _self.totalReceived : totalReceived // ignore: cast_nullable_to_non_nullable
as double,totalPending: null == totalPending ? _self.totalPending : totalPending // ignore: cast_nullable_to_non_nullable
as double,paidCount: null == paidCount ? _self.paidCount : paidCount // ignore: cast_nullable_to_non_nullable
as int,pendingCount: null == pendingCount ? _self.pendingCount : pendingCount // ignore: cast_nullable_to_non_nullable
as int,overdueCount: null == overdueCount ? _self.overdueCount : overdueCount // ignore: cast_nullable_to_non_nullable
as int,receivedPercentage: null == receivedPercentage ? _self.receivedPercentage : receivedPercentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [BillingSummary].
extension BillingSummaryPatterns on BillingSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillingSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillingSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillingSummary value)  $default,){
final _that = this;
switch (_that) {
case _BillingSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillingSummary value)?  $default,){
final _that = this;
switch (_that) {
case _BillingSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalExpected,  double totalReceived,  double totalPending,  int paidCount,  int pendingCount,  int overdueCount,  double receivedPercentage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillingSummary() when $default != null:
return $default(_that.totalExpected,_that.totalReceived,_that.totalPending,_that.paidCount,_that.pendingCount,_that.overdueCount,_that.receivedPercentage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalExpected,  double totalReceived,  double totalPending,  int paidCount,  int pendingCount,  int overdueCount,  double receivedPercentage)  $default,) {final _that = this;
switch (_that) {
case _BillingSummary():
return $default(_that.totalExpected,_that.totalReceived,_that.totalPending,_that.paidCount,_that.pendingCount,_that.overdueCount,_that.receivedPercentage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalExpected,  double totalReceived,  double totalPending,  int paidCount,  int pendingCount,  int overdueCount,  double receivedPercentage)?  $default,) {final _that = this;
switch (_that) {
case _BillingSummary() when $default != null:
return $default(_that.totalExpected,_that.totalReceived,_that.totalPending,_that.paidCount,_that.pendingCount,_that.overdueCount,_that.receivedPercentage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BillingSummary extends BillingSummary {
  const _BillingSummary({required this.totalExpected, required this.totalReceived, required this.totalPending, required this.paidCount, required this.pendingCount, required this.overdueCount, required this.receivedPercentage}): super._();
  factory _BillingSummary.fromJson(Map<String, dynamic> json) => _$BillingSummaryFromJson(json);

@override final  double totalExpected;
@override final  double totalReceived;
@override final  double totalPending;
@override final  int paidCount;
@override final  int pendingCount;
@override final  int overdueCount;
@override final  double receivedPercentage;

/// Create a copy of BillingSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillingSummaryCopyWith<_BillingSummary> get copyWith => __$BillingSummaryCopyWithImpl<_BillingSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillingSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillingSummary&&(identical(other.totalExpected, totalExpected) || other.totalExpected == totalExpected)&&(identical(other.totalReceived, totalReceived) || other.totalReceived == totalReceived)&&(identical(other.totalPending, totalPending) || other.totalPending == totalPending)&&(identical(other.paidCount, paidCount) || other.paidCount == paidCount)&&(identical(other.pendingCount, pendingCount) || other.pendingCount == pendingCount)&&(identical(other.overdueCount, overdueCount) || other.overdueCount == overdueCount)&&(identical(other.receivedPercentage, receivedPercentage) || other.receivedPercentage == receivedPercentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalExpected,totalReceived,totalPending,paidCount,pendingCount,overdueCount,receivedPercentage);

@override
String toString() {
  return 'BillingSummary(totalExpected: $totalExpected, totalReceived: $totalReceived, totalPending: $totalPending, paidCount: $paidCount, pendingCount: $pendingCount, overdueCount: $overdueCount, receivedPercentage: $receivedPercentage)';
}


}

/// @nodoc
abstract mixin class _$BillingSummaryCopyWith<$Res> implements $BillingSummaryCopyWith<$Res> {
  factory _$BillingSummaryCopyWith(_BillingSummary value, $Res Function(_BillingSummary) _then) = __$BillingSummaryCopyWithImpl;
@override @useResult
$Res call({
 double totalExpected, double totalReceived, double totalPending, int paidCount, int pendingCount, int overdueCount, double receivedPercentage
});




}
/// @nodoc
class __$BillingSummaryCopyWithImpl<$Res>
    implements _$BillingSummaryCopyWith<$Res> {
  __$BillingSummaryCopyWithImpl(this._self, this._then);

  final _BillingSummary _self;
  final $Res Function(_BillingSummary) _then;

/// Create a copy of BillingSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalExpected = null,Object? totalReceived = null,Object? totalPending = null,Object? paidCount = null,Object? pendingCount = null,Object? overdueCount = null,Object? receivedPercentage = null,}) {
  return _then(_BillingSummary(
totalExpected: null == totalExpected ? _self.totalExpected : totalExpected // ignore: cast_nullable_to_non_nullable
as double,totalReceived: null == totalReceived ? _self.totalReceived : totalReceived // ignore: cast_nullable_to_non_nullable
as double,totalPending: null == totalPending ? _self.totalPending : totalPending // ignore: cast_nullable_to_non_nullable
as double,paidCount: null == paidCount ? _self.paidCount : paidCount // ignore: cast_nullable_to_non_nullable
as int,pendingCount: null == pendingCount ? _self.pendingCount : pendingCount // ignore: cast_nullable_to_non_nullable
as int,overdueCount: null == overdueCount ? _self.overdueCount : overdueCount // ignore: cast_nullable_to_non_nullable
as int,receivedPercentage: null == receivedPercentage ? _self.receivedPercentage : receivedPercentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$PaymentReminder {

 String get id; String get paymentId; String get studentId; String get message; DateTime get sentAt; String get channel;// whatsapp, email, push
 bool? get delivered; bool? get read;
/// Create a copy of PaymentReminder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentReminderCopyWith<PaymentReminder> get copyWith => _$PaymentReminderCopyWithImpl<PaymentReminder>(this as PaymentReminder, _$identity);

  /// Serializes this PaymentReminder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentReminder&&(identical(other.id, id) || other.id == id)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.message, message) || other.message == message)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.delivered, delivered) || other.delivered == delivered)&&(identical(other.read, read) || other.read == read));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,paymentId,studentId,message,sentAt,channel,delivered,read);

@override
String toString() {
  return 'PaymentReminder(id: $id, paymentId: $paymentId, studentId: $studentId, message: $message, sentAt: $sentAt, channel: $channel, delivered: $delivered, read: $read)';
}


}

/// @nodoc
abstract mixin class $PaymentReminderCopyWith<$Res>  {
  factory $PaymentReminderCopyWith(PaymentReminder value, $Res Function(PaymentReminder) _then) = _$PaymentReminderCopyWithImpl;
@useResult
$Res call({
 String id, String paymentId, String studentId, String message, DateTime sentAt, String channel, bool? delivered, bool? read
});




}
/// @nodoc
class _$PaymentReminderCopyWithImpl<$Res>
    implements $PaymentReminderCopyWith<$Res> {
  _$PaymentReminderCopyWithImpl(this._self, this._then);

  final PaymentReminder _self;
  final $Res Function(PaymentReminder) _then;

/// Create a copy of PaymentReminder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? paymentId = null,Object? studentId = null,Object? message = null,Object? sentAt = null,Object? channel = null,Object? delivered = freezed,Object? read = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String,delivered: freezed == delivered ? _self.delivered : delivered // ignore: cast_nullable_to_non_nullable
as bool?,read: freezed == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentReminder].
extension PaymentReminderPatterns on PaymentReminder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentReminder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentReminder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentReminder value)  $default,){
final _that = this;
switch (_that) {
case _PaymentReminder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentReminder value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentReminder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String paymentId,  String studentId,  String message,  DateTime sentAt,  String channel,  bool? delivered,  bool? read)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentReminder() when $default != null:
return $default(_that.id,_that.paymentId,_that.studentId,_that.message,_that.sentAt,_that.channel,_that.delivered,_that.read);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String paymentId,  String studentId,  String message,  DateTime sentAt,  String channel,  bool? delivered,  bool? read)  $default,) {final _that = this;
switch (_that) {
case _PaymentReminder():
return $default(_that.id,_that.paymentId,_that.studentId,_that.message,_that.sentAt,_that.channel,_that.delivered,_that.read);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String paymentId,  String studentId,  String message,  DateTime sentAt,  String channel,  bool? delivered,  bool? read)?  $default,) {final _that = this;
switch (_that) {
case _PaymentReminder() when $default != null:
return $default(_that.id,_that.paymentId,_that.studentId,_that.message,_that.sentAt,_that.channel,_that.delivered,_that.read);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentReminder extends PaymentReminder {
  const _PaymentReminder({required this.id, required this.paymentId, required this.studentId, required this.message, required this.sentAt, required this.channel, this.delivered, this.read}): super._();
  factory _PaymentReminder.fromJson(Map<String, dynamic> json) => _$PaymentReminderFromJson(json);

@override final  String id;
@override final  String paymentId;
@override final  String studentId;
@override final  String message;
@override final  DateTime sentAt;
@override final  String channel;
// whatsapp, email, push
@override final  bool? delivered;
@override final  bool? read;

/// Create a copy of PaymentReminder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentReminderCopyWith<_PaymentReminder> get copyWith => __$PaymentReminderCopyWithImpl<_PaymentReminder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentReminderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentReminder&&(identical(other.id, id) || other.id == id)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.message, message) || other.message == message)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.delivered, delivered) || other.delivered == delivered)&&(identical(other.read, read) || other.read == read));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,paymentId,studentId,message,sentAt,channel,delivered,read);

@override
String toString() {
  return 'PaymentReminder(id: $id, paymentId: $paymentId, studentId: $studentId, message: $message, sentAt: $sentAt, channel: $channel, delivered: $delivered, read: $read)';
}


}

/// @nodoc
abstract mixin class _$PaymentReminderCopyWith<$Res> implements $PaymentReminderCopyWith<$Res> {
  factory _$PaymentReminderCopyWith(_PaymentReminder value, $Res Function(_PaymentReminder) _then) = __$PaymentReminderCopyWithImpl;
@override @useResult
$Res call({
 String id, String paymentId, String studentId, String message, DateTime sentAt, String channel, bool? delivered, bool? read
});




}
/// @nodoc
class __$PaymentReminderCopyWithImpl<$Res>
    implements _$PaymentReminderCopyWith<$Res> {
  __$PaymentReminderCopyWithImpl(this._self, this._then);

  final _PaymentReminder _self;
  final $Res Function(_PaymentReminder) _then;

/// Create a copy of PaymentReminder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? paymentId = null,Object? studentId = null,Object? message = null,Object? sentAt = null,Object? channel = null,Object? delivered = freezed,Object? read = freezed,}) {
  return _then(_PaymentReminder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String,delivered: freezed == delivered ? _self.delivered : delivered // ignore: cast_nullable_to_non_nullable
as bool?,read: freezed == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
