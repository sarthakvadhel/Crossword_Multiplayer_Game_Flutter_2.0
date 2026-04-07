class TileModel {
  final int row;
  final int col;
  final String? letter;
  final bool isGiven;
  final bool isBlocked;
  final bool isHighlighted;
  final int? clueNumber;

  const TileModel({
    required this.row,
    required this.col,
    this.letter,
    this.isGiven = false,
    this.isBlocked = false,
    this.isHighlighted = false,
    this.clueNumber,
  });

  TileModel copyWith({
    String? letter,
    bool? isGiven,
    bool? isBlocked,
    bool? isHighlighted,
    int? clueNumber,
    bool clearLetter = false,
  }) {
    return TileModel(
      row: row,
      col: col,
      letter: clearLetter ? null : (letter ?? this.letter),
      isGiven: isGiven ?? this.isGiven,
      isBlocked: isBlocked ?? this.isBlocked,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      clueNumber: clueNumber ?? this.clueNumber,
    );
  }
}
