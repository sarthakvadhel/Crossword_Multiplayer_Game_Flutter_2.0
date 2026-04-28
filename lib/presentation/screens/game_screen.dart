import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/game_state.dart';
import '../../data/models/puzzle_model.dart';
import '../../state/game_provider.dart';
import '../widgets/crossword_board_widget.dart';
import '../widgets/hand_letters_widget.dart';
import '../widgets/score_bar.dart';

// ─── Game Screen ──────────────────────────────────────────────────────────────

class GameScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  const GameScreen({super.key, required this.onBack});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  int? _lastPlacedRow;
  int? _lastPlacedCol;
  bool _lastWasOpponent = false;

  // Key to access board state for wrong-cell animation
  final GlobalKey<CrosswordBoardWidgetState> _boardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);

    if (state.phase == GamePhase.finished) {
      return _FinishedOverlay(
        state: state,
        onPlayAgain: () => ref
            .read(gameProvider.notifier)
            .startSoloGame(playerName: state.localPlayer.name),
        onHome: widget.onBack,
      );
    }

    final isSolo = state.mode == GameMode.solo;
    final isAiThinking = !state.isLocalTurn && isSolo;
    final hasPending = state.hasPendingPlacements;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B4B),
      body: SafeArea(
        child: Column(children: [
          // ── Top bar ────────────────────────────────────────────────────
          _TopBar(state: state, isSolo: isSolo, onBack: widget.onBack),

          // ── Score bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
            child: ScoreBar(
              localPlayer: state.localPlayer,
              remotePlayer: state.remotePlayer,
              isLocalTurn: state.isLocalTurn,
              label: isSolo ? 'vs Computer' : 'vs ${state.remotePlayer.name}',
            ),
          ),

          // ── Status bar ─────────────────────────────────────────────────
          _StatusBar(state: state, isAiThinking: isAiThinking),

          // ── Board ──────────────────────────────────────────────────────
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: AspectRatio(
                aspectRatio: 1,
                child: CrosswordBoardWidget(
                  key: _boardKey,
                  grid: state.grid,
                  words: state.words,
                  highlightedWordId: state.highlightedWordId,
                  enabled: state.canAct && state.selectedHandIndex != null,
                  lastPlacedRow: _lastPlacedRow,
                  lastPlacedCol: _lastPlacedCol,
                  lastWasOpponent: _lastWasOpponent,
                  onCellTap: (row, col) {
                    setState(() {
                      _lastPlacedRow = row;
                      _lastPlacedCol = col;
                      _lastWasOpponent = false;
                    });
                    _handlePlace(row, col, null);
                  },
                  onCellDrop: (row, col, data) {
                    ref.read(gameProvider.notifier).selectHandLetter(data.handIndex);
                    setState(() {
                      _lastPlacedRow = row;
                      _lastPlacedCol = col;
                      _lastWasOpponent = false;
                    });
                    _handlePlace(row, col, data);
                  },
                ),
              ),
            ),
          ),

          // ── Clues panel — always visible ───────────────────────────────
          _CluesPanel(
            words: state.words,
            highlightedWordId: state.highlightedWordId,
            onWordTap: (id) => ref.read(gameProvider.notifier).highlightWord(id),
          ),

          // ── Hand letters ───────────────────────────────────────────────
          Container(
            color: const Color(0xFF0D1B4B),
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
            child: HandLettersWidget(
              letters: state.playerHand,
              selectedIndex: state.selectedHandIndex,
              enabled: state.canAct,
              onTap: (idx) =>
                  ref.read(gameProvider.notifier).selectHandLetter(idx),
              onSwap: (idx) =>
                  ref.read(gameProvider.notifier).swapLetter(idx),
            ),
          ),

          // ── Action bar ─────────────────────────────────────────────────
          _ActionBar(
            state: state,
            hasPending: hasPending,
            onCommit: () => ref.read(gameProvider.notifier).commitTurn(),
            onUndo: () => ref.read(gameProvider.notifier).undoLastPlacement(),
            onPass: () => ref.read(gameProvider.notifier).passTurn(),
          ),
        ]),
      ),
    );
  }

  void _handlePlace(int row, int col, LetterDragData? dragData) {
    ref.read(gameProvider.notifier).placeLetterAt(row, col);
    // Check if placement was wrong — trigger bounce-back shake animation
    final stateAfter = ref.read(gameProvider);
    if (row < stateAfter.grid.length && col < stateAfter.grid[row].length) {
      final cell = stateAfter.grid[row][col];
      if (cell.isPending &&
          cell.playerLetter != null &&
          cell.playerLetter != cell.correctLetter) {
        _boardKey.currentState?.triggerWrongCell(row, col);
      }
    }
  }
}

