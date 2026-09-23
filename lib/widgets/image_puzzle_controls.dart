import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/puzzle_image.dart';

class ImagePuzzleControls extends StatelessWidget {
  const ImagePuzzleControls({super.key, required this.selected, required this.onChanged});

  final PuzzleImage selected;
  final ValueChanged<PuzzleImage> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<PuzzleImage>(
      value: selected,
      decoration: const InputDecoration(
        labelText: 'Picture',
        prefixIcon: Icon(Icons.palette_outlined),
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: PuzzleImage.values
          .map(
            (image) => DropdownMenuItem(
              value: image,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SvgPicture.asset(image.assetPath, width: 32, height: 32),
                  ),
                  const SizedBox(width: 10),
                  Text(image.label),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: (image) {
        if (image != null) onChanged(image);
      },
    );
  }
}

class PuzzleImageReference extends StatelessWidget {
  const PuzzleImageReference({super.key, required this.image});

  final PuzzleImage image;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ORIGINAL IMAGE',
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: SvgPicture.asset(image.assetPath, fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(image.label, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
