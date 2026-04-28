import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/multiplayer_service.dart';
import '../data/models/game_state.dart';
import '../data/models/player_model.dart';
import '../data/models/puzzle_model.dart';
import '../data/repositories/puzzle_repo.dart';
import '../game_engine/ai_engine.dart';
import '../game_engine/letter_generator.dart';

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});

class GameNotifier extends StateNotifier<GameState> {
  final PuzzleRepository _puzzleRepo = PuzzleRepository();
  final LetterGenerator _letterGen = LetterGenerator();
  final AiEngine _ai = AiEngine();
  final MultiplayerService _mp = MultiplayerService();
  final Random _random = Random();

  StreamSubscription<Map<String, dynamic>>? _mpSub;
  Timer? _aiTimer;
  bool _aiThinking = false;

  GameNotifier() : super(_buildInitialState(PuzzleRepository().getPuzzle(0)));

  static GameState _buildInitialState(CrosswordPuzzle puzzle) {
    final grid = PuzzleRepository.buildGrid(puzzle);
    final gen = LetterGenerator();
    return GameState(
      puzzle: puzzle,
      grid: grid,
      words: List.from(puzzle.words),
      playerHand: gen.generateHand(count: 7, puzzle: puzzle, grid: grid),
      aiHand: gen.generateHand(count: 7, puzzle: puzzle, grid: grid),
      localPlayer: const PlayerModel(id: 'local', name: 'You'),
      remotePlayer: const PlayerModel(id: 'ai', name: 'Computer'),
      mode: GameMode.solo,
      phase: GamePhase.home,
      turnOwner: TurnOwner.local,
      isHosting: false,
      sessionCode: null,
      statusMessage: 'Welcome! Choose a game mode.',
      selectedHandIndex: null,
      highlightedWordId: null,
      isPuzzleComplete: false,
      winnerName: null,
      pendingPlacements: const [],
      wrongPlacementsThisTurn: 0,
    );
  }

  // ─── Navigation / Mode Setup ─────────────────────────────────────────────

  void goHome() {
    _cancelAi();
    state = state.copyWith(
        phase: GamePhase.home, statusMessage: 'Choose a game mode.');
  }

  Future<void> startSoloGame(
      {int puzzleIndex = 0, String playerName = 'You'}) async {
    _cancelAi();
    await _mp.reset();
    _mpSub?.cancel();

    final puzzle = _puzzleRepo.getPuzzle(puzzleIndex);
    final grid = PuzzleRepository.buildGrid(puzzle);

    state = GameState(
      puzzle: puzzle,
      grid: grid,
      words: List.from(puzzle.words),
      playerHand:
          _letterGen.generateHand(count: 7, puzzle: puzzle, grid: grid),
      aiHand: _letterGen.generateHand(count: 7, puzzle: puzzle, grid: grid),
      localPlayer: PlayerModel(
          id: 'local',
          name: playerName.trim().isEmpty ? 'You' : playerName),
      remotePlayer: const PlayerModel(id: 'ai', name: 'Computer'),
      mode: GameMode.solo,
      phase: GamePhase.playing,
      turnOwner: TurnOwner.local,
      isHosting: false,
      sessionCode: null,
      statusMessage: 'Your turn! Place letters then tap Commit.',
      selectedHandIndex: null,
      highlightedWordId: null,
      isPuzzleComplete: false,
      winnerName: null,
      pendingPlacements: const [],
      wrongPlacementsThisTurn: 0,
    );
  }

  Future<void> startSoloPractice() {
    return startSoloGame(playerName: state.localPlayer.name);
  }

  // ─── Multiplayer ──────────────────────────────────────────────────────────

