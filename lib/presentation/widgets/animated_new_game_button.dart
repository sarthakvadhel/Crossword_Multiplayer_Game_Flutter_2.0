import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'tap_bounce.dart';

class AnimatedNewGameButton extends StatelessWidget {
  const AnimatedNewGameButton({
    super.key,
    required this.onPressed,
    this.puzzleNumber = 1,
  });

  final VoidCallback onPressed;
  final int puzzleNumber;

  @override
  Widget build(BuildContext context) {
    return TapBounce(
      onTap: onPressed,
      pressedScale: 0.97,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'New Game',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Puzzle $puzzleNumber',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFB3D9FF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
