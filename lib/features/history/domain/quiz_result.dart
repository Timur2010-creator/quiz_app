class QuizResult {
  const QuizResult({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.skipped,
    required this.finishedAt,
  });

  final String id;
  final String category;
  final String difficulty;
  final int total;
  final int correct;
  final int wrong;
  final int skipped;
  final DateTime finishedAt;

  int get scorePercent => total == 0 ? 0 : (correct * 100 / total).round();

  Map<String, Object> toMap() => {
        'id': id,
        'category': category,
        'difficulty': difficulty,
        'total': total,
        'correct': correct,
        'wrong': wrong,
        'skipped': skipped,
        'finishedAt': finishedAt.millisecondsSinceEpoch,
      };

  factory QuizResult.fromMap(Map map) => QuizResult(
        id: map['id'] as String,
        category: map['category'] as String,
        difficulty: map['difficulty'] as String,
        total: map['total'] as int,
        correct: map['correct'] as int,
        wrong: map['wrong'] as int,
        skipped: map['skipped'] as int,
        finishedAt: DateTime.fromMillisecondsSinceEpoch(map['finishedAt'] as int),
      );
}
