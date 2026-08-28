// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_states.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppState()';
}


}

/// @nodoc
class $AppStateCopyWith<$Res>  {
$AppStateCopyWith(AppState _, $Res Function(AppState) __);
}


/// Adds pattern-matching-related methods to [AppState].
extension AppStatePatterns on AppState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AppStateUnauthenticated value)?  unauthenticated,TResult Function( AppStateAuthenticated value)?  authenticated,TResult Function( AppStateOnboarded value)?  onboarded,TResult Function( AppStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AppStateUnauthenticated() when unauthenticated != null:
return unauthenticated(_that);case AppStateAuthenticated() when authenticated != null:
return authenticated(_that);case AppStateOnboarded() when onboarded != null:
return onboarded(_that);case AppStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AppStateUnauthenticated value)  unauthenticated,required TResult Function( AppStateAuthenticated value)  authenticated,required TResult Function( AppStateOnboarded value)  onboarded,required TResult Function( AppStateError value)  error,}){
final _that = this;
switch (_that) {
case AppStateUnauthenticated():
return unauthenticated(_that);case AppStateAuthenticated():
return authenticated(_that);case AppStateOnboarded():
return onboarded(_that);case AppStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AppStateUnauthenticated value)?  unauthenticated,TResult? Function( AppStateAuthenticated value)?  authenticated,TResult? Function( AppStateOnboarded value)?  onboarded,TResult? Function( AppStateError value)?  error,}){
final _that = this;
switch (_that) {
case AppStateUnauthenticated() when unauthenticated != null:
return unauthenticated(_that);case AppStateAuthenticated() when authenticated != null:
return authenticated(_that);case AppStateOnboarded() when onboarded != null:
return onboarded(_that);case AppStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  unauthenticated,TResult Function()?  authenticated,TResult Function()?  onboarded,TResult Function( Failure failure)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AppStateUnauthenticated() when unauthenticated != null:
return unauthenticated();case AppStateAuthenticated() when authenticated != null:
return authenticated();case AppStateOnboarded() when onboarded != null:
return onboarded();case AppStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  unauthenticated,required TResult Function()  authenticated,required TResult Function()  onboarded,required TResult Function( Failure failure)  error,}) {final _that = this;
switch (_that) {
case AppStateUnauthenticated():
return unauthenticated();case AppStateAuthenticated():
return authenticated();case AppStateOnboarded():
return onboarded();case AppStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  unauthenticated,TResult? Function()?  authenticated,TResult? Function()?  onboarded,TResult? Function( Failure failure)?  error,}) {final _that = this;
switch (_that) {
case AppStateUnauthenticated() when unauthenticated != null:
return unauthenticated();case AppStateAuthenticated() when authenticated != null:
return authenticated();case AppStateOnboarded() when onboarded != null:
return onboarded();case AppStateError() when error != null:
return error(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class AppStateUnauthenticated implements AppState {
  const AppStateUnauthenticated();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppStateUnauthenticated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppState.unauthenticated()';
}


}




/// @nodoc


class AppStateAuthenticated implements AppState {
  const AppStateAuthenticated();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppStateAuthenticated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppState.authenticated()';
}


}




/// @nodoc


class AppStateOnboarded implements AppState {
  const AppStateOnboarded();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppStateOnboarded);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppState.onboarded()';
}


}




/// @nodoc


class AppStateError implements AppState {
  const AppStateError(this.failure);
  

 final  Failure failure;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppStateErrorCopyWith<AppStateError> get copyWith => _$AppStateErrorCopyWithImpl<AppStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppStateError&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'AppState.error(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $AppStateErrorCopyWith<$Res> implements $AppStateCopyWith<$Res> {
  factory $AppStateErrorCopyWith(AppStateError value, $Res Function(AppStateError) _then) = _$AppStateErrorCopyWithImpl;
@useResult
$Res call({
 Failure failure
});




}
/// @nodoc
class _$AppStateErrorCopyWithImpl<$Res>
    implements $AppStateErrorCopyWith<$Res> {
  _$AppStateErrorCopyWithImpl(this._self, this._then);

  final AppStateError _self;
  final $Res Function(AppStateError) _then;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(AppStateError(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}


}

/// @nodoc
mixin _$PaymentState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PaymentState()';
}


}

/// @nodoc
class $PaymentStateCopyWith<$Res>  {
$PaymentStateCopyWith(PaymentState _, $Res Function(PaymentState) __);
}


/// Adds pattern-matching-related methods to [PaymentState].
extension PaymentStatePatterns on PaymentState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PaymentStateStandard value)?  standard,TResult Function( PaymentStatePremium value)?  premium,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PaymentStateStandard() when standard != null:
return standard(_that);case PaymentStatePremium() when premium != null:
return premium(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PaymentStateStandard value)  standard,required TResult Function( PaymentStatePremium value)  premium,}){
final _that = this;
switch (_that) {
case PaymentStateStandard():
return standard(_that);case PaymentStatePremium():
return premium(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PaymentStateStandard value)?  standard,TResult? Function( PaymentStatePremium value)?  premium,}){
final _that = this;
switch (_that) {
case PaymentStateStandard() when standard != null:
return standard(_that);case PaymentStatePremium() when premium != null:
return premium(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  standard,TResult Function()?  premium,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PaymentStateStandard() when standard != null:
return standard();case PaymentStatePremium() when premium != null:
return premium();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  standard,required TResult Function()  premium,}) {final _that = this;
switch (_that) {
case PaymentStateStandard():
return standard();case PaymentStatePremium():
return premium();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  standard,TResult? Function()?  premium,}) {final _that = this;
switch (_that) {
case PaymentStateStandard() when standard != null:
return standard();case PaymentStatePremium() when premium != null:
return premium();case _:
  return null;

}
}

}

/// @nodoc


class PaymentStateStandard implements PaymentState {
  const PaymentStateStandard();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentStateStandard);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PaymentState.standard()';
}


}




/// @nodoc


class PaymentStatePremium implements PaymentState {
  const PaymentStatePremium();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentStatePremium);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PaymentState.premium()';
}


}




// dart format on
