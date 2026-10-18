import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../models/puzzle_mode.dart';
import '../../providers/puzzle_provider.dart';
import '../../widgets/completion_message.dart';
import '../../widgets/image_puzzle_controls.dart';
import '../../widgets/puzzle_board_view.dart';
import '../../widgets/puzzle_header.dart';
import '../settings/settings_view.dart';

class PuzzleView extends StatelessWidget {
  const PuzzleView({super.key});

  void _showImagePreviewDialog(BuildContext context, PuzzleProvider game) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 24, offset: Offset(0, 10)),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Original Picture',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: game.personalImageBytes == null
                            ? SvgPicture.asset(game.image.assetPath, fit: BoxFit.cover)
                            : Image.memory(game.personalImageBytes!, fit: BoxFit.cover),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<PuzzleProvider>();
    final provider = context.read<PuzzleProvider>();
    final colors = Theme.of(context).colorScheme;

    final isNumberMode = game.mode == PuzzleMode.numbers;
    final modeLabel = isNumberMode ? 'NUMBERS' : 'IMAGE';
    final diffLabel = game.difficulty.label.toUpperCase();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Bar Header with Back Button
                  PuzzleHeader(
                    title: 'Board',
                    onBack: () => Navigator.of(context).pop(),
                    onReset: provider.newGame,
                    onSettings: () => SettingsView.show(context),
                    onToggleSound: provider.toggleSound,
                    isSoundEnabled: game.soundEnabled,
                  ),
                  const SizedBox(height: 18),

                  // Interactive Status Bar with Target Picture preview on the right of chips
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colors.surfaceContainerHigh.withValues(alpha: 0.8),
                              colors.surfaceContainerHighest.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadow.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Mode Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isNumberMode
                                      ? const [Color(0xFF8D5328), Color(0xFFC7844A)]
                                      : [colors.primary, colors.secondary],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isNumberMode ? const Color(0xFF8D5328) : colors.primary).withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isNumberMode ? Icons.pin_rounded : Icons.photo_library_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$modeLabel · $diffLabel',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 10,),
                            // Moves and Timer Chips + Target Preview on the right side
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _InteractiveStatChip(
                                  icon: Icons.touch_app_rounded,
                                  label: '${game.moves}',
                                  unit: 'moves',
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 8),
                                _InteractiveStatChip(
                                  icon: Icons.timer_rounded,
                                  label: game.formattedTime,
                                  unit: '',
                                  color: const Color(0xFF00897B),
                                ),
                                // Always visible target image preview to the right of Moves & Timer chips

                              ],
                            ),

                          ],
                        ),
                      ),
                      if (game.mode == PuzzleMode.image) ...[
                        const SizedBox(width: 10),
                        _TargetPreviewThumbnail(
                          game: game,
                          onTap: () => _showImagePreviewDialog(context, game),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Puzzle Board & Win Overlay Stack
                  Builder(
                    builder: (context) {
                      final boardWidget = Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 400),
                            opacity: game.isComplete ? 0.3 : 1.0,
                            child: IgnorePointer(
                              ignoring: game.isComplete,
                              child: const PuzzleBoardView(),
                            ),
                          ),
                          if (game.isComplete)
                            CompletionMessage(
                              onNewGame: provider.newGame,
                              onHome: () => Navigator.of(context).pop(),
                              moves: game.moves,
                              time: game.formattedTime,
                              gridSize: game.difficulty.size,
                            ),
                        ],
                      );

                      if (game.mode == PuzzleMode.image) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final sideBySide = constraints.maxWidth >= 640;
                            if (sideBySide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: boardWidget),
                                  const SizedBox(width: 24),
                                  SizedBox(
                                    width: 140,
                                    child: Column(
                                      children: [
                                        PuzzleImageReference(
                                          image: game.image,
                                          personalImageBytes: game.personalImageBytes,
                                        ),
                                        const SizedBox(height: 10),
                                        TextButton.icon(
                                          onPressed: () => _showImagePreviewDialog(context, game),
                                          icon: const Icon(Icons.fullscreen_rounded, size: 18),
                                          label: const Text('Enlarge Photo'),
                                          style: TextButton.styleFrom(
                                            visualDensity: VisualDensity.compact,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }

                            // On mobile/portrait, the target image is now permanently visible in the status bar
                            return boardWidget;
                          },
                        );
                      }

                      return boardWidget;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Bottom Action Tip / Interactive bar
                  AnimatedOpacity(
                    opacity: game.isComplete ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isNumberMode ? Icons.swap_horiz_rounded : Icons.auto_awesome_rounded,
                            size: 18,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isNumberMode
                                  ? 'Tap any tile adjacent to the empty slot to slide it'
                                  : 'Slide tiles to restore the image (preview in top-right)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TargetPreviewThumbnail extends StatelessWidget {
  const _TargetPreviewThumbnail({
    required this.game,
    required this.onTap,
  });

  final PuzzleProvider game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: 'Target picture (tap to enlarge)',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.7),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: game.personalImageBytes == null
                    ? SvgPicture.asset(game.image.assetPath, fit: BoxFit.cover)
                    : Image.memory(game.personalImageBytes!, fit: BoxFit.cover),
              ),
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Icon(
                    Icons.zoom_in_rounded,
                    size: 9,
                    color: Colors.white,
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

class _InteractiveStatChip extends StatelessWidget {
  const _InteractiveStatChip({
    required this.icon,
    required this.label,
    required this.unit,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (unit.isNotEmpty) ...[
            const SizedBox(width: 3),
            Text(
              unit,
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
