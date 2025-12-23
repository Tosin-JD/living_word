// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bible_reference.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BibleReference _$BibleReferenceFromJson(Map<String, dynamic> json) {
  return _BibleReference.fromJson(json);
}

/// @nodoc
mixin _$BibleReference {
  String get book => throw _privateConstructorUsedError;
  int get chapter => throw _privateConstructorUsedError;
  int get verse => throw _privateConstructorUsedError;

  /// Serializes this BibleReference to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BibleReference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BibleReferenceCopyWith<BibleReference> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BibleReferenceCopyWith<$Res> {
  factory $BibleReferenceCopyWith(
    BibleReference value,
    $Res Function(BibleReference) then,
  ) = _$BibleReferenceCopyWithImpl<$Res, BibleReference>;
  @useResult
  $Res call({String book, int chapter, int verse});
}

/// @nodoc
class _$BibleReferenceCopyWithImpl<$Res, $Val extends BibleReference>
    implements $BibleReferenceCopyWith<$Res> {
  _$BibleReferenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BibleReference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? book = null,
    Object? chapter = null,
    Object? verse = null,
  }) {
    return _then(
      _value.copyWith(
            book: null == book
                ? _value.book
                : book // ignore: cast_nullable_to_non_nullable
                      as String,
            chapter: null == chapter
                ? _value.chapter
                : chapter // ignore: cast_nullable_to_non_nullable
                      as int,
            verse: null == verse
                ? _value.verse
                : verse // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BibleReferenceImplCopyWith<$Res>
    implements $BibleReferenceCopyWith<$Res> {
  factory _$$BibleReferenceImplCopyWith(
    _$BibleReferenceImpl value,
    $Res Function(_$BibleReferenceImpl) then,
  ) = __$$BibleReferenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String book, int chapter, int verse});
}

/// @nodoc
class __$$BibleReferenceImplCopyWithImpl<$Res>
    extends _$BibleReferenceCopyWithImpl<$Res, _$BibleReferenceImpl>
    implements _$$BibleReferenceImplCopyWith<$Res> {
  __$$BibleReferenceImplCopyWithImpl(
    _$BibleReferenceImpl _value,
    $Res Function(_$BibleReferenceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BibleReference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? book = null,
    Object? chapter = null,
    Object? verse = null,
  }) {
    return _then(
      _$BibleReferenceImpl(
        book: null == book
            ? _value.book
            : book // ignore: cast_nullable_to_non_nullable
                  as String,
        chapter: null == chapter
            ? _value.chapter
            : chapter // ignore: cast_nullable_to_non_nullable
                  as int,
        verse: null == verse
            ? _value.verse
            : verse // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BibleReferenceImpl implements _BibleReference {
  const _$BibleReferenceImpl({
    required this.book,
    required this.chapter,
    required this.verse,
  });

  factory _$BibleReferenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$BibleReferenceImplFromJson(json);

  @override
  final String book;
  @override
  final int chapter;
  @override
  final int verse;

  @override
  String toString() {
    return 'BibleReference(book: $book, chapter: $chapter, verse: $verse)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BibleReferenceImpl &&
            (identical(other.book, book) || other.book == book) &&
            (identical(other.chapter, chapter) || other.chapter == chapter) &&
            (identical(other.verse, verse) || other.verse == verse));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, book, chapter, verse);

  /// Create a copy of BibleReference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BibleReferenceImplCopyWith<_$BibleReferenceImpl> get copyWith =>
      __$$BibleReferenceImplCopyWithImpl<_$BibleReferenceImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BibleReferenceImplToJson(this);
  }
}

abstract class _BibleReference implements BibleReference {
  const factory _BibleReference({
    required final String book,
    required final int chapter,
    required final int verse,
  }) = _$BibleReferenceImpl;

  factory _BibleReference.fromJson(Map<String, dynamic> json) =
      _$BibleReferenceImpl.fromJson;

  @override
  String get book;
  @override
  int get chapter;
  @override
  int get verse;

  /// Create a copy of BibleReference
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BibleReferenceImplCopyWith<_$BibleReferenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
