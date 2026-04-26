import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/game_state_model.dart';
import '../../state/game_provider.dart';
import '../widgets/crossword_board.dart';
import '../widgets/hand_letters.dart';
import '../widgets/score_display.dart';
import '../widgets/swap_panel.dart';
import '../widgets/turn_indicator.dart';
import 'hint_popup.dart';
import 'word_popup.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  ProviderSubscription<GameStateModel>? _gameSubscription;
  Timer? _presenceTimer;
  String? _presenceMessage;
  int _presenceEpoch = 0;

  @override
  void initState() {
    super.initState();
    _gameSubscription = ref.listenManual<GameStateModel>(
      gameProvider,
      (previous, next) {
        if (previous == null || !mounted || !next.isMultiplayer) {
          return;
        }
        if (!previous.hasOpponent && next.hasOpponent) {
          _showPresence('${next.opponent.name} joined the match');
          return;
        }
        if (previous.hasOpponent && !next.hasOpponent) {
          _showPresence('${previous.opponent.name} left the match');
        }
      },
    );
  }

  @override
  void dispose() {
    _gameSubscription?.close();
    _presenceTimer?.cancel();
    super.dispose();
  }

  void _showPresence(String message) {
    _presenceTimer?.cancel();
    setState(() {
      _presenceMessage = message;
      _presenceEpoch++;
    });
    _presenceTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      setState(() => _presenceMessage = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    final showTypingIndicator = gameState.isMultiplayer &&
        gameState.hasOpponent &&
        !gameState.isPlayerTurn;

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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, animation) => SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: _presenceMessage == null
                ? const SizedBox(
                    key: ValueKey('presence-none'),
                    height: 0,
                  )
                : Padding(
                    key: ValueKey('presence-$_presenceEpoch'),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: _PresenceEventBanner(message: _presenceMessage!),
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
            emphasizeTurn: gameState.isMultiplayer &&
                gameState.hasOpponent &&
                gameState.isPlayerTurn,
          ),
          const SizedBox(height: 8),
          _OpponentTypingIndicator(
            visible: showTypingIndicator,
            opponentName: gameState.opponent.name,
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
                isMultiplayer: gameState.isMultiplayer,
                isLocalTurn: gameState.isPlayerTurn,
                hasOpponent: gameState.hasOpponent,
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

class _PresenceEventBanner extends StatelessWidget {
  const _PresenceEventBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.people_alt_rounded, color: AppColors.successText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.successText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpponentTypingIndicator extends StatelessWidget {
  const _OpponentTypingIndicator({
    required this.visible,
    required this.opponentName,
  });

  final bool visible;
  final String opponentName;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: child,
          ),
        );
      },
      child: !visible
          ? const SizedBox(
              key: ValueKey('typing-hidden'),
              height: 0,
            )
          : Container(
              key: const ValueKey('typing-visible'),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.secondary),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$opponentName is typing',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const _TypingDots(),
                ],
              ),
            ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  static const double _phaseOffsetPerDot = 0.2;
  static const double _waveCenter = 0.5;
  static const double _baseOpacity = 0.25;
  static const double _waveOpacityRange = 0.75;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _dotOpacity(int index) {
    final phase = (_controller.value + (index * _phaseOffsetPerDot)) % 1.0;
    final wave = 1 - ((phase - _waveCenter).abs() * 2);
    return _baseOpacity + (wave * _waveOpacityRange);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          children: List.generate(3, (index) {
            return Opacity(
              opacity: _dotOpacity(index),
              child: Container(
                margin: EdgeInsets.only(right: index == 2 ? 0 : 4),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Text(
                    status,
                    key: ValueKey(status),
                  ),
                ),
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
