import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game_engine/ai_engine.dart';

final aiEngineProvider = Provider<AiEngine>((ref) {
  return AiEngine();
});
