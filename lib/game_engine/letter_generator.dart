import 'dart:math';

class LetterGenerator {
  static const _vowels = ['A', 'E', 'I', 'O', 'U'];
  static const _consonants = [
    'B',
    'C',
    'D',
    'F',
    'G',
    'H',
    'J',
    'K',
    'L',
    'M',
    'N',
    'P',
    'R',
    'S',
    'T',
    'V',
    'W',
    'Y',
  ];

  final Random _random = Random();

  List<String> generateHand(int count) {
    return List.generate(count, (index) {
      final useVowel = _random.nextDouble() < 0.4;
      final pool = useVowel ? _vowels : _consonants;
      return pool[_random.nextInt(pool.length)];
    });
  }
}
