import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class LobbyHeader extends StatelessWidget {
  const LobbyHeader({
    super.key,
    required this.statusText,
    this.roomId,
  });

  final String statusText;
  final String? roomId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wifi_tethering_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Multiplayer Lobby',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            statusText,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            roomId == null ? 'Room ID: Not created yet' : 'Room ID: $roomId',
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
