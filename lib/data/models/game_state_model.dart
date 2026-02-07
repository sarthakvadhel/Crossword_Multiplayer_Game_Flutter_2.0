import 'player_model.dart';
import 'tile_model.dart';

class GameStateModel {
  final List<TileModel> board;
  final List<String> playerHand;
  final List<String> aiHand;
  final PlayerModel player;
  final PlayerModel opponent;
  final bool isPlayerTurn;

  const GameStateModel({
    required this.board,
    required this.playerHand,
    required this.aiHand,
    required this.player,
    required this.opponent,
    required this.isPlayerTurn,
  });

  GameStateModel copyWith({
    List<TileModel>? board,
    List<String>? playerHand,
    List<String>? aiHand,
    PlayerModel? player,
    PlayerModel? opponent,
    bool? isPlayerTurn,
  }) {
    return GameStateModel(
      board: board ?? this.board,
      playerHand: playerHand ?? this.playerHand,
      aiHand: aiHand ?? this.aiHand,
      player: player ?? this.player,
      opponent: opponent ?? this.opponent,
      isPlayerTurn: isPlayerTurn ?? this.isPlayerTurn,
    );
  }
}
