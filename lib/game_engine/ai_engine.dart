import 'dart:async';

import '../data/repositories/ai_repo.dart';

class AiEngine {
  final AiRepository repository;

  AiEngine(this.repository);

  Future<int> performTurn() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return repository.lettersToPlay();
  }
}
