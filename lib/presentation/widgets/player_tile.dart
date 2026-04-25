import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class PlayerTile extends StatelessWidget {
  const PlayerTile({
    super.key,
    required this.name,
    required this.isReady,
    this.isLocal = false,
  });

  final String name;
  final bool isReady;
  final bool isLocal;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            foregroundColor: AppColors.primary,
            child: Text(initial),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isLocal ? '$name (You)' : name,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isReady
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              isReady ? 'Ready' : 'Waiting',
              style: TextStyle(
                color: isReady ? const Color(0xFF166534) : const Color(0xFF9A3412),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