  Future<String?> hostRoom(
      {required String playerName, int puzzleIndex = 0}) async {
    _cancelAi();
    await _mp.reset();
    _mpSub?.cancel();

    final puzzle = _puzzleRepo.getPuzzle(puzzleIndex);
    final grid = PuzzleRepository.buildGrid(puzzle);
    final cleanName = playerName.trim().isEmpty ? 'Host' : playerName.trim();

    state = GameState(
      puzzle: puzzle,
      grid: grid,
      words: List.from(puzzle.words),
      playerHand:
          _letterGen.generateHand(count: 7, puzzle: puzzle, grid: grid),
      aiHand: const [],
      localPlayer:
          PlayerModel(id: 'host-${_random.nextInt(9999)}', name: cleanName),
      remotePlayer: const PlayerModel(id: 'guest', name: 'Waiting...'),
      mode: GameMode.multiplayer,
      phase: GamePhase.lobby,
      turnOwner: TurnOwner.local,
      isHosting: true,
      sessionCode: null,
      statusMessage: 'Opening room on your Wi-Fi...',
      selectedHandIndex: null,
      highlightedWordId: null,
      isPuzzleComplete: false,
      winnerName: null,
      pendingPlacements: const [],
      wrongPlacementsThisTurn: 0,
    );

    try {
      final info = await _mp.startHosting();
      _mpSub = _mp.events.listen(_handleMpEvent);
      state = state.copyWith(
        sessionCode: info.shareCode,
        statusMessage: 'Room ready! Share code: ${info.shareCode}',
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        phase: GamePhase.home,
        statusMessage: 'Failed to open room: $e',
      );
      return 'Could not open room. Make sure you are on Wi-Fi.';
    }
  }

  Future<String?> joinRoom(
      {required String playerName, required String roomCode}) async {
    _cancelAi();
    await _mp.reset();
    _mpSub?.cancel();

    final parts = roomCode.trim().split(':');
    if (parts.length != 2) return 'Invalid room code. Format: 192.168.x.x:4040';
    final host = parts[0].trim();
    final port = int.tryParse(parts[1].trim());
    if (port == null) return 'Invalid port in room code.';

    final cleanName = playerName.trim().isEmpty ? 'Guest' : playerName.trim();

    state = state.copyWith(
      mode: GameMode.multiplayer,
      phase: GamePhase.lobby,
      isHosting: false,
      sessionCode: roomCode,
      statusMessage: 'Connecting to $roomCode...',
      localPlayer:
          PlayerModel(id: 'guest-${_random.nextInt(9999)}', name: cleanName),
    );

    try {
      await _mp.joinRoom(host: host, port: port);
      _mpSub = _mp.events.listen(_handleMpEvent);
      await _mp.send({
        'type': 'join_request',
        'name': cleanName,
        'id': state.localPlayer.id,
      });
      state = state.copyWith(
          statusMessage: 'Joined! Waiting for host to start...');
      return null;
    } catch (e) {
      state = state.copyWith(
        phase: GamePhase.home,
        statusMessage: 'Could not join: $e',
      );
      return 'Could not join. Make sure both devices are on the same Wi-Fi.';
    }
  }

  // ─── In-Game Actions ──────────────────────────────────────────────────────

  void selectHandLetter(int index) {
    if (!state.canAct) return;
    final newIndex = state.selectedHandIndex == index ? null : index;
    state = state.copyWith(
      selectedHandIndex: newIndex,
      clearSelection: newIndex == null,
    );
  }

  void highlightWord(String wordId) {
    state = state.copyWith(highlightedWordId: wordId);
  }

