import 'dart:math';

import '../data/models/puzzle_model.dart';
import '../data/models/tile_model.dart';

class LetterGenerator {
  static const _vowels = ['A', 'E', 'I', 'O', 'U'];
  static const _consonants = [
    'B',
    'C',
    'D',
    'F',
    'G',
    'H',
    'J',
    'K',
    'L',
    'M',
    'N',
    'P',
    'R',
    'S',
    'T',
    'V',
    'W',
    'Y',
  ];

  final Random _random = Random();

  List<String> generateHand(int count) {
    return List.generate(count, (index) {
      final useVowel = _random.nextDouble() < 0.4;
      final pool = useVowel ? _vowels : _consonants;
      return pool[_random.nextInt(pool.length)];
    });
  }

  /// Generates a hand of [handSize] tiles that includes letters still needed
  /// to solve the puzzle (mix of needed + random extras).
  List<String> generateHandForPuzzle(
    PuzzleModel puzzle,
    List<TileModel> board,
    int handSize,
  ) {
    final correct = puzzle.correctLetters;
    final size = puzzle.gridSize;

    // Collect letters that still need to be placed
    final needed = <String>[];
    for (final entry in correct.entries) {
      final idx = entry.key.$1 * size + entry.key.$2;
      if (idx < board.length && board[idx].letter == null) {
        needed.add(entry.value);
      }
    }
    needed.shuffle(_random);

    // Fill ~60 % of hand with needed letters, rest random
    final takeNeeded = ((handSize * 0.6).ceil()).clamp(0, needed.length);
    final hand = <String>[
      ...needed.take(takeNeeded),
      ...generateHand(handSize - takeNeeded),
    ]..shuffle(_random);

    return hand;
  }
}
