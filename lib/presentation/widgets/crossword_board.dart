import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/tile_model.dart';

class CrosswordBoard extends StatelessWidget {
  const CrosswordBoard({
    super.key,
    required this.size,
    required this.tiles,
    required this.enabled,
    required this.onTileTap,
  });

  final int size;
  final List<TileModel> tiles;
  final bool enabled;
  final ValueChanged<int> onTileTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tiles.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: size,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final tile = tiles[index];
          final canPlace = enabled && tile.letter == null;

          return GestureDetector(
            onTap: canPlace ? () => onTileTap(index) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: tile.letter != null
                    ? AppColors.secondary
                    : canPlace
                        ? AppColors.accent.withValues(alpha: 0.28)
                        : AppColors.boardTile,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.boardBorder),
              ),
              alignment: Alignment.center,
              child: tile.letter == null
                  ? Text(
                      '${tile.row + 1},${tile.col + 1}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    )
                  : Text(
                      tile.letter!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
