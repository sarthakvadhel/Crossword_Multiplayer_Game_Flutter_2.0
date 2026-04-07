import '../data/models/puzzle_model.dart';

class MoveValidator {
  /// Returns `true` when [letter] is the correct answer for cell ([row],[col]).
  bool isValidPlacement(PuzzleModel puzzle, int row, int col, String letter) {
    final correct = puzzle.correctLetters[(row, col)];
    return correct != null && correct == letter.toUpperCase();
  }

  /// Returns `true` when the cell is part of the puzzle (not a black square).
  bool isCellPlayable(PuzzleModel puzzle, int row, int col) {
    return puzzle.wordCells.contains((row, col));
  }
}
