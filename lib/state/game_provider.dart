import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/storage_service.dart';
import '../data/models/game_state_model.dart';
import '../data/models/player_model.dart';
import '../data/models/tile_model.dart';
import '../data/puzzles/puzzle_1.dart';
import '../game_engine/ai_engine.dart';
import '../game_engine/board_engine.dart';
import '../game_engine/letter_generator.dart';
import '../game_engine/move_validator.dart';
import '../game_engine/scoring_engine.dart';

final gameProvider =
    StateNotifierProvider<GameNotifier, GameStateModel>((ref) {
  return GameNotifier(
    storageService: StorageService(),
    boardEngine: BoardEngine(),
    letterGenerator: LetterGenerator(),
    aiEngine: AiEngine(),
    moveValidator: MoveValidator(),
    scoringEngine: ScoringEngine(),
  );
});

class GameNotifier extends StateNotifier<GameStateModel> {
  GameNotifier({
    required this.storageService,
    required this.boardEngine,
    required this.letterGenerator,
    required this.aiEngine,
    required this.moveValidator,
    required this.scoringEngine,
  }) : super(_buildInitialState(
          boardEngine: boardEngine,
          letterGenerator: letterGenerator,
        ));

  final StorageService storageService;
  final BoardEngine boardEngine;
  final LetterGenerator letterGenerator;
  final AiEngine aiEngine;
  final MoveValidator moveValidator;
  final ScoringEngine scoringEngine;

  // ── State construction ──────────────────────────────────────────────────

  static GameStateModel _buildInitialState({
    required BoardEngine boardEngine,
    required LetterGenerator letterGenerator,
  }) {
    final puzzle = puzzle1;
    final board = boardEngine.buildBoardFromPuzzle(puzzle);
    final playerHand =
        letterGenerator.generateHandForPuzzle(puzzle, board, 7);
    final aiHand = letterGenerator.generateHandForPuzzle(puzzle, board, 7);

    return GameStateModel(
      board: board,
      playerHand: playerHand,
      aiHand: aiHand,
      player: const PlayerModel(
        name: 'You',
        score: 0,
        longestWord: 0,
        streak: 0,
      ),
      opponent: const PlayerModel(
        name: 'Computer',
        score: 0,
        longestWord: 0,
        streak: 0,
      ),
      isPlayerTurn: true,
      puzzle: puzzle,
    );
  }

  // ── Player actions ───────────────────────────────────────────────────────

  /// Toggle selection of a tile in the player's hand.
  void selectHandTile(int index) {
    if (!state.isPlayerTurn) return;
    if (index == state.selectedHandIndex) {
      state = state.copyWith(clearSelectedHand: true);
    } else {
      state = state.copyWith(selectedHandIndex: index);
    }
  }

  /// Called when the player taps a cell on the board.
  void tapBoardCell(int boardIndex) {
    if (state.isGameOver) return;

    final tile = state.board[boardIndex];
    if (tile.isBlocked) return;

    final selIdx = state.selectedHandIndex;

    // No hand tile selected – just show the clue for this cell
    if (selIdx == null) {
      _updateActiveClue(tile.row, tile.col);
      return;
    }

    // Can't place on a given/already-filled cell
    if (tile.isGiven || tile.letter != null) {
      state = state.copyWith(clearSelectedHand: true);
      return;
    }

    final letter = state.playerHand[selIdx];
    final correct = moveValidator.isValidPlacement(
        state.puzzle, tile.row, tile.col, letter);

    if (correct) {
      _placeLetter(boardIndex, letter, byPlayer: true, handIndex: selIdx);
    } else {
      // Wrong letter – deselect without placing
      state = state.copyWith(clearSelectedHand: true);
    }
  }

