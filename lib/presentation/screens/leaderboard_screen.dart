import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../state/auth_provider.dart';
import '../../state/game_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final authUser = ref.watch(authProvider);
    final playerName = authUser?.displayName ?? gameState.localPlayer.name;
    final playerScore = gameState.localPlayer.score;

    // Build a simple local leaderboard with mock opponents + current player
    final entries = <_Entry>[
      const _Entry(name: 'Lexi', score: 48),
      const _Entry(name: 'Arjun', score: 39),
      const _Entry(name: 'Mina', score: 31),
      const _Entry(name: 'Zoe', score: 24),
      const _Entry(name: 'Kai', score: 18),
      _Entry(name: playerName, score: playerScore, isMe: true),
    ]..sort((a, b) => b.score.compareTo(a.score));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final e = entries[index];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            decoration: BoxDecoration(
              color: e.isMe ? AppColors.secondary : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: e.isMe ? AppColors.primary : AppColors.boardBorder,
                width: e.isMe ? 1.5 : 1,
              ),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '#${index + 1}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      e.name.trim().isEmpty
                          ? '?'
                          : e.name.trim()[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                e.name,
                style: TextStyle(
                  fontWeight:
                      e.isMe ? FontWeight.w800 : FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              subtitle: e.isMe
                  ? const Text('You',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700))
                  : null,
              trailing: Text(
                '${e.score}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Entry {
  const _Entry({required this.name, required this.score, this.isMe = false});
  final String name;
  final int score;
  final bool isMe;
}
