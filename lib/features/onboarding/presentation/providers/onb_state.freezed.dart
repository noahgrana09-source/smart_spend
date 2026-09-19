// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onb_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OnbState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnbState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OnbState()';
}


}

/// @nodoc
class $OnbStateCopyWith<$Res>  {
$OnbStateCopyWith(OnbState _, $Res Function(OnbState) __);
}


/// Adds pattern-matching-related methods to [OnbState].
extension OnbStatePatterns on OnbState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( OnbNormal value)?  normal,TResult Function( OnbLoading value)?  loading,TResult Function( OnbError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case OnbNormal() when normal != null:
return normal(_that);case OnbLoading() when loading != null:
return loading(_that);case OnbError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( OnbNormal value)  normal,required TResult Function( OnbLoading value)  loading,required TResult Function( OnbError value)  error,}){
final _that = this;
switch (_that) {
case OnbNormal():
return normal(_that);case OnbLoading():
return loading(_that);case OnbError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( OnbNormal value)?  normal,TResult? Function( OnbLoading value)?  loading,TResult? Function( OnbError value)?  error,}){
final _that = this;
switch (_that) {
case OnbNormal() when normal != null:
return normal(_that);case OnbLoading() when loading != null:
return loading(_that);case OnbError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  normal,TResult Function()?  loading,TResult Function( Failure failure)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case OnbNormal() when normal != null:
return normal();case OnbLoading() when loading != null:
return loading();case OnbError() when error != null:
return error(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  normal,required TResult Function()  loading,required TResult Function( Failure failure)  error,}) {final _that = this;
switch (_that) {
case OnbNormal():
return normal();case OnbLoading():
return loading();case OnbError():
return error(_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  normal,TResult? Function()?  loading,TResult? Function( Failure failure)?  error,}) {final _that = this;
switch (_that) {
case OnbNormal() when normal != null:
return normal();case OnbLoading() when loading != null:
return loading();case OnbError() when error != null:
return error(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class OnbNormal implements OnbState {
  const OnbNormal();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnbNormal);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OnbState.normal()';
}


}




/// @nodoc


class OnbLoading implements OnbState {
  const OnbLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnbLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OnbState.loading()';
}


}




/// @nodoc


class OnbError implements OnbState {
  const OnbError(this.failure);
  

 final  Failure failure;

/// Create a copy of OnbState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnbErrorCopyWith<OnbError> get copyWith => _$OnbErrorCopyWithImpl<OnbError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnbError&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'OnbState.error(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $OnbErrorCopyWith<$Res> implements $OnbStateCopyWith<$Res> {
  factory $OnbErrorCopyWith(OnbError value, $Res Function(OnbError) _then) = _$OnbErrorCopyWithImpl;
@useResult
$Res call({
 Failure failure
});




}
/// @nodoc
class _$OnbErrorCopyWithImpl<$Res>
    implements $OnbErrorCopyWith<$Res> {
  _$OnbErrorCopyWithImpl(this._self, this._then);

  final OnbError _self;
  final $Res Function(OnbError) _then;

/// Create a copy of OnbState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(OnbError(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}


}

// dart format on
