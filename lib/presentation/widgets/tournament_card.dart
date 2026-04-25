import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class TournamentCard extends StatelessWidget {
  const TournamentCard({
    super.key,
    required this.timeRemaining,
    required this.score,
    required this.onPlay,
    this.buttonLabel = 'Play',
  });

  final String timeRemaining;
  final int score;
  final VoidCallback onPlay;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.tournamentGradientStart,
            AppColors.tournamentGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.tournamentGradientStart.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Stack(
          children: [
            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top spacing for timer badge
                const SizedBox(height: 12),
                // Trophy ranking
                _TrophyRanking(),
                const SizedBox(height: 16),
                // Label
                const Text(
                  'TOURNAMENT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFD9B3),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                // Score
                Text(
                  'Score: $score',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 20),
                // Play Button
                SizedBox(
                  height: 44,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onPlay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tournamentPlayButton,
                      elevation: 4,
                      shadowColor: AppColors.tournamentPlayButton.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      buttonLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Timer badge (top right)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B6F47),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.schedule,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeRemaining,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrophyRanking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Position 2 (left)
          Positioned(
            left: 0,
            bottom: 0,
            child: _RankingBadge(
              position: 2,
              size: 48,
              offset: 0,
            ),
          ),
          // Position 1 (center, larger)
          Positioned(
            child: _RankingBadge(
              position: 1,
              size: 56,
              offset: 0,
            ),
          ),
          // Position 3 (right)
          Positioned(
            right: 0,
            bottom: 0,
            child: _RankingBadge(
              position: 3,
              size: 48,
              offset: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingBadge extends StatelessWidget {
  const _RankingBadge({
    required this.position,
    required this.size,
    required this.offset,
  });

  final int position;
  final double size;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (position == 1)
          const Icon(
            Icons.star,
            color: Color(0xFFFFD700),
            size: 20,
          ),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEB3B),
            borderRadius: BorderRadius.circular(size / 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$position',
              style: TextStyle(
                fontSize: size > 50 ? 20 : 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
