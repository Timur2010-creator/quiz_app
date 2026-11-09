import 'package:flutter/foundation.dart';

@immutable
class TriviaCategory {
  const TriviaCategory({required this.id, required this.name});

  /// Pseudo-category that means "no category filter".
  static const any = TriviaCategory(id: 0, name: 'Mixed');

  final int id;
  final String name;

  bool get isAny => id == 0;

  @override
  bool operator ==(Object other) => other is TriviaCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
