import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class SwapPanel extends StatelessWidget {
  const SwapPanel({super.key, required this.onSwap});

  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
          onPressed: onSwap,
        ),
        const Text('Swap'),
      ],
    );
  }
}
