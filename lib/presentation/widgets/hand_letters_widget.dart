import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'crossword_board_widget.dart';

class HandLettersWidget extends StatelessWidget {
  final List<String> letters;
  final int? selectedIndex;
  final bool enabled;
  final void Function(int) onTap;
  final void Function(int) onSwap;

  const HandLettersWidget({
    super.key,
    required this.letters,
    required this.selectedIndex,
    required this.enabled,
    required this.onTap,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Label row
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(children: [
            const Text(
              'YOUR LETTERS',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white54,
                  letterSpacing: 1.2),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'tap • drag to board • hold to swap',
                style: TextStyle(fontSize: 9, color: Colors.white38),
              ),
            ),
          ]),
        ),
        // Tiles row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < letters.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _DraggableLetterTile(
                  letter: letters[i],
                  index: i,
                  isSelected: selectedIndex == i,
                  isPlaced: letters[i] == '_',
                  enabled: enabled && letters[i] != '_',
                  onTap: () => onTap(i),
                  onSwap: () => onSwap(i),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _DraggableLetterTile extends StatelessWidget {
  final String letter;
  final int index;
  final bool isSelected;
  final bool isPlaced;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onSwap;

  const _DraggableLetterTile({
    required this.letter,
    required this.index,
    required this.isSelected,
    required this.isPlaced,
    required this.enabled,
    required this.onTap,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    final tile = _TileVisual(
      letter: letter,
      isSelected: isSelected,
      isPlaced: isPlaced,
      enabled: enabled,
    );

    if (!enabled || isPlaced) return tile;

    return Draggable<LetterDragData>(
      data: LetterDragData(letter: letter, handIndex: index),
      onDragStarted: () => HapticFeedback.selectionClick(),
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.25,
          child: _TileVisual(
            letter: letter,
            isSelected: true,
            isPlaced: false,
            enabled: true,
            isDragging: true,
          ),
        ),
      ),
      childWhenDragging: _TileVisual(
        letter: letter,
        isSelected: false,
        isPlaced: true, // ghost while dragging
        enabled: false,
      ),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onSwap,
        child: tile,
      ),
    );
  }
}

class _TileVisual extends StatelessWidget {
  final String letter;
  final bool isSelected;
  final bool isPlaced;
  final bool enabled;
  final bool isDragging;

  const _TileVisual({
    required this.letter,
    required this.isSelected,
    required this.isPlaced,
    required this.enabled,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg, borderColor;
    double bw;

    if (isPlaced) {
      bg = Colors.white10;
      borderColor = Colors.white12;
      bw = 1;
    } else if (isSelected || isDragging) {
      bg = const Color(0xFF1565C0);
      borderColor = const Color(0xFF42A5F5);
      bw = 2.5;
    } else {
      bg = const Color(0xFFF0F4FF);
      borderColor = const Color(0xFF90A4AE);
      bw = 1.5;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 42,
      height: 50,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: bw),
        boxShadow: isPlaced
            ? []
            : isSelected || isDragging
                ? [
                    BoxShadow(
                        color: const Color(0xFF1565C0).withValues(alpha: 0.55),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]
                : [
                    const BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 4,
                        offset: Offset(0, 3))
                  ],
      ),
      child: Center(
        child: isPlaced
            ? const Icon(Icons.check_rounded, color: Colors.white24, size: 18)
            : Text(
                letter,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isSelected || isDragging
                      ? Colors.white
                      : const Color(0xFF1A237E),
                ),
              ),
      ),
    );
  }
}
