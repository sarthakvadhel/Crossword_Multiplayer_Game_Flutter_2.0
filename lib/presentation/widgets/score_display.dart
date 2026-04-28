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

class _ScorePill extends StatefulWidget {
  const _ScorePill({
    required this.label,
    required this.score,
    required this.highlight,
  });

  final String label;
  final int score;
  final bool highlight;

  @override
  State<_ScorePill> createState() => _ScorePillState();
}

class _ScorePillState extends State<_ScorePill> {
  late int _previousScore;

  @override
  void initState() {
    super.initState();
    _previousScore = widget.score;
  }

  @override
  void didUpdateWidget(covariant _ScorePill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _previousScore = oldWidget.score;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('pill-${widget.label}-${widget.score}'),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      tween: Tween<double>(begin: 1.08, end: 1),
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: widget.highlight ? Colors.white : AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.highlight ? AppColors.primary : Colors.white,
          ),
        ),
        child: Column(
          children: [
            Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(
                begin: _previousScore.toDouble(),
                end: widget.score.toDouble(),
              ),
              builder: (context, value, _) {
                return Text(
                  '${value.round()}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
