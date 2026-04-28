/// Represents a single word in a crossword puzzle
class CrosswordWord {
  final String id;
  final String clue;
  final String answer;
  final int startRow;
  final int startCol;
  final bool isAcross;
  bool isCompleted;
  /// Cartoon clipart emoji shown on the first cell of this word
  final String? imageEmoji;

  CrosswordWord({
    required this.id,
    required this.clue,
    required this.answer,
    required this.startRow,
    required this.startCol,
    required this.isAcross,
    this.isCompleted = false,
    this.imageEmoji,
  });

  List<(int, int)> get positions {
    final result = <(int, int)>[];
    for (int i = 0; i < answer.length; i++) {
      if (isAcross) {
        result.add((startRow, startCol + i));
      } else {
        result.add((startRow + i, startCol));
      }
    }
    return result;
  }

  CrosswordWord copyWith({bool? isCompleted}) {
    return CrosswordWord(
      id: id,
      clue: clue,
      answer: answer,
      startRow: startRow,
      startCol: startCol,
      isAcross: isAcross,
      isCompleted: isCompleted ?? this.isCompleted,
      imageEmoji: imageEmoji,
    );
  }
}

/// A full crossword puzzle definition
class CrosswordPuzzle {
  final String id;
  final String title;
  final int gridSize;
  final List<CrosswordWord> words;

  const CrosswordPuzzle({
    required this.id,
    required this.title,
    required this.gridSize,
    required this.words,
  });
}

/// A single cell in the crossword grid
class GridCell {
  final int row;
  final int col;
  final bool isBlack;
  final String? correctLetter;
  String? playerLetter;
  String? opponentLetter;
  final List<String> wordIds;
  bool isHighlighted;
  /// Cartoon emoji shown on the first cell of a word
  final String? imageEmoji;
  /// Short clue text shown alongside the emoji on the first cell
  final String? clueLabel;
  /// Word number label (1, 2, 3…) shown in the corner of the first cell
  final int? wordNumber;
  /// True when this cell has a pending (not yet committed) letter this turn
  bool isPending;

  GridCell({
    required this.row,
    required this.col,
    this.isBlack = false,
    this.correctLetter,
    this.playerLetter,
    this.opponentLetter,
    this.wordIds = const [],
    this.isHighlighted = false,
    this.imageEmoji,
    this.clueLabel,
    this.wordNumber,
    this.isPending = false,
  });

  bool get isEmpty => playerLetter == null && opponentLetter == null;
  bool get isFilledCorrectly =>
      playerLetter == correctLetter || opponentLetter == correctLetter;
  String? get displayLetter => playerLetter ?? opponentLetter;

  GridCell copyWith({
    String? playerLetter,
    String? opponentLetter,
    bool? isHighlighted,
    bool? isPending,
    bool clearPlayerLetter = false,
  }) {
    return GridCell(
      row: row,
      col: col,
      isBlack: isBlack,
      correctLetter: correctLetter,
      playerLetter:
          clearPlayerLetter ? null : (playerLetter ?? this.playerLetter),
      opponentLetter: opponentLetter ?? this.opponentLetter,
      wordIds: wordIds,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      imageEmoji: imageEmoji,
      clueLabel: clueLabel,
      wordNumber: wordNumber,
      isPending: isPending ?? this.isPending,
    );
  }

  Map<String, dynamic> toJson() => {
        'row': row,
        'col': col,
        'playerLetter': playerLetter,
        'opponentLetter': opponentLetter,
      };

  factory GridCell.fromJson(Map<String, dynamic> json, GridCell template) {
    return template.copyWith(
      playerLetter: json['playerLetter'] as String?,
      opponentLetter: json['opponentLetter'] as String?,
    );
  }
}
