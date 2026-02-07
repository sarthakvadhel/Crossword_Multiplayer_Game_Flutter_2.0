class PlayerModel {
  final String name;
  final int score;
  final int longestWord;
  final int streak;

  const PlayerModel({
    required this.name,
    required this.score,
    required this.longestWord,
    required this.streak,
  });

  PlayerModel copyWith({
    String? name,
    int? score,
    int? longestWord,
    int? streak,
  }) {
    return PlayerModel(
      name: name ?? this.name,
      score: score ?? this.score,
      longestWord: longestWord ?? this.longestWord,
      streak: streak ?? this.streak,
    );
  }
}
