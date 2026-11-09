enum QuestionKind { multiple, boolean }

class Question {
  const Question({
    required this.category,
    required this.text,
    required this.kind,
    required this.options,
    required this.correctIndex,
  });

  final String category;
  final String text;
  final QuestionKind kind;
  final List<String> options;
  final int correctIndex;
}
