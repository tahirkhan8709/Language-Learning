import 'package:material_ui/material_ui.dart';

enum LessonCategory {
  vocabulary(
    'Vocabulary',
    'Everyday words',
    Icons.menu_book_rounded,
    Color(0xFF14B8A6),
  ),
  phrases(
    'Phrases',
    'Greetings and useful expressions',
    Icons.chat_bubble_rounded,
    Color(0xFFF97316),
  ),
  grammar(
    'Grammar',
    'Sentence patterns and rules',
    Icons.rule_rounded,
    Color(0xFF6366F1),
  );

  const LessonCategory(this.label, this.description, this.icon, this.color);

  final String label;
  final String description;
  final IconData icon;
  final Color color;
}
