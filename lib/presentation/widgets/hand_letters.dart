import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_provider.dart';
import 'letter_tile.dart';

class HandLetters extends ConsumerWidget {
  const HandLetters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final letters = gameState.playerHand;
    final selectedIdx = gameState.selectedHandIndex;
    final isPlayerTurn = gameState.isPlayerTurn;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: letters.asMap().entries.map((entry) {
          final i = entry.key;
          final letter = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: isPlayerTurn
                  ? () => ref.read(gameProvider.notifier).selectHandTile(i)
                  : null,
              child: LetterTile(
                letter: letter,
                highlighted: selectedIdx == i,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
