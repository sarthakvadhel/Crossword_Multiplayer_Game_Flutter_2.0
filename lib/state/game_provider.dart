import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/local_multiplayer_service.dart';
import '../data/models/game_state_model.dart';
import '../data/models/player_model.dart';
import '../data/models/tile_model.dart';
import '../game_engine/board_engine.dart';
import '../game_engine/letter_generator.dart';

final gameProvider = StateNotifierProvider<GameNotifier, GameStateModel>((ref) {
  return GameNotifier(
    boardEngine: BoardEngine(),
    letterGenerator: LetterGenerator(),
    multiplayerService: LocalMultiplayerService(),
  );
});

class GameNotifier extends StateNotifier<GameStateModel> {
  GameNotifier({
    required this.boardEngine,
    required this.letterGenerator,
    required this.multiplayerService,
  })  : _random = Random(),
        super(
          _buildSoloState(
            boardEngine: boardEngine,
            letterGenerator: letterGenerator,
          ),
        ) {
    _multiplayerSubscription =
        multiplayerService.messages.listen(_handleTransportEvent);
  }

  final BoardEngine boardEngine;
  final LetterGenerator letterGenerator;
  final LocalMultiplayerService multiplayerService;
  final Random _random;

  late final StreamSubscription<Map<String, dynamic>> _multiplayerSubscription;

  Future<void> startSoloPractice({String playerName = 'You'}) async {
    await multiplayerService.reset();
    state = _buildSoloState(
      boardEngine: boardEngine,
      letterGenerator: letterGenerator,
      playerName: _cleanName(playerName, fallback: 'You'),
    );
  }

  Future<String?> hostMultiplayer(String playerName) async {
    final cleanedName = _cleanName(playerName, fallback: 'Host');
    final localPlayerId = _nextPlayerId(prefix: 'host');

    await multiplayerService.reset();
    state = _buildMultiplayerLobbyState(
      boardEngine: boardEngine,
      letterGenerator: letterGenerator,
      localPlayerId: localPlayerId,
      playerName: cleanedName,
      isHosting: true,
      status: 'Opening a room on your Wi-Fi...',
    );

    try {
      final roomInfo = await multiplayerService.startHosting();
      state = state.copyWith(
        sessionCode: roomInfo.shareCode,
        connectionStatus:
            'Room ready. Share ${roomInfo.shareCode} with your opponent.',
      );
      return null;
    } catch (error) {
      state = _buildSoloState(
        boardEngine: boardEngine,
        letterGenerator: letterGenerator,
        playerName: cleanedName,
      );
      return 'Could not create a room. Make sure this phone is on Wi-Fi.';
    }
  }

  Future<String?> joinMultiplayer(String playerName, String roomCode) async {
    final cleanedName = _cleanName(playerName, fallback: 'Guest');
    final parsedRoom = _parseRoomCode(roomCode);
    if (parsedRoom == null) {
      return 'Use the host code in the form host:port, for example 192.168.1.8:4040.';
    }

    final localPlayerId = _nextPlayerId(prefix: 'guest');

    await multiplayerService.reset();
    state = _buildMultiplayerLobbyState(
      boardEngine: boardEngine,
      letterGenerator: letterGenerator,
      localPlayerId: localPlayerId,
      playerName: cleanedName,
      isHosting: false,
      status: 'Joining ${parsedRoom.shareCode}...',
      sessionCode: parsedRoom.shareCode,
    );

    try {
      await multiplayerService.joinRoom(
        host: parsedRoom.host,
        port: parsedRoom.port,
      );
      await multiplayerService.sendMessage({
        'type': 'join_request',
        'playerId': localPlayerId,
        'playerName': cleanedName,
      });
      state = state.copyWith(
          connectionStatus: 'Waiting for the host to start the match...');
      return null;
    } catch (error) {
      state = _buildSoloState(
        boardEngine: boardEngine,
        letterGenerator: letterGenerator,
        playerName: cleanedName,
      );
      return 'Could not join that room. Make sure both devices are on the same Wi-Fi.';
    }
  }

  void selectHandLetter(int index) {
    if (!state.canLocalPlayerAct) {
      return;
    }
    if (index < 0 || index >= state.playerHand.length) {
      return;
    }
    state = state.copyWith(
      selectedHandIndex: state.selectedHandIndex == index ? null : index,
      connectionStatus: _statusForState(state),
    );
  }

