import 'dart:math';
import '../data/models/puzzle_model.dart';

class LetterGenerator {
  final Random _random = Random();

  // Weighted English letter frequency
  static const _pool = [
    'E', 'E', 'E', 'E', 'E', 'E',
    'A', 'A', 'A', 'A',
    'R', 'R', 'R',
    'I', 'I', 'I',
    'O', 'O', 'O',
    'T', 'T', 'T',
    'N', 'N',
    'S', 'S',
    'L', 'L',
    'C', 'C',
    'U', 'U',
    'D', 'D',
    'P', 'P',
    'M', 'M',
    'H', 'H',
    'G', 'G',
    'B', 'B',
    'F',
    'Y',
    'W',
    'K',
    'V',
    'X',
    'Z',
    'Q',
  ];

  /// Generate a hand of letters, biased toward letters needed in the puzzle
  List<String> generateHand({
    required int count,
    CrosswordPuzzle? puzzle,
    List<List<GridCell>>? grid,
  }) {
    final hand = <String>[];

    // Collect needed letters (not yet placed)
    List<String> neededLetters = [];
    if (puzzle != null && grid != null) {
      for (final word in puzzle.words) {
        final positions = word.positions;
        for (int i = 0; i < positions.length; i++) {
          final (r, c) = positions[i];
          if (r < grid.length && c < grid[r].length) {
            final cell = grid[r][c];
            if (!cell.isBlack && cell.displayLetter == null) {
              neededLetters.add(word.answer[i]);
            }
          }
        }
      }
    }

    // 60% bias toward needed letters, 40% random
    for (int i = 0; i < count; i++) {
      if (neededLetters.isNotEmpty && _random.nextDouble() < 0.6) {
        final idx = _random.nextInt(neededLetters.length);
        hand.add(neededLetters[idx]);
        neededLetters.removeAt(idx);
      } else {
        hand.add(_pool[_random.nextInt(_pool.length)]);
      }
    }

    return hand;
  }

  String randomLetter() => _pool[_random.nextInt(_pool.length)];
}