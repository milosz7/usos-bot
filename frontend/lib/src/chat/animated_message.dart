import 'package:flutter/material.dart';

class TypingAnimation extends StatefulWidget {
  const TypingAnimation({super.key});

  @override
  _TypingAnimationState createState() => _TypingAnimationState();
}

class _TypingAnimationState extends State<TypingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dot1Animation;
  late Animation<double> _dot2Animation;
  late Animation<double> _dot3Animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _dot1Animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -7.0), weight: 32),
      TweenSequenceItem(tween: Tween(begin: -7.0, end: 0.0), weight: 68),
    ]).animate(
        CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6)));

    _dot2Animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -7.0), weight: 32),
      TweenSequenceItem(tween: Tween(begin: -7.0, end: 0.0), weight: 68),
    ]).animate(CurvedAnimation(
        parent: _controller, curve: const Interval(0.16, 0.76)));

    _dot3Animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -7.0), weight: 32),
      TweenSequenceItem(tween: Tween(begin: -7.0, end: 0.0), weight: 68),
    ]).animate(CurvedAnimation(
        parent: _controller, curve: const Interval(0.32, 0.92)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 32,
        width: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedDot(animation: _dot1Animation),
            const SizedBox(width: 4),
            AnimatedDot(animation: _dot2Animation),
            const SizedBox(width: 4),
            AnimatedDot(animation: _dot3Animation),
          ],
        ));
  }
}

class AnimatedDot extends StatelessWidget {
  final Animation<double> animation;

  const AnimatedDot({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, animation.value),
          child: child,
        );
      },
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: Colors.grey[500],
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
