import 'package:flutter/material.dart';

import '../theme/quiz_palette.dart';

class LabeledDropdown<T> extends StatelessWidget {
  const LabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T item) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: palette.textMuted)),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: palette.field,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: palette.line),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              borderRadius: BorderRadius.circular(8),
              dropdownColor: palette.card,
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  color: palette.textPrimary),
              items: [
                for (final item in items)
                  DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      labelOf(item),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
              ],
              onChanged: (next) {
                if (next != null) onChanged(next);
              },
            ),
          ),
        ),
      ],
    );
  }
}
