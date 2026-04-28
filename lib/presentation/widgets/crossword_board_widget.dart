import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/puzzle_model.dart';

// ─── Drag Data ────────────────────────────────────────────────────────────────

class LetterDragData {
  final String letter;
  final int handIndex;
  const LetterDragData({required this.letter, required this.handIndex});
}

// ─── Board Widget ─────────────────────────────────────────────────────────────

class CrosswordBoardWidget extends StatefulWidget {
  final List<List<GridCell>> grid;
  final List<CrosswordWord> words;
  final String? highlightedWordId;
  final bool enabled;
  final int? lastPlacedRow;
  final int? lastPlacedCol;
  final bool lastWasOpponent;
  final void Function(int row, int col) onCellTap;
  final void Function(int row, int col, LetterDragData data)? onCellDrop;
  final void Function(String wordId, int points)? onWordCompleted;

  const CrosswordBoardWidget({
    super.key,
    required this.grid,
    required this.words,
    required this.highlightedWordId,
    required this.enabled,
    required this.onCellTap,
    this.onCellDrop,
    this.lastPlacedRow,
    this.lastPlacedCol,
    this.lastWasOpponent = false,
    this.onWordCompleted,
  });

  @override
  State<CrosswordBoardWidget> createState() => CrosswordBoardWidgetState();
}

class CrosswordBoardWidgetState extends State<CrosswordBoardWidget> {
  final List<_ScorePop> _pops = [];
  int _popKey = 0;

  // Wrong-letter cells currently animating bounce-back
  final Set<String> _wrongCells = {};

  @override
  void didUpdateWidget(covariant CrosswordBoardWidget old) {
    super.didUpdateWidget(old);
    for (final word in widget.words) {
      final wasCompleted =
          old.words.firstWhere((w) => w.id == word.id, orElse: () => word).isCompleted;
      if (!wasCompleted && word.isCompleted) {
        final size = widget.grid.length;
        final positions = word.positions;
        final mid = positions[positions.length ~/ 2];
        final (r, c) = mid;
        final k = _popKey++;
        setState(() {
          _pops.add(_ScorePop(
            key: k,
            label: '+${word.answer.length + 1}',
            fx: (c + 0.5) / size,
            fy: (r + 0.5) / size,
          ));
        });
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) setState(() => _pops.removeWhere((p) => p.key == k));
        });
      }
    }
  }

  void triggerWrongCell(int row, int col) {
    final key = '$row,$col';
    setState(() => _wrongCells.add(key));
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _wrongCells.remove(key));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.grid.isEmpty) return const SizedBox.shrink();
    final size = widget.grid.length;

    return LayoutBuilder(builder: (context, constraints) {
      final boardPx = constraints.maxWidth;
      final gap = 2.5;
      final cellPx = (boardPx - gap * (size + 1)) / size;

      return Stack(children: [
        // ── Board background ──────────────────────────────────────────────
        Container(
          width: boardPx,
          height: boardPx,
          decoration: BoxDecoration(
            color: const Color(0xFF1B2A4A),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(color: Color(0x55000000), blurRadius: 16, offset: Offset(0, 6)),
            ],
          ),
        ),

        // ── Cells ─────────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.all(gap),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(size, (row) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(size, (col) {
                  final cell = widget.grid[row][col];
                  final isHighlighted = _isCellHighlighted(cell);
                  final isLastPlaced =
                      widget.lastPlacedRow == row && widget.lastPlacedCol == col;
                  final isWrong = _wrongCells.contains('$row,$col');
                  final canDrop = widget.enabled &&
                      !cell.isBlack &&
                      cell.displayLetter == null &&
                      !cell.isPending;

                  return Padding(
                    padding: EdgeInsets.all(gap / 2),
                    child: SizedBox(
                      width: cellPx,
                      height: cellPx,
                      child: _BoardCell(
                        cell: cell,
                        isHighlighted: isHighlighted,
                        isLastPlaced: isLastPlaced,
                        isWrong: isWrong,
                        enabled: widget.enabled &&
                            !cell.isBlack &&
                            cell.displayLetter == null,
                        canDrop: canDrop,
                        cellPx: cellPx,
                        onTap: () => widget.onCellTap(row, col),
                        onDrop: widget.onCellDrop != null
                            ? (data) => widget.onCellDrop!(row, col, data)
                            : null,
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ),

        // ── Score pops ────────────────────────────────────────────────────
        for (final pop in _pops)
          _ScorePopWidget(
            key: ValueKey('pop-${pop.key}'),
            pop: pop,
            boardPx: boardPx,
          ),
      ]);
    });
  }

  bool _isCellHighlighted(GridCell cell) {
    if (widget.highlightedWordId == null) return false;
    return cell.wordIds.contains(widget.highlightedWordId);
  }
}

