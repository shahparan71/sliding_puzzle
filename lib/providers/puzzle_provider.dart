import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/difficulty.dart';
import '../models/puzzle_board.dart';

class PuzzleProvider extends ChangeNotifier {
  PuzzleProvider() : _board = PuzzleBoard(Difficulty.medium.size);

  Difficulty _difficulty = Difficulty.medium;
  PuzzleBoard _board;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  bool _hasStarted = false;
  bool _isComplete = false;

  Difficulty get difficulty => _difficulty;
  List<int> get tiles => _board.tiles;
  bool get isComplete => _isComplete;
  String get formattedTime {
    final seconds = _stopwatch.elapsed.inSeconds;
    final minutes = seconds ~/ 60;
    return '${minutes.toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  void selectDifficulty(Difficulty difficulty) {
    _difficulty = difficulty;
    newGame();
  }

  void newGame() {
    _timer?.cancel();
    _stopwatch
      ..stop()
      ..reset();
    _board = PuzzleBoard(_difficulty.size);
    _hasStarted = false;
    _isComplete = false;
    notifyListeners();
  }

  void move(int tile) {
    if (_isComplete) return;
    _startTimer();
    if (!_board.move(tile)) return;

    if (_board.isSolved) {
      _isComplete = true;
      _stopwatch.stop();
      _timer?.cancel();
    }
    notifyListeners();
  }

  void _startTimer() {
    if (_hasStarted) return;
    _hasStarted = true;
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) => notifyListeners());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
