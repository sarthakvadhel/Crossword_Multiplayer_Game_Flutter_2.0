import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/tile_model.dart';
import '../../state/game_provider.dart';

class CrosswordBoard extends ConsumerWidget {
  const CrosswordBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final puzzle = gameState.puzzle;
    final board = gameState.board;
    final size = puzzle.gridSize;
    final hasHandSelection = gameState.selectedHandIndex != null;

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellSize = constraints.maxWidth / size;
          return Stack(
            children: [
              // Grid lines
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _GridPainter(size: size),
              ),
              // Cells
              ...board.map((tile) {
                final left = tile.col * cellSize;
                final top = tile.row * cellSize;
                final boardIndex = tile.row * size + tile.col;

                return Positioned(
                  left: left,
                  top: top,
                  width: cellSize,
                  height: cellSize,
                  child: _BoardCell(
                    tile: tile,
                    cellSize: cellSize,
                    isTarget: hasHandSelection &&
                        !tile.isBlocked &&
                        tile.letter == null,
                    onTap: () => ref
                        .read(gameProvider.notifier)
                        .tapBoardCell(boardIndex),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BoardCell extends StatelessWidget {
  const _BoardCell({
    required this.tile,
    required this.cellSize,
    required this.isTarget,
    required this.onTap,
  });

  final TileModel tile;
  final double cellSize;
  final bool isTarget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (tile.isBlocked) {
      return const SizedBox.expand();
    }

    Color bgColor;
    if (tile.isGiven && tile.letter != null) {
      // Pre-filled hint or correctly placed letter
      bgColor = AppColors.secondary;
    } else if (tile.letter != null) {
      bgColor = const Color(0xFFD4EDDA); // light green – player-filled
    } else if (isTarget) {
      bgColor = AppColors.accent.withOpacity(0.35);
    } else {
      bgColor = Colors.white;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: AppColors.boardBorder, width: 0.8),
        ),
        child: Stack(
          children: [
            // Clue number (top-left corner)
            if (tile.clueNumber != null)
              Positioned(
                top: 1,
                left: 2,
                child: Text(
                  '${tile.clueNumber}',
                  style: TextStyle(
                    fontSize: (cellSize * 0.22).clamp(8.0, 14.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    height: 1,
                  ),
                ),
              ),
            // Letter (centered)
            if (tile.letter != null)
              Center(
                child: Text(
                  tile.letter!,
                  style: TextStyle(
                    fontSize: (cellSize * 0.48).clamp(12.0, 28.0),
                    fontWeight: FontWeight.bold,
                    color: tile.isGiven
                        ? AppColors.primary
                        : AppColors.textDark,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  _GridPainter({required this.size});

  final int size;

  @override
  void paint(Canvas canvas, Size sizePx) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.boardBorder
      ..strokeWidth = 0.8;
    final cellSize = sizePx.width / size;
    for (var i = 0; i <= size; i++) {
      final offset = cellSize * i;
      canvas.drawLine(Offset(offset, 0), Offset(offset, sizePx.height), paint);
      canvas.drawLine(Offset(0, offset), Offset(sizePx.width, offset), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => old.size != size;
}
