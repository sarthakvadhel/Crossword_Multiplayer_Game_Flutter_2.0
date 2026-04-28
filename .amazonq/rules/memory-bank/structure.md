# Project Structure

## Directory Layout
```
lib/
├── main.dart                  # App entry point, ProviderScope, MainShell (bottom nav + screen transitions)
├── core/
│   ├── constants/
│   │   └── app_colors.dart    # Shared color constants
│   ├── services/
│   │   ├── auth_service.dart          # Google Sign-In wrapper
│   │   ├── multiplayer_service.dart   # WebSocket host/join over local Wi-Fi
│   │   ├── local_multiplayer_service.dart
│   │   ├── banner_service.dart
│   │   ├── sound_service.dart
│   │   └── storage_service.dart       # Hive/SharedPreferences persistence
│   └── theme/
│       └── app_theme.dart             # MaterialApp theme factory
├── data/
│   ├── models/
│   │   ├── game_state.dart    # Immutable GameState + enums (GameMode, GamePhase, TurnOwner)
│   │   ├── puzzle_model.dart  # CrosswordPuzzle, CrosswordWord, GridCell
│   │   ├── player_model.dart  # PlayerModel (id, name, score, stats)
│   │   ├── tile_model.dart    # TileModel (flat board representation)
│   │   ├── word_model.dart
│   │   └── game_state_model.dart
│   └── repositories/
│       ├── puzzle_repo.dart   # Puzzle data + grid builder
│       ├── ai_repo.dart
│       └── score_repo.dart
├── game_engine/
│   ├── ai_engine.dart         # AI move computation
│   ├── board_engine.dart      # Board logic helpers
│   ├── letter_generator.dart  # Hand replenishment
│   ├── move_validator.dart    # Move legality checks
│   ├── scoring_engine.dart    # Score calculation
│   └── turn_manager.dart      # Turn sequencing
├── presentation/
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── game_screen.dart
│   │   ├── multiplayer_lobby_screen.dart
│   │   ├── multiplayer_setup_sheet.dart
│   │   ├── profile_screen.dart
│   │   ├── leaderboard_screen.dart
│   │   ├── tournament_mode_screen.dart
│   │   ├── banner_overlay.dart
│   │   ├── hint_popup.dart
│   │   └── word_popup.dart
│   └── widgets/
│       ├── crossword_board.dart / crossword_board_widget.dart
│       ├── hand_letters.dart / hand_letters_widget.dart
│       ├── letter_tile.dart
│       ├── score_bar.dart / score_display.dart
│       ├── clues_panel.dart
│       ├── turn_indicator.dart
│       ├── swap_panel.dart
│       ├── animated_card_tap.dart
│       ├── animated_new_game_button.dart
│       ├── tap_bounce.dart
│       └── (lobby/multiplayer widgets)
└── state/
    ├── game_provider.dart     # GameNotifier (StateNotifier<GameState>) – central game logic
    ├── auth_provider.dart     # AuthNotifier (StateNotifier<GoogleSignInAccount?>)
    └── ai_provider.dart
```

## Architectural Pattern
**Feature-layered architecture** with Riverpod state management:

- `state/` — Riverpod `StateNotifierProvider`s own all mutable state
- `game_engine/` — Pure logic layer (no Flutter dependencies); called by `GameNotifier`
- `data/` — Immutable models + repository data sources
- `core/services/` — Side-effect services (network, auth, storage)
- `presentation/` — Stateless/ConsumerWidget UI; reads providers, dispatches notifier calls

## Key Relationships
- `MainShell` (ConsumerStatefulWidget) owns screen navigation via `IndexedStack` + `AnimationController`
- `GameNotifier` orchestrates: `PuzzleRepository` → `LetterGenerator` → `AiEngine` → `MultiplayerService`
- `MultiplayerService` exposes a broadcast `Stream<Map<String,dynamic>>` events; `GameNotifier` subscribes via `StreamSubscription`
- `GameState` is fully immutable with a `copyWith` pattern; nullable fields use `clear*` boolean flags in `copyWith`
