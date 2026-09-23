enum Difficulty {
  easy('Easy', 2),
  medium('Medium', 3),
  hard('Hard', 4);

  const Difficulty(this.label, this.size);

  final String label;
  final int size;
}
