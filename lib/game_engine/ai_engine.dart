import 'dart:async';
import 'dart:math';

import '../data/models/game_state_model.dart';

/// AI opponent logic.
///
/// The AI is "moderately smart":
/// • It plays 1–2 letters per turn.
/// • 75 % of the time it picks the correct letter for a cell; otherwise it
///   skips that slot (rather than placing wrong letters on the board).
class AiEngine {
  final Random _random = Random();

  /// Returns a list of `(boardIndex, letter)` placements the AI wants to make.
  Future<List<(int, String)>> performTurn(GameStateModel state) async {
    // Simulate thinking time
    await Future<void>.delayed(const Duration(milliseconds: 1400));

    final correct = state.puzzle.correctLetters;
    final size = state.puzzle.gridSize;

    // Collect empty (unfilled, non-blocked) cells
    final empty = state.board
        .where((t) => !t.isBlocked && !t.isGiven && t.letter == null)
        .toList()
      ..shuffle(_random);

    if (empty.isEmpty) return [];

    // Pick 1–2 cells
    final count = _random.nextInt(2) + 1;
    final chosen = empty.take(count).toList();

    final placements = <(int, String)>[];
    for (final tile in chosen) {
      final pos = (tile.row, tile.col);
      final letter = correct[pos];
      if (letter == null) continue;
      // 75 % accuracy
      if (_random.nextDouble() < 0.75) {
        placements.add((tile.row * size + tile.col, letter));
      }
    }
    return placements;
  }
}
