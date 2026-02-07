import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../state/game_provider.dart';
import '../widgets/crossword_board.dart';
import '../widgets/hand_letters.dart';
import '../widgets/score_display.dart';
import '../widgets/swap_panel.dart';
import '../widgets/turn_indicator.dart';
import 'hint_popup.dart';
import 'word_popup.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
                ),
                Expanded(
                  child: Text(
                    'February 1',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings, color: AppColors.primary),
                ),
              ],
            ),
          ),
          ScoreDisplay(
            playerScore: gameState.player.score,
            aiScore: gameState.opponent.score,
          ),
          const SizedBox(height: 12),
          TurnIndicator(isPlayerTurn: gameState.isPlayerTurn),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.boardBorder),
              ),
              child: const CrosswordBoard(size: 9),
            ),
          ),
          const SizedBox(height: 16),
          HandLetters(letters: gameState.playerHand),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SwapPanel(onSwap: () => ref.read(gameProvider.notifier).swapLetters([0, 1])),
                ElevatedButton(
                  onPressed: () => ref.read(gameProvider.notifier).endTurn(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(160, 54),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text('Pass', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu_book, color: AppColors.primary),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const WordPopup(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.lightbulb_outline, color: AppColors.primary),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const HintPopup(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
