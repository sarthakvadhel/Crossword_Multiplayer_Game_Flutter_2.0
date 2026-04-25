import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../state/game_provider.dart';
import '../widgets/crossword_board.dart';
import '../widgets/hand_letters.dart';
import '../widgets/swap_panel.dart';

class TournamentModeScreen extends ConsumerStatefulWidget {
  const TournamentModeScreen({super.key});

  @override
  ConsumerState<TournamentModeScreen> createState() =>
      _TournamentModeScreenState();
}

class _TournamentModeScreenState extends ConsumerState<TournamentModeScreen> {
  static const int _matchDurationSeconds = 120;
  static const int _startCountdownSeconds = 3;

  Timer? _matchTimer;
  Timer? _startTimer;
  int _timeLeftSeconds = _matchDurationSeconds;
  int _startCountdown = _startCountdownSeconds;
  bool _countdownActive = true;
  bool _resultPresented = false;

  @override
  void initState() {
    super.initState();
    _startTournamentAnimation();
  }

  @override
  void dispose() {
    _matchTimer?.cancel();
    _startTimer?.cancel();
    super.dispose();
  }

  void _startTournamentAnimation() {
    _startTimer?.cancel();
    _startCountdown = _startCountdownSeconds;
    _countdownActive = true;

    _startTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_startCountdown == 0) {
        timer.cancel();
        setState(() => _countdownActive = false);
        _startMatchTimer();
        return;
      }
      setState(() => _startCountdown--);
    });
  }

  void _startMatchTimer() {
    _matchTimer?.cancel();
    _timeLeftSeconds = _matchDurationSeconds;
    _matchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_timeLeftSeconds == 0) {
        timer.cancel();
        _openResults();
        return;
      }
      setState(() => _timeLeftSeconds--);
    });
  }

  Future<void> _openResults() async {
    if (_resultPresented) {
      return;
    }
    _resultPresented = true;
    _matchTimer?.cancel();
    _startTimer?.cancel();

    final gameState = ref.read(gameProvider);
    final leaderboard = _buildLeaderboard(
      gameState.player.name,
      gameState.player.score,
    );
    final rank = leaderboard
            .indexWhere((entry) => entry.name == gameState.player.name) +
        1;

    final action = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => TournamentResultScreen(
          score: gameState.player.score,
          rank: rank,
          localPlayerName: gameState.player.name,
          leaderboard: leaderboard,
        ),
      ),
    );

    if (!mounted) {
      return;
    }
    if (action == 'play_again') {
      await ref.read(gameProvider.notifier).startSoloPractice();
      if (!mounted) {
        return;
      }
      setState(() {
        _timeLeftSeconds = _matchDurationSeconds;
        _resultPresented = false;
      });
      _startTournamentAnimation();
      return;
    }

    Navigator.of(context).maybePop();
  }

  List<_LeaderboardEntry> _buildLeaderboard(String playerName, int playerScore) {
    final entries = <_LeaderboardEntry>[
      const _LeaderboardEntry(name: 'Lexi', score: 40),
      const _LeaderboardEntry(name: 'Arjun', score: 32),
      const _LeaderboardEntry(name: 'Mina', score: 27),
      const _LeaderboardEntry(name: 'Zoe', score: 21),
      _LeaderboardEntry(name: playerName, score: playerScore),
    ];
    entries.sort((a, b) => b.score.compareTo(a.score));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    final leaderboard = _buildLeaderboard(
      gameState.player.name,
      gameState.player.score,
    );
    final rank =
        leaderboard.indexWhere((entry) => entry.name == gameState.player.name) +
            1;
    final timerLabel =
        '${(_timeLeftSeconds ~/ 60).toString().padLeft(2, '0')}:${(_timeLeftSeconds % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tournament Mode'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TournamentStatusHeader(
                      timerLabel: timerLabel,
                      score: gameState.player.score,
                      rank: rank,
                    ),
                    const SizedBox(height: 12),
                    _LeaderboardPreview(
                      leaderboard: leaderboard.take(4).toList(),
                      localPlayerName: gameState.player.name,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.boardBorder),
                      ),
                      child: CrosswordBoard(
                        size: gameState.boardSize,
                        tiles: gameState.board,
                        enabled: !_countdownActive &&
                            gameState.canLocalPlayerAct &&
                            gameState.selectedHandIndex != null,
                        onTileTap: gameNotifier.placeSelectedLetter,
                        isMultiplayer: false,
                        isLocalTurn: true,
                        hasOpponent: false,
                      ),
                    ),
                    const SizedBox(height: 12),
                    HandLetters(
                      letters: gameState.playerHand,
                      selectedIndex: gameState.selectedHandIndex,
                      enabled: !_countdownActive && gameState.canLocalPlayerAct,
                      onTap: gameNotifier.selectHandLetter,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SwapPanel(
                            onSwap: _countdownActive || _resultPresented
                                ? null
                                : gameNotifier.swapLetters,
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _countdownActive || _resultPresented
                                ? null
                                : _openResults,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(54),
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              'Finish Match',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_countdownActive)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.36),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Text(
                          _startCountdown == 0
                              ? 'GO!'
                              : 'Starts in $_startCountdown',
                          key: ValueKey(_startCountdown),
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TournamentStatusHeader extends StatelessWidget {
  const _TournamentStatusHeader({
    required this.timerLabel,
    required this.score,
    required this.rank,
  });

  final String timerLabel;
  final int score;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: AppColors.secondary),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MetricPill(
              icon: Icons.timer_rounded,
              label: 'Time',
              value: timerLabel,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MetricPill(
              icon: Icons.emoji_events_rounded,
              label: 'Score',
              value: '$score',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MetricPill(
              icon: Icons.leaderboard_rounded,
              label: 'Rank',
              value: '#$rank',
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardPreview extends StatelessWidget {
  const _LeaderboardPreview({
    required this.leaderboard,
    required this.localPlayerName,
  });

  final List<_LeaderboardEntry> leaderboard;
  final String localPlayerName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Leaderboard Preview',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < leaderboard.length; index++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 26,
                    child: Text(
                      '#${index + 1}',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      leaderboard[index].name,
                      style: TextStyle(
                        fontWeight: leaderboard[index].name == localPlayerName
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Text(
                    '${leaderboard[index].score}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
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

class TournamentResultScreen extends StatelessWidget {
  const TournamentResultScreen({
    super.key,
    required this.score,
    required this.rank,
    required this.localPlayerName,
    required this.leaderboard,
  });

  final int score;
  final int rank;
  final String localPlayerName;
  final List<_LeaderboardEntry> leaderboard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Icon(
                Icons.emoji_events_rounded,
                size: 58,
                color: AppColors.primary,
              ),
              const SizedBox(height: 14),
              const Text(
                'Match Complete',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Final Score: $score   •   Rank #$rank',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: _LeaderboardPreview(
                  leaderboard: leaderboard.take(5).toList(),
                  localPlayerName: localPlayerName,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop('play_again'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Text(
                  'Play Again',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop('home'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  side: const BorderSide(color: AppColors.boardBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderboardEntry {
  const _LeaderboardEntry({
    required this.name,
    required this.score,
  });

  final String name;
  final int score;
}