// ─── Board Cell ───────────────────────────────────────────────────────────────

class _BoardCell extends StatefulWidget {
  final GridCell cell;
  final bool isHighlighted;
  final bool isLastPlaced;
  final bool isWrong;
  final bool enabled;
  final bool canDrop;
  final double cellPx;
  final VoidCallback onTap;
  final void Function(LetterDragData)? onDrop;

  const _BoardCell({
    required this.cell,
    required this.isHighlighted,
    required this.isLastPlaced,
    required this.isWrong,
    required this.enabled,
    required this.canDrop,
    required this.cellPx,
    required this.onTap,
    this.onDrop,
  });

  @override
  State<_BoardCell> createState() => _BoardCellState();
}

class _BoardCellState extends State<_BoardCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;
  bool _isDragOver = false;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = Tween(begin: 0.0, end: 1.0).animate(_shakeCtrl);
  }

  @override
  void didUpdateWidget(covariant _BoardCell old) {
    super.didUpdateWidget(old);
    if (widget.isWrong && !old.isWrong) {
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cell = widget.cell;

    if (cell.isBlack) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1C35),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    // ── Colors ────────────────────────────────────────────────────────────
    Color bg;
    Color border;
    double bw = 1.5;

    if (widget.isWrong) {
      bg = const Color(0xFFFFCDD2);
      border = const Color(0xFFE53935);
      bw = 2.5;
    } else if (cell.isPending) {
      bg = const Color(0xFFFFF8E1);
      border = const Color(0xFFFFB300);
      bw = 2.5;
    } else if (cell.playerLetter != null) {
      bg = widget.isHighlighted ? const Color(0xFFB9F6CA) : const Color(0xFFE8F5E9);
      border = const Color(0xFF2E7D32);
      bw = 2;
    } else if (cell.opponentLetter != null) {
      bg = const Color(0xFFFFEBEE);
      border = const Color(0xFFC62828);
      bw = 2;
    } else if (_isDragOver) {
      bg = const Color(0xFFE3F2FD);
      border = const Color(0xFF1565C0);
      bw = 2.5;
    } else if (widget.isHighlighted) {
      bg = const Color(0xFFE8EAF6);
      border = const Color(0xFF3949AB);
      bw = 2;
    } else if (cell.imageEmoji != null) {
      bg = const Color(0xFFFFFDE7);
      border = const Color(0xFFFFCA28);
    } else {
      bg = const Color(0xFFF0F4FF);
      border = const Color(0xFFB0BEC5);
    }

    Widget cellWidget = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: border, width: bw),
        boxShadow: (widget.isLastPlaced || cell.isPending || _isDragOver)
            ? [BoxShadow(color: border.withValues(alpha: 0.45), blurRadius: 7, spreadRadius: 1)]
            : [const BoxShadow(color: Color(0x22000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: _CellContent(cell: cell, cellPx: widget.cellPx, enabled: widget.enabled),
    );

    // ── Shake animation for wrong letter ──────────────────────────────────
    cellWidget = AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, child) {
        final offset = _shakeAnim.value < 1.0
            ? math.sin(_shakeAnim.value * math.pi * 5) * 5.0
            : 0.0;
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: cellWidget,
    );

    // ── Drag target ───────────────────────────────────────────────────────
    if (widget.canDrop && widget.onDrop != null) {
      cellWidget = DragTarget<LetterDragData>(
        onWillAcceptWithDetails: (_) {
          setState(() => _isDragOver = true);
          return true;
        },
        onLeave: (_) => setState(() => _isDragOver = false),
        onAcceptWithDetails: (details) {
          setState(() => _isDragOver = false);
          widget.onDrop!(details.data);
          HapticFeedback.lightImpact();
        },
        builder: (_, __, ___) => GestureDetector(
          onTap: widget.enabled ? widget.onTap : null,
          child: cellWidget,
        ),
      );
    } else {
      cellWidget = GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: cellWidget,
      );
    }

    return cellWidget;
  }
}

// ─── Cell Content ─────────────────────────────────────────────────────────────

class _CellContent extends StatelessWidget {
  final GridCell cell;
  final double cellPx;
  final bool enabled;

  const _CellContent({required this.cell, required this.cellPx, required this.enabled});

