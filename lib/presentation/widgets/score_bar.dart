import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/player_model.dart';

class ScoreBar extends StatelessWidget {
  final PlayerModel localPlayer;
  final PlayerModel remotePlayer;
  final bool isLocalTurn;
  final String label; // "vs Computer" or "vs [name]"

  const ScoreBar({
    super.key,
    required this.localPlayer,
    required this.remotePlayer,
    required this.isLocalTurn,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.boardBorder),
      ),
      child: Row(
        children: [
          _PlayerScore(
            player: localPlayer,
            isActive: isLocalTurn,
            isLocal: true,
          ),
          Expanded(
            child: Column(
              children: [
                const Text('VS', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textMuted, fontSize: 12)),
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          _PlayerScore(
            player: remotePlayer,
            isActive: !isLocalTurn,
            isLocal: false,
          ),
        ],
      ),
    );
  }
}

class _PlayerScore extends StatelessWidget {
  final PlayerModel player;
  final bool isActive;
  final bool isLocal;

  const _PlayerScore({required this.player, required this.isActive, required this.isLocal});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        crossAxisAlignment: isLocal ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: isLocal ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              if (isActive && isLocal)
                Container(
                  width: 8, height: 8,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                ),
              Flexible(
                child: Text(
                  player.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isActive && !isLocal)
                Container(
                  width: 8, height: 8,
                  margin: const EdgeInsets.only(left: 6),
                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                ),
            ],
          ),
          const SizedBox(height: 2),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: player.score.toDouble()),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (ctx, val, _) => Text(
              val.round().toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: isActive ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ),
          Text(
            '${player.wordsCompleted} words',
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}