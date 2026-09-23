import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../providers/puzzle_provider.dart';
import '../models/puzzle_mode.dart';
import '../models/puzzle_image.dart';

class PuzzleBoardView extends StatelessWidget {
  const PuzzleBoardView({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<PuzzleProvider>();
    final colors = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: .16),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = game.difficulty.size;
            final gap = 8.0;
            final tileSize = (constraints.maxWidth - gap * (size - 1)) / size;

            return DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: .45),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                children: [
                  for (var index = 0; index < game.tiles.length; index++)
                    if (game.tiles[index] != 0)
                      AnimatedPositioned(
                        key: ValueKey('position-${game.tiles[index]}'),
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        left: (index % size) * (tileSize + gap),
                        top: (index ~/ size) * (tileSize + gap),
                        width: tileSize,
                        height: tileSize,
                        child: PuzzleTile(
                          key: ValueKey('tile-${game.tiles[index]}'),
                          value: game.tiles[index],
                          mode: game.mode,
                          image: game.image,
                          onTap: () => context.read<PuzzleProvider>().move(game.tiles[index]),
                        ),
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class PuzzleTile extends StatelessWidget {
  const PuzzleTile({super.key, required this.value, required this.mode, required this.image, required this.onTap});

  final int value;
  final PuzzleMode mode;
  final PuzzleImage image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (mode == PuzzleMode.image) {
      return _ImagePuzzleTile(value: value, image: image, onTap: onTap);
    }

    return Material(
      color: colors.primaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: colors.primary.withValues(alpha: .16),
        highlightColor: colors.primary.withValues(alpha: .08),
        child: Center(
          child: Text(
            '$value',
            style: TextStyle(
              color: colors.onPrimaryContainer,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagePuzzleTile extends StatelessWidget {
  const _ImagePuzzleTile({required this.value, required this.image, required this.onTap});

  final int value;
  final PuzzleImage image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = context.read<PuzzleProvider>().difficulty.size;
    final sourceIndex = value - 1;

    return Material(
      color: colors.surfaceContainerHighest,
      borderRadius: BorderRadius.zero,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        splashColor: colors.primary.withValues(alpha: .18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tileSize = constraints.biggest;
            return Stack(
              children: [
                Positioned(
                  left: -(sourceIndex % size) * tileSize.width,
                  top: -(sourceIndex ~/ size) * tileSize.height,
                  width: tileSize.width * size,
                  height: tileSize.height * size,
                  child: SvgPicture.asset(
                    image.assetPath,
                    fit: BoxFit.fill,
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withValues(alpha: .22), width: 1),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
