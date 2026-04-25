import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/ai_repo.dart';
import '../game_engine/ai_engine.dart';

final aiEngineProvider = Provider<AiEngine>((ref) {
  return AiEngine(AiRepository());
});
