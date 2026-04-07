import '../models/puzzle_model.dart';
import '../models/word_model.dart';

/// Puzzle 1 – "Everyday Words"
///
/// Grid layout (9×9, 0-indexed).  ■ = black square.
///
///      0  1  2  3  4  5  6  7  8
///   0: ■  ■  ■  ■  ■  ■  ■  ■  ■
///   1: ■  ■  ■  ■  ■  ■  ■  ■  ■
///   2: ■  W  O  R  D  ■  ■  ■  ■   ← 1-ACROSS: WORD
///   3: ■  ■  W  A  R  ■  ■  ■  ■   ← 2-ACROSS: WAR  / OWL 1-DOWN col 2
///   4: ■  P  L  A  Y  ■  ■  ■  ■   ← 3-ACROSS: PLAY / DRY 2-DOWN col 4
///   5: ■  ■  ■  ■  ■  ■  ■  ■  ■
///   6: ■  ■  ■  ■  ■  ■  ■  ■  ■
///   7: ■  ■  ■  ■  ■  ■  ■  ■  ■
///   8: ■  ■  ■  ■  ■  ■  ■  ■  ■
///
/// Intersection check:
///   OWL  (col 2): O(2,2) = WORD[1] ✓  W(3,2) = WAR[0] ✓  L(4,2) = PLAY[1] ✓
///   DRY  (col 4): D(2,4) = WORD[3] ✓  R(3,4) = WAR[2] ✓  Y(4,4) = PLAY[3] ✓
const puzzle1 = PuzzleModel(
  id: 'puzzle_1',
  title: 'Puzzle 1',
  gridSize: 9,
  words: [
    // ── ACROSS ──────────────────────────────────────────────────────────────
    WordModel(
      id: 1,
      clue: '1-Across: Unit of language (4)',
      answer: 'WORD',
      startRow: 2,
      startCol: 1,
      direction: WordDirection.across,
    ),
    WordModel(
      id: 2,
      clue: '2-Across: Armed conflict (3)',
      answer: 'WAR',
      startRow: 3,
      startCol: 2,
      direction: WordDirection.across,
    ),
    WordModel(
      id: 3,
      clue: '3-Across: Have fun (4)',
      answer: 'PLAY',
      startRow: 4,
      startCol: 1,
      direction: WordDirection.across,
    ),
    // ── DOWN ────────────────────────────────────────────────────────────────
    WordModel(
      id: 4,
      clue: '1-Down: Nocturnal bird (3)',
      answer: 'OWL',
      startRow: 2,
      startCol: 2,
      direction: WordDirection.down,
    ),
    WordModel(
      id: 5,
      clue: '2-Down: Not wet (3)',
      answer: 'DRY',
      startRow: 2,
      startCol: 4,
      direction: WordDirection.down,
    ),
  ],
);
