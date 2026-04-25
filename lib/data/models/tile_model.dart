class TileModel {
  final int row;
  final int col;
  final String? letter;
  final bool isLocked;
  final bool isHighlighted;

  const TileModel({
    required this.row,
    required this.col,
    this.letter,
    this.isLocked = false,
    this.isHighlighted = false,
  });

  TileModel copyWith({
    String? letter,
    bool? isLocked,
    bool? isHighlighted,
  }) {
    return TileModel(
      row: row,
      col: col,
      letter: letter ?? this.letter,
      isLocked: isLocked ?? this.isLocked,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'row': row,
      'col': col,
      'letter': letter,
      'isLocked': isLocked,
      'isHighlighted': isHighlighted,
    };
  }

  factory TileModel.fromJson(Map<String, dynamic> json) {
    return TileModel(
      row: json['row'] as int? ?? 0,
      col: json['col'] as int? ?? 0,
      letter: json['letter'] as String?,
      isLocked: json['isLocked'] as bool? ?? false,
      isHighlighted: json['isHighlighted'] as bool? ?? false,
    );
  }
}