  /// Place a letter from hand onto the board as a PENDING placement.
  /// The letter is shown immediately but not scored until commitTurn().
  /// Wrong placements are tracked and penalised on commit.
  void placeLetterAt(int row, int col) {
    if (!state.canAct) return;
    final selIdx = state.selectedHandIndex;
    if (selIdx == null) return;

    final cell = state.grid[row][col];
    if (cell.isBlack) return;
    // Cannot place on a cell that already has a committed letter
    if (cell.displayLetter != null && !cell.isPending) return;
    // Cannot place on a cell already pending this turn
    if (cell.isPending) return;

    final letter = state.playerHand[selIdx];
    final isCorrect = cell.correctLetter == letter;

    // Mark cell as pending
    final newGrid = _cloneGrid(state.grid);
    newGrid[row][col] = cell.copyWith(
      playerLetter: letter,
      isPending: true,
    );

    // Remove letter from hand (replace with placeholder '_')
    final newHand = List<String>.from(state.playerHand);
    newHand[selIdx] = '_';

    final newPending = [
      ...state.pendingPlacements,
      PendingPlacement(
        row: row,
        col: col,
        letter: letter,
        handIndex: selIdx,
        isCorrect: isCorrect,
      ),
    ];

    final wrongCount =
        state.wrongPlacementsThisTurn + (isCorrect ? 0 : 1);

    final hint = isCorrect
        ? 'Good placement! Place more or tap Commit.'
        : '⚠️ Wrong letter! -2 pts penalty on commit. Place more or commit.';

    state = state.copyWith(
      grid: newGrid,
      playerHand: newHand,
      pendingPlacements: newPending,
      wrongPlacementsThisTurn: wrongCount,
      clearSelection: true,
      statusMessage: hint,
    );
  }

  /// Undo the last pending placement, returning the letter to hand.
  void undoLastPlacement() {
    if (!state.canAct) return;
    final pending = state.pendingPlacements;
    if (pending.isEmpty) return;

    final last = pending.last;
    final newGrid = _cloneGrid(state.grid);
    newGrid[last.row][last.col] = newGrid[last.row][last.col].copyWith(
      clearPlayerLetter: true,
      isPending: false,
    );

    final newHand = List<String>.from(state.playerHand);
    newHand[last.handIndex] = last.letter;

    final newPending = pending.sublist(0, pending.length - 1);
    final wrongCount =
        state.wrongPlacementsThisTurn - (last.isCorrect ? 0 : 1);

    state = state.copyWith(
      grid: newGrid,
      playerHand: newHand,
      pendingPlacements: newPending,
      wrongPlacementsThisTurn: wrongCount.clamp(0, 99),
      statusMessage: newPending.isEmpty
          ? 'Placement undone. Select a letter to place.'
          : 'Undone. ${newPending.length} letter(s) placed this turn.',
    );
  }

  /// Commit all pending placements:
  /// +1 pt per correct letter, +word-length bonus for completed words,
  /// -2 pts per wrong letter placed this turn.
  void commitTurn() {
    if (!state.canAct) return;
    if (state.pendingPlacements.isEmpty) return;

    final newGrid = _cloneGrid(state.grid);

    // Finalise all pending cells
    for (final p in state.pendingPlacements) {
      newGrid[p.row][p.col] =
          newGrid[p.row][p.col].copyWith(isPending: false);
    }

    // Replenish hand: replace '_' placeholders
    final newHand = List<String>.from(state.playerHand);
    for (int i = 0; i < newHand.length; i++) {
      if (newHand[i] == '_') {
        newHand[i] = _letterGen
            .generateHand(count: 1, puzzle: state.puzzle, grid: newGrid)
            .first;
      }
    }

    // Score: +1 per correct placement
    final correctCount =
        state.pendingPlacements.where((p) => p.isCorrect).length;
    final wrongCount = state.wrongPlacementsThisTurn;

    // Check word completions
    final (newWords, completedWordIds, wordBonus) =
        _checkCompletions(newGrid, state.words);

    int scoreGain = correctCount + wordBonus - (wrongCount * 2);
    // Score cannot go below 0
    final newScore =
        (state.localPlayer.score + scoreGain).clamp(0, 99999);

    final newLocalPlayer = state.localPlayer.copyWith(
      score: newScore,
      lettersPlaced:
          state.localPlayer.lettersPlaced + state.pendingPlacements.length,
      wordsCompleted:
          state.localPlayer.wordsCompleted + completedWordIds.length,
    );

    if (completedWordIds.isNotEmpty) {
      _flashCompletedWords(newGrid, completedWordIds, newWords);
    }

    final isPuzzleComplete = newWords.every((w) => w.isCompleted);

    String msg;
    if (isPuzzleComplete) {
      msg = _buildWinMessage(newLocalPlayer, state.remotePlayer);
    } else if (completedWordIds.isNotEmpty && wrongCount > 0) {
      msg = '🎉 Word done! But $wrongCount wrong letter(s) cost you ${wrongCount * 2} pts.';
    } else if (completedWordIds.isNotEmpty) {
      msg = '🎉 Word completed! +${correctCount + wordBonus} pts. Computer\'s turn.';
    } else if (wrongCount > 0) {
      msg = '⚠️ $wrongCount wrong letter(s): -${wrongCount * 2} pts. Computer\'s turn.';
    } else {
      msg = state.mode == GameMode.multiplayer
          ? '+$correctCount pts. Opponent\'s turn.'
          : '+$correctCount pts. Computer is thinking…';
    }

    state = state.copyWith(
      grid: newGrid,
      words: newWords,
      playerHand: newHand,
      localPlayer: newLocalPlayer,
      turnOwner: TurnOwner.remote,
      clearSelection: true,
      pendingPlacements: const [],
      wrongPlacementsThisTurn: 0,
      statusMessage: msg,
      isPuzzleComplete: isPuzzleComplete,
      winnerName: isPuzzleComplete
          ? _determineWinner(newLocalPlayer, state.remotePlayer)
          : null,
    );

    if (isPuzzleComplete) {
      state = state.copyWith(phase: GamePhase.finished);
      return;
    }

    if (state.mode == GameMode.multiplayer) {
      _mp.send({
        'type': 'commit_turn',
        'placements': state.pendingPlacements
            .map((p) => {'row': p.row, 'col': p.col, 'letter': p.letter})
            .toList(),
        'score': newLocalPlayer.score,
        'wordsCompleted': newLocalPlayer.wordsCompleted,
      }).catchError((_) {});
    } else {
      _scheduleAiMove();
    }
  }