  void _placeLetter(
    int boardIndex,
    String letter, {
    required bool byPlayer,
    int? handIndex,
  }) {
    final size = state.puzzle.gridSize;
    final oldBoard = List<TileModel>.from(state.board);
    final newBoard = List<TileModel>.from(state.board);
    newBoard[boardIndex] = newBoard[boardIndex].copyWith(
      letter: letter,
      isGiven: true,
    );

    int playerScore = state.player.score;
    int aiScore = state.opponent.score;
    final newHand = List<String>.from(state.playerHand);

    final completionBonus = _newCompletionBonus(oldBoard, newBoard, size);

    if (byPlayer && handIndex != null) {
      playerScore += scoringEngine.scoreLetters(1) + completionBonus;

      newHand.removeAt(handIndex);
      // Replenish hand
      final replenish =
          letterGenerator.generateHandForPuzzle(state.puzzle, newBoard, 1);
      if (replenish.isNotEmpty) newHand.add(replenish.first);
    } else {
      aiScore += scoringEngine.scoreLetters(1) + completionBonus;
    }

    state = state.copyWith(
      board: newBoard,
      playerHand: newHand,
      player: state.player.copyWith(score: playerScore),
      opponent: state.opponent.copyWith(score: aiScore),
      clearSelectedHand: true,
    );

    if (byPlayer && !state.isGameOver) {
      _scheduleAiTurn();
    }
  }

  /// Returns bonus points only for words newly completed by this placement.
  int _newCompletionBonus(
    List<TileModel> oldBoard,
    List<TileModel> newBoard,
    int size,
  ) {
    int bonus = 0;
    for (final word in state.puzzle.words) {
      final wasComplete = word.positions.every((pos) {
        final idx = pos.$1 * size + pos.$2;
        return idx < oldBoard.length && oldBoard[idx].letter != null;
      });
      if (wasComplete) continue;

      final isNowComplete = word.positions.every((pos) {
        final idx = pos.$1 * size + pos.$2;
        return idx < newBoard.length && newBoard[idx].letter != null;
      });
      if (isNowComplete) {
        bonus += scoringEngine.scoreWordCompletion(word.answer.length);
      }
    }
    return bonus;
  }

  void _updateActiveClue(int row, int col) {
    final pos = (row, col);
    for (final word in state.puzzle.words) {
      if (word.positions.contains(pos)) {
        state = state.copyWith(activeClue: word.clue);
        return;
      }
    }
  }

  // ── AI turn ──────────────────────────────────────────────────────────────

  Future<void> _scheduleAiTurn() async {
    state = state.copyWith(isPlayerTurn: false);

    final placements = await aiEngine.performTurn(state);
    if (!mounted) return;

    final size = state.puzzle.gridSize;
    var newBoard = List<TileModel>.from(state.board);
    int aiScore = state.opponent.score;

    for (final (idx, letter) in placements) {
      if (idx < newBoard.length && newBoard[idx].letter == null) {
        final before = List<TileModel>.from(newBoard);
        newBoard[idx] = newBoard[idx].copyWith(letter: letter, isGiven: true);
        aiScore += scoringEngine.scoreLetters(1) +
            _newCompletionBonus(before, newBoard, size);
      }
    }

    state = state.copyWith(
      board: newBoard,
      opponent: state.opponent.copyWith(score: aiScore),
      isPlayerTurn: true,
    );
  }

  // ── Utility actions ──────────────────────────────────────────────────────

  void swapLetters(List<int> indices) {
    if (!state.isPlayerTurn) return;
    final updated = List<String>.from(state.playerHand);
    for (final i in indices) {
      if (i >= 0 && i < updated.length) {
        final fresh = letterGenerator.generateHandForPuzzle(
            state.puzzle, state.board, 1);
        updated[i] = fresh.isNotEmpty
            ? fresh.first
            : letterGenerator.generateHand(1).first;
      }
    }
    state = state.copyWith(playerHand: updated);
    _scheduleAiTurn();
  }

  void endTurn() {
    if (!state.isPlayerTurn || state.isGameOver) return;
    _scheduleAiTurn();
  }

  void resetGame() {
    state = _buildInitialState(
      boardEngine: boardEngine,
      letterGenerator: letterGenerator,
    );
  }
}
