import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/puzzle_provider.dart';

class PuzzleBoardView extends StatelessWidget {
  const PuzzleBoardView({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<PuzzleProvider>();
    final colors = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 7)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: game.tiles.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: game.difficulty.size,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final tile = game.tiles[index];
              return tile == 0
                  ? const SizedBox.expand()
                  : PuzzleTile(
                      key: ValueKey('tile-$tile'),
                      value: tile,
                      onTap: () => context.read<PuzzleProvider>().move(tile),
                    );
            },
          ),
        ),
      ),
    );
  }
}

class PuzzleTile extends StatelessWidget {
  const PuzzleTile({super.key, required this.value, required this.onTap});

  final int value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(
            '$value',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
