import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/core/theme/quiz_palette.dart';
import 'package:quiz_app/features/quiz/logic/quiz_cubit.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        final result = state.result!;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      ),
                      Expanded(
                        child: Text(
                          'Result',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: palette.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.check_rounded, size: 120, color: palette.success),
                  const SizedBox(height: 8),
                  Text(
                    'Category: ${result.category}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${result.scorePercent}% correct',
                    style: TextStyle(fontSize: 14, color: palette.textMuted),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCell(
                          label: 'Correct',
                          value: result.correct,
                          color: palette.success,
                        ),
                      ),
                      Expanded(
                        child: _StatCell(
                          label: 'Wrong',
                          value: result.wrong,
                          color: palette.danger,
                        ),
                      ),
                      Expanded(
                        child: _StatCell(
                          label: 'Skipped',
                          value: result.skipped,
                          color: palette.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SaveNotice(status: state.saveStatus),
                  const Spacer(),
                  SizedBox(
                    width: 200,
                    height: 48,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.success,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'Back to home',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
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

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: palette.textMuted)),
      ],
    );
  }
}

class _SaveNotice extends StatelessWidget {
  const _SaveNotice({required this.status});

  final SaveStatus status;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return switch (status) {
      SaveStatus.saving => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Text('Saving result...', style: TextStyle(color: palette.textMuted)),
          ],
        ),
      SaveStatus.saved => Text(
          'Saved to history',
          style: TextStyle(fontSize: 12, color: palette.textMuted),
        ),
      SaveStatus.failed => Column(
          children: [
            Text(
              'Could not save your result.',
              style: TextStyle(color: palette.danger),
            ),
            TextButton(
              onPressed: context.read<QuizCubit>().retrySave,
              child: const Text('Try again'),
            ),
          ],
        ),
    };
  }
}
