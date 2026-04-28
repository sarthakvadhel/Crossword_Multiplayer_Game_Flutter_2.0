class WordModel {
  final String clue;
  final String answer;
  final List<int> positions;
  final String? imageAsset;
  final bool isCompleted;

  const WordModel({
    required this.clue,
    required this.answer,
    required this.positions,
    this.imageAsset,
    this.isCompleted = false,
  });

  WordModel copyWith({
    bool? isCompleted,
  }) {
    return WordModel(
      clue: clue,
      answer: answer,
      positions: positions,
      imageAsset: imageAsset,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
