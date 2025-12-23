import 'package:freezed_annotation/freezed_annotation.dart';

part 'bible_reference.freezed.dart';
part 'bible_reference.g.dart';

@freezed
class BibleReference with _$BibleReference {
  const factory BibleReference({
    required String book,
    required int chapter,
    required int verse,
  }) = _BibleReference;

  factory BibleReference.fromJson(Map<String, dynamic> json) =>
      _$BibleReferenceFromJson(json);
}
