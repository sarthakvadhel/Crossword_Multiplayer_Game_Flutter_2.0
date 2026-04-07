import 'player_model.dart';
import 'puzzle_model.dart';
import 'tile_model.dart';

class GameStateModel {
  final List<TileModel> board;
  final List<String> playerHand;
  final List<String> aiHand;
  final PlayerModel player;
  final PlayerModel opponent;
  final bool isPlayerTurn;
  final int? selectedHandIndex;
  final PuzzleModel puzzle;
  final String? activeClue;

  const GameStateModel({
    required this.board,
    required this.playerHand,
    required this.aiHand,
    required this.player,
    required this.opponent,
    required this.isPlayerTurn,
    required this.puzzle,
    this.selectedHandIndex,
    this.activeClue,
  });

  GameStateModel copyWith({
    List<TileModel>? board,
    List<String>? playerHand,
    List<String>? aiHand,
    PlayerModel? player,
    PlayerModel? opponent,
    bool? isPlayerTurn,
    int? selectedHandIndex,
    PuzzleModel? puzzle,
    String? activeClue,
    bool clearSelectedHand = false,
    bool clearActiveClue = false,
  }) {
    return GameStateModel(
      board: board ?? this.board,
      playerHand: playerHand ?? this.playerHand,
      aiHand: aiHand ?? this.aiHand,
      player: player ?? this.player,
      opponent: opponent ?? this.opponent,
      isPlayerTurn: isPlayerTurn ?? this.isPlayerTurn,
      selectedHandIndex:
          clearSelectedHand ? null : (selectedHandIndex ?? this.selectedHandIndex),
      puzzle: puzzle ?? this.puzzle,
      activeClue: clearActiveClue ? null : (activeClue ?? this.activeClue),
    );
  }

  bool get isGameOver {
    final correct = puzzle.correctLetters;
    return correct.keys.every((pos) {
      final idx = pos.$1 * puzzle.gridSize + pos.$2;
      return idx < board.length && board[idx].letter != null;
    });
  }
}
