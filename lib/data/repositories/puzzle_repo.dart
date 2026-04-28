import '../models/puzzle_model.dart';

class PuzzleRepository {
  static final List<CrosswordPuzzle> _puzzles = [
    _buildPuzzle1(),
    _buildPuzzle2(),
    _buildPuzzle3(),
    _buildPuzzle4(),
    _buildPuzzle5(),
  ];

  List<CrosswordPuzzle> getAllPuzzles() => _puzzles;
  CrosswordPuzzle getPuzzle(int index) => _puzzles[index % _puzzles.length];
  CrosswordPuzzle getDailyPuzzle() => _puzzles[0];

  // ─── Puzzle 1: Wild Animals ───────────────────────────────────────────────
  static CrosswordPuzzle _buildPuzzle1() {
    return CrosswordPuzzle(
      id: 'puzzle_1',
      title: '🐾 Wild Animals',
      gridSize: 11,
      words: [
        CrosswordWord(id: '1A', clue: 'Largest land animal with a trunk',
            answer: 'ELEPHANT', startRow: 0, startCol: 0, isAcross: true, imageEmoji: '🐘'),
        CrosswordWord(id: '2A', clue: 'Tallest animal, long neck',
            answer: 'GIRAFFE', startRow: 2, startCol: 0, isAcross: true, imageEmoji: '🦒'),
        CrosswordWord(id: '3A', clue: 'Tuxedo bird that cannot fly',
            answer: 'PENGUIN', startRow: 4, startCol: 0, isAcross: true, imageEmoji: '🐧'),
        CrosswordWord(id: '4A', clue: 'Intelligent ocean mammal',
            answer: 'DOLPHIN', startRow: 6, startCol: 0, isAcross: true, imageEmoji: '🐬'),
        CrosswordWord(id: '5A', clue: 'Fastest land animal with spots',
            answer: 'CHEETAH', startRow: 8, startCol: 0, isAcross: true, imageEmoji: '🐆'),
        CrosswordWord(id: '6A', clue: 'Largest great ape',
            answer: 'GORILLA', startRow: 10, startCol: 0, isAcross: true, imageEmoji: '🦍'),
        CrosswordWord(id: '1D', clue: 'Oval shell laid by birds',
            answer: 'EGG', startRow: 0, startCol: 0, isAcross: false, imageEmoji: '🥚'),
        CrosswordWord(id: '2D', clue: 'Spotted big cat that climbs trees',
            answer: 'LEOPARD', startRow: 0, startCol: 2, isAcross: false, imageEmoji: '🐆'),
        CrosswordWord(id: '3D', clue: 'Large river animal, big mouth',
            answer: 'HIPPO', startRow: 0, startCol: 4, isAcross: false, imageEmoji: '🦛'),
        CrosswordWord(id: '4D', clue: 'Colorful bird that mimics speech',
            answer: 'PARROT', startRow: 2, startCol: 6, isAcross: false, imageEmoji: '🦜'),
        CrosswordWord(id: '5D', clue: 'Majestic bird of prey',
            answer: 'EAGLE', startRow: 4, startCol: 8, isAcross: false, imageEmoji: '🦅'),
        CrosswordWord(id: '6D', clue: 'King of the jungle with a mane',
            answer: 'LION', startRow: 6, startCol: 1, isAcross: false, imageEmoji: '🦁'),
      ],
    );
  }

