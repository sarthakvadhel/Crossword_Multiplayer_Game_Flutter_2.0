import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class LetterTile extends StatelessWidget {
  const LetterTile({
    super.key,
    required this.letter,
    required this.highlighted,
    required this.enabled,
    required this.onTap,
  });

  final String letter;
  final bool highlighted;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: highlighted ? AppColors.primary : AppColors.boardTile,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: highlighted ? AppColors.primary : AppColors.boardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: enabled ? 0.08 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: highlighted ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