  Future<void> placeSelectedLetter(int tileIndex) async {
    final selectedHandIndex = state.selectedHandIndex;
    if (selectedHandIndex == null || !state.canLocalPlayerAct) {
      return;
    }

    final action = {
      'type': 'action',
      'action': 'place_tile',
      'playerId': state.localPlayerId,
      'handIndex': selectedHandIndex,
      'tileIndex': tileIndex,
    };

    await _dispatchAction(action, clearSelectionWhileSending: true);
  }

  Future<void> swapLetters() async {
    if (!state.canLocalPlayerAct || state.playerHand.isEmpty) {
      return;
    }

    final selectedHandIndex = state.selectedHandIndex;
    final indices = selectedHandIndex == null
        ? List<int>.generate(state.playerHand.length, (index) => index)
        : <int>[selectedHandIndex];

    final action = {
      'type': 'action',
      'action': 'swap_letters',
      'playerId': state.localPlayerId,
      'indices': indices,
    };

    await _dispatchAction(action, clearSelectionWhileSending: true);
  }

  Future<void> endTurn() async {
    if (!state.canLocalPlayerAct) {
      return;
    }

    final action = {
      'type': 'action',
      'action': 'pass_turn',
      'playerId': state.localPlayerId,
    };

    await _dispatchAction(action, clearSelectionWhileSending: true);
  }

  @override
  void dispose() {
    _multiplayerSubscription.cancel();
    unawaited(multiplayerService.dispose());
    super.dispose();
  }

  Future<void> _dispatchAction(
    Map<String, dynamic> action, {
    required bool clearSelectionWhileSending,
  }) async {
    if (state.isMultiplayer && !state.isHosting) {
      try {
        await multiplayerService.sendMessage(action);
        if (clearSelectionWhileSending) {
          state = state.copyWith(
            selectedHandIndex: null,
            connectionStatus:
                'Move sent. Waiting for the host to sync the board...',
          );
        }
      } catch (error) {
        state = state.copyWith(
            connectionStatus: 'Could not send the move to the host.');
      }
      return;
    }

    final updatedState = _applyAction(state, action);
    if (updatedState == null) {
      return;
    }

    state = updatedState.copyWith(
      selectedHandIndex: null,
      connectionStatus: _statusForState(updatedState),
    );

    if (state.isMultiplayer && state.isHosting) {
      await _broadcastState();
    }
  }

  Future<void> _broadcastState() async {
    try {
      await multiplayerService.sendMessage({
        'type': 'state_sync',
        'payload': state.toMultiplayerJson(),
      });
    } catch (error) {
      state = state.copyWith(
          connectionStatus:
              'Could not sync the room. Check your Wi-Fi connection.');
    }
  }

  void _handleTransportEvent(Map<String, dynamic> event) {
    switch (event['type']) {
      case 'peer_connected':
        if (state.isHosting) {
          state = state.copyWith(
            connectionStatus:
                'Opponent connected. Waiting for their player name...',
          );
        }
        return;
      case 'peer_disconnected':
        if (state.isHosting) {
          state = state.copyWith(
            guestId: null,
            guestHand: const [],
            guestPlayer: const PlayerModel(
              name: 'Waiting for opponent',
              score: 0,
              longestWord: 0,
              streak: 0,
            ),
            currentTurnPlayerId: state.hostId,
            selectedHandIndex: null,
            connectionStatus:
                'Opponent disconnected. The room is open for a new join.',
          );
        }
        return;
      case 'host_disconnected':
        if (!state.isHosting) {
          state = state.copyWith(
            selectedHandIndex: null,
            connectionStatus:
                'Host disconnected. Start a new room to continue.',
          );
        }
        return;
      case 'transport_error':
        state = state.copyWith(
          connectionStatus:
              event['message'] as String? ?? 'A network error occurred.',
        );
        return;
      case 'join_request':
        if (!state.isHosting) {
          return;
        }
        final joiningPlayerId =
            event['playerId'] as String? ?? _nextPlayerId(prefix: 'guest');
        final joiningName =
            _cleanName(event['playerName'] as String? ?? '', fallback: 'Guest');
        state = state.copyWith(
          guestId: joiningPlayerId,
          guestHand: letterGenerator.generateHand(5),
          guestPlayer: PlayerModel(
            name: joiningName,
            score: 0,
            longestWord: 0,
            streak: 0,
          ),
          currentTurnPlayerId: state.hostId,
          selectedHandIndex: null,
          connectionStatus:
              '$joiningName joined. Your turn to make the first move.',
        );
        unawaited(_broadcastState());
        return;
      case 'action':
        if (!state.isHosting) {
          return;
        }
        final updatedState = _applyAction(state, event);
        if (updatedState == null) {
          return;
        }
        state = updatedState.copyWith(
          selectedHandIndex: null,
          connectionStatus: _statusForState(updatedState),
        );
        unawaited(_broadcastState());
        return;
      case 'state_sync':
        if (state.isHosting) {
          return;
        }
        final payload = event['payload'];
        if (payload is! Map) {
          return;
        }
        final syncedState = GameStateModel.fromMultiplayerJson(
          Map<String, dynamic>.from(payload),
          localPlayerId: state.localPlayerId,
          isHosting: false,
          sessionCode: state.sessionCode,
          connectionStatus: '',
        );
        state = syncedState.copyWith(
            connectionStatus: _statusForState(syncedState));
        return;
    }
  }

