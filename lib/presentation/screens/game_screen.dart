import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/word_model.dart';
import '../../state/game_provider.dart';
import '../widgets/crossword_board.dart';
import '../widgets/hand_letters.dart';
import '../widgets/score_display.dart';
import '../widgets/swap_panel.dart';
import '../widgets/turn_indicator.dart';
import 'hint_popup.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return SafeArea(
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Text(
                    gameState.puzzle.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const HintPopup(),
                  ),
                  icon: const Icon(Icons.lightbulb_outline,
                      color: AppColors.primary),
                ),
              ],
            ),
          ),

          // ── Scores ──────────────────────────────────────────────────────
          ScoreDisplay(
            playerScore: gameState.player.score,
            aiScore: gameState.opponent.score,
          ),
          const SizedBox(height: 8),

          // ── Turn indicator ───────────────────────────────────────────────
          TurnIndicator(isPlayerTurn: gameState.isPlayerTurn),
          const SizedBox(height: 8),

          // ── Clue display ─────────────────────────────────────────────────
          if (gameState.activeClue != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.clueTile,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  gameState.activeClue!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // ── Clue list (compact) ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _ClueList(words: gameState.puzzle.words),
          ),

          // ── Board ────────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.boardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const CrosswordBoard(),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ── Player hand ──────────────────────────────────────────────────
          const HandLetters(),
          const SizedBox(height: 10),

          // ── Controls ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SwapPanel(
                  onSwap: () => ref
                      .read(gameProvider.notifier)
                      .swapLetters([0, 1]),
                ),
                ElevatedButton(
                  onPressed: gameState.isPlayerTurn
                      ? () => ref.read(gameProvider.notifier).endTurn()
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(140, 50),
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Pass',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.menu_book, color: AppColors.primary),
                  onPressed: () => _showCluesDialog(context, gameState),
                ),
              ],
            ),
          ),

          // ── Game over banner ─────────────────────────────────────────────
          if (gameState.isGameOver)
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                gameState.player.score >= gameState.opponent.score
                    ? '🎉 Puzzle Complete! You win!'
                    : '✅ Puzzle Complete! Computer wins!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCluesDialog(BuildContext context, dynamic gameState) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clues'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('ACROSS',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 4),
              ...(gameState.puzzle.words as List<WordModel>)
                  .where((w) => w.direction == WordDirection.across)
                  .map((w) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(w.clue,
                            style: const TextStyle(fontSize: 14)),
                      )),
              const SizedBox(height: 8),
              const Text('DOWN',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 4),
              ...(gameState.puzzle.words as List<WordModel>)
                  .where((w) => w.direction == WordDirection.down)
                  .map((w) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(w.clue,
                            style: const TextStyle(fontSize: 14)),
                      )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// ── Compact clue list embedded in screen ────────────────────────────────────

class _ClueList extends StatelessWidget {
  const _ClueList({required this.words});

  final List<WordModel> words;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ClueColumn(
            header: 'ACROSS',
            clues: words
                .where((w) => w.direction == WordDirection.across)
                .toList(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ClueColumn(
            header: 'DOWN',
            clues: words
                .where((w) => w.direction == WordDirection.down)
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _ClueColumn extends StatelessWidget {
  const _ClueColumn({required this.header, required this.clues});

  final String header;
  final List<WordModel> clues;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        ...clues.map(
          (w) => Text(
            w.clue,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
