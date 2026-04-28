class PlayerModel {
  final String id;
  final String name;
  final int score;
  final int wordsCompleted;
  final int lettersPlaced;

  const PlayerModel({
    required this.id,
    required this.name,
    this.score = 0,
    this.wordsCompleted = 0,
    this.lettersPlaced = 0,
  });

  PlayerModel copyWith({
    String? name,
    int? score,
    int? wordsCompleted,
    int? lettersPlaced,
  }) {
    return PlayerModel(
      id: id,
      name: name ?? this.name,
      score: score ?? this.score,
      wordsCompleted: wordsCompleted ?? this.wordsCompleted,
      lettersPlaced: lettersPlaced ?? this.lettersPlaced,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'score': score,
    'wordsCompleted': wordsCompleted,
    'lettersPlaced': lettersPlaced,
  };

  factory PlayerModel.fromJson(Map<String, dynamic> json) => PlayerModel(
    id: json['id'] as String? ?? 'unknown',
    name: json['name'] as String? ?? 'Player',
    score: json['score'] as int? ?? 0,
    wordsCompleted: json['wordsCompleted'] as int? ?? 0,
    lettersPlaced: json['lettersPlaced'] as int? ?? 0,
  );
}