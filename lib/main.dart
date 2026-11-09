import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/quiz_app.dart';
import 'features/history/data/history_repository.dart';
import 'features/settings/logic/theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final historyBox = await Hive.openBox<Map>(HiveHistoryRepository.boxName);
  final settingsBox = await Hive.openBox<String>(ThemeCubit.boxName);

  runApp(
    QuizApp(
      historyRepository: HiveHistoryRepository(historyBox),
      themeCubit: ThemeCubit(settingsBox),
    ),
  );
}
