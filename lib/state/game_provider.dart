import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/storage_service.dart';
import '../data/models/game_state_model.dart';
import '../data/models/player_model.dart';
import '../game_engine/board_engine.dart';
import '../game_engine/letter_generator.dart';
import '../game_engine/turn_manager.dart';

final gameProvider = StateNotifierProvider<GameNotifier, GameStateModel>((ref) {
  return GameNotifier(
    storageService: StorageService(),
    boardEngine: BoardEngine(),
    letterGenerator: LetterGenerator(),
    turnManager: TurnManager(),
  );
});

class GameNotifier extends StateNotifier<GameStateModel> {
  GameNotifier({
    required this.storageService,
    required this.boardEngine,
    required this.letterGenerator,
    required this.turnManager,
  }) : super(
          GameStateModel(
            board: boardEngine.buildBoard(9),
            playerHand: letterGenerator.generateHand(5),
            aiHand: letterGenerator.generateHand(5),
            player: const PlayerModel(
              name: 'You',
              score: 0,
              longestWord: 0,
              streak: 0,
            ),
            opponent: const PlayerModel(
              name: 'Opponent',
              score: 2,
              longestWord: 0,
              streak: 0,
            ),
            isPlayerTurn: true,
          ),
        );

  final StorageService storageService;
  final BoardEngine boardEngine;
  final LetterGenerator letterGenerator;
  final TurnManager turnManager;

  void swapLetters(List<int> indices) {
    final updated = [...state.playerHand];
    for (final index in indices) {
      if (index >= 0 && index < updated.length) {
        updated[index] = letterGenerator.generateHand(1).first;
      }
    }
    state = state.copyWith(playerHand: updated, isPlayerTurn: false);
  }

  void endTurn() {
    turnManager.toggleTurn();
    state = state.copyWith(isPlayerTurn: turnManager.isPlayerTurn);
  }
}
