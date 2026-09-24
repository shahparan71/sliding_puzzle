import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/puzzle_mode.dart';
import '../../providers/puzzle_provider.dart';
import '../../widgets/difficulty_selector.dart';
import '../../widgets/image_puzzle_controls.dart';
import '../../widgets/puzzle_header.dart';
import '../settings/settings_view.dart';
import '../puzzle/puzzle_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  Future<void> _pickPersonalImage(BuildContext context) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !context.mounted) return;
    final bytes = await picked.readAsBytes();
    if (context.mounted) context.read<PuzzleProvider>().selectPersonalImage(bytes);
  }

  void _startPuzzle(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PuzzleView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<PuzzleProvider>();
    final provider = context.read<PuzzleProvider>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PuzzleHeader(
                    onReset: provider.newGame,
                    onSettings: () => SettingsView.show(context),
                  ),
                  const SizedBox(height: 34),
                  Text(
                    'Set up your puzzle',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a mode, difficulty, and picture before you begin.',
                    style: TextStyle(color: colors.onSurfaceVariant, fontSize: 16),
                  ),
                  const SizedBox(height: 28),
                  _SetupSection(
                    title: '1. Puzzle type',
                    child: SegmentedButton<PuzzleMode>(
                      segments: PuzzleMode.values
                          .map(
                            (mode) => ButtonSegment(
                              value: mode,
                              icon: Icon(mode == PuzzleMode.numbers ? Icons.pin_outlined : Icons.image_outlined),
                              label: Text(mode.label),
                            ),
                          )
                          .toList(),
                      selected: {game.mode},
                      onSelectionChanged: (value) => provider.selectMode(value.first),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SetupSection(
                    title: '2. Difficulty',
                    child: DifficultySelector(
                      selected: game.difficulty,
                      onChanged: provider.selectDifficulty,
                    ),
                  ),
                  if (game.mode == PuzzleMode.image) ...[
                    const SizedBox(height: 18),
                    _SetupSection(
                      title: '3. Picture',
                      child: ImagePuzzleControls(
                        selected: game.image,
                        onChanged: provider.selectImage,
                        hasPersonalImage: game.personalImageBytes != null,
                        personalImageBytes: game.personalImageBytes,
                        onPickPersonalImage: () => _pickPersonalImage(context),
                        onClearPersonalImage: provider.clearPersonalImage,
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  FilledButton.icon(
                    onPressed: () => _startPuzzle(context),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('Start puzzle'),
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

class _SetupSection extends StatelessWidget {
  const _SetupSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
