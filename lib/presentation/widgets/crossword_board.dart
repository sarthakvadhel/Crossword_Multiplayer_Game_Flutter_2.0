import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class CrosswordBoard extends StatelessWidget {
  const CrosswordBoard({super.key, required this.size});

  final int size;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _BoardPainter(size: size),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  _BoardPainter({required this.size});

  final int size;

  @override
  void paint(Canvas canvas, Size sizePx) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.boardBorder
      ..strokeWidth = 1.2;
    final tileSize = sizePx.width / size;
    for (var i = 0; i <= size; i++) {
      final offset = tileSize * i;
      canvas.drawLine(Offset(offset, 0), Offset(offset, sizePx.height), paint);
      canvas.drawLine(Offset(0, offset), Offset(sizePx.width, offset), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
