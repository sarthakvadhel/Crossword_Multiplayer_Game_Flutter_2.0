import 'package:flutter/material.dart';

import '../widgets/animated_card_tap.dart';
import '../widgets/animated_new_game_button.dart';
import '../widgets/multiplayer_mode_card.dart';
import '../widgets/tournament_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onContinue,
    required this.onRestart,
    required this.onMultiplayer,
    required this.onTournament,
    required this.onLeaderboard,
    required this.statusText,
    required this.roomCode,
    required this.isMultiplayerActive,
  });

  final Future<void> Function() onContinue;
  final Future<void> Function() onRestart;
  final Future<void> Function() onMultiplayer;
  final Future<void> Function() onTournament;
  final Future<void> Function() onLeaderboard;
  final String statusText;
  final String? roomCode;
  final bool isMultiplayerActive;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Crossword Master',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2F5A),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onLeaderboard,
                  icon: const Icon(Icons.leaderboard_rounded),
                  label: const Text('Leaderboard'),
                ),
              ),
              const SizedBox(height: 36),

              // Top Cards Section
              SizedBox(
                height: 280,
                child: Row(
                  children: [
                    // Multiplayer Mode Card
                    Expanded(
                      child: AnimatedCardTap(
                        child: MultiplayerModeCard(
                          onlinePlayers: 42,
                          onPlay: onMultiplayer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tournament Card
                    Expanded(
                      child: AnimatedCardTap(
                        child: TournamentCard(
                          timeRemaining: '4d 17h',
                          score: 42,
                          onPlay: onTournament,
                          buttonLabel: 'Play Tournament',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 64),

              // New Game Button
              Center(
                child: AnimatedNewGameButton(
                  onPressed: onContinue,
                  puzzleNumber: 2,
                ),
              ),
              const SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }
}