  GameStateModel? _applyAction(
    GameStateModel currentState,
    Map<String, dynamic> action,
  ) {
    final playerId = action['playerId'] as String?;
    final actionType = action['action'] as String?;
    if (playerId == null || actionType == null) {
      return null;
    }

    if (currentState.isMultiplayer &&
        currentState.currentTurnPlayerId != playerId &&
        actionType != 'pass_turn') {
      return null;
    }

    switch (actionType) {
      case 'place_tile':
        return _applyPlacement(
          currentState,
          playerId: playerId,
          tileIndex: action['tileIndex'] as int? ?? -1,
          handIndex: action['handIndex'] as int? ?? -1,
        );
      case 'swap_letters':
        final rawIndices = action['indices'] as List<dynamic>? ?? const [];
        return _applySwap(
          currentState,
          playerId: playerId,
          indices: rawIndices.map((entry) => entry as int).toList(),
        );
      case 'pass_turn':
        return currentState.copyWith(
          currentTurnPlayerId:
              _nextTurnPlayerId(currentState, currentPlayerId: playerId),
        );
      default:
        return null;
    }
  }

  GameStateModel? _applyPlacement(
    GameStateModel currentState, {
    required String playerId,
    required int tileIndex,
    required int handIndex,
  }) {
    if (tileIndex < 0 || tileIndex >= currentState.board.length) {
      return null;
    }
    if (currentState.board[tileIndex].letter != null) {
      return null;
    }

    final hand = _handForPlayer(currentState, playerId);
    if (handIndex < 0 || handIndex >= hand.length) {
      return null;
    }

    final updatedBoard = [...currentState.board];
    updatedBoard[tileIndex] = updatedBoard[tileIndex].copyWith(
      letter: hand[handIndex],
      isLocked: true,
    );

    final updatedHand = [...hand];
    updatedHand[handIndex] = letterGenerator.generateHand(1).first;

    final player = _playerForId(currentState, playerId);
    final updatedPlayer = player.copyWith(
      score: player.score + 1,
      longestWord: max(player.longestWord, 1),
      streak: player.streak + 1,
    );

    return _copyForPlayer(
      currentState,
      playerId: playerId,
      board: updatedBoard,
      hand: updatedHand,
      player: updatedPlayer,
      currentTurnPlayerId:
          _nextTurnPlayerId(currentState, currentPlayerId: playerId),
    );
  }

  GameStateModel _applySwap(
    GameStateModel currentState, {
    required String playerId,
    required List<int> indices,
  }) {
    final hand = [..._handForPlayer(currentState, playerId)];
    for (final index in indices) {
      if (index < 0 || index >= hand.length) {
        continue;
      }
      hand[index] = letterGenerator.generateHand(1).first;
    }

    final player = _playerForId(currentState, playerId);
    final updatedPlayer = player.copyWith(streak: 0);

    return _copyForPlayer(
      currentState,
      playerId: playerId,
      hand: hand,
      player: updatedPlayer,
      currentTurnPlayerId:
          _nextTurnPlayerId(currentState, currentPlayerId: playerId),
    );
  }

  GameStateModel _copyForPlayer(
    GameStateModel currentState, {
    required String playerId,
    List<TileModel>? board,
    List<String>? hand,
    PlayerModel? player,
    String? currentTurnPlayerId,
  }) {
    if (playerId == currentState.hostId) {
      return currentState.copyWith(
        board: board,
        hostHand: hand,
        hostPlayer: player,
        currentTurnPlayerId: currentTurnPlayerId,
      );
    }

    return currentState.copyWith(
      board: board,
      guestHand: hand,
      guestPlayer: player,
      currentTurnPlayerId: currentTurnPlayerId,
    );
  }

