import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/features/quiz/data/trivia_client.dart';
import 'package:quiz_app/features/quiz/domain/question.dart';
import 'package:quiz_app/features/quiz/domain/quiz_config.dart';
import 'package:quiz_app/features/quiz/domain/trivia_category.dart';


typedef QuizSession = ({QuizConfig config, List<Question> questions});

enum LoadStatus { loading, ready, failed }

class SetupState {
  const SetupState({
    this.categoriesStatus = LoadStatus.loading,
    this.categories = const [],
    this.categoriesError,
    this.amount = 10,
    this.category = TriviaCategory.any,
    this.difficulty = Difficulty.any,
    this.format = QuestionFormat.any,
    this.starting = false,
    this.startError,
  });

  final LoadStatus categoriesStatus;
  final List<TriviaCategory> categories;
  final String? categoriesError;
  final int amount;
  final TriviaCategory category;
  final Difficulty difficulty;
  final QuestionFormat format;
  final bool starting;
  final String? startError;

  /// Nullable fields are passed as getters so that `() => null` can clear them.
  SetupState copyWith({
    LoadStatus? categoriesStatus,
    List<TriviaCategory>? categories,
    ValueGetter<String?>? categoriesError,
    int? amount,
    TriviaCategory? category,
    Difficulty? difficulty,
    QuestionFormat? format,
    bool? starting,
    ValueGetter<String?>? startError,
  }) =>
      SetupState(
        categoriesStatus: categoriesStatus ?? this.categoriesStatus,
        categories: categories ?? this.categories,
        categoriesError:
            categoriesError != null ? categoriesError() : this.categoriesError,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        difficulty: difficulty ?? this.difficulty,
        format: format ?? this.format,
        starting: starting ?? this.starting,
        startError: startError != null ? startError() : this.startError,
      );
}

class SetupCubit extends Cubit<SetupState> {
  SetupCubit(this._client) : super(const SetupState());

  final TriviaClient _client;

  Future<void> loadCategories() async {
    emit(
      state.copyWith(
        categoriesStatus: LoadStatus.loading,
        categoriesError: () => null,
      ),
    );
    try {
      final categories = await _client.loadCategories();
      if (isClosed) return;
      emit(
        state.copyWith(
          categoriesStatus: LoadStatus.ready,
          categories: categories,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          categoriesStatus: LoadStatus.failed,
          categoriesError: () => _messageOf(error),
        ),
      );
    }
  }

  void setAmount(int value) => emit(state.copyWith(amount: value));

  void setCategory(TriviaCategory value) =>
      emit(state.copyWith(category: value));

  void setDifficulty(Difficulty value) =>
      emit(state.copyWith(difficulty: value));

  void setFormat(QuestionFormat value) => emit(state.copyWith(format: value));

  /// Loads the questions for the current selection. Returns `null` on failure
  /// (the reason is then available in [SetupState.startError]).
  Future<QuizSession?> startQuiz() async {
    if (state.starting) return null;
    emit(state.copyWith(starting: true, startError: () => null));

    final config = QuizConfig(
      amount: state.amount,
      category: state.category,
      difficulty: state.difficulty,
      format: state.format,
    );
    try {
      final questions = await _client.loadQuestions(config);
      if (isClosed) return null;
      emit(state.copyWith(starting: false));
      return (config: config, questions: questions);
    } catch (error) {
      if (isClosed) return null;
      emit(state.copyWith(starting: false, startError: () => _messageOf(error)));
      return null;
    }
  }

  String _messageOf(Object error) => error is TriviaException
      ? error.message
      : 'Something went wrong. Please try again.';

  @override
  Future<void> close() {
    _client.close();
    return super.close();
  }
}
