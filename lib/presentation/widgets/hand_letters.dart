import 'package:flutter/material.dart';

import 'letter_tile.dart';

class HandLetters extends StatelessWidget {
  const HandLetters({super.key, required this.letters});

  final List<String> letters;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: letters
          .map((letter) => LetterTile(letter: letter))
          .toList(),
    );
  }
}
