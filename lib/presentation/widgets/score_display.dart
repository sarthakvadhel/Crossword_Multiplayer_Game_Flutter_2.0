import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ScoreDisplay extends StatelessWidget {
  const ScoreDisplay({
    super.key,
    required this.playerName,
    required this.opponentName,
    required this.playerScore,
    required this.opponentScore,
  });

  final String playerName;
  final String opponentName;
  final int playerScore;
  final int opponentScore;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ScorePill(label: playerName, score: playerScore, highlight: true),
        const SizedBox(width: 12),
        Text('vs', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(width: 12),
        _ScorePill(label: opponentName, score: opponentScore, highlight: false),
      ],
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({
    required this.label,
    required this.score,
    required this.highlight,
  });

  final String label;
  final int score;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: highlight ? Colors.white : AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: highlight ? AppColors.primary : Colors.white),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '$score',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
