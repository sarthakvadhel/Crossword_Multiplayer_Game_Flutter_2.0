import 'package:flutter/material.dart';

import 'letter_tile.dart';

class HandLetters extends StatelessWidget {
  const HandLetters({
    super.key,
    required this.letters,
    required this.selectedIndex,
    required this.enabled,
    required this.onTap,
  });

  final List<String> letters;
  final int? selectedIndex;
  final bool enabled;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        for (var index = 0; index < letters.length; index++)
          LetterTile(
            letter: letters[index],
            highlighted: selectedIndex == index,
            enabled: enabled,
            onTap: () => onTap(index),
          ),
      ],
    );
  }
}