  void swapLetter(int handIndex) {
    if (!state.canAct) return;
    // Cannot swap a letter that's been placed pending
    if (state.playerHand[handIndex] == '_') return;

    final newHand = List<String>.from(state.playerHand);
    newHand[handIndex] = _letterGen
        .generateHand(count: 1, puzzle: state.puzzle, grid: state.grid)
        .first;

    state = state.copyWith(
      playerHand: newHand,
      clearSelection: true,
      statusMessage: 'Letter swapped. Keep placing or commit your turn.',
    );
  }

  void passTurn() {
    if (!state.canAct) return;
    // Cancel any pending placements first (return letters to hand)
    if (state.pendingPlacements.isNotEmpty) {
      _cancelPendingPlacements();
    }

    state = state.copyWith(
      turnOwner: TurnOwner.remote,
      clearSelection: true,
      pendingPlacements: const [],
      wrongPlacementsThisTurn: 0,
      statusMessage: state.mode == GameMode.solo
          ? 'Turn passed. Computer\'s turn…'
          : 'Turn passed. Opponent\'s turn.',
    );
    if (state.mode == GameMode.solo) _scheduleAiMove();
    if (state.mode == GameMode.multiplayer) {
      _mp.send({'type': 'pass_turn'}).catchError((_) {});
    }
  }

  void _cancelPendingPlacements() {
    final newGrid = _cloneGrid(state.grid);
    final newHand = List<String>.from(state.playerHand);
    for (final p in state.pendingPlacements) {
      newGrid[p.row][p.col] = newGrid[p.row][p.col].copyWith(
        clearPlayerLetter: true,
        isPending: false,
      );
      newHand[p.handIndex] = p.letter;
    }
    state = state.copyWith(
      grid: newGrid,
      playerHand: newHand,
      pendingPlacements: const [],
      wrongPlacementsThisTurn: 0,
    );
  }

  // ─── AI Logic ─────────────────────────────────────────────────────────────

  void _scheduleAiMove() {
    if (_aiThinking) return;
    _aiThinking = true;
    _aiTimer?.cancel();
    _aiTimer = Timer(
      Duration(milliseconds: 1200 + _random.nextInt(1000)),
      _performAiMove,
    );
  }

