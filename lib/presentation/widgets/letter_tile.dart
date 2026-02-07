import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class LetterTile extends StatelessWidget {
  const LetterTile({super.key, required this.letter, this.highlighted = false});

  final String letter;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: highlighted ? AppColors.secondary : AppColors.boardTile,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.boardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}
