import 'trivia_category.dart';

enum Difficulty {
  any('Any', null),
  easy('Easy', 'easy'),
  medium('Medium', 'medium'),
  hard('Hard', 'hard');

  const Difficulty(this.label, this.apiValue);

  final String label;
  final String? apiValue;
}

enum QuestionFormat {
  any('Any', null),
  multiple('Multiple choice', 'multiple'),
  boolean('True / False', 'boolean');

  const QuestionFormat(this.label, this.apiValue);

  final String label;
  final String? apiValue;
}

class QuizConfig {
  const QuizConfig({
    required this.amount,
    required this.category,
    required this.difficulty,
    required this.format,
  });

  final int amount;
  final TriviaCategory category;
  final Difficulty difficulty;
  final QuestionFormat format;
}
