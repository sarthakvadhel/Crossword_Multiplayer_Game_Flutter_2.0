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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'score': score,
      'longestWord': longestWord,
      'streak': streak,
    };
  }

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      name: json['name'] as String? ?? 'Player',
      score: json['score'] as int? ?? 0,
      longestWord: json['longestWord'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
    );
  }
}
