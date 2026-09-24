import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final game = context.watch<PuzzleProvider>();
    final provider = context.read<PuzzleProvider>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PuzzleHeader(
                    onReset: provider.newGame,
                    onSettings: () => SettingsView.show(context),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${game.difficulty.label.toUpperCase()} ${game.mode == PuzzleMode.image ? 'IMAGE' : 'NUMBER'}',
                          style: TextStyle(
                            color: colors.onPrimaryContainer,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.swipe_rounded, size: 16, color: colors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  '${game.moves}',
                                  style: TextStyle(color: colors.primary, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.timer_outlined, size: 16, color: colors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  game.formattedTime,
                                  style: TextStyle(color: colors.primary, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (game.mode == PuzzleMode.image)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final sideBySide = constraints.maxWidth >= 620;
                        final board = const PuzzleBoardView();
                        final reference = PuzzleImageReference(
                          image: game.image,
                          personalImageBytes: game.personalImageBytes,
                        );
                        if (sideBySide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: board),
                              const SizedBox(width: 24),
                              SizedBox(width: 120, child: reference),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            SizedBox(width: constraints.maxWidth * .4, child: reference),
                            const SizedBox(height: 24),
                            board,
                          ],
                        );
                      },
                    )
                  else
                    const PuzzleBoardView(),
                  const SizedBox(height: 32),
                  game.isComplete
                      ? CompletionMessage(onNewGame: provider.newGame, moves: game.moves, time: game.formattedTime)
                      : AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            game.mode == PuzzleMode.numbers
                                ? 'Slide the tiles into numerical order'
                                : 'Slide the picture back together',
                            key: ValueKey(game.mode),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 16, fontStyle: FontStyle.italic),
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