  Future<void> _performAiMove() async {
    _aiThinking = false;
    if (state.phase != GamePhase.playing ||
        state.turnOwner != TurnOwner.remote) return;

    final move = await _ai.computeMove(
      state: state,
      thinkTime: const Duration(milliseconds: 200),
    );

    if (!mounted) return;

    if (move == null) {
      final newHand = List<String>.from(state.aiHand);
      if (newHand.isNotEmpty) {
        final idx = _random.nextInt(newHand.length);
        newHand[idx] = _letterGen
            .generateHand(count: 1, puzzle: state.puzzle, grid: state.grid)
            .first;
      }
      state = state.copyWith(
        aiHand: newHand,
        turnOwner: TurnOwner.local,
        statusMessage: 'Computer passed. Your turn!',
      );
      return;
    }

    final newGrid = _cloneGrid(state.grid);
    final cell = newGrid[move.row][move.col];
    newGrid[move.row][move.col] =
        cell.copyWith(opponentLetter: move.letter);

    final newAiHand = List<String>.from(state.aiHand);
    newAiHand[move.handIndex] = _letterGen
        .generateHand(count: 1, puzzle: state.puzzle, grid: newGrid)
        .first;

    final (newWords, completedWordIds, scoreGain) =
        _checkCompletions(newGrid, state.words);

    final newRemotePlayer = state.remotePlayer.copyWith(
      score: state.remotePlayer.score + 1 + scoreGain,
      lettersPlaced: state.remotePlayer.lettersPlaced + 1,
      wordsCompleted:
          state.remotePlayer.wordsCompleted + completedWordIds.length,
    );

    final isPuzzleComplete = newWords.every((w) => w.isCompleted);

    state = state.copyWith(
      grid: newGrid,
      words: newWords,
      aiHand: newAiHand,
      remotePlayer: newRemotePlayer,
      turnOwner: TurnOwner.local,
      statusMessage: isPuzzleComplete
          ? _buildWinMessage(state.localPlayer, newRemotePlayer)
          : completedWordIds.isNotEmpty
              ? 'Computer completed a word! Your turn.'
              : 'Computer played. Your turn!',
      isPuzzleComplete: isPuzzleComplete,
      winnerName: isPuzzleComplete
          ? _determineWinner(state.localPlayer, newRemotePlayer)
          : null,
    );

    if (isPuzzleComplete) {
      state = state.copyWith(phase: GamePhase.finished);
    }
  }

  // ─── Multiplayer Event Handling ───────────────────────────────────────────

