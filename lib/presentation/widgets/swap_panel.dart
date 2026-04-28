import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class SwapPanel extends StatelessWidget {
  const SwapPanel({super.key, required this.onSwap});

  final Future<void> Function()? onSwap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(
            Icons.swap_horiz_rounded,
            color: onSwap == null ? AppColors.textMuted : AppColors.primary,
          ),
          onPressed: onSwap,
        ),
        const Text('Swap'),
      ],
    );
  }
}
