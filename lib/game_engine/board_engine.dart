import '../data/models/puzzle_model.dart';
import '../data/models/tile_model.dart';
import '../data/models/word_model.dart';

class BoardEngine {
  /// Build a plain empty grid (fallback / testing).
  List<TileModel> buildBoard(int size) {
    return List.generate(
      size * size,
      (index) => TileModel(
        row: index ~/ size,
        col: index % size,
        isBlocked: true,
      ),
    );
  }

  /// Build a crossword board from a [PuzzleModel].
  ///
  /// • All cells start as black squares.
  /// • Word cells are opened up; shared cells between an ACROSS and a DOWN
  ///   word are handled correctly (single [TileModel] for each grid position).
  /// • Corner letters of the outermost ACROSS words are given as hints.
  List<TileModel> buildBoardFromPuzzle(PuzzleModel puzzle) {
    final size = puzzle.gridSize;
    final correct = puzzle.correctLetters;

    // Start with all black
    final board = List.generate(
      size * size,
      (i) => TileModel(row: i ~/ size, col: i % size, isBlocked: true),
    );

    // ── Clue numbers ──────────────────────────────────────────────────────
    // Number cells left-to-right / top-to-bottom for each unique word start.
    final clueNumbers = <(int, int), int>{};
    int nextNum = 1;

    final starts = puzzle.words
        .map((w) => (row: w.startRow, col: w.startCol))
        .toList()
      ..sort((a, b) =>
          a.row != b.row ? a.row.compareTo(b.row) : a.col.compareTo(b.col));

    for (final s in starts) {
      final pos = (s.row, s.col);
      if (!clueNumbers.containsKey(pos)) {
        clueNumbers[pos] = nextNum++;
      }
    }

    // ── Pre-given letters ─────────────────────────────────────────────────
    // Mark the first and last letter of EVERY across word as a hint.
    final given = <(int, int)>{};
    for (final w in puzzle.words) {
      if (w.direction == WordDirection.across) {
        given.add((w.startRow, w.startCol));
        given.add((w.startRow, w.startCol + w.answer.length - 1));
      }
    }

    // ── Fill board ────────────────────────────────────────────────────────
    return board.map((tile) {
      final pos = (tile.row, tile.col);
      if (!correct.containsKey(pos)) return tile; // stays black

      final isGiven = given.contains(pos);
      return tile.copyWith(
        isBlocked: false,
        isGiven: isGiven,
        letter: isGiven ? correct[pos] : null,
        clueNumber: clueNumbers[pos],
      );
    }).toList();
  }
}
