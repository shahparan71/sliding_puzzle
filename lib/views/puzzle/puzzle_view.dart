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

    final isWood = game.mode == PuzzleMode.numbers;
    final modeLabel = isWood ? 'WOODEN' : 'IMAGE';
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

                  // Interactive Status Bar (Responsive)
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
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Mode Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isWood
                                  ? const [Color(0xFF8D5328), Color(0xFFC7844A)]
                                  : [colors.primary, colors.secondary],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: (isWood ? const Color(0xFF8D5328) : colors.primary).withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isWood ? Icons.grid_view_rounded : Icons.photo_library_rounded,
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

                        // Moves and Timer Chips
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
                          ],
                        ),
                      ],
                    ),
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
                            final reference = Column(
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
                            );

                            if (sideBySide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: boardWidget),
                                  const SizedBox(width: 24),
                                  SizedBox(width: 140, child: reference),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () => _showImagePreviewDialog(context, game),
                                      icon: const Icon(Icons.image_search_rounded, size: 16),
                                      label: const Text('View Target Picture'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                boardWidget,
                              ],
                            );
                          },
                        );
                      }

                      return boardWidget;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Bottom Action Tip / Interactive bar (Safe wrapping with Expanded)
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
                            isWood ? Icons.swap_horiz_rounded : Icons.auto_awesome_rounded,
                            size: 18,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isWood
                                  ? 'Tap any tile adjacent to the empty slot to slide it'
                                  : 'Slide tiles to restore the whole image',
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
