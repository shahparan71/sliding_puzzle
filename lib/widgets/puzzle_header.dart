import 'package:flutter/material.dart';

class PuzzleHeader extends StatelessWidget {
  const PuzzleHeader({super.key, required this.onReset, required this.onSettings});

  final VoidCallback onReset;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SLIDE', style: TextStyle(color: Color(0xffd46a3a), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 4)),
            Text('Eight', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 42, fontWeight: FontWeight.bold, height: .95)),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: onSettings,
              tooltip: 'Settings',
              icon: const Icon(Icons.settings_outlined),
            ),
            IconButton(
              onPressed: onReset,
              tooltip: 'New game',
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
      ],
    );
  }
}
