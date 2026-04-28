import 'player_model.dart';
import 'tile_model.dart';

const _gameStateNoValue = Object();

class GameStateModel {
  final int boardSize;
  final List<TileModel> board;
  final List<String> hostHand;
  final List<String> guestHand;
  final PlayerModel hostPlayer;
  final PlayerModel guestPlayer;
  final String hostId;
  final String? guestId;
  final String localPlayerId;
  final String currentTurnPlayerId;
  final bool isMultiplayer;
  final bool isHosting;
  final String? sessionCode;
  final String connectionStatus;
  final int? selectedHandIndex;

  const GameStateModel({
    required this.boardSize,
    required this.board,
    required this.hostHand,
    required this.guestHand,
    required this.hostPlayer,
    required this.guestPlayer,
    required this.hostId,
    required this.guestId,
    required this.localPlayerId,
    required this.currentTurnPlayerId,
    required this.isMultiplayer,
    required this.isHosting,
    required this.sessionCode,
    required this.connectionStatus,
    required this.selectedHandIndex,
  });

  PlayerModel get player => localPlayerId == hostId ? hostPlayer : guestPlayer;

  PlayerModel get opponent =>
      localPlayerId == hostId ? guestPlayer : hostPlayer;

  List<String> get playerHand {
    return List.unmodifiable(localPlayerId == hostId ? hostHand : guestHand);
  }

  List<String> get opponentHand {
    return List.unmodifiable(localPlayerId == hostId ? guestHand : hostHand);
  }

  bool get isPlayerTurn {
    return !isMultiplayer || currentTurnPlayerId == localPlayerId;
  }

  bool get hasOpponent => guestId != null;

  bool get isWaitingForOpponent => isMultiplayer && !hasOpponent;

  bool get canLocalPlayerAct => !isMultiplayer || (hasOpponent && isPlayerTurn);

  GameStateModel copyWith({
    int? boardSize,
    List<TileModel>? board,
    List<String>? hostHand,
    List<String>? guestHand,
    PlayerModel? hostPlayer,
    PlayerModel? guestPlayer,
    String? hostId,
    Object? guestId = _gameStateNoValue,
    String? localPlayerId,
    String? currentTurnPlayerId,
    bool? isMultiplayer,
    bool? isHosting,
    Object? sessionCode = _gameStateNoValue,
    String? connectionStatus,
    Object? selectedHandIndex = _gameStateNoValue,
  }) {
    return GameStateModel(
      boardSize: boardSize ?? this.boardSize,
      board: board ?? this.board,
      hostHand: hostHand ?? this.hostHand,
      guestHand: guestHand ?? this.guestHand,
      hostPlayer: hostPlayer ?? this.hostPlayer,
      guestPlayer: guestPlayer ?? this.guestPlayer,
      hostId: hostId ?? this.hostId,
      guestId: guestId == _gameStateNoValue ? this.guestId : guestId as String?,
      localPlayerId: localPlayerId ?? this.localPlayerId,
      currentTurnPlayerId: currentTurnPlayerId ?? this.currentTurnPlayerId,
      isMultiplayer: isMultiplayer ?? this.isMultiplayer,
      isHosting: isHosting ?? this.isHosting,
      sessionCode: sessionCode == _gameStateNoValue
          ? this.sessionCode
          : sessionCode as String?,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      selectedHandIndex: selectedHandIndex == _gameStateNoValue
          ? this.selectedHandIndex
          : selectedHandIndex as int?,
    );
  }

  Map<String, dynamic> toMultiplayerJson() {
    return {
      'boardSize': boardSize,
      'board': board.map((tile) => tile.toJson()).toList(),
      'hostHand': hostHand,
      'guestHand': guestHand,
      'hostPlayer': hostPlayer.toJson(),
      'guestPlayer': guestPlayer.toJson(),
      'hostId': hostId,
      'guestId': guestId,
      'currentTurnPlayerId': currentTurnPlayerId,
      'isMultiplayer': isMultiplayer,
    };
  }

  factory GameStateModel.fromMultiplayerJson(
    Map<String, dynamic> json, {
    required String localPlayerId,
    required bool isHosting,
    required String? sessionCode,
    required String connectionStatus,
  }) {
    return GameStateModel(
      boardSize: json['boardSize'] as int? ?? 9,
      board: (json['board'] as List<dynamic>? ?? const [])
          .map((entry) =>
              TileModel.fromJson(Map<String, dynamic>.from(entry as Map)))
          .toList(),
      hostHand: (json['hostHand'] as List<dynamic>? ?? const [])
          .map((entry) => entry as String)
          .toList(),
      guestHand: (json['guestHand'] as List<dynamic>? ?? const [])
          .map((entry) => entry as String)
          .toList(),
      hostPlayer: PlayerModel.fromJson(
        Map<String, dynamic>.from(json['hostPlayer'] as Map? ?? const {}),
      ),
      guestPlayer: PlayerModel.fromJson(
        Map<String, dynamic>.from(json['guestPlayer'] as Map? ?? const {}),
      ),
      hostId: json['hostId'] as String? ?? 'host-player',
      guestId: json['guestId'] as String?,
      localPlayerId: localPlayerId,
      currentTurnPlayerId:
          json['currentTurnPlayerId'] as String? ?? 'host-player',
      isMultiplayer: json['isMultiplayer'] as bool? ?? true,
      isHosting: isHosting,
      sessionCode: sessionCode,
      connectionStatus: connectionStatus,
      selectedHandIndex: null,
    );
  }
}
