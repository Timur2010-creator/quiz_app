import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';


class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._box)
      : super(_box.get(_key) == 'dark' ? ThemeMode.dark : ThemeMode.light);

  static const boxName = 'ui_settings';
  static const _key = 'theme';

  final Box<String> _box;

  Future<void> setDark(bool dark) async {
    final previous = state;
    emit(dark ? ThemeMode.dark : ThemeMode.light);
    try {
      await _box.put(_key, dark ? 'dark' : 'light');
    } catch (_) {
      emit(previous);
      rethrow;
    }
  }
}
