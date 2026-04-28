# Development Guidelines

## State Management Patterns

### Riverpod StateNotifier
All mutable state lives in `StateNotifierProvider`s in `lib/state/`.

```dart
final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier() : super(_buildInitialState(...));
  // mutate via: state = state.copyWith(...)
}
```

- Never mutate state fields directly; always use `state = state.copyWith(...)`
- Use `bool clear*` flags in `copyWith` to null out optional fields (e.g. `clearSelection: true`)
- Widgets consume state with `ConsumerWidget` / `ConsumerStatefulWidget` and `ref.watch(provider)`
- Side-effect calls use `ref.read(provider.notifier).method()`

### Immutable Models
All data models are immutable with `copyWith`:

```dart
class PlayerModel {
  final String id;
  final String name;
  final int score;
  const PlayerModel({required this.id, required this.name, ...});
  PlayerModel copyWith({String? id, String? name, int? score, ...}) => ...;
}
```

- Use `const` constructors wherever possible
- Enums for finite states: `GameMode`, `GamePhase`, `TurnOwner`

## Code Organization Conventions

### Layer Separation
- `game_engine/` — pure Dart logic, no Flutter imports, no state
- `core/services/` — async side effects (network, auth, storage); no UI
- `data/models/` — plain data classes; no business logic
- `presentation/` — UI only; reads providers, never holds business logic
- `state/` — bridges services + engine + UI via Riverpod notifiers

### File Naming
- `snake_case.dart` for all Dart files
- Screens: `*_screen.dart`, Widgets: `*_widget.dart` or descriptive name
- Providers: `*_provider.dart`, Services: `*_service.dart`, Models: `*_model.dart`

### Section Comments in Long Files
Use `// ─── Section Name ───...` dividers to group related methods:

```dart
// ─── Navigation / Mode Setup ─────────────────────────────────────────────
// ─── Multiplayer ──────────────────────────────────────────────────────────
// ─── In-Game Actions ──────────────────────────────────────────────────────
// ─── AI Logic ─────────────────────────────────────────────────────────────
// ─── Helpers ──────────────────────────────────────────────────────────────
```

## Dart / Flutter Patterns

### Async Error Handling
Fire-and-forget multiplayer sends use `.catchError((_) {})` to avoid unhandled exceptions:

```dart
_mp.send({'type': 'pass_turn'}).catchError((_) {});
```

For user-facing async operations, return `String?` as an error message (null = success):

```dart
Future<String?> hostRoom({...}) async {
  try { ... return null; }
  catch (e) { return 'Could not open room: $e'; }
}
```

### Stream Subscriptions
Store `StreamSubscription` references and cancel on cleanup:

```dart
StreamSubscription<Map<String, dynamic>>? _mpSub;
_mpSub = _mp.events.listen(_handleMpEvent);
// in dispose:
_mpSub?.cancel();
```

### Record / Destructuring (Dart 3)
Use Dart 3 records for multi-value returns:

```dart
(List<CrosswordWord>, List<String>, int) _checkCompletions(...) { ... }
final (newWords, completedWordIds, scoreGain) = _checkCompletions(...);
```

### Grid Cloning
Always clone the grid before mutation (immutability):

```dart
List<List<GridCell>> _cloneGrid(List<List<GridCell>> source) {
  return source.map((row) => List<GridCell>.from(row)).toList();
}
```

### AI Move Pattern
AI engine returns `null` to signal "pass"; callers handle null explicitly:

```dart
final move = await _ai.computeMove(state: state, thinkTime: ...);
if (move == null) { /* AI passes */ return; }
// apply move
```

### Timer for Delayed AI
Use `Timer` (not `Future.delayed`) for cancellable AI scheduling:

```dart
_aiTimer = Timer(Duration(milliseconds: 1200 + _random.nextInt(1000)), _performAiMove);
// cancel with: _aiTimer?.cancel();
```

## Networking (WebSocket Multiplayer)

- All messages are `Map<String, dynamic>` serialized as JSON
- Message type discriminated by `'type'` key (string)
- Event types: `peer_connected`, `join_request`, `game_start`, `place_letter`, `swap_turn`, `pass_turn`, `peer_disconnected`, `host_disconnected`
- Room code format: `"<ipv4>:<port>"` (e.g. `"192.168.1.5:4040"`)
- Host binds on port 4040 with fallback to OS-assigned port
- Only one guest per room (`room_full` event if second guest attempts)

## Platform Runner Conventions

### Android (Kotlin)
Minimal `MainActivity` — just extend `FlutterActivity`, no overrides unless platform channels are needed:

```kotlin
class MainActivity : FlutterActivity()
```

### Windows (C++)
- Singleton `WindowClassRegistrar` manages WNDCLASS registration/unregistration
- `Win32Window::WndProc` stores `this` pointer in `GWLP_USERDATA` for instance dispatch
- DPI scaling applied at window creation via `FlutterDesktopGetDpiForMonitor`
- Dark mode synced from Windows registry key `AppsUseLightTheme`

### Linux (C/GTK)
- GTK application declared with `G_DECLARE_FINAL_TYPE` macro
- Header guard pattern: `#ifndef FLUTTER_MY_APPLICATION_H_`

## UI Conventions

### Screen Transitions
`MainShell` uses `IndexedStack` + `AnimationController` for slide+fade transitions:

```dart
Opacity(
  opacity: t,
  child: Transform.translate(offset: Offset(slideX, 0), child: child),
)
```

- `_slideDirection` is `+1` (forward) or `-1` (back) based on index delta
- Duration: 260ms with `Curves.easeOutCubic`

### Navigation
- No named routes; navigation is index-based via `_animateToIndex(int)`
- Bottom nav has 3 tabs: Main (0), Multiplayer (1), Me (2)
- Game screen is index 2 internally but maps to bottom nav index 0

### Widget Composition
- Prefer small, focused widgets in `lib/presentation/widgets/`
- Animated wrappers (`AnimatedCardTap`, `TapBounce`, `AnimatedNewGameButton`) wrap content widgets
- Score and turn state displayed via dedicated `ScoreBar`/`ScoreDisplay`/`TurnIndicator` widgets

## Analysis & Linting
- `analysis_options.yaml` at project root includes `flutter_lints`
- Keep `flutter analyze` clean before committing
