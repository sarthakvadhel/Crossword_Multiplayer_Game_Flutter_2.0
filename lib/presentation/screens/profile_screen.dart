import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../state/auth_provider.dart';
import '../../state/game_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String? _nameOverride;

  String _rankingFromScore(int score) {
    if (score >= 120) {
      return 'Diamond';
    }
    if (score >= 80) {
      return 'Platinum';
    }
    if (score >= 40) {
      return 'Gold';
    }
    if (score >= 10) {
      return 'Silver';
    }
    return 'Bronze';
  }

  Future<void> _editProfileName(String currentName) async {
    final controller = TextEditingController(text: currentName);
    final nextName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit profile'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (!mounted || nextName == null || nextName.isEmpty) {
      return;
    }
    setState(() => _nameOverride = nextName);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final gameState = ref.watch(gameProvider);
    final username = _nameOverride ?? user?.displayName ?? gameState.player.name;
    final wins = gameState.player.streak;
    final losses = gameState.opponent.streak;
    final matches = wins + losses;
    final ranking = _rankingFromScore(gameState.player.score);
    final winRate = matches == 0 ? 0 : ((wins / matches) * 100).round();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.secondary),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.secondary,
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? const Icon(Icons.person, size: 38, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(username, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? 'Local player',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _StatsCard(
            multiplayerScore: gameState.player.score,
            wins: wins,
            losses: losses,
            ranking: ranking,
            winRate: '$winRate%',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _editProfileName(username),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit profile'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: user == null
                      ? null
                      : () async {
                          await ref.read(authProvider.notifier).signOut();
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Logged out')),
                          );
                        },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (user == null)
            ElevatedButton(
              onPressed: () => ref.read(authProvider.notifier).signIn(),
              child: const Text('Sign in with Google'),
            ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.multiplayerScore,
    required this.wins,
    required this.losses,
    required this.ranking,
    required this.winRate,
  });

  final int multiplayerScore;
  final int wins;
  final int losses;
  final String ranking;
  final String winRate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Multiplayer stats',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _StatRow(title: 'Score', value: '$multiplayerScore'),
          _StatRow(title: 'Wins', value: '$wins'),
          _StatRow(title: 'Losses', value: '$losses'),
          _StatRow(title: 'Win rate', value: winRate),
          _StatRow(title: 'Ranking', value: ranking),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
