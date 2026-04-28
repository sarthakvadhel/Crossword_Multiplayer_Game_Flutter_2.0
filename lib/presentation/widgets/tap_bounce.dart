import 'package:flutter/material.dart';

class TapBounce extends StatefulWidget {
  const TapBounce({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.96,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  @override
  State<TapBounce> createState() => _TapBounceState();
}

class _TapBounceState extends State<TapBounce> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TweenAnimationBuilder<double>(
      tween: Tween<double>(end: _pressed ? widget.pressedScale : 1),
      duration: Duration(milliseconds: _pressed ? 90 : 260),
      curve: _pressed ? Curves.easeOut : Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );

    content = Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      behavior: HitTestBehavior.translucent,
      child: content,
    );

    if (widget.onTap != null) {
      content = GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.translucent,
        child: content,
      );
    }

    return content;
  }
}
