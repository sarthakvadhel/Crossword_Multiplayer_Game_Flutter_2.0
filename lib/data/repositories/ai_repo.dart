import 'dart:math';

class AiRepository {
  final Random _random = Random();

  int lettersToPlay() {
    final roll = _random.nextDouble();
    if (roll < 0.5) return 1;
    if (roll < 0.8) return 2;
    if (roll < 0.95) return 3;
    return 5;
  }
}