  List<String> _handForPlayer(GameStateModel currentState, String playerId) {
    return playerId == currentState.hostId
        ? currentState.hostHand
        : currentState.guestHand;
  }

  PlayerModel _playerForId(GameStateModel currentState, String playerId) {
    return playerId == currentState.hostId
        ? currentState.hostPlayer
        : currentState.guestPlayer;
  }

  String _nextTurnPlayerId(
    GameStateModel currentState, {
    required String currentPlayerId,
  }) {
    if (!currentState.isMultiplayer || currentState.guestId == null) {
      return currentState.hostId;
    }
    return currentPlayerId == currentState.hostId
        ? currentState.guestId!
        : currentState.hostId;
  }

  String _nextPlayerId({required String prefix}) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(9999)}';
  }

  String _cleanName(String name, {required String fallback}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return fallback;
    }
    return trimmed.length <= 18 ? trimmed : trimmed.substring(0, 18);
  }

  HostedRoomInfo? _parseRoomCode(String roomCode) {
    final trimmed = roomCode.trim();
    final separatorIndex = trimmed.lastIndexOf(':');
    if (separatorIndex <= 0 || separatorIndex == trimmed.length - 1) {
      return null;
    }

    final host = trimmed.substring(0, separatorIndex).trim();
    final port = int.tryParse(trimmed.substring(separatorIndex + 1).trim());
    if (host.isEmpty || port == null) {
      return null;
    }

    return HostedRoomInfo(host: host, port: port);
  }

  String _statusForState(GameStateModel currentState) {
    if (!currentState.isMultiplayer) {
      return 'Practice mode. Pick a letter and tap a square.';
    }
    if (currentState.isWaitingForOpponent) {
      final roomCode = currentState.sessionCode;
      if (roomCode == null) {
        return 'Preparing your room...';
      }
      return 'Waiting for your opponent. Share $roomCode.';
    }
    if (currentState.isPlayerTurn) {
      return 'Your turn. Tap a letter, then place it on the board.';
    }
    return '${currentState.opponent.name} is making a move...';
  }
}

GameStateModel _buildSoloState({
  required BoardEngine boardEngine,
  required LetterGenerator letterGenerator,
  String playerName = 'You',
}) {
  return GameStateModel(
    boardSize: 9,
    board: boardEngine.buildBoard(9),
    hostHand: letterGenerator.generateHand(5),
    guestHand: const [],
    hostPlayer: PlayerModel(
      name: playerName,
      score: 0,
      longestWord: 0,
      streak: 0,
    ),
    guestPlayer: const PlayerModel(
      name: 'Practice Bot',
      score: 0,
      longestWord: 0,
      streak: 0,
    ),
    hostId: 'solo-player',
    guestId: null,
    localPlayerId: 'solo-player',
    currentTurnPlayerId: 'solo-player',
    isMultiplayer: false,
    isHosting: true,
    sessionCode: null,
    connectionStatus: 'Practice mode. Pick a letter and tap a square.',
    selectedHandIndex: null,
  );
}

GameStateModel _buildMultiplayerLobbyState({
  required BoardEngine boardEngine,
  required LetterGenerator letterGenerator,
  required String localPlayerId,
  required String playerName,
  required bool isHosting,
  required String status,
  String? sessionCode,
}) {
  return GameStateModel(
    boardSize: 9,
    board: boardEngine.buildBoard(9),
    hostHand: isHosting ? letterGenerator.generateHand(5) : const [],
    guestHand: isHosting ? const [] : letterGenerator.generateHand(5),
    hostPlayer: PlayerModel(
      name: isHosting ? playerName : 'Host',
      score: 0,
      longestWord: 0,
      streak: 0,
    ),
    guestPlayer: PlayerModel(
      name: isHosting ? 'Waiting for opponent' : playerName,
      score: 0,
      longestWord: 0,
      streak: 0,
    ),
    hostId: isHosting ? localPlayerId : 'remote-host',
    guestId: isHosting ? null : localPlayerId,
    localPlayerId: localPlayerId,
    currentTurnPlayerId: isHosting ? localPlayerId : 'remote-host',
    isMultiplayer: true,
    isHosting: isHosting,
    sessionCode: sessionCode,
    connectionStatus: status,
    selectedHandIndex: null,
  );
}
