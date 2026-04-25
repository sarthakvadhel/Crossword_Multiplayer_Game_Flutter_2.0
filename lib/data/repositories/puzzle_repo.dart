import '../models/puzzle_model.dart';
import '../models/word_model.dart';

class PuzzleRepository {
  PuzzleModel getPuzzleOne() {
    return const PuzzleModel(
      id: 'puzzle_1',
      title: 'February 1',
      size: 9,
      words: [
        WordModel(
          clue: 'Bring into existence',
          answer: 'CREATE',
          positions: [0, 1, 2, 3, 4, 5],
        ),
        WordModel(
          clue: 'Round letter',
          answer: 'O',
          positions: [10],
        ),
      ],
    );
  }
}
