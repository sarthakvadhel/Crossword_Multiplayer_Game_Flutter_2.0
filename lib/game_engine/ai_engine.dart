import 'dart:async';
import 'dart:math';
import '../data/models/puzzle_model.dart';
import '../data/models/game_state.dart';

class AiMove {
  final int row;
  final int col;
  final String letter;
  final int handIndex;

  const AiMove({
    required this.row,
    required this.col,
    required this.letter,
    required this.handIndex,
  });
}

class AiEngine {
  final Random _random = Random();

  /// Delay to simulate AI thinking
  Future<AiMove?> computeMove({
    required GameState state,
    required Duration thinkTime,
  }) async {
    await Future.delayed(thinkTime);

    // Find the best cell to place a letter
    // Strategy: prefer cells that complete words
    final candidates = <(int, int, String, int, int priority)>[];

    for (int handIdx = 0; handIdx < state.aiHand.length; handIdx++) {
      final letter = state.aiHand[handIdx];

      for (final word in state.words) {
        if (word.isCompleted) continue;
        final positions = word.positions;

        for (int posIdx = 0; posIdx < positions.length; posIdx++) {
          final (r, c) = positions[posIdx];
          final cell = state.grid[r][c];

          // Only place if cell is empty and letter matches
          if (cell.isBlack || cell.displayLetter != null) continue;
          if (word.answer[posIdx] != letter) continue;

          // Calculate priority: higher = better
          int priority = 1;

          // Big bonus if this completes a word
          final filledCount = positions.where((pos) {
            final (pr, pc) = pos;
            return state.grid[pr][pc].displayLetter != null;
          }).length;

          if (filledCount == word.answer.length - 1) {
            priority = 10; // Completing a word!
          } else if (filledCount > 0) {
            priority = 3; // Continuing a word
          }

          candidates.add((r, c, letter, handIdx, priority));
        }
      }
    }

    if (candidates.isEmpty) return null;

    // Sort by priority, take highest
    candidates.sort((a, b) => b.$5.compareTo(a.$5));

    // With some randomness among top candidates
    final topPriority = candidates.first.$5;
    final topCandidates = candidates.where((c) => c.$5 == topPriority).toList();
    final chosen = topCandidates[_random.nextInt(topCandidates.length)];

    return AiMove(
      row: chosen.$1,
      col: chosen.$2,
      letter: chosen.$3,
      handIndex: chosen.$4,
    );
  }
}