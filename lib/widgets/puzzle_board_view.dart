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
    final isWoodTheme = game.mode == PuzzleMode.numbers;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: isWoodTheme ? _buildWoodBoardDecoration() : _buildModernBoardDecoration(context),
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
                        color: isWoodTheme ? const Color(0xFF2C1608) : const Color(0xFF131A22),
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

                  // Empty slot recessed floor with subtle indicator arrow (as in reference image 1)
                  if (blankIdx >= 0)
                    Positioned(
                      left: (blankIdx % size) * (tileSize + gap),
                      top: (blankIdx ~/ size) * (tileSize + gap),
                      width: tileSize,
                      height: tileSize,
                      child: _EmptySlotView(
                        isWood: isWoodTheme,
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

  BoxDecoration _buildWoodBoardDecoration() {
    return BoxDecoration(
      // Multi-layer beveled wood frame matching Image 1
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
// Empty Slot View (Recessed 3D Tray + Subtle Directional Arrow)
// ─────────────────────────────────────────────────────────────────────────────

class _EmptySlotView extends StatelessWidget {
  const _EmptySlotView({
    required this.isWood,
    required this.size,
    required this.blankIndex,
  });

  final bool isWood;
  final int size;
  final int blankIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0.5),
      decoration: BoxDecoration(
        color: isWood ? const Color(0xFF261205) : const Color(0xFF10171F),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isWood ? const Color(0xFF180A02) : const Color(0xFF080D12),
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
          color: (isWood ? const Color(0xFFDCA16A) : Colors.white).withValues(alpha: 0.15),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Puzzle Tile Widget (Wood 3D or Photo Tile)
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
    return _buildWoodTile(context);
  }

  Widget _buildWoodTile(BuildContext context) {
    final size = widget.totalTiles <= 9 ? 3 : (widget.totalTiles <= 16 ? 4 : 5);
    final fontSize = size == 3 ? 46.0 : (size == 4 ? 34.0 : 26.0);

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
            // Wood surface gradient (Light warm pine / maple matching image 1)
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFBE4C8),
                Color(0xFFF2D1A9),
                Color(0xFFE4BC8F),
                Color(0xFFD6A977),
              ],
            ),
            // Realistic 3D beveled wood edges (light at top/left, shadow at bottom/right)
            border: Border(
              top: const BorderSide(color: Color(0xFFFFF7ED), width: 2.2),
              left: const BorderSide(color: Color(0xFFFFF0DC), width: 1.8),
              right: const BorderSide(color: Color(0xFF9E683E), width: 2.0),
              bottom: const BorderSide(color: Color(0xFF7E4A25), width: 2.8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Subtle fine wood grain streaks
              Positioned.fill(
                child: CustomPaint(
                  painter: _WoodGrainPainter(),
                ),
              ),

              // Subtle guide arrow towards blank slot if adjacent (as shown in reference image 1!)
              if (widget.isAdjacentToBlank && widget.directionToBlank != null)
                Positioned(
                  left: widget.directionToBlank!.$1 == 1 ? null : 4,
                  right: widget.directionToBlank!.$1 == -1 ? null : 4,
                  top: widget.directionToBlank!.$2 == 1 ? null : 4,
                  bottom: widget.directionToBlank!.$2 == -1 ? null : 4,
                  child: _buildDirectionHint(widget.directionToBlank!),
                ),

              // Carved / Engraved Number
              Center(
                child: Text(
                  '${widget.value}',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF5A2A0C), // Dark warm mahogany
                    shadows: const [
                      // Inset shadow creating engraved look
                      Shadow(
                        color: Color(0xAA1C0A02),
                        offset: Offset(0, 1.8),
                        blurRadius: 1.2,
                      ),
                      // Bottom highlight for carved bevel edge
                      Shadow(
                        color: Color(0x80FFFFFF),
                        offset: Offset(0, -1),
                        blurRadius: 0.5,
                      ),
                    ],
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
        color: const Color(0x335A2A0C),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 11,
        color: const Color(0xFF5A2A0C).withValues(alpha: 0.5),
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
                    // Micro 3D beveled edge highlight & shadow for physical tile feel
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(size == 3 ? 6 : 4),
                          border: Border(
                            top: BorderSide(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 1.2,
                            ),
                            left: BorderSide(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.0,
                            ),
                            right: BorderSide(
                              color: Colors.black.withValues(alpha: 0.35),
                              width: 1.2,
                            ),
                            bottom: BorderSide(
                              color: Colors.black.withValues(alpha: 0.45),
                              width: 1.8,
                            ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Subtle Wood Grain Texture Painter
// ─────────────────────────────────────────────────────────────────────────────

class _WoodGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLight = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final paintDark = Paint()
      ..color = const Color(0xFF6B3E1F).withValues(alpha: 0.06)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final step = size.height / 7;
    for (var i = 1; i <= 6; i++) {
      final y = i * step;
      final path = Path()
        ..moveTo(0, y + (i % 2 == 0 ? 1 : -1))
        ..quadraticBezierTo(size.width * 0.5, y + (i % 3 == 0 ? 2 : -2), size.width, y);
      canvas.drawPath(path, i % 2 == 0 ? paintLight : paintDark);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
