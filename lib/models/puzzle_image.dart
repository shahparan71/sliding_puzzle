enum PuzzleImage {
  ladybug('Ladybug', 'assets/images/ladybug_puzzle.svg'),
  flower('Flower', 'assets/images/flower_puzzle.svg'),
  fruit('Fruit', 'assets/images/fruit_puzzle.svg'),
  safari('Safari', 'assets/images/safari_puzzle.svg');

  const PuzzleImage(this.label, this.assetPath);

  final String label;
  final String assetPath;
}
