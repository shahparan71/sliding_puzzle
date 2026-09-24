import 'package:flutter/material.dart';

import '../models/difficulty.dart';

class DifficultySelector extends StatelessWidget {
  const DifficultySelector({super.key, required this.selected, required this.onChanged});

  final Difficulty selected;
  final ValueChanged<Difficulty> onChanged;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<Difficulty>(
              segments: Difficulty.values
                  .map((difficulty) => ButtonSegment(value: difficulty, label: Text(difficulty.label)))
                  .toList(),
              selected: {selected},
              onSelectionChanged: (value) => onChanged(value.first),
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
            ),
          ),
        ],
      ),
    );
  }
}
