import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final gameNotifier = ref.read(gameProvider.notifier);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_ios,
                      color: AppColors.primary),
                ),
                Expanded(
                  child: Text(
                    gameState.isMultiplayer
                        ? 'Multiplayer Board'
                        : 'Solo Practice Board',
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
          if (gameState.isMultiplayer)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _RoomBanner(
                status: gameState.connectionStatus,
                roomCode: gameState.sessionCode,
              ),
            ),
          ScoreDisplay(
            playerName: gameState.player.name,
            opponentName: gameState.opponent.name,
            playerScore: gameState.player.score,
            opponentScore: gameState.opponent.score,
          ),
          const SizedBox(height: 12),
          TurnIndicator(
            label: gameState.connectionStatus,
            active: gameState.canLocalPlayerAct,
          ),
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
              child: CrosswordBoard(
                size: gameState.boardSize,
                tiles: gameState.board,
                enabled: gameState.canLocalPlayerAct &&
                    gameState.selectedHandIndex != null,
                onTileTap: gameNotifier.placeSelectedLetter,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            gameState.selectedHandIndex == null
                ? 'Pick a letter from your rack to place it on the board.'
                : 'Tap an empty square to place the selected letter.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          HandLetters(
            letters: gameState.playerHand,
            selectedIndex: gameState.selectedHandIndex,
            enabled: gameState.canLocalPlayerAct,
            onTap: gameNotifier.selectHandLetter,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SwapPanel(
                    onSwap: gameState.canLocalPlayerAct
                        ? gameNotifier.swapLetters
                        : null,
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: gameState.canLocalPlayerAct
                        ? gameNotifier.endTurn
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Text(
                      gameState.isMultiplayer ? 'Pass Turn' : 'Refresh Turn',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu_book,
                            color: AppColors.primary),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => const WordPopup(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.lightbulb_outline,
                            color: AppColors.primary),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => const HintPopup(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomBanner extends StatelessWidget {
  const _RoomBanner({
    required this.status,
    required this.roomCode,
  });

  final String status;
  final String? roomCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_tethering_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roomCode == null ? 'Connecting match' : 'Room $roomCode',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(status),
              ],
            ),
          ),
          if (roomCode != null)
            TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: roomCode!));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Room code copied')),
                  );
                }
              },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copy'),
            ),
        ],
      ),
    );
  }
}
