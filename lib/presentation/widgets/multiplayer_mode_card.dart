import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class MultiplayerModeCard extends StatelessWidget {
  const MultiplayerModeCard({
    super.key,
    required this.onlinePlayers,
    required this.onPlay,
  });

  final int onlinePlayers;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.dailyPuzzleGradientStart,
            AppColors.dailyPuzzleGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.groups_rounded,
                color: AppColors.accent,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'MULTIPLAYER',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFB3D9FF),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$onlinePlayers Online',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPlay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dailyPlayButton,
                  elevation: 4,
                  shadowColor: AppColors.dailyPlayButton.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Play Multiplayer',
                  textAlign: TextAlign.center,
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
      ),
    );
  }
}
