import 'package:flutter/material.dart';

class PuzzleHeader extends StatelessWidget {
  const PuzzleHeader({
    super.key,
    required this.onReset,
    required this.onSettings,
    this.onBack,
    this.onToggleSound,
    this.isSoundEnabled = true,
    this.title = 'PuzzlePlay',
  });

  final VoidCallback onReset;
  final VoidCallback onSettings;
  final VoidCallback? onBack;
  final VoidCallback? onToggleSound;
  final bool isSoundEnabled;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        if (onBack != null) ...[
          _HeaderIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: 'Back to Home',
            onTap: onBack!,
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SLIDING',
                style: TextStyle(
                  color: const Color(0xFFD46A3A),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3.5,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        if (onToggleSound != null) ...[
          _HeaderIconButton(
            icon: isSoundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            tooltip: isSoundEnabled ? 'Mute Sound' : 'Enable Sound',
            color: isSoundEnabled ? colors.primary : colors.onSurfaceVariant,
            onTap: onToggleSound!,
          ),
          const SizedBox(width: 8),
        ],
        _HeaderIconButton(
          icon: Icons.refresh_rounded,
          tooltip: 'Shuffle / Restart',
          onTap: onReset,
        ),
        const SizedBox(width: 8),
        _HeaderIconButton(
          icon: Icons.settings_outlined,
          tooltip: 'Settings',
          onTap: onSettings,
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color ?? colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
