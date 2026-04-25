import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/tile_model.dart';

class CrosswordBoard extends StatefulWidget {
  const CrosswordBoard({
    super.key,
    required this.size,
    required this.tiles,
    required this.enabled,
    required this.onTileTap,
    this.isMultiplayer = false,
    this.isLocalTurn = true,
    this.hasOpponent = false,
  });

  final int size;
  final List<TileModel> tiles;
  final bool enabled;
  final ValueChanged<int> onTileTap;
  final bool isMultiplayer;
  final bool isLocalTurn;
  final bool hasOpponent;

  @override
  State<CrosswordBoard> createState() => _CrosswordBoardState();
}

class _CrosswordBoardState extends State<CrosswordBoard> {
  static const _shakeFrequency = 4.0;
  static const _shakeAmplitude = 6.0;

  late List<String?> _previousLetters;
  int? _activePlayerCellIndex;
  int? _opponentCursorIndex;
  int? _invalidShakeIndex;
  int _shakeEpoch = 0;
  int? _entryFlashIndex;
  int _entryFlashEpoch = 0;

  @override
  void initState() {
    super.initState();
    _previousLetters = widget.tiles.map((tile) => tile.letter).toList();
  }

  @override
  void didUpdateWidget(covariant CrosswordBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changedIndices = <int>[];
    final previous = _previousLetters;
    for (var index = 0; index < widget.tiles.length; index++) {
      final before = index < previous.length ? previous[index] : null;
      final after = widget.tiles[index].letter;
      if (before != after && after != null) {
        changedIndices.add(index);
      }
    }
    if (changedIndices.isNotEmpty) {
      final latestIndex = changedIndices.last;
      final turnTransitionedToLocal = !oldWidget.isLocalTurn && widget.isLocalTurn;
      final opponentMoved = widget.isMultiplayer &&
          widget.hasOpponent &&
          turnTransitionedToLocal;
      setState(() {
        _entryFlashIndex = latestIndex;
        _entryFlashEpoch++;
        if (opponentMoved) {
          _opponentCursorIndex = latestIndex;
        } else {
          _activePlayerCellIndex = latestIndex;
        }
      });
    }
    _previousLetters = widget.tiles.map((tile) => tile.letter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.tiles.length,
         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.size,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final tile = widget.tiles[index];
          final canPlace = widget.enabled && tile.letter == null;
          final isActiveCell = _activePlayerCellIndex == index;
          final hasOpponentCursor = _opponentCursorIndex == index;
          final isNewEntry = _entryFlashIndex == index;
          final isShaking = _invalidShakeIndex == index;

          return GestureDetector(
            onTap: () {
              if (!widget.enabled) {
                return;
              }
              if (canPlace) {
                widget.onTileTap(index);
                return;
              }
              setState(() {
                _invalidShakeIndex = index;
                _shakeEpoch++;
              });
            },
            child: TweenAnimationBuilder<double>(
              key: ValueKey('tile-$index-$isShaking-$_shakeEpoch'),
              duration: const Duration(milliseconds: 320),
              tween: Tween<double>(begin: 0, end: isShaking ? 1 : 0),
              builder: (context, value, child) {
                final offset = isShaking
                    ? (value < 1
                        ? math.sin(value * math.pi * _shakeFrequency) *
                            _shakeAmplitude
                        : 0)
                    : 0.0;
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: child,
                );
              },
              child: TweenAnimationBuilder<double>(
                key: ValueKey('entry-$index-$isNewEntry-$_entryFlashEpoch'),
                duration: const Duration(milliseconds: 420),
                tween: Tween<double>(begin: 0, end: isNewEntry ? 1 : 0),
                builder: (context, flashValue, _) {
                  final baseColor = tile.letter != null
                      ? AppColors.secondary
                      : canPlace
                          ? AppColors.accent.withValues(alpha: 0.28)
                          : AppColors.boardTile;
                  final flashColor = Color.lerp(
                    AppColors.flashHighlight.withValues(alpha: 0.75),
                    baseColor,
                    flashValue,
                  );
                  final borderColor = isActiveCell
                      ? AppColors.primary
                      : hasOpponentCursor
                          ? AppColors.danger
                          : AppColors.boardBorder;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: flashColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: borderColor,
                        width: isActiveCell || hasOpponentCursor ? 2 : 1,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: tile.letter == null
                              ? Text(
                                  '${tile.row + 1},${tile.col + 1}',
                                  key: ValueKey('coord-$index'),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textMuted,
                                  ),
                                )
                              : Text(
                                  tile.letter!,
                                  key: ValueKey('letter-${tile.letter}-$index'),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                        ),
                        if (hasOpponentCursor)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: const Icon(
                              Icons.adjust_rounded,
                              size: 12,
                              color: AppColors.danger,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
