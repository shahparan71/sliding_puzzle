import 'package:flutter/material.dart';

class CompletionMessage extends StatefulWidget {
  const CompletionMessage({super.key, required this.onNewGame, required this.moves, required this.time});

  final VoidCallback onNewGame;
  final int moves;
  final String time;

  @override
  State<CompletionMessage> createState() => _CompletionMessageState();
}

class _CompletionMessageState extends State<CompletionMessage> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.primaryContainer,
                colors.secondaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.primary.withValues(alpha: .35), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: .18),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy icon with glow
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .12),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: colors.primary.withValues(alpha: .25), blurRadius: 16),
                  ],
                ),
                child: Icon(Icons.emoji_events_rounded, size: 30, color: colors.primary),
              ),
              const SizedBox(height: 10),
              Text(
                'Puzzle Solved!',
                style: textTheme.headlineSmall?.copyWith(
                  color: colors.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Excellent work — you cracked it!',
                style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatChip(icon: Icons.timer_outlined, label: widget.time, colors: colors, textTheme: textTheme),
                  const SizedBox(width: 10),
                  _StatChip(icon: Icons.swipe_outlined, label: '${widget.moves} moves', colors: colors, textTheme: textTheme),
                ],
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: widget.onNewGame,
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: const Text('Play Again'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label, required this.colors, required this.textTheme});
  final IconData icon;
  final String label;
  final ColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.primary),
          const SizedBox(width: 5),
          Text(label, style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