  // ─── Puzzle 2: Food & Kitchen ─────────────────────────────────────────────
  static CrosswordPuzzle _buildPuzzle2() {
    return CrosswordPuzzle(
      id: 'puzzle_2',
      title: '🍕 Food & Kitchen',
      gridSize: 11,
      words: [
        CrosswordWord(id: '1A', clue: 'Red fruit, keeps doctor away',
            answer: 'APPLE', startRow: 0, startCol: 0, isAcross: true, imageEmoji: '🍎'),
        CrosswordWord(id: '2A', clue: 'Yellow curved tropical fruit',
            answer: 'BANANA', startRow: 2, startCol: 0, isAcross: true, imageEmoji: '🍌'),
        CrosswordWord(id: '3A', clue: 'Italian flatbread with toppings',
            answer: 'PIZZA', startRow: 4, startCol: 0, isAcross: true, imageEmoji: '🍕'),
        CrosswordWord(id: '4A', clue: 'Grilled meat between two buns',
            answer: 'BURGER', startRow: 6, startCol: 0, isAcross: true, imageEmoji: '🍔'),
        CrosswordWord(id: '5A', clue: 'Sweet frozen dessert on a cone',
            answer: 'ICECREAM', startRow: 8, startCol: 0, isAcross: true, imageEmoji: '🍦'),
        CrosswordWord(id: '6A', clue: 'Baked dough ring with a hole',
            answer: 'DONUT', startRow: 10, startCol: 0, isAcross: true, imageEmoji: '🍩'),
        CrosswordWord(id: '1D', clue: 'Juicy orange citrus fruit',
            answer: 'APRICOT', startRow: 0, startCol: 0, isAcross: false, imageEmoji: '🍊'),
        CrosswordWord(id: '2D', clue: 'Tropical fruit with spiky skin',
            answer: 'PINEAPPLE', startRow: 0, startCol: 2, isAcross: false, imageEmoji: '🍍'),
        CrosswordWord(id: '3D', clue: 'Long pasta in tomato sauce',
            answer: 'PASTA', startRow: 0, startCol: 4, isAcross: false, imageEmoji: '🍝'),
        CrosswordWord(id: '4D', clue: 'Baked bread loaf',
            answer: 'BREAD', startRow: 2, startCol: 6, isAcross: false, imageEmoji: '🍞'),
        CrosswordWord(id: '5D', clue: 'Fried potato strips',
            answer: 'CHIPS', startRow: 4, startCol: 8, isAcross: false, imageEmoji: '🍟'),
        CrosswordWord(id: '6D', clue: 'Layered sweet birthday treat',
            answer: 'CAKE', startRow: 6, startCol: 1, isAcross: false, imageEmoji: '🎂'),
      ],
    );
  }

  // ─── Puzzle 3: Space & Science ────────────────────────────────────────────
  static CrosswordPuzzle _buildPuzzle3() {
    return CrosswordPuzzle(
      id: 'puzzle_3',
      title: '🚀 Space & Science',
      gridSize: 11,
      words: [
        CrosswordWord(id: '1A', clue: 'Closest star, source of light',
            answer: 'SUN', startRow: 0, startCol: 0, isAcross: true, imageEmoji: '☀️'),
        CrosswordWord(id: '2A', clue: 'Earth\'s natural satellite',
            answer: 'MOON', startRow: 2, startCol: 0, isAcross: true, imageEmoji: '🌙'),
        CrosswordWord(id: '3A', clue: 'H2O, essential for all life',
            answer: 'WATER', startRow: 4, startCol: 0, isAcross: true, imageEmoji: '💧'),
        CrosswordWord(id: '4A', clue: 'Invisible force pulling objects down',
            answer: 'GRAVITY', startRow: 6, startCol: 0, isAcross: true, imageEmoji: '🌍'),
        CrosswordWord(id: '5A', clue: 'Smallest unit of a chemical element',
            answer: 'ATOM', startRow: 8, startCol: 0, isAcross: true, imageEmoji: '⚛️'),
        CrosswordWord(id: '6A', clue: 'Vehicle that travels to outer space',
            answer: 'ROCKET', startRow: 10, startCol: 0, isAcross: true, imageEmoji: '🚀'),
        CrosswordWord(id: '1D', clue: 'Vast dark expanse beyond Earth',
            answer: 'SPACE', startRow: 0, startCol: 0, isAcross: false, imageEmoji: '🌌'),
        CrosswordWord(id: '2D', clue: 'Gas plants produce via photosynthesis',
            answer: 'OXYGEN', startRow: 0, startCol: 2, isAcross: false, imageEmoji: '🌿'),
        CrosswordWord(id: '3D', clue: 'Negatively charged subatomic particle',
            answer: 'ELECTRON', startRow: 0, startCol: 4, isAcross: false, imageEmoji: '⚡'),
        CrosswordWord(id: '4D', clue: 'Instrument to see distant stars',
            answer: 'TELESCOPE', startRow: 0, startCol: 6, isAcross: false, imageEmoji: '🔭'),
        CrosswordWord(id: '5D', clue: 'Red planet fourth from the Sun',
            answer: 'MARS', startRow: 4, startCol: 8, isAcross: false, imageEmoji: '🔴'),
        CrosswordWord(id: '6D', clue: 'Bright streak of light in night sky',
            answer: 'COMET', startRow: 6, startCol: 1, isAcross: false, imageEmoji: '☄️'),
      ],
    );
  }

