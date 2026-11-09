import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/core/theme/quiz_palette.dart';
import 'package:quiz_app/features/history/logic/history_cubit.dart';
import 'package:quiz_app/features/settings/logic/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _setDark(BuildContext context, bool value) async {
    try {
      await context.read<ThemeCubit>().setDark(value);
    } catch (error) {
      if (context.mounted) _toast(context, 'Could not save the theme: $error');
    }
  }

  Future<void> _share(BuildContext context) async {
    await Clipboard.setData(
      const ClipboardData(text: 'Try Quiz and challenge your knowledge!'),
    );
    if (context.mounted) _toast(context, 'Invitation copied to clipboard');
  }

  Future<void> _clearHistory(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('All saved quiz results will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<HistoryCubit>().clear();
      if (context.mounted) _toast(context, 'History cleared');
    } catch (error) {
      if (context.mounted) _toast(context, 'Could not clear history: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
          child: Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
          ),
        ),
        Divider(height: 1, color: palette.line),
        _SettingsTile(
          title: 'Dark mode',
          subtitle: isDark ? 'Easy on the eyes' : 'Light appearance',
          trailing: Switch.adaptive(
            value: isDark,
            onChanged: (value) => _setDark(context, value),
          ),
        ),
        _SettingsTile(
          title: 'Share this app',
          onTap: () => _share(context),
        ),
        _SettingsTile(
          title: 'Rate us',
          onTap: () => _toast(context, 'Store rating is not set up yet.'),
        ),
        _SettingsTile(
          title: 'Leave feedback',
          onTap: () => _toast(context, 'Feedback is not set up yet.'),
        ),
        _SettingsTile(
          title: 'Clear history',
          highlight: true,
          onTap: () => _clearHistory(context),
        ),
        const Spacer(),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'v 1.0.0',
              style: TextStyle(fontSize: 11, color: palette.textMuted),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.highlight = false,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: palette.line)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: highlight ? palette.accent : palette.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 11, color: palette.textMuted),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right, size: 20, color: palette.accent),
          ],
        ),
      ),
    );
  }
}