  void _handleMpEvent(Map<String, dynamic> event) {
    switch (event['type']) {
      case 'peer_connected':
        state = state.copyWith(
            statusMessage: 'Opponent connected! Starting game...');
        if (state.isHosting) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _mp.send({
              'type': 'game_start',
              'puzzleId': state.puzzle.id,
              'hostName': state.localPlayer.name,
            }).catchError((_) {});
            state = state.copyWith(
              phase: GamePhase.playing,
              statusMessage: 'Game started! Your turn.',
            );
          });
        }
        break;

      case 'join_request':
        if (state.isHosting) {
          final guestName = event['name'] as String? ?? 'Guest';
          state = state.copyWith(
            remotePlayer: PlayerModel(
                id: event['id'] as String? ?? 'guest', name: guestName),
            statusMessage: '$guestName joined!',
          );
        }
        break;

      case 'game_start':
        if (!state.isHosting) {
          final hostName = event['hostName'] as String? ?? 'Host';
          state = state.copyWith(
            phase: GamePhase.playing,
            turnOwner: TurnOwner.remote,
            remotePlayer: state.remotePlayer.copyWith(name: hostName),
            statusMessage: 'Game started! Host goes first.',
          );
        }
        break;

      case 'commit_turn':
        _handleRemoteCommitTurn(event);
        break;

      case 'swap_turn':
      case 'pass_turn':
        state = state.copyWith(
          turnOwner: TurnOwner.local,
          statusMessage: 'Opponent passed. Your turn!',
        );
        break;

      case 'peer_disconnected':
      case 'host_disconnected':
        state = state.copyWith(
          statusMessage: 'Opponent disconnected.',
          phase: GamePhase.home,
        );
        break;
    }
  }

  void _handleRemoteCommitTurn(Map<String, dynamic> event) {
    final placements =
        (event['placements'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final remoteScore = event['score'] as int? ?? state.remotePlayer.score;
    final remoteWords =
        event['wordsCompleted'] as int? ?? state.remotePlayer.wordsCompleted;

    final newGrid = _cloneGrid(state.grid);
    for (final p in placements) {
      final row = p['row'] as int? ?? -1;
      final col = p['col'] as int? ?? -1;
      final letter = p['letter'] as String? ?? '';
      if (row < 0 || col < 0 || letter.isEmpty) continue;
      final cell = newGrid[row][col];
      if (!cell.isBlack && cell.displayLetter == null) {
        newGrid[row][col] = cell.copyWith(opponentLetter: letter);
      }
    }

    final (newWords, _, _) = _checkCompletions(newGrid, state.words);
    final isPuzzleComplete = newWords.every((w) => w.isCompleted);

    state = state.copyWith(
      grid: newGrid,
      words: newWords,
      turnOwner: TurnOwner.local,
      remotePlayer: state.remotePlayer.copyWith(
        score: remoteScore,
        wordsCompleted: remoteWords,
      ),
      statusMessage: isPuzzleComplete
          ? _buildWinMessage(state.localPlayer, state.remotePlayer)
          : 'Opponent played. Your turn!',
      isPuzzleComplete: isPuzzleComplete,
      winnerName: isPuzzleComplete
          ? _determineWinner(state.localPlayer, state.remotePlayer)
          : null,
    );

    if (isPuzzleComplete) {
      state = state.copyWith(phase: GamePhase.finished);
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  (List<CrosswordWord>, List<String>, int) _checkCompletions(
    List<List<GridCell>> grid,
    List<CrosswordWord> currentWords,
  ) {
    final newWords = <CrosswordWord>[];
    final completedIds = <String>[];
    int bonusScore = 0;

    for (final word in currentWords) {
      if (word.isCompleted) {
        newWords.add(word);
        continue;
      }
      final positions = word.positions;
      final isNowComplete = positions.every((pos) {
        final (r, c) = pos;
        return !grid[r][c].isBlack && grid[r][c].displayLetter != null;
      });
      if (isNowComplete) {
        newWords.add(word.copyWith(isCompleted: true));
        completedIds.add(word.id);
        bonusScore += word.answer.length;
      } else {
        newWords.add(word);
      }
    }
    return (newWords, completedIds, bonusScore);
  }

  void _flashCompletedWords(
    List<List<GridCell>> grid,
    List<String> wordIds,
    List<CrosswordWord> words,
  ) {
    for (final wordId in wordIds) {
      final word =
          words.firstWhere((w) => w.id == wordId, orElse: () => words.first);
      for (final (r, c) in word.positions) {
        if (r < grid.length && c < grid[r].length) {
          grid[r][c] = grid[r][c].copyWith(isHighlighted: true);
        }
      }
    }
  }

  List<List<GridCell>> _cloneGrid(List<List<GridCell>> source) {
    return source.map((row) => List<GridCell>.from(row)).toList();
  }

  String _buildWinMessage(PlayerModel local, PlayerModel remote) {
    if (local.score > remote.score)
      return '🏆 You win! ${local.score} vs ${remote.score}';
    if (remote.score > local.score)
      return '${remote.name} wins! ${remote.score} vs ${local.score}';
    return 'It\'s a tie! ${local.score} pts each';
  }

  String? _determineWinner(PlayerModel local, PlayerModel remote) {
    if (local.score > remote.score) return local.name;
    if (remote.score > local.score) return remote.name;
    return 'Tie';
  }

  void _cancelAi() {
    _aiTimer?.cancel();
    _aiTimer = null;
    _aiThinking = false;
  }

  @override
  void dispose() {
    _cancelAi();
    _mpSub?.cancel();
    _mp.dispose();
    super.dispose();
  }
}
