import 'package:flutter/material.dart';
import '../widgets/daily_puzzle_card.dart';
import '../widgets/tournament_card.dart';
import '../widgets/animated_new_game_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onContinue,
    required this.onRestart,
    required this.onMultiplayer,
    required this.statusText,
    required this.roomCode,
    required this.isMultiplayerActive,
  });

  final Future<void> Function() onContinue;
  final Future<void> Function() onRestart;
  final Future<void> Function() onMultiplayer;
  final String statusText;
  final String? roomCode;
  final bool isMultiplayerActive;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dateStr = 'April ${today.day}';

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Cards Section
              SizedBox(
                height: 280,
                child: Row(
                  children: [
                    // Daily Puzzle Card
                    Expanded(
                      child: DailyPuzzleCard(
                        date: dateStr,
                        onPlay: onContinue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tournament Card
                    Expanded(
                      child: TournamentCard(
                        timeRemaining: '4d 17h',
                        score: 42,
                        onPlay: onMultiplayer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Title
              const Text(
                'Crossword Master',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2F5A),
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
