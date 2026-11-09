import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../history/data/history_repository.dart';
import '../logic/quiz_cubit.dart';
import '../logic/setup_cubit.dart';
import 'question_page.dart';
import 'result_page.dart';

class QuizFlowPage extends StatelessWidget {
  const QuizFlowPage({super.key, required this.session});

  final QuizSession session;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => QuizCubit(
          config: session.config,
          questions: session.questions,
          history: context.read<HistoryRepository>(),
        ),
        child: BlocBuilder<QuizCubit, QuizState>(
          buildWhen: (previous, current) =>
              previous.isFinished != current.isFinished,
          builder: (context, state) =>
              state.isFinished ? const ResultPage() : const QuestionPage(),
        ),
      );
}