// ─── Clues Panel ─────────────────────────────────────────────────────────────

class _CluesPanel extends StatelessWidget {
  final List<CrosswordWord> words;
  final String? highlightedWordId;
  final void Function(String) onWordTap;

  const _CluesPanel({
    required this.words,
    required this.highlightedWordId,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    final across = words.where((w) => w.isAcross).toList();
    final down = words.where((w) => !w.isAcross).toList();

    return Container(
      height: 148,
      margin: const EdgeInsets.fromLTRB(10, 4, 10, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF162040),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(children: [
          // Tab bar
          const TabBar(
            labelColor: Color(0xFF82B1FF),
            unselectedLabelColor: Colors.white38,
            indicatorColor: Color(0xFF82B1FF),
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8),
            tabs: [Tab(text: 'ACROSS'), Tab(text: 'DOWN')],
          ),
          // Tab content
          Expanded(
            child: TabBarView(children: [
              _ClueList(words: across, highlightedId: highlightedWordId, onTap: onWordTap),
              _ClueList(words: down, highlightedId: highlightedWordId, onTap: onWordTap),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _ClueList extends StatelessWidget {
  final List<CrosswordWord> words;
  final String? highlightedId;
  final void Function(String) onTap;

  const _ClueList({required this.words, required this.highlightedId, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      scrollDirection: Axis.horizontal,
      itemCount: words.length,
      itemBuilder: (_, i) {
        final w = words[i];
        final isSelected = highlightedId == w.id;
        final isDone = w.isCompleted;
        return GestureDetector(
          onTap: () => onTap(w.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            constraints: const BoxConstraints(maxWidth: 160, minWidth: 80),
            decoration: BoxDecoration(
              color: isDone
                  ? const Color(0xFF1B5E20).withValues(alpha: 0.6)
                  : isSelected
                      ? const Color(0xFF1565C0).withValues(alpha: 0.7)
                      : Colors.white10,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDone
                    ? const Color(0xFF4CAF50)
                    : isSelected
                        ? const Color(0xFF82B1FF)
                        : Colors.white12,
                width: isSelected || isDone ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  // Emoji clipart thumbnail
                  if (w.imageEmoji != null) ...[
                    Text(w.imageEmoji!, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                  ],
                  // Word number badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: isDone
                          ? const Color(0xFF4CAF50)
                          : isSelected
                              ? const Color(0xFF82B1FF)
                              : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      w.id,
                      style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.white),
                    ),
                  ),
                  if (isDone) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF4CAF50), size: 12),
                  ],
                ]),
                const SizedBox(height: 3),
                Text(
                  w.clue,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDone ? Colors.white54 : Colors.white70,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                // Answer length dots
                Row(children: [
                  for (int j = 0; j < w.answer.length; j++)
                    Container(
                      width: 6, height: 6,
                      margin: const EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(
                        color: isDone
                            ? const Color(0xFF4CAF50)
                            : Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final GameState state;
  final bool isSolo;
  final VoidCallback onBack;

  const _TopBar({required this.state, required this.isSolo, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70, size: 20),
          onPressed: onBack,
        ),
        // Logo
        Image.asset('assets/images/logo.png', width: 30, height: 30),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(state.puzzle.title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
            Text(isSolo ? 'Solo vs Computer' : 'Multiplayer',
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ]),
        ),
        if (state.sessionCode != null)
          const Icon(Icons.wifi_rounded, color: Color(0xFF69F0AE), size: 18),
      ]),
    );
  }
}

// ─── Status Bar ───────────────────────────────────────────────────────────────

class _StatusBar extends StatelessWidget {
  final GameState state;
  final bool isAiThinking;

  const _StatusBar({required this.state, required this.isAiThinking});

  @override
  Widget build(BuildContext context) {
    final isWrong = state.statusMessage.contains('⚠️');
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 4, 10, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isWrong
            ? const Color(0xFFB71C1C).withValues(alpha: 0.85)
            : state.isLocalTurn
                ? const Color(0xFF1565C0).withValues(alpha: 0.85)
                : Colors.black38,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        if (isAiThinking) ...[
          const SizedBox(
            width: 12, height: 12,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(state.statusMessage,
              style: const TextStyle(
                  fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
        ),
        if (state.pendingPlacements.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
                color: const Color(0xFFFF9800),
                borderRadius: BorderRadius.circular(12)),
            child: Text('${state.pendingPlacements.length} placed',
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
      ]),
    );
  }
}

// ─── Action Bar ───────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  final GameState state;
  final bool hasPending;
  final VoidCallback onCommit, onUndo, onPass;

  const _ActionBar({
    required this.state,
    required this.hasPending,
    required this.onCommit,
    required this.onUndo,
    required this.onPass,
  });

  @override
  Widget build(BuildContext context) {
    final canAct = state.canAct;
    final wrong = state.wrongPlacementsThisTurn;

    return Container(
      color: const Color(0xFF0D1B4B),
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
      child: Row(children: [
        _Btn(
          icon: Icons.skip_next_rounded,
          label: 'Pass',
          bg: Colors.white12,
          fg: Colors.white54,
          enabled: canAct && !hasPending,
          onTap: onPass,
        ),
        const SizedBox(width: 6),
        _Btn(
          icon: Icons.undo_rounded,
          label: 'Undo',
          bg: hasPending
              ? const Color(0xFFFF9800).withValues(alpha: 0.18)
              : Colors.white10,
          fg: hasPending ? const Color(0xFFFF9800) : Colors.white30,
          enabled: canAct && hasPending,
          onTap: onUndo,
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: canAct && hasPending ? onCommit : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 48,
              decoration: BoxDecoration(
                gradient: canAct && hasPending
                    ? const LinearGradient(
                        colors: [Color(0xFF2E7D32), Color(0xFF43A047)])
                    : null,
                color: canAct && hasPending ? null : Colors.white10,
                borderRadius: BorderRadius.circular(12),
                boxShadow: canAct && hasPending
                    ? [
                        BoxShadow(
                            color: const Color(0xFF2E7D32).withValues(alpha: 0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 3))
                      ]
                    : null,
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.check_circle_rounded,
                    color: canAct && hasPending ? Colors.white : Colors.white30,
                    size: 20),
                const SizedBox(width: 6),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Commit Turn',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: canAct && hasPending
                                ? Colors.white
                                : Colors.white30)),
                    if (wrong > 0)
                      Text('$wrong wrong → -${wrong * 2} pts',
                          style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFFFFCC80),
                              fontWeight: FontWeight.w600)),
                  ],
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg, fg;
  final bool enabled;
  final VoidCallback onTap;

  const _Btn({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: fg, size: 18),
          Text(label,
              style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

// ─── Finished Overlay ─────────────────────────────────────────────────────────

class _FinishedOverlay extends StatelessWidget {
  final GameState state;
  final VoidCallback onPlayAgain, onHome;

  const _FinishedOverlay(
      {required this.state, required this.onPlayAgain, required this.onHome});

  @override
  Widget build(BuildContext context) {
    final localWon = state.localPlayer.score >= state.remotePlayer.score;
    final isTie = state.localPlayer.score == state.remotePlayer.score;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B4B), Color(0xFF1A237E)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(isTie ? '🤝' : localWon ? '🏆' : '🥈',
                  style: const TextStyle(fontSize: 80)),
              const SizedBox(height: 16),
              Text(
                isTie
                    ? "It's a Tie!"
                    : localWon
                        ? 'You Win!'
                        : '${state.remotePlayer.name} Wins!',
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(state.puzzle.title,
                  style: const TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 28),
              Row(children: [
                Expanded(
                    child: _ScoreCard(
                        player: state.localPlayer, isWinner: localWon && !isTie)),
                const SizedBox(width: 12),
                Expanded(
                    child: _ScoreCard(
                        player: state.remotePlayer, isWinner: !localWon && !isTie)),
              ]),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onPlayAgain,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Play Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onHome,
                icon: const Icon(Icons.home_rounded),
                label: const Text('Home'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white30),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final dynamic player;
  final bool isWinner;
  const _ScoreCard({required this.player, required this.isWinner});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWinner
            ? const Color(0xFFFFD600).withValues(alpha: 0.12)
            : Colors.white10,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isWinner ? const Color(0xFFFFD600) : Colors.white24,
            width: isWinner ? 2 : 1),
      ),
      child: Column(children: [
        Text(player.name,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text('${player.score}',
            style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFFD600))),
        Text('${player.wordsCompleted} words',
            style: const TextStyle(fontSize: 11, color: Colors.white54)),
        if (isWinner) const Text('🏆', style: TextStyle(fontSize: 22)),
      ]),
    );
  }
}
