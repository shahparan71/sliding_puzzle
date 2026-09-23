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
          padding: const EdgeInsets.fromLTRB(12, 28, 12, 24),
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
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${game.difficulty.label.toUpperCase()} ${game.mode == PuzzleMode.image ? 'IMAGE' : 'NUMBER'} PUZZLE',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.3,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 18, color: colors.primary),
                          const SizedBox(width: 6),
                          Text(
                            game.formattedTime,
                            style: TextStyle(color: colors.primary, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                              const SizedBox(width: 18),
                              SizedBox(width: 95, child: reference),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            SizedBox(width: constraints.maxWidth * .5, child: reference),
                            const SizedBox(height: 16),
                            board,
                          ],
                        );
                      },
                    )
                  else
                    const PuzzleBoardView(),
                  const SizedBox(height: 22),
                  game.isComplete
                      ? CompletionMessage(onNewGame: provider.newGame)
                      : Text(
                          game.mode == PuzzleMode.numbers
                              ? 'Slide the tiles into numerical order'
                              : 'Slide the picture back together',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 15),
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
