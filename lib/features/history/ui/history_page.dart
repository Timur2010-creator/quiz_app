import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/core/theme/quiz_palette.dart';
import 'package:quiz_app/features/history/domain/quiz_result.dart';
import 'package:quiz_app/features/history/logic/history_cubit.dart';


class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Future<void> _delete(BuildContext context, String id) async {
    try {
      await context.read<HistoryCubit>().remove(id);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete the result: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: BlocBuilder<HistoryCubit, HistoryState>(
              builder: (context, state) {
                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Could not load history: ${state.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: palette.danger),
                        ),
                        TextButton(
                          onPressed: context.read<HistoryCubit>().load,
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  );
                }
                if (state.items.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 52,                       color: palette.navIdle),
                      const SizedBox(height: 14),
                      Text(
                        'No quiz results yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Finish a quiz and it will show up here.',
                        style: TextStyle(color: palette.textMuted),
                      ),
                      const SizedBox(height: 60),
                    ],
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final result = state.items[index];
                    return _HistoryCard(
                      result: result,
                      onDelete: () => _delete(context, result.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.result, required this.onDelete});

  final QuizResult result;
  final VoidCallback onDelete;

  static String _stamp(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}.${two(date.month)}.${date.year}  '
        '${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 12),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Category: ${result.category}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: palette.textPrimary,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Options',
                padding: EdgeInsets.zero,
                icon: Icon(Icons.more_horiz, size: 20, color: palette.textMuted),
                onSelected: (value) {
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'delete', child: Text('Delete result')),
                ],
              ),
            ],
          ),
          Text(
            'Correct answers: ${result.correct}/${result.total}',
            style: TextStyle(fontSize: 12, color: palette.textMuted),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Difficulty: ${result.difficulty}',
                  style: TextStyle(fontSize: 12, color: palette.textMuted),
                ),
              ),
              Text(
                _stamp(result.finishedAt),
                style: TextStyle(fontSize: 10, color: palette.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
