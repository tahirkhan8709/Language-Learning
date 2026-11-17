import 'language.dart';
import 'lesson_category.dart';

/// One word, phrase or sentence to learn.
class LessonItem {
  final String id;
  final Language language;
  final LessonCategory category;
  final String english;
  final String target; // the word/phrase in the language being learned
  final String phonetic; // easy "say it like this" spelling
  final String note; // usage or grammar tip

  const LessonItem({
    required this.id,
    required this.language,
    required this.category,
    required this.english,
    required this.target,
    required this.phonetic,
    required this.note,
  });
}
