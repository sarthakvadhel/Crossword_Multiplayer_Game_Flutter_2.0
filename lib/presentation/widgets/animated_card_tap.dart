import 'package:flutter/material.dart';

class AnimatedCardTap extends StatefulWidget {
  const AnimatedCardTap({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  @override
  State<AnimatedCardTap> createState() => _AnimatedCardTapState();
}

class _AnimatedCardTapState extends State<AnimatedCardTap> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.translucent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _pressed ? 0.18 : 0.08),
              blurRadius: _pressed ? 20 : 10,
              offset: Offset(0, _pressed ? 10 : 4),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
