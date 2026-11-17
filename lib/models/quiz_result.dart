class QuizResult {
  final String languageLabel;
  final String categoryLabel; // "All topics" or a category name
  final int score;
  final int total;
  final DateTime date;

  const QuizResult({
    required this.languageLabel,
    required this.categoryLabel,
    required this.score,
    required this.total,
    required this.date,
  });

  int get percent => total == 0 ? 0 : ((score / total) * 100).round();

  Map<String, dynamic> toJson() => {
        'languageLabel': languageLabel,
        'categoryLabel': categoryLabel,
        'score': score,
        'total': total,
        'date': date.toIso8601String(),
      };

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      languageLabel: json['languageLabel'] as String,
      categoryLabel: json['categoryLabel'] as String,
      score: (json['score'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
    );
  }
}
