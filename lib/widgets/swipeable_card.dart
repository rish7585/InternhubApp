import 'package:flutter/material.dart';
import 'dart:math' as math;

class SwipeableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;

  const SwipeableCard({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _rotationAnimation;
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(2.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    const swipeThreshold = 100.0;
    final dx = _dragOffset.dx;
    final dy = _dragOffset.dy;

    if (dx.abs() > swipeThreshold || dy.abs() > swipeThreshold) {
      if (dx.abs() > dy.abs()) {
        // Horizontal swipe
        if (dx > 0) {
          widget.onSwipeRight?.call();
        } else {
          widget.onSwipeLeft?.call();
        }
      } else {
        // Vertical swipe
        if (dy < 0) {
          widget.onSwipeUp?.call();
        } else {
          widget.onSwipeDown?.call();
        }
      }
      _animateOut();
    } else {
      _resetPosition();
    }
  }

  void _animateOut() {
    _controller.forward().then((_) {
      _resetPosition();
    });
  }

  void _resetPosition() {
    setState(() {
      _dragOffset = Offset.zero;
    });
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    final angle = _dragOffset.dx / 1000;
    final opacity = 1.0 - (_dragOffset.distance / 500).clamp(0.0, 1.0);

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..translate(_dragOffset.dx, _dragOffset.dy)
          ..rotateZ(angle),
        child: Opacity(
          opacity: opacity,
          child: widget.child,
        ),
      ),
    );
  }
}

