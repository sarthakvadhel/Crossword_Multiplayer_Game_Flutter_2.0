import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class TurnIndicator extends StatelessWidget {
  const TurnIndicator({super.key, required this.isPlayerTurn});

  final bool isPlayerTurn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isPlayerTurn ? AppColors.primary : AppColors.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPlayerTurn ? 'Your Turn' : 'Opponent Thinking',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
