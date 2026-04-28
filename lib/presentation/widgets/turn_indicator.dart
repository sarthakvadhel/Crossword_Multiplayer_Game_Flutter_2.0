import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class TurnIndicator extends StatelessWidget {
  const TurnIndicator({
    super.key,
    required this.label,
    required this.active,
    this.emphasizeTurn = false,
  });

  final String label;
  final bool active;
  final bool emphasizeTurn;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.secondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: emphasizeTurn
              ? AppColors.flashHighlight.withValues(alpha: 0.85)
              : Colors.transparent,
          width: emphasizeTurn ? 1.5 : 0,
        ),
        boxShadow: emphasizeTurn
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  spreadRadius: 1.2,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (emphasizeTurn) ...[
            _TurnPulseDot(animate: emphasizeTurn),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TurnPulseDot extends StatefulWidget {
  const _TurnPulseDot({required this.animate});

  final bool animate;

  @override
  State<_TurnPulseDot> createState() => _TurnPulseDotState();
}

class _TurnPulseDotState extends State<_TurnPulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _TurnPulseDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate == oldWidget.animate) {
      return;
    }
    if (widget.animate) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final scale = 0.9 + (t * 0.2);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.35 + (t * 0.15)),
                  blurRadius: 4 + (t * 2),
                  spreadRadius: 1 + (t * 0.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
