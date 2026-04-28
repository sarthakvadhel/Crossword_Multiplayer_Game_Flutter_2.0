import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/puzzle_model.dart';

class CluesPanel extends StatelessWidget {
  final List<CrosswordWord> words;
  final String? highlightedWordId;
  final void Function(String wordId) onWordTap;

  const CluesPanel({
    super.key,
    required this.words,
    required this.highlightedWordId,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    final acrossWords = words.where((w) => w.isAcross).toList();
    final downWords = words.where((w) => !w.isAcross).toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'ACROSS'),
              Tab(text: 'DOWN'),
            ],
          ),
          SizedBox(
            height: 140,
            child: TabBarView(
              children: [
                _WordList(words: acrossWords, highlightedId: highlightedWordId, onTap: onWordTap),
                _WordList(words: downWords, highlightedId: highlightedWordId, onTap: onWordTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WordList extends StatelessWidget {
  final List<CrosswordWord> words;
  final String? highlightedId;
  final void Function(String) onTap;

  const _WordList({required this.words, required this.highlightedId, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: words.length,
      itemBuilder: (ctx, i) {
        final w = words[i];
        final isSelected = highlightedId == w.id;
        return GestureDetector(
          onTap: () => onTap(w.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: w.isCompleted
                  ? AppColors.successLight
                  : isSelected
                      ? AppColors.primary.withOpacity(0.08)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected ? Border.all(color: AppColors.primary.withOpacity(0.3)) : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: w.isCompleted
                        ? AppColors.success
                        : isSelected
                            ? AppColors.primary
                            : AppColors.boardBorder,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    w.id,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: (w.isCompleted || isSelected) ? Colors.white : AppColors.textMid,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    w.clue,
                    style: TextStyle(
                      fontSize: 13,
                      color: w.isCompleted ? AppColors.success : AppColors.textDark,
                      decoration: w.isCompleted ? TextDecoration.lineThrough : null,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (w.isCompleted)
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}