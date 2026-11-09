import 'package:hive_flutter/hive_flutter.dart';
import 'package:quiz_app/features/history/domain/quiz_result.dart';

abstract interface class HistoryRepository {
  Future<void> save(QuizResult result);

  Future<List<QuizResult>> readAll();

  Future<void> remove(String id);

  Future<void> clear();

  /// Emits when a result is added, updated, or removed.
  Stream<void> get changes;
}

class HiveHistoryRepository implements HistoryRepository {
  HiveHistoryRepository(this._box);

  static const boxName = 'results_v2';

  final Box<Map> _box;

  @override
  Future<void> save(QuizResult result) => _box.put(result.id, result.toMap());

  @override
  Future<List<QuizResult>> readAll() async {
    final results = _box.values.map(QuizResult.fromMap).toList();
    results.sort(
      (first, second) => second.finishedAt.compareTo(first.finishedAt),
    );
    return results;
  }

  @override
  Future<void> remove(String id) => _box.delete(id);

  @override
  Future<void> clear() async {
    await _box.clear();
  }

  @override
  Stream<void> get changes => _box.watch().map((_) {});
}
