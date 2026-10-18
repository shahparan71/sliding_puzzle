import 'package:flutter/material.dart';
import '../models/difficulty.dart';

class DifficultySelector extends StatelessWidget {
  const DifficultySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Difficulty selected;
  final ValueChanged<Difficulty> onChanged;

  static const _diffData = {
    Difficulty.easy: (
      name: 'Easy',
      grid: '3 × 3',
      tiles: '8 Tiles',
      desc: 'Casual',
      color: Color(0xFF2E7D32),
      gradient: [Color(0xFF43A047), Color(0xFF2E7D32)],
    ),
    Difficulty.medium: (
      name: 'Medium',
      grid: '4 × 4',
      tiles: '15 Tiles',
      desc: 'Classic',
      color: Color(0xFFE65100),
      gradient: [Color(0xFFFB8C00), Color(0xFFE65100)],
    ),
    Difficulty.hard: (
      name: 'Hard',
      grid: '5 × 5',
      tiles: '24 Tiles',
      desc: 'Expert',
      color: Color(0xFFC2185B),
      gradient: [Color(0xFFE91E63), Color(0xFFAD1457)],
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: Difficulty.values.map((diff) {
        final data = _diffData[diff]!;
        final isSelected = selected == diff;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _DifficultyCard(
              difficulty: diff,
              data: data,
              isSelected: isSelected,
              onTap: () => onChanged(diff),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DifficultyCard extends StatefulWidget {
  const _DifficultyCard({
    required this.difficulty,
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  final Difficulty difficulty;
  final ({Color color, String desc, List<Color> gradient, String grid, String name, String tiles}) data;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_DifficultyCard> createState() => _DifficultyCardState();
}

class _DifficultyCardState extends State<_DifficultyCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isSelected = widget.isSelected;
    final data = widget.data;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : (isSelected ? 1.02 : 1.0),
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: data.gradient,
                  )
                : null,
            color: isSelected ? null : colors.surfaceContainerHigh.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? Colors.white.withValues(alpha: 0.6) : colors.outlineVariant.withValues(alpha: 0.5),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: data.color.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.grid,
                style: TextStyle(
                  color: isSelected ? Colors.white : colors.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.name,
                style: TextStyle(
                  color: isSelected ? Colors.white.withValues(alpha: 0.95) : colors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black.withValues(alpha: 0.2) : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  data.tiles,
                  style: TextStyle(
                    color: isSelected ? Colors.white70 : colors.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
