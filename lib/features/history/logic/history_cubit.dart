import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/features/history/data/history_repository.dart';
import 'package:quiz_app/features/history/domain/quiz_result.dart';


class HistoryState {
  const HistoryState({
    this.items = const [],
    this.loading = true,
    this.error,
  });

  final List<QuizResult> items;
  final bool loading;
  final String? error;
}

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(this._repository) : super(const HistoryState()) {
    _subscription = _repository.changes.listen((_) => load());
  }

  final HistoryRepository _repository;
  late final StreamSubscription<void> _subscription;

  Future<void> load() async {
    try {
      final results = await _repository.readAll();
      if (!isClosed) emit(HistoryState(items: results, loading: false));
    } catch (error) {
      if (!isClosed) emit(HistoryState(loading: false, error: '$error'));
    }
  }

  Future<void> remove(String id) async {
    await _repository.remove(id);
    await load();
  }

  Future<void> clear() async {
    await _repository.clear();
    await load();
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
