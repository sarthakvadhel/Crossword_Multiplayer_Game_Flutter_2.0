import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/local_multiplayer_service.dart';
import '../../state/auth_provider.dart';
import '../../state/game_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final authUser = ref.watch(authProvider);
    final currentPlayerId = gameState.localPlayerId;
    final currentPlayerName = authUser?.displayName ?? gameState.player.name;
    final currentPlayerAvatarUrl = authUser?.photoUrl;
    final currentPlayerScore = gameState.player.score;
    final service = ref.read(gameProvider.notifier).multiplayerService;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: FutureBuilder<List<LeaderboardPlayer>>(
        future: service.fetchLeaderboard(
          currentPlayerId: currentPlayerId,
          currentPlayerName: currentPlayerName,
          currentPlayerScore: currentPlayerScore,
          currentPlayerAvatarUrl: currentPlayerAvatarUrl,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final players = snapshot.data ?? const <LeaderboardPlayer>[];
          if (players.isEmpty) {
            return const Center(
              child: Text(
                'No leaderboard data available.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            );
          }
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              final isCurrentUser = player.id == currentPlayerId;
              return _LeaderboardTile(
                rank: index + 1,
                player: player,
                isCurrentUser: isCurrentUser,
              );
            },
          );
        },
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({
    required this.rank,
    required this.player,
    required this.isCurrentUser,
  });

  final int rank;
  final LeaderboardPlayer player;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppColors.secondary : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentUser ? AppColors.primary : AppColors.boardBorder,
          width: isCurrentUser ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        leading: SizedBox(
          width: 60,
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child: Text(
                  '#$rank',
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
                backgroundImage: player.avatarUrl != null
                    ? NetworkImage(player.avatarUrl!)
                    : null,
                child: player.avatarUrl == null
                    ? Text(
                        player.name.trim().isEmpty
                            ? '?'
                            : player.name.trim()[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
        title: Text(
          player.name,
          style: TextStyle(
            fontWeight: isCurrentUser ? FontWeight.w800 : FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        subtitle: isCurrentUser
            ? const Text(
                'You',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              )
            : null,
        trailing: Text(
          '${player.score}',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
