import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/puzzle_image.dart';

class ImagePuzzleControls extends StatelessWidget {
  const ImagePuzzleControls({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.onPickPersonalImage,
    required this.onClearPersonalImage,
    required this.hasPersonalImage,
    this.personalImageBytes,
  });

  final PuzzleImage selected;
  final ValueChanged<PuzzleImage> onChanged;
  final VoidCallback onPickPersonalImage;
  final VoidCallback onClearPersonalImage;
  final bool hasPersonalImage;
  final Uint8List? personalImageBytes;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Preview panel ────────────────────────────────────────────
        _ImagePreviewPanel(
          selected: selected,
          personalImageBytes: personalImageBytes,
          hasPersonalImage: hasPersonalImage,
          colors: colors,
          textTheme: textTheme,
        ),

        const SizedBox(height: 16),

        // ── Source A: Preset dropdown ────────────────────────────────
        _SourceCard(
          isActive: !hasPersonalImage,
          label: 'Preset picture',
          icon: Icons.collections_outlined,
          colors: colors,
          textTheme: textTheme,
          child: DropdownButtonFormField<PuzzleImage>(
            initialValue: selected,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.palette_outlined),
              border: const OutlineInputBorder(),
              isDense: true,
              filled: true,
              fillColor: colors.surfaceContainerLowest,
            ),
            items: PuzzleImage.values
                .map(
                  (image) => DropdownMenuItem(
                    value: image,
                    child: Row(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(4), child: SvgPicture.asset(image.assetPath, width: 30, height: 30)),
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
          ),
        ),

        const SizedBox(height: 10),

        // ── Source B: Personal image ─────────────────────────────────
        _SourceCard(
          isActive: hasPersonalImage,
          label: 'Your photo',
          icon: Icons.person_outlined,
          colors: colors,
          textTheme: textTheme,
          child: Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: onPickPersonalImage,
                  icon: const Icon(Icons.upload_file_outlined, size: 18),
                  label: Text(hasPersonalImage ? 'Replace photo…' : 'Upload from gallery', overflow: TextOverflow.ellipsis),
                  style: FilledButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              if (hasPersonalImage) ...[
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Remove personal image',
                  child: IconButton.outlined(
                    onPressed: onClearPersonalImage,
                    icon: const Icon(Icons.close_rounded),
                    color: colors.error,
                    style: IconButton.styleFrom(side: BorderSide(color: colors.error.withValues(alpha: 0.5))),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Preview panel ────────────────────────────────────────────────────────────

class _ImagePreviewPanel extends StatelessWidget {
  const _ImagePreviewPanel({
    required this.selected,
    required this.personalImageBytes,
    required this.hasPersonalImage,
    required this.colors,
    required this.textTheme,
  });

  final PuzzleImage selected;
  final Uint8List? personalImageBytes;
  final bool hasPersonalImage;
  final ColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final label = hasPersonalImage ? 'Your photo' : selected.label;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 72,
              height: 72,
              child: hasPersonalImage
                  ? Image.memory(personalImageBytes!, fit: BoxFit.cover)
                  : SvgPicture.asset(selected.assetPath, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selected image', style: textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant, letterSpacing: 0.8)),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(hasPersonalImage ? Icons.person_rounded : Icons.collections_rounded, size: 14, color: colors.primary),
                    const SizedBox(width: 4),
                    Text(hasPersonalImage ? 'Personal photo' : 'Preset', style: textTheme.labelSmall?.copyWith(color: colors.primary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Selectable source card ────────────────────────────────────────────────────

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.isActive,
    required this.label,
    required this.icon,
    required this.colors,
    required this.textTheme,
    required this.child,
  });

  final bool isActive;
  final String label;
  final IconData icon;
  final ColorScheme colors;
  final TextTheme textTheme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final borderColor = isActive ? colors.primary : colors.outlineVariant;
    final bgColor = isActive ? colors.primaryContainer.withValues(alpha: 0.25) : colors.surfaceContainerLowest;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: isActive ? 2.0 : 1.0),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: isActive ? colors.primary : colors.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  color: isActive ? colors.primary : colors.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const Spacer(),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    'Active',
                    style: textTheme.labelSmall?.copyWith(color: colors.onPrimary, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ── PuzzleImageReference (used in puzzle view) ───────────────────────────────

class PuzzleImageReference extends StatelessWidget {
  const PuzzleImageReference({super.key, required this.image, required this.personalImageBytes});

  final PuzzleImage image;
  final Uint8List? personalImageBytes;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ORIGINAL IMAGE',
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.3),
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outlineVariant, width: 2),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: .1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  personalImageBytes == null
                      ? SvgPicture.asset(image.assetPath, fit: BoxFit.cover)
                      : Image.memory(personalImageBytes!, fit: BoxFit.cover),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: .7),
                            Colors.black.withValues(alpha: 0),
                          ],
                        ),
                      ),
                      child: Text(
                        personalImageBytes == null ? image.label : 'Personal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
