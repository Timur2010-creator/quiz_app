import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/core/theme/quiz_palette.dart';
import 'package:quiz_app/features/quiz/domain/question.dart';
import 'package:quiz_app/features/quiz/logic/quiz_cubit.dart';


enum _Tone { idle, correct, wrong, dimmed }

class QuestionPage extends StatelessWidget {
  const QuestionPage({super.key});

  Color _timerColor(QuizPalette palette, int seconds) {
    if (seconds <= 5) return palette.danger;
    if (seconds <= 10) return palette.warning;
    return palette.success;
  }

  _Tone _toneFor(QuizState state, int option) {
    if (!state.revealed) return _Tone.idle;
    if (option == state.current.correctIndex) return _Tone.correct;
    if (option == state.currentPick) return _Tone.wrong;
    return _Tone.dimmed;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cubit = context.read<QuizCubit>();

    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        final question = state.current;
        final timerColor = _timerColor(palette, state.secondsLeft);

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      ),
                      Expanded(
                        child: Text(
                          question.category,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: palette.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: state.progress,
                      minHeight: 6,
                      backgroundColor: palette.track,
                      valueColor: AlwaysStoppedAnimation(palette.accent),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${state.index + 1}/${state.questions.length}',
                      style: TextStyle(
                        fontSize: 10,
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer_outlined, size: 16, color: timerColor),
                      const SizedBox(width: 4),
                      Text(
                        '${state.secondsLeft} s',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: timerColor,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          Text(
                            question.text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              height: 1.25,
                              color: palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          for (var i = 0; i < question.options.length; i++)
                            _OptionTile(
                              label: question.options[i],
                              tone: _toneFor(state, i),
                              outlined: question.kind == QuestionKind.boolean,
                              onTap: state.revealed ? null : () => cubit.pick(i),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: cubit.skip,
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.skip,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.tone,
    required this.outlined,
    required this.onTap,
  });

  final String label;
  final _Tone tone;
  final bool outlined;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (Color background, Color foreground, Color border) = switch (tone) {
      _Tone.idle => outlined
          ? (Colors.transparent, palette.textPrimary, palette.brand)
          : (palette.brand, Colors.white, palette.brand),
      _Tone.correct => (palette.success, Colors.white, palette.success),
      _Tone.wrong => (palette.danger, Colors.white, palette.danger),
      _Tone.dimmed => (palette.field, palette.textMuted, palette.line),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: border),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 46),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
