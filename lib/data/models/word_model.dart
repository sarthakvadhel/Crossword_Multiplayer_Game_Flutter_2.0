enum WordDirection { across, down }

class WordModel {
  final int id;
  final String clue;
  final String answer;
  final int startRow;
  final int startCol;
  final WordDirection direction;
  final bool isCompleted;

  const WordModel({
    required this.id,
    required this.clue,
    required this.answer,
    required this.startRow,
    required this.startCol,
    required this.direction,
    this.isCompleted = false,
  });

  List<(int, int)> get positions {
    return List.generate(answer.length, (i) {
      return direction == WordDirection.across
          ? (startRow, startCol + i)
          : (startRow + i, startCol);
    });
  }

  WordModel copyWith({bool? isCompleted}) => WordModel(
        id: id,
        clue: clue,
        answer: answer,
        startRow: startRow,
        startCol: startCol,
        direction: direction,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}
