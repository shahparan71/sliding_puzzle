import 'package:flutter/material.dart';

class CompletionMessage extends StatelessWidget {
  const CompletionMessage({super.key, required this.onNewGame});

  final VoidCallback onNewGame;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Puzzle solved!',
          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),
        TextButton.icon(onPressed: onNewGame, icon: const Icon(Icons.replay), label: const Text('Again')),
      ],
    );
  }
}
