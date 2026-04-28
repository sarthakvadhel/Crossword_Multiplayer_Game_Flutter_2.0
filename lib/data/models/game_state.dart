import '../models/puzzle_model.dart';
import '../models/player_model.dart';
import '../models/tile_model.dart';

enum GameMode { solo, multiplayer }

enum GamePhase { home, lobby, playing, finished }

enum TurnOwner { local, remote }

/// Tracks a single pending letter placement during a multi-letter turn
class PendingPlacement {
  final int row;
  final int col;
  final String letter;
  final int handIndex;
  final bool isCorrect;
  const PendingPlacement({
    required this.row,
    required this.col,
    required this.letter,
    required this.handIndex,
    required this.isCorrect,
  });
}

class GameState {
  final CrosswordPuzzle puzzle;
  final List<List<GridCell>> grid;
  final List<CrosswordWord> words;
  final List<String> playerHand;
  final List<String> aiHand;
  final PlayerModel localPlayer;
  final PlayerModel remotePlayer;
  final GameMode mode;
  final GamePhase phase;
  final TurnOwner turnOwner;
  final bool isHosting;
  final String? sessionCode;
  final String statusMessage;
  final int? selectedHandIndex;
  final String? highlightedWordId;
  final bool isPuzzleComplete;
  final String? winnerName;
  /// Letters placed this turn but not yet committed
  final List<PendingPlacement> pendingPlacements;
  /// Count of wrong placements this turn (each costs -2 pts on commit)
  final int wrongPlacementsThisTurn;

  const GameState({
    required this.puzzle,
    required this.grid,
    required this.words,
    required this.playerHand,
    required this.aiHand,
    required this.localPlayer,
    required this.remotePlayer,
    required this.mode,
    required this.phase,
    required this.turnOwner,
    required this.isHosting,
    required this.sessionCode,
    required this.statusMessage,
    required this.selectedHandIndex,
    required this.highlightedWordId,
    required this.isPuzzleComplete,
    required this.winnerName,
    this.pendingPlacements = const [],
    this.wrongPlacementsThisTurn = 0,
  });

  bool get isLocalTurn => turnOwner == TurnOwner.local;
  bool get canAct => phase == GamePhase.playing && isLocalTurn;
  bool get hasPendingPlacements => pendingPlacements.isNotEmpty;

  PlayerModel get player => localPlayer;
  PlayerModel get opponent => remotePlayer;
  bool get isMultiplayer => mode == GameMode.multiplayer;
  bool get hasOpponent =>
      isMultiplayer && remotePlayer.name != 'Waiting...';
  String get connectionStatus => statusMessage;
  int get boardSize => grid.length;

  List<TileModel> get board {
    return [
      for (final row in grid)
        for (final cell in row)
          TileModel(
            row: cell.row,
            col: cell.col,
            letter: cell.displayLetter,
            isLocked: cell.isBlack,
            isHighlighted: cell.isHighlighted,
          ),
    ];
  }

  GameState copyWith({
    CrosswordPuzzle? puzzle,
    List<List<GridCell>>? grid,
    List<CrosswordWord>? words,
    List<String>? playerHand,
    List<String>? aiHand,
    PlayerModel? localPlayer,
    PlayerModel? remotePlayer,
    GameMode? mode,
    GamePhase? phase,
    TurnOwner? turnOwner,
    bool? isHosting,
    String? sessionCode,
    bool clearSession = false,
    String? statusMessage,
    int? selectedHandIndex,
    bool clearSelection = false,
    String? highlightedWordId,
    bool clearHighlight = false,
    bool? isPuzzleComplete,
    String? winnerName,
    bool clearWinner = false,
    List<PendingPlacement>? pendingPlacements,
    int? wrongPlacementsThisTurn,
  }) {
    return GameState(
      puzzle: puzzle ?? this.puzzle,
      grid: grid ?? this.grid,
      words: words ?? this.words,
      playerHand: playerHand ?? this.playerHand,
      aiHand: aiHand ?? this.aiHand,
      localPlayer: localPlayer ?? this.localPlayer,
      remotePlayer: remotePlayer ?? this.remotePlayer,
      mode: mode ?? this.mode,
      phase: phase ?? this.phase,
      turnOwner: turnOwner ?? this.turnOwner,
      isHosting: isHosting ?? this.isHosting,
      sessionCode:
          clearSession ? null : (sessionCode ?? this.sessionCode),
      statusMessage: statusMessage ?? this.statusMessage,
      selectedHandIndex: clearSelection
          ? null
          : (selectedHandIndex ?? this.selectedHandIndex),
      highlightedWordId: clearHighlight
          ? null
          : (highlightedWordId ?? this.highlightedWordId),
      isPuzzleComplete: isPuzzleComplete ?? this.isPuzzleComplete,
      winnerName: clearWinner ? null : (winnerName ?? this.winnerName),
      pendingPlacements: pendingPlacements ?? this.pendingPlacements,
      wrongPlacementsThisTurn:
          wrongPlacementsThisTurn ?? this.wrongPlacementsThisTurn,
    );
  }

  Map<String, dynamic> toSyncJson() {
    final gridData = <Map<String, dynamic>>[];
    for (final row in grid) {
      for (final cell in row) {
        if (!cell.isBlack && cell.displayLetter != null) {
          gridData.add(cell.toJson());
        }
      }
    }
    return {
      'gridData': gridData,
      'words': words
          .map((w) => {'id': w.id, 'isCompleted': w.isCompleted})
          .toList(),
      'localPlayerData': remotePlayer.toJson(),
      'localScore': localPlayer.score,
      'remoteScore': remotePlayer.score,
      'turnOwner': turnOwner.name,
    };
  }
}
