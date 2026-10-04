import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/brand_logo.dart';

class LogoIntroPage extends StatelessWidget {
  const LogoIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CenteredStartupPage(
      key: ValueKey('logo-content'),
      child: BrandLogo(width: 238),
    );
  }
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({required this.indicator, super.key});

  final Widget indicator;

  @override
  Widget build(BuildContext context) {
    return _CenteredStartupPage(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BrandLogo(width: 194),
          const SizedBox(height: 18),
          indicator,
          const SizedBox(height: 12),
          const Text(
            'Loading...',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenteredStartupPage extends StatelessWidget {
  const _CenteredStartupPage({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: child,
        ),
      ),
    );
  }
}

class SplashDotOrbit extends StatefulWidget {
  const SplashDotOrbit();

  @override
  State<SplashDotOrbit> createState() => SplashDotOrbitState();
}

class SplashDotOrbitState extends State<SplashDotOrbit>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const colors = <Color>[
      AppColors.blue,
      Color(0xFFF7B1B3),
      AppColors.blue,
      Color(0xFFF4C5AA),
      AppColors.blue,
      Color(0xFFF7B1B3),
      AppColors.blue,
      Color(0xFFF4C5AA),
    ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * math.pi * 2,
          child: child,
        );
      },
      child: SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (var i = 0; i < colors.length; i++)
              Transform.translate(
                offset: Offset(
                  math.cos(i * math.pi / 4) * 19,
                  math.sin(i * math.pi / 4) * 19,
                ),
                child: Container(
                  width: i.isEven ? 7 : 6,
                  height: i.isEven ? 7 : 6,
                  decoration: BoxDecoration(
                    color: colors[i],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SplashTwoToneRing extends StatefulWidget {
  const SplashTwoToneRing();

  @override
  State<SplashTwoToneRing> createState() => SplashTwoToneRingState();
}

class SplashTwoToneRingState extends State<SplashTwoToneRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.rotate(
        angle: _controller.value * math.pi * 2,
        child: child,
      ),
      child: const SizedBox(
        width: 42,
        height: 42,
        child: CustomPaint(painter: _RingPainter()),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final blue = Paint()
      ..color = AppColors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final pink = Paint()
      ..color = const Color(0xFFF6A9AE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect.deflate(3), -math.pi / 2, math.pi * 8 / 9, false, blue);
    canvas.drawArc(rect.deflate(3), math.pi / 2, math.pi * 8 / 9, false, pink);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => false;
}
