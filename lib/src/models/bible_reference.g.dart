// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_reference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BibleReferenceImpl _$$BibleReferenceImplFromJson(Map<String, dynamic> json) =>
    _$BibleReferenceImpl(
      book: json['book'] as String,
      chapter: (json['chapter'] as num).toInt(),
      verse: (json['verse'] as num).toInt(),
    );

Map<String, dynamic> _$$BibleReferenceImplToJson(
  _$BibleReferenceImpl instance,
) => <String, dynamic>{
  'book': instance.book,
  'chapter': instance.chapter,
  'verse': instance.verse,
};
