import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/features/history/data/history_repository.dart';
import 'package:quiz_app/features/history/domain/quiz_result.dart';
import 'package:quiz_app/features/quiz/domain/question.dart';
import 'package:quiz_app/features/quiz/domain/quiz_config.dart';


enum SaveStatus { saving, saved, failed }

class QuizState {
  const QuizState({
    required this.questions,
    required this.picks,
    this.index = 0,
    this.secondsLeft = QuizCubit.secondsPerQuestion,
    this.revealed = false,
    this.result,
    this.saveStatus = SaveStatus.saving,
  });

  factory QuizState.start(List<Question> questions) => QuizState(
        questions: List.unmodifiable(questions),
        picks: List<int?>.filled(questions.length, null),
      );

  final List<Question> questions;

  /// Chosen option per question; `null` means skipped or timed out.
  final List<int?> picks;
  final int index;
  final int secondsLeft;

  /// True while the right/wrong colours are shown for the current question.
  final bool revealed;
  final QuizResult? result;
  final SaveStatus saveStatus;

  Question get current => questions[index];
  int? get currentPick => picks[index];
  double get progress => (index + 1) / questions.length;
  bool get isFinished => result != null;

  int get correctCount {
    var count = 0;
    for (var i = 0; i < questions.length; i++) {
      if (picks[i] == questions[i].correctIndex) count++;
    }
    return count;
  }

  int get skippedCount => picks.where((pick) => pick == null).length;

  int get wrongCount => questions.length - correctCount - skippedCount;

  QuizState copyWith({
    List<int?>? picks,
    int? index,
    int? secondsLeft,
    bool? revealed,
    QuizResult? result,
    SaveStatus? saveStatus,
  }) =>
      QuizState(
        questions: questions,
        picks: picks ?? this.picks,
        index: index ?? this.index,
        secondsLeft: secondsLeft ?? this.secondsLeft,
        revealed: revealed ?? this.revealed,
        result: result ?? this.result,
        saveStatus: saveStatus ?? this.saveStatus,
      );
}

class QuizCubit extends Cubit<QuizState> {
  QuizCubit({
    required this.config,
    required List<Question> questions,
    required HistoryRepository history,
  })  : assert(questions.isNotEmpty),
        _history = history,
        super(QuizState.start(questions)) {
    _startCountdown();
  }

  static const secondsPerQuestion = 15;
  static const _revealDelay = Duration(milliseconds: 900);

  final QuizConfig config;
  final HistoryRepository _history;
  Timer? _ticker;
  Timer? _advanceTimer;

  void pick(int option) {
    if (state.revealed || state.isFinished) return;
    if (option < 0 || option >= state.current.options.length) return;

    _ticker?.cancel();
    final picks = List<int?>.of(state.picks)..[state.index] = option;
    emit(state.copyWith(picks: picks, revealed: true));
    _advanceTimer = Timer(_revealDelay, _advance);
  }

  void skip() {
    if (state.isFinished) return;
    _ticker?.cancel();
    _advanceTimer?.cancel();
    _advance();
  }

  Future<void> retrySave() async {
    final result = state.result;
    if (result == null || state.saveStatus == SaveStatus.saving) return;
    emit(state.copyWith(saveStatus: SaveStatus.saving));
    await _persist(result);
  }

  void _startCountdown() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _onTick(Timer _) {
    if (state.revealed || state.isFinished) return;
    final left = state.secondsLeft - 1;
    if (left <= 0) {
      _ticker?.cancel();
      emit(state.copyWith(secondsLeft: 0, revealed: true));
      _advanceTimer = Timer(_revealDelay, _advance);
    } else {
      emit(state.copyWith(secondsLeft: left));
    }
  }

  void _advance() {
    _advanceTimer?.cancel();
    if (isClosed || state.isFinished) return;

    if (state.index + 1 >= state.questions.length) {
      unawaited(_finish());
      return;
    }
    emit(
      state.copyWith(
        index: state.index + 1,
        secondsLeft: secondsPerQuestion,
        revealed: false,
      ),
    );
    _startCountdown();
  }

  Future<void> _finish() async {
    _ticker?.cancel();
    final now = DateTime.now();
    final result = QuizResult(
      id: now.microsecondsSinceEpoch.toString(),
      category: config.category.name,
      difficulty: config.difficulty.label,
      total: state.questions.length,
      correct: state.correctCount,
      wrong: state.wrongCount,
      skipped: state.skippedCount,
      finishedAt: now,
    );
    emit(state.copyWith(result: result, saveStatus: SaveStatus.saving));
    await _persist(result);
  }

  Future<void> _persist(QuizResult result) async {
    try {
      await _history.save(result);
      if (!isClosed) emit(state.copyWith(saveStatus: SaveStatus.saved));
    } catch (_) {
      if (!isClosed) emit(state.copyWith(saveStatus: SaveStatus.failed));
    }
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    _advanceTimer?.cancel();
    return super.close();
  }
}
