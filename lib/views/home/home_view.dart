import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/puzzle_provider.dart';
import '../settings/settings_view.dart';
import '../../widgets/completion_message.dart';
import '../../widgets/difficulty_selector.dart';
import '../../widgets/puzzle_board_view.dart';
import '../../widgets/puzzle_header.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<PuzzleProvider>();
    final provider = context.read<PuzzleProvider>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PuzzleHeader(
                    onReset: provider.newGame,
                    onSettings: () => SettingsView.show(context),
                  ),
                  const SizedBox(height: 28),
                  DifficultySelector(selected: game.difficulty, onChanged: provider.selectDifficulty),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${game.difficulty.label.toUpperCase()} BOARD',
                        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
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
                  const PuzzleBoardView(),
                  const SizedBox(height: 22),
                  game.isComplete
                      ? CompletionMessage(onNewGame: provider.newGame)
                        : Text(
                          'Slide the tiles into numerical order',
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
