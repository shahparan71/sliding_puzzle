import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/puzzle_mode.dart';
import '../../providers/puzzle_provider.dart';
import '../../services/sound_service.dart';
import '../../widgets/difficulty_selector.dart';
import '../../widgets/image_puzzle_controls.dart';
import '../../widgets/puzzle_header.dart';
import '../puzzle/puzzle_view.dart';
import '../settings/settings_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  Future<void> _pickPersonalImage(BuildContext context) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !context.mounted) return;
    final bytes = await picked.readAsBytes();
    if (context.mounted) context.read<PuzzleProvider>().selectPersonalImage(bytes);
  }

  void _startPuzzle(BuildContext context) {
    SoundService.instance.playSlide();
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
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Header
                  PuzzleHeader(
                    title: 'PuzzlePlay',
                    onReset: provider.newGame,
                    onSettings: () => SettingsView.show(context),
                    onToggleSound: provider.toggleSound,
                    isSoundEnabled: game.soundEnabled,
                  ),
                  const SizedBox(height: 24),

                  // Hero Banner Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colors.primaryContainer.withValues(alpha: 0.7),
                          colors.surfaceContainerHighest.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD48B47), Color(0xFF8B4D22)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(color: Color(0x408B4D22), blurRadius: 10, offset: Offset(0, 4)),
                            ],
                          ),
                          child: const Icon(Icons.extension_rounded, color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Slide & Solve',
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Choose your style, scramble the tiles, and enjoy tactile sliding mechanics.',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),

                  // 1. Puzzle Style Section
                  _SectionHeader(
                    icon: Icons.auto_awesome_motion_rounded,
                    title: '1. Puzzle Style',
                    subtitle: 'Choose between numbered tiles or picture tiles',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ModeCard(
                          title: 'Number Puzzle',
                          subtitle: 'Classic numbered blocks in numerical order',
                          icon: Icons.pin_rounded,
                          accentColor: const Color(0xFFC7844A),
                          isSelected: game.mode == PuzzleMode.numbers,
                          badge: 'Numbers',
                          onTap: () => provider.selectMode(PuzzleMode.numbers),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ModeCard(
                          title: 'Picture Tile',
                          subtitle: 'Artworks & your own camera photos',
                          icon: Icons.photo_library_rounded,
                          accentColor: const Color(0xFF1976D2),
                          isSelected: game.mode == PuzzleMode.image,
                          badge: 'Photo',
                          onTap: () => provider.selectMode(PuzzleMode.image),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 2. Difficulty Section
                  _SectionHeader(
                    icon: Icons.grid_view_rounded,
                    title: '2. Grid Difficulty',
                    subtitle: 'Choose the dimensions of the sliding board',
                  ),
                  const SizedBox(height: 12),
                  DifficultySelector(
                    selected: game.difficulty,
                    onChanged: provider.selectDifficulty,
                  ),
                  const SizedBox(height: 24),

                  // 3. Picture Section (if Image mode)
                  if (game.mode == PuzzleMode.image) ...[
                    _SectionHeader(
                      icon: Icons.image_rounded,
                      title: '3. Select Artwork',
                      subtitle: 'Choose a preset illustration or upload yours',
                    ),
                    const SizedBox(height: 12),
                    ImagePuzzleControls(
                      selected: game.image,
                      onChanged: provider.selectImage,
                      hasPersonalImage: game.personalImageBytes != null,
                      personalImageBytes: game.personalImageBytes,
                      onPickPersonalImage: () => _pickPersonalImage(context),
                      onClearPersonalImage: provider.clearPersonalImage,
                    ),
                    const SizedBox(height: 26),
                  ],

                  // Start Game CTA Button
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE65100),
                          Color(0xFFF57C00),
                          Color(0xFFFF9800),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE65100).withValues(alpha: 0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => _startPuzzle(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_circle_fill_rounded, size: 26, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'START PUZZLE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colors.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
    required this.badge,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.12) : colors.surfaceContainerHigh.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : colors.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 2.2 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor : colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected ? Colors.white : colors.onSurfaceVariant,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor : colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: isSelected ? Colors.white : colors.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? accentColor : colors.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 11,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
