import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/local_multiplayer_service.dart';
import '../../state/auth_provider.dart';
import '../../state/game_provider.dart';

final leaderboardProvider =
    FutureProvider.autoDispose.family<List<LeaderboardPlayer>, _LeaderboardRequest>(
  (ref, request) {
    final service = ref.read(gameProvider.notifier).multiplayerService;
    return service.fetchLeaderboard(
      currentPlayerId: request.currentPlayerId,
      currentPlayerName: request.currentPlayerName,
      currentPlayerScore: request.currentPlayerScore,
      currentPlayerAvatarUrl: request.currentPlayerAvatarUrl,
    );
  },
);

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPlayerId = ref.watch(gameProvider.select((s) => s.localPlayerId));
    final fallbackPlayerName = ref.watch(gameProvider.select((s) => s.player.name));
    final currentPlayerScore = ref.watch(gameProvider.select((s) => s.player.score));
    final authUser = ref.watch(authProvider);
    final request = _LeaderboardRequest(
      currentPlayerId: currentPlayerId,
      currentPlayerName: authUser?.displayName ?? fallbackPlayerName,
      currentPlayerScore: currentPlayerScore,
      currentPlayerAvatarUrl: authUser?.photoUrl,
    );
    final leaderboardAsync = ref.watch(leaderboardProvider(request));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: leaderboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          debugPrint('Leaderboard fetch failed: $error');
          debugPrint('$stackTrace');
          return _LeaderboardErrorState(
            onRetry: () => ref.invalidate(leaderboardProvider(request)),
          );
        },
        data: (players) {
          if (players.isEmpty) {
            return const _LeaderboardEmptyState();
          }
          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: players.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final player = players[index];
              final isCurrentUser = player.id == currentPlayerId;
              return RepaintBoundary(
                child: _LeaderboardTile(
                  rank: index + 1,
                  player: player,
                  isCurrentUser: isCurrentUser,
                ),
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
      decoration: BoxDecoration(
        color: isCurrentUser ? AppColors.secondary : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentUser ? AppColors.primary : AppColors.boardBorder,
          width: isCurrentUser ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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

class _LeaderboardRequest {
  const _LeaderboardRequest({
    required this.currentPlayerId,
    required this.currentPlayerName,
    required this.currentPlayerScore,
    this.currentPlayerAvatarUrl,
  });

  final String currentPlayerId;
  final String currentPlayerName;
  final int currentPlayerScore;
  final String? currentPlayerAvatarUrl;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _LeaderboardRequest &&
        currentPlayerId == other.currentPlayerId &&
        currentPlayerName == other.currentPlayerName &&
        currentPlayerScore == other.currentPlayerScore &&
        currentPlayerAvatarUrl == other.currentPlayerAvatarUrl;
  }

  @override
  int get hashCode => Object.hash(
        currentPlayerId,
        currentPlayerName,
        currentPlayerScore,
        currentPlayerAvatarUrl,
      );
}

class _LeaderboardErrorState extends StatelessWidget {
  const _LeaderboardErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.danger,
              size: 34,
            ),
            const SizedBox(height: 10),
            const Text(
              'Could not load leaderboard.',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardEmptyState extends StatelessWidget {
  const _LeaderboardEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.leaderboard_outlined,
              color: AppColors.textMuted,
              size: 34,
            ),
            SizedBox(height: 10),
            Text(
              'No leaderboard data available yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
