import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_theme.dart';
import '../features/history/data/history_repository.dart';
import '../features/history/logic/history_cubit.dart';
import '../features/settings/logic/theme_cubit.dart';
import 'home_shell.dart';

class QuizApp extends StatelessWidget {
  const QuizApp({
    super.key,
    required this.historyRepository,
    required this.themeCubit,
  });

  final HistoryRepository historyRepository;
  final ThemeCubit themeCubit;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<HistoryRepository>.value(
      value: historyRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>.value(value: themeCubit),
          BlocProvider<HistoryCubit>(
            create: (_) => HistoryCubit(historyRepository)..load(),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) => MaterialApp(
            title: 'Quiz',
            debugShowCheckedModeBanner: false,
            themeMode: mode,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            home: const HomeShell(),
          ),
        ),
      ),
    );
  }
}
