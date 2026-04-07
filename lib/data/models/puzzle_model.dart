import 'word_model.dart';

class PuzzleModel {
  final String id;
  final String title;
  final int gridSize;
  final List<WordModel> words;

  const PuzzleModel({
    required this.id,
    required this.title,
    required this.gridSize,
    required this.words,
  });

  /// Maps each (row, col) to the correct letter for that cell.
  Map<(int, int), String> get correctLetters {
    final map = <(int, int), String>{};
    for (final word in words) {
      for (int i = 0; i < word.answer.length; i++) {
        map[word.positions[i]] = word.answer[i];
      }
    }
    return map;
  }

  Set<(int, int)> get wordCells => correctLetters.keys.toSet();
}
