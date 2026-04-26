import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class TurnIndicator extends StatelessWidget {
  const TurnIndicator({
    super.key,
    required this.label,
    required this.active,
    this.emphasizeTurn = false,
  });

  final String label;
  final bool active;
  final bool emphasizeTurn;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: emphasizeTurn ? 1 : 0),
      builder: (context, glow, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.secondary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: emphasizeTurn
                  ? AppColors.flashHighlight.withValues(alpha: 0.85)
                  : Colors.transparent,
              width: emphasizeTurn ? 1.5 : 0,
            ),
            boxShadow: emphasizeTurn
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25 + glow * 0.2),
                      blurRadius: 8 + (glow * 6),
                      spreadRadius: glow * 1.2,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (emphasizeTurn) ...[
                _TurnPulseDot(progress: glow),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TurnPulseDot extends StatelessWidget {
  const _TurnPulseDot({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final scale = 0.9 + (progress * 0.2);
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.35),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