  // ─── Puzzle 4: Sports & Games ─────────────────────────────────────────────
  static CrosswordPuzzle _buildPuzzle4() {
    return CrosswordPuzzle(
      id: 'puzzle_4',
      title: '⚽ Sports & Games',
      gridSize: 11,
      words: [
        CrosswordWord(id: '1A', clue: 'Round ball kicked into a net',
            answer: 'SOCCER', startRow: 0, startCol: 0, isAcross: true, imageEmoji: '⚽'),
        CrosswordWord(id: '2A', clue: 'Sport played with a bat and ball',
            answer: 'CRICKET', startRow: 2, startCol: 0, isAcross: true, imageEmoji: '🏏'),
        CrosswordWord(id: '3A', clue: 'Swim race in a pool',
            answer: 'SWIMMING', startRow: 4, startCol: 0, isAcross: true, imageEmoji: '🏊'),
        CrosswordWord(id: '4A', clue: 'Run 26.2 miles in a race',
            answer: 'MARATHON', startRow: 6, startCol: 0, isAcross: true, imageEmoji: '🏃'),
        CrosswordWord(id: '5A', clue: 'Hit shuttlecock over a net',
            answer: 'BADMINTON', startRow: 8, startCol: 0, isAcross: true, imageEmoji: '🏸'),
        CrosswordWord(id: '6A', clue: 'Throw a ball through a hoop',
            answer: 'BASKET', startRow: 10, startCol: 0, isAcross: true, imageEmoji: '🏀'),
        CrosswordWord(id: '1D', clue: 'Glide on ice with blades',
            answer: 'SKATING', startRow: 0, startCol: 0, isAcross: false, imageEmoji: '⛸️'),
        CrosswordWord(id: '2D', clue: 'Hit a ball over a net with a racket',
            answer: 'CRICKET', startRow: 0, startCol: 2, isAcross: false, imageEmoji: '🎾'),
        CrosswordWord(id: '3D', clue: 'Ride waves on a board',
            answer: 'SURFING', startRow: 0, startCol: 4, isAcross: false, imageEmoji: '🏄'),
        CrosswordWord(id: '4D', clue: 'Jump over a bar on a pole',
            answer: 'VAULTING', startRow: 0, startCol: 6, isAcross: false, imageEmoji: '🏋️'),
        CrosswordWord(id: '5D', clue: 'Pedal a two-wheeled vehicle',
            answer: 'BIKING', startRow: 4, startCol: 8, isAcross: false, imageEmoji: '🚴'),
        CrosswordWord(id: '6D', clue: 'Punch opponent in a ring',
            answer: 'BOXING', startRow: 6, startCol: 1, isAcross: false, imageEmoji: '🥊'),
      ],
    );
  }

