import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/difficulty.dart';
import '../models/puzzle_board.dart';
import '../models/puzzle_mode.dart';
import '../models/puzzle_image.dart';
import '../services/sound_service.dart';

class PuzzleProvider extends ChangeNotifier {
  PuzzleProvider() : _board = PuzzleBoard(Difficulty.medium.size);

  Difficulty _difficulty = Difficulty.medium;
  PuzzleMode _mode = PuzzleMode.numbers;
  PuzzleImage _image = PuzzleImage.ladybug;
  Uint8List? _personalImageBytes;
  PuzzleBoard _board;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  int _moves = 0;
  bool _hasStarted = false;
  bool _isComplete = false;
  bool _soundEnabled = true;

  Difficulty get difficulty => _difficulty;
  PuzzleMode get mode => _mode;
  PuzzleImage get image => _image;
  Uint8List? get personalImageBytes => _personalImageBytes;
  bool get usePersonalImage => _personalImageBytes != null;
  List<int> get tiles => _board.tiles;
  int get blankIndex => _board.tiles.indexOf(0);
  int get moves => _moves;
  bool get isComplete => _isComplete;
  bool get soundEnabled => _soundEnabled;

  int get elapsedSeconds => _stopwatch.elapsed.inSeconds;

  String get formattedTime {
    final seconds = _stopwatch.elapsed.inSeconds;
    final minutes = seconds ~/ 60;
    return '${minutes.toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  bool canMove(int tile) => _board.canMove(tile);
  (int, int)? directionToBlank(int tile) => _board.directionToBlank(tile);

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    SoundService.instance.soundEnabled = _soundEnabled;
    notifyListeners();
  }

  void selectDifficulty(Difficulty difficulty) {
    _difficulty = difficulty;
    newGame();
  }

  void selectMode(PuzzleMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    newGame();
  }

  void selectImage(PuzzleImage image) {
    if (_image == image) return;
    _image = image;
    _personalImageBytes = null;
    newGame();
  }

  void selectPersonalImage(Uint8List bytes) {
    _personalImageBytes = bytes;
    newGame();
  }

  void clearPersonalImage() {
    if (_personalImageBytes == null) return;
    _personalImageBytes = null;
    newGame();
  }

  void newGame() {
    _timer?.cancel();
    _stopwatch
      ..stop()
      ..reset();
    _board = PuzzleBoard(_difficulty.size);
    _moves = 0;
    _hasStarted = false;
    _isComplete = false;
    notifyListeners();
  }

  void move(int tile) {
    if (_isComplete) return;
    _startTimer();
    final didMove = _board.move(tile);
    if (!didMove) return;

    _moves++;
    SoundService.instance.playSlide();

    if (_board.isSolved) {
      _isComplete = true;
      _stopwatch.stop();
      _timer?.cancel();
      SoundService.instance.playWin();
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