  @override
  Widget build(BuildContext context) {
    // ── Placed letter ──────────────────────────────────────────────────────
    if (cell.displayLetter != null) {
      return Stack(children: [
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Text(
              cell.displayLetter!,
              key: ValueKey('L${cell.row}${cell.col}${cell.displayLetter}'),
              style: TextStyle(
                fontSize: cellPx * 0.52,
                fontWeight: FontWeight.w900,
                color: cell.isPending
                    ? const Color(0xFFE65100)
                    : cell.playerLetter != null
                        ? const Color(0xFF1B5E20)
                        : const Color(0xFFB71C1C),
              ),
            ),
          ),
        ),
        if (cell.wordNumber != null)
          Positioned(
            top: 1, left: 2,
            child: Text('${cell.wordNumber}',
                style: TextStyle(
                    fontSize: cellPx * 0.17,
                    fontWeight: FontWeight.w800,
                    color: Colors.black38)),
          ),
        if (cell.isPending)
          Positioned(
            top: 2, right: 2,
            child: Container(
              width: 5, height: 5,
              decoration: const BoxDecoration(
                  color: Color(0xFFFF9800), shape: BoxShape.circle),
            ),
          ),
      ]);
    }

    // ── Emoji clipart cell (first cell of word) ────────────────────────────
    if (cell.imageEmoji != null) {
      return Stack(children: [
        // Emoji — large, centered
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(bottom: cellPx * 0.28),
            child: Center(
              child: Text(cell.imageEmoji!,
                  style: TextStyle(fontSize: cellPx * 0.48)),
            ),
          ),
        ),
        // Clue label below emoji
        if (cell.clueLabel != null)
          Positioned(
            bottom: 2, left: 2, right: 2,
            child: Text(
              _shortClue(cell.clueLabel!),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: cellPx * 0.145,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A237E),
                height: 1.1,
              ),
            ),
          ),
        // Word number
        if (cell.wordNumber != null)
          Positioned(
            top: 1, left: 2,
            child: Text('${cell.wordNumber}',
                style: TextStyle(
                    fontSize: cellPx * 0.18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1A237E))),
          ),
        // Drop indicator dot
        if (enabled)
          Positioned(
            bottom: 2, right: 2,
            child: Container(
              width: 5, height: 5,
              decoration: const BoxDecoration(
                  color: Color(0xFF1565C0), shape: BoxShape.circle),
            ),
          ),
      ]);
    }

    // ── Empty playable cell ────────────────────────────────────────────────
    return Stack(children: [
      if (enabled)
        Center(
          child: Container(
            width: cellPx * 0.2,
            height: cellPx * 0.2,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
          ),
        ),
      if (cell.wordNumber != null)
        Positioned(
          top: 1, left: 2,
          child: Text('${cell.wordNumber}',
              style: TextStyle(
                  fontSize: cellPx * 0.18,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A237E))),
        ),
    ]);
  }

  String _shortClue(String clue) {
    final words = clue.split(' ');
    if (words.length <= 3) return clue;
    return '${words.take(3).join(' ')}…';
  }
}

// ─── Score Pop ────────────────────────────────────────────────────────────────

class _ScorePop {
  final int key;
  final String label;
  final double fx, fy;
  _ScorePop({required this.key, required this.label, required this.fx, required this.fy});
}

class _ScorePopWidget extends StatefulWidget {
  final _ScorePop pop;
  final double boardPx;
  const _ScorePopWidget({super.key, required this.pop, required this.boardPx});

  @override
  State<_ScorePopWidget> createState() => _ScorePopWidgetState();
}

class _ScorePopWidgetState extends State<_ScorePopWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity, _scale, _rise;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));
    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 12),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 33),
    ]).animate(_ctrl);
    _scale = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.2, end: 1.35)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 40),
    ]).animate(_ctrl);
    _rise = Tween(begin: 0.0, end: -64.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final x = widget.pop.fx * widget.boardPx;
    final y = widget.pop.fy * widget.boardPx;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Positioned(
        left: x - 44,
        top: y + _rise.value - 18,
        child: Opacity(
          opacity: _opacity.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: _scale.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFFFD600), Color(0xFFFF8F00)]),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFFFF8F00).withValues(alpha: 0.65),
                      blurRadius: 14,
                      spreadRadius: 2)
                ],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('⭐', style: TextStyle(fontSize: 17)),
                const SizedBox(width: 5),
                Text(widget.pop.label,
                    style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4E342E))),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