  // ─── Puzzle 5: Nature & Weather ───────────────────────────────────────────
  static CrosswordPuzzle _buildPuzzle5() {
    return CrosswordPuzzle(
      id: 'puzzle_5',
      title: '🌿 Nature & Weather',
      gridSize: 11,
      words: [
        CrosswordWord(id: '1A', clue: 'Water falling from clouds',
            answer: 'RAIN', startRow: 0, startCol: 0, isAcross: true, imageEmoji: '🌧️'),
        CrosswordWord(id: '2A', clue: 'White frozen flakes from sky',
            answer: 'SNOW', startRow: 2, startCol: 0, isAcross: true, imageEmoji: '❄️'),
        CrosswordWord(id: '3A', clue: 'Bright arc of colors after rain',
            answer: 'RAINBOW', startRow: 4, startCol: 0, isAcross: true, imageEmoji: '🌈'),
        CrosswordWord(id: '4A', clue: 'Violent spinning wind column',
            answer: 'TORNADO', startRow: 6, startCol: 0, isAcross: true, imageEmoji: '🌪️'),
        CrosswordWord(id: '5A', clue: 'Tall tree with green leaves',
            answer: 'FOREST', startRow: 8, startCol: 0, isAcross: true, imageEmoji: '🌲'),
        CrosswordWord(id: '6A', clue: 'Large body of salt water',
            answer: 'OCEAN', startRow: 10, startCol: 0, isAcross: true, imageEmoji: '🌊'),
        CrosswordWord(id: '1D', clue: 'Rocky peak high above sea level',
            answer: 'RIDGE', startRow: 0, startCol: 0, isAcross: false, imageEmoji: '⛰️'),
        CrosswordWord(id: '2D', clue: 'Bright light flash in a storm',
            answer: 'NOVA', startRow: 0, startCol: 2, isAcross: false, imageEmoji: '⚡'),
        CrosswordWord(id: '3D', clue: 'Colorful garden plant with petals',
            answer: 'ROSE', startRow: 0, startCol: 4, isAcross: false, imageEmoji: '🌹'),
        CrosswordWord(id: '4D', clue: 'Flowing water channel to the sea',
            answer: 'RIVER', startRow: 0, startCol: 6, isAcross: false, imageEmoji: '🏞️'),
        CrosswordWord(id: '5D', clue: 'Dry sandy landscape with dunes',
            answer: 'DESERT', startRow: 4, startCol: 8, isAcross: false, imageEmoji: '🏜️'),
        CrosswordWord(id: '6D', clue: 'Molten rock erupting from a mountain',
            answer: 'LAVA', startRow: 6, startCol: 1, isAcross: false, imageEmoji: '🌋'),
      ],
    );
  }

  /// Build a grid from a puzzle definition.
  /// - First cell of each word: emoji clipart + word number + clue label
  /// - All other cells: just the letter slot
  static List<List<GridCell>> buildGrid(CrosswordPuzzle puzzle) {
    final size = puzzle.gridSize;

    final grid = List.generate(
      size,
      (r) => List.generate(size, (c) => GridCell(row: r, col: c, isBlack: true)),
    );

    // Sort words to assign numbers by reading order (top-to-bottom, left-to-right)
    final sorted = [...puzzle.words]
      ..sort((a, b) {
        final rowCmp = a.startRow.compareTo(b.startRow);
        return rowCmp != 0 ? rowCmp : a.startCol.compareTo(b.startCol);
      });

    // Assign word numbers — cells at the same position share the same number
    final Map<String, int> wordNumbers = {};
    final Map<String, int> cellNumbers = {}; // "r,c" -> number
    int num = 1;
    for (final w in sorted) {
      final key = '${w.startRow},${w.startCol}';
      if (!cellNumbers.containsKey(key)) {
        cellNumbers[key] = num++;
      }
      wordNumbers[w.id] = cellNumbers[key]!;
    }

    for (final word in puzzle.words) {
      final positions = word.positions;
      for (int i = 0; i < word.answer.length; i++) {
        final (r, c) = positions[i];
        if (r >= size || c >= size) continue;

        final existing = grid[r][c];
        final wordIds = [...existing.wordIds, word.id];
        final isFirst = i == 0;

        // Emoji only on first cell; if two words share first cell, keep existing
        final emoji = isFirst
            ? (existing.imageEmoji ?? word.imageEmoji)
            : existing.imageEmoji;

        // Clue label only on first cell
        final clue = isFirst
            ? (existing.clueLabel ?? word.clue)
            : existing.clueLabel;

        // Word number on first cell
        final wordNum = isFirst ? wordNumbers[word.id] : existing.wordNumber;

        // Correct letter: intersections keep the already-assigned letter
        final correctLetter = existing.correctLetter ?? word.answer[i];

        grid[r][c] = GridCell(
          row: r,
          col: c,
          isBlack: false,
          correctLetter: correctLetter,
          wordIds: wordIds,
          imageEmoji: emoji,
          clueLabel: clue,
          wordNumber: wordNum,
        );
      }
    }

    return grid;
  }
}
