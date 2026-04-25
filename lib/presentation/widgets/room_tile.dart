import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class RoomTile extends StatelessWidget {
  const RoomTile({
    super.key,
    required this.roomId,
    required this.isJoinable,
    required this.onJoin,
  });

  final String roomId;
  final bool isJoinable;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Row(
        children: [
          const Icon(Icons.meeting_room_rounded, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Room',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  roomId,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: isJoinable ? onJoin : null,
            child: const Text('Join Room'),
          ),
        ],
      ),
    );
  }
}
