import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../models/puzzle_image.dart';
import '../models/puzzle_mode.dart';
import '../providers/puzzle_provider.dart';

class PuzzleBoardView extends StatelessWidget {
  const PuzzleBoardView({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<PuzzleProvider>();
    final isNumberMode = game.mode == PuzzleMode.numbers;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: isNumberMode ? _buildNumberBoardDecoration() : _buildModernBoardDecoration(context),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = game.difficulty.size;
            // Compact gap matching the reference images (2-3px)
            final gap = size == 3 ? 3.0 : (size == 4 ? 2.5 : 2.0);
            final tileSize = (constraints.maxWidth - gap * (size - 1)) / size;
            final blankIdx = game.blankIndex;

            return ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  // Recessed board bed / background
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isNumberMode ? const Color(0xFF2C1608) : const Color(0xFF131A22),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 6,
                            spreadRadius: 2,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Empty slot recessed floor with indicator icon
                  if (blankIdx >= 0)
                    Positioned(
                      left: (blankIdx % size) * (tileSize + gap),
                      top: (blankIdx ~/ size) * (tileSize + gap),
                      width: tileSize,
                      height: tileSize,
                      child: _EmptySlotView(
                        isNumberTheme: isNumberMode,
                        size: size,
                        blankIndex: blankIdx,
                      ),
                    ),

                  // Animated tiles
                  for (var index = 0; index < game.tiles.length; index++)
                    if (game.tiles[index] != 0)
                      AnimatedPositioned(
                        key: ValueKey('pos-${game.tiles[index]}'),
                        duration: const Duration(milliseconds: 200),
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
                          isAdjacentToBlank: game.canMove(game.tiles[index]),
                          directionToBlank: game.directionToBlank(game.tiles[index]),
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

  BoxDecoration _buildNumberBoardDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFC68449),
          Color(0xFFA76632),
          Color(0xFF8B4D22),
          Color(0xFF6F3B17),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFDCA16A), width: 2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 18,
          spreadRadius: 2,
          offset: Offset(0, 8),
        ),
        BoxShadow(
          color: Color(0x40FFA726),
          blurRadius: 24,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  BoxDecoration _buildModernBoardDecoration(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colors.surfaceContainerHighest,
          colors.surfaceContainerHigh,
          colors.surfaceContainer,
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.8), width: 2),
      boxShadow: [
        BoxShadow(
          color: colors.shadow.withValues(alpha: 0.25),
          blurRadius: 20,
          spreadRadius: 1,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: colors.primary.withValues(alpha: 0.1),
          blurRadius: 30,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty Slot View (Recessed 3D Tray)
// ─────────────────────────────────────────────────────────────────────────────

class _EmptySlotView extends StatelessWidget {
  const _EmptySlotView({
    required this.isNumberTheme,
    required this.size,
    required this.blankIndex,
  });

  final bool isNumberTheme;
  final int size;
  final int blankIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0.5),
      decoration: BoxDecoration(
        color: isNumberTheme ? const Color(0xFF261205) : const Color(0xFF10171F),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isNumberTheme ? const Color(0xFF180A02) : const Color(0xFF080D12),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 4,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.touch_app_rounded,
          size: 20,
          color: (isNumberTheme ? const Color(0xFFDCA16A) : Colors.white).withValues(alpha: 0.18),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Puzzle Tile Widget (Numbers Tile or Photo Tile)
// ─────────────────────────────────────────────────────────────────────────────

class PuzzleTile extends StatefulWidget {
  const PuzzleTile({
    super.key,
    required this.value,
    required this.mode,
    required this.image,
    required this.personalImageBytes,
    required this.totalTiles,
    required this.isAdjacentToBlank,
    required this.directionToBlank,
    required this.onTap,
  });

  final int value;
  final PuzzleMode mode;
  final PuzzleImage image;
  final Uint8List? personalImageBytes;
  final int totalTiles;
  final bool isAdjacentToBlank;
  final (int, int)? directionToBlank;
  final VoidCallback onTap;

  @override
  State<PuzzleTile> createState() => _PuzzleTileState();
}

class _PuzzleTileState extends State<PuzzleTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.mode == PuzzleMode.image) {
      return _buildImageTile(context);
    }
    return _buildNumberTile(context);
  }

  Widget _buildNumberTile(BuildContext context) {
    final size = widget.totalTiles <= 9 ? 3 : (widget.totalTiles <= 16 ? 4 : 5);
    final targetFontSize = size == 3 ? 48.0 : (size == 4 ? 36.0 : 26.0);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 70),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size == 3 ? 8 : 6),
            // Light, warm, high-contrast face
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF2DF),
                Color(0xFFFCE3C5),
                Color(0xFFF3CE9F),
                Color(0xFFE5BB87),
              ],
            ),
            // Uniform border required by Flutter when borderRadius is specified
            border: Border.all(
              color: const Color(0xFFD4A373),
              width: 1.5,
            ),
            boxShadow: [
              // Top-left highlight and bottom-right shadow for 3D bevel depth
              const BoxShadow(
                color: Color(0x99FFFFFF),
                offset: Offset(-1, -1),
                blurRadius: 0,
              ),
              const BoxShadow(
                color: Color(0x607E4A25),
                offset: Offset(1.5, 1.5),
                blurRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Directional hint towards blank slot if adjacent
              if (widget.isAdjacentToBlank && widget.directionToBlank != null)
                Positioned(
                  left: widget.directionToBlank!.$1 == 1 ? null : 4,
                  right: widget.directionToBlank!.$1 == -1 ? null : 4,
                  top: widget.directionToBlank!.$2 == 1 ? null : 4,
                  bottom: widget.directionToBlank!.$2 == -1 ? null : 4,
                  child: _buildDirectionHint(widget.directionToBlank!),
                ),

              // Prominently Visible Number (High Contrast, Bold, Scaled to Fit)
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      '${widget.value}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: targetFontSize,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2C1304), // Deep, bold, high-contrast dark brown
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionHint((int, int) dir) {
    IconData icon;
    if (dir.$1 == -1) {
      icon = Icons.arrow_back_rounded;
    } else if (dir.$1 == 1) {
      icon = Icons.arrow_forward_rounded;
    } else if (dir.$2 == -1) {
      icon = Icons.arrow_upward_rounded;
    } else {
      icon = Icons.arrow_downward_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0x282C1304),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 11,
        color: const Color(0xFF2C1304).withValues(alpha: 0.55),
      ),
    );
  }

  Widget _buildImageTile(BuildContext context) {
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
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 70),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size == 3 ? 7 : 5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 3,
                offset: Offset(0, 1.5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size == 3 ? 6 : 4),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tileSize = constraints.biggest;
                return Stack(
                  fit: StackFit.expand,
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
                    // Uniform border compatible with borderRadius
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(size == 3 ? 6 : 4),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.25),
                            width: 1.0,
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
      ),
    );
  }
}
