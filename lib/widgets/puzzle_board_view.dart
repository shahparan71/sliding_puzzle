import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.surfaceContainerHigh,
              colors.surfaceContainerHighest,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.outlineVariant, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: .2),
              blurRadius: 28,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: colors.primary.withValues(alpha: .06),
              blurRadius: 40,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = game.difficulty.size;
            const gap = 7.0;
            final tileSize = (constraints.maxWidth - gap * (size - 1)) / size;

            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Board background grid hint
                  Positioned.fill(
                    child: CustomPaint(painter: _GridPainter(size: size, gap: gap, color: colors.outlineVariant.withValues(alpha: .3))),
                  ),
                  for (var index = 0; index < game.tiles.length; index++)
                    if (game.tiles[index] != 0)
                      AnimatedPositioned(
                        key: ValueKey('position-${game.tiles[index]}'),
                        duration: const Duration(milliseconds: 240),
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
                          personalImageBytes: game.personalImageBytes,
                          totalTiles: size * size,
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

// ── Ghost grid painter ──────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.size, required this.gap, required this.color});
  final int size;
  final double gap;
  final Color color;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final cell = (canvasSize.width - gap * (size - 1)) / size;
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        final x = c * (cell + gap);
        final y = r * (cell + gap);
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, y, cell, cell), const Radius.circular(10)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.size != size || old.color != color;
}

// ── Tile ─────────────────────────────────────────────────────────────────────

class PuzzleTile extends StatelessWidget {
  const PuzzleTile({
    super.key,
    required this.value,
    required this.mode,
    required this.image,
    required this.personalImageBytes,
    required this.totalTiles,
    required this.onTap,
  });

  final int value;
  final PuzzleMode mode;
  final PuzzleImage image;
  final Uint8List? personalImageBytes;
  final int totalTiles;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (mode == PuzzleMode.image) {
      return _ImagePuzzleTile(
        value: value,
        image: image,
        personalImageBytes: personalImageBytes,
        onTap: onTap,
      );
    }

    // Number tile — gradient card with depth shadow
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primary,
              colors.primaryContainer,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: .35),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Subtle gloss overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 40,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: .18),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                '$value',
                style: TextStyle(
                  color: colors.onPrimary,
                  fontSize: totalTiles <= 4 ? 48 : totalTiles <= 9 ? 36 : 26,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: colors.primary.withValues(alpha: .5),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Image tile ────────────────────────────────────────────────────────────────

class _ImagePuzzleTile extends StatefulWidget {
  const _ImagePuzzleTile({required this.value, required this.image, required this.personalImageBytes, required this.onTap});

  final int value;
  final PuzzleImage image;
  final Uint8List? personalImageBytes;
  final VoidCallback onTap;

  @override
  State<_ImagePuzzleTile> createState() => _ImagePuzzleTileState();
}

class _ImagePuzzleTileState extends State<_ImagePuzzleTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = context.read<PuzzleProvider>().difficulty.size;
    final sourceIndex = widget.value - 1;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
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
                    child: widget.personalImageBytes == null
                        ? SvgPicture.asset(widget.image.assetPath, fit: BoxFit.fill)
                        : Image.memory(widget.personalImageBytes!, fit: BoxFit.fill),
                  ),
                  // Edge highlight
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _pressed
                              ? colors.primary.withValues(alpha: .6)
                              : Colors.white.withValues(alpha: .25),
                          width: _pressed ? 2 : 1,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
