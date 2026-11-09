import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/core/theme/quiz_palette.dart';
import 'package:quiz_app/core/widgets/labeled_dropdown.dart';
import 'package:quiz_app/features/quiz/data/trivia_client.dart';
import 'package:quiz_app/features/quiz/domain/quiz_config.dart';
import 'package:quiz_app/features/quiz/domain/trivia_category.dart';
import 'package:quiz_app/features/quiz/logic/setup_cubit.dart';
import 'package:quiz_app/features/quiz/ui/quiz_flow_page.dart';


class QuizSetupPage extends StatelessWidget {
  const QuizSetupPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => SetupCubit(TriviaClient())..loadCategories(),
        child: const _SetupBody(),
      );
}

class _SetupBody extends StatelessWidget {
  const _SetupBody();

  Future<void> _startQuiz(BuildContext context) async {
    final session = await context.read<SetupCubit>().startQuiz();
    if (session == null || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => QuizFlowPage(session: session)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cubit = context.read<SetupCubit>();

    return BlocBuilder<SetupCubit, SetupState>(
      builder: (context, state) => Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quiz',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(child: _QuizBadge()),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Text(
                        'Questions amount:',
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.textMuted,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${state.amount}',
                        style: TextStyle(
                          fontSize: 14,
                          color: palette.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      activeTrackColor: palette.accent,
                      thumbColor: palette.accent,
                      inactiveTrackColor: palette.track,
                      overlayColor: palette.accent.withValues(alpha: 0.12),
                    ),
                    child: Slider(
                      min: 1,
                      max: 10,
                      divisions: 9,
                      value: state.amount.toDouble(),
                      onChanged: (value) => cubit.setAmount(value.round()),
                    ),
                  ),
                  LabeledDropdown<TriviaCategory>(
                    label: 'Category',
                    value: state.category,
                    items: [TriviaCategory.any, ...state.categories],
                    labelOf: (category) => category.name,
                    onChanged: cubit.setCategory,
                  ),
                  if (state.categoriesStatus == LoadStatus.loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  if (state.categoriesStatus == LoadStatus.failed)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              state.categoriesError ??
                                  'Could not load categories.',
                              style: TextStyle(
                                fontSize: 11,
                                color: palette.danger,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Retry',
                            onPressed: cubit.loadCategories,
                            icon: Icon(Icons.refresh, color: palette.brand),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),
                  LabeledDropdown<Difficulty>(
                    label: 'Difficulty',
                    value: state.difficulty,
                    items: Difficulty.values,
                    labelOf: (difficulty) => difficulty.label,
                    onChanged: cubit.setDifficulty,
                  ),
                  const SizedBox(height: 14),
                  LabeledDropdown<QuestionFormat>(
                    label: 'Type',
                    value: state.format,
                    items: QuestionFormat.values,
                    labelOf: (format) => format.label,
                    onChanged: cubit.setFormat,
                  ),
                ],
              ),
            ),
          ),
          if (state.startError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 0),
              child: Text(
                state.startError!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: palette.danger),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
            child: SizedBox(
              width: 200,
              height: 48,
              child: FilledButton(
                onPressed: state.starting ? null : () => _startQuiz(context),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.brand,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      palette.brand.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: state.starting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'START',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizBadge extends StatelessWidget {
  const _QuizBadge();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.accent.withValues(alpha: 0.12),
      ),
      child: Icon(
        Icons.hourglass_bottom_rounded,
        size: 42,
        color: palette.accent,
      ),
    );
  }
}
