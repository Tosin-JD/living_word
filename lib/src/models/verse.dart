import 'package:freezed_annotation/freezed_annotation.dart';
import 'bible_reference.dart';

part 'verse.freezed.dart';
part 'verse.g.dart';

@freezed
class Verse with _$Verse {
  const factory Verse({
    required BibleReference reference,
    required String text,
  }) = _Verse;

  factory Verse.fromJson(Map<String, dynamic> json) => _$VerseFromJson(json);
}
