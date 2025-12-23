// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verse.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Verse _$VerseFromJson(Map<String, dynamic> json) {
  return _Verse.fromJson(json);
}

/// @nodoc
mixin _$Verse {
  BibleReference get reference => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;

  /// Serializes this Verse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Verse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VerseCopyWith<Verse> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerseCopyWith<$Res> {
  factory $VerseCopyWith(Verse value, $Res Function(Verse) then) =
      _$VerseCopyWithImpl<$Res, Verse>;
  @useResult
  $Res call({BibleReference reference, String text});

  $BibleReferenceCopyWith<$Res> get reference;
}

/// @nodoc
class _$VerseCopyWithImpl<$Res, $Val extends Verse>
    implements $VerseCopyWith<$Res> {
  _$VerseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Verse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? reference = null, Object? text = null}) {
    return _then(
      _value.copyWith(
            reference: null == reference
                ? _value.reference
                : reference // ignore: cast_nullable_to_non_nullable
                      as BibleReference,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of Verse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BibleReferenceCopyWith<$Res> get reference {
    return $BibleReferenceCopyWith<$Res>(_value.reference, (value) {
      return _then(_value.copyWith(reference: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VerseImplCopyWith<$Res> implements $VerseCopyWith<$Res> {
  factory _$$VerseImplCopyWith(
    _$VerseImpl value,
    $Res Function(_$VerseImpl) then,
  ) = __$$VerseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({BibleReference reference, String text});

  @override
  $BibleReferenceCopyWith<$Res> get reference;
}

/// @nodoc
class __$$VerseImplCopyWithImpl<$Res>
    extends _$VerseCopyWithImpl<$Res, _$VerseImpl>
    implements _$$VerseImplCopyWith<$Res> {
  __$$VerseImplCopyWithImpl(
    _$VerseImpl _value,
    $Res Function(_$VerseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Verse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? reference = null, Object? text = null}) {
    return _then(
      _$VerseImpl(
        reference: null == reference
            ? _value.reference
            : reference // ignore: cast_nullable_to_non_nullable
                  as BibleReference,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VerseImpl implements _Verse {
  const _$VerseImpl({required this.reference, required this.text});

  factory _$VerseImpl.fromJson(Map<String, dynamic> json) =>
      _$$VerseImplFromJson(json);

  @override
  final BibleReference reference;
  @override
  final String text;

  @override
  String toString() {
    return 'Verse(reference: $reference, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerseImpl &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, reference, text);

  /// Create a copy of Verse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VerseImplCopyWith<_$VerseImpl> get copyWith =>
      __$$VerseImplCopyWithImpl<_$VerseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VerseImplToJson(this);
  }
}

abstract class _Verse implements Verse {
  const factory _Verse({
    required final BibleReference reference,
    required final String text,
  }) = _$VerseImpl;

  factory _Verse.fromJson(Map<String, dynamic> json) = _$VerseImpl.fromJson;

  @override
  BibleReference get reference;
  @override
  String get text;

  /// Create a copy of Verse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VerseImplCopyWith<_$VerseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
