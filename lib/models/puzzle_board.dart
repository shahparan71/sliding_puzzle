import 'dart:math';

class PuzzleBoard {
  PuzzleBoard(this.size) : tiles = _scramble(size);

  final int size;
  final List<int> tiles;

  bool get isSolved => tiles.asMap().entries.every((entry) => entry.value == (entry.key + 1) % tiles.length);

  bool move(int tile) {
    final tileIndex = tiles.indexOf(tile);
    final blankIndex = tiles.indexOf(0);
    final rowDistance = (tileIndex ~/ size - blankIndex ~/ size).abs();
    final columnDistance = (tileIndex % size - blankIndex % size).abs();
    if (rowDistance + columnDistance != 1) return false;
    tiles[blankIndex] = tile;
    tiles[tileIndex] = 0;
    return true;
  }

  static List<int> _scramble(int size) {
    final values = List<int>.generate(size * size, (index) => (index + 1) % (size * size));
    final random = Random();
    var blankIndex = values.indexOf(0);
    var previousIndex = -1;
    final moves = size == 2 ? 18 : size == 3 ? 80 : 160;

    for (var step = 0; step < moves; step++) {
      final candidates = <int>[];
      final row = blankIndex ~/ size;
      final column = blankIndex % size;
      for (final index in [blankIndex - size, blankIndex + size, blankIndex - 1, blankIndex + 1]) {
        if (index < 0 || index >= values.length || index == previousIndex) continue;
        if ((index ~/ size - row).abs() + (index % size - column).abs() == 1) candidates.add(index);
      }
      final nextIndex = candidates[random.nextInt(candidates.length)];
      values[blankIndex] = values[nextIndex];
      values[nextIndex] = 0;
      previousIndex = blankIndex;
      blankIndex = nextIndex;
    }
    return values;
  }
}
