import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _sky = Color(0xFFC6E7F4);
const _ink = Color(0xFF594F4B);
const _pink = Color(0xFFF5A6AE);
const _blue = Color(0xFF9ABDE4);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: _sky,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const BabyShopHubApp());
}

class BabyShopHubApp extends StatelessWidget {
  const BabyShopHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BabyShopHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _sky,
        colorScheme: ColorScheme.fromSeed(seedColor: _pink),
      ),
      home: const StartupSequence(),
    );
  }
}

/// Plays the three splash stages, then transitions into onboarding.
class StartupSequence extends StatefulWidget {
  const StartupSequence({super.key});

  @override
  State<StartupSequence> createState() => _StartupSequenceState();
}

class _StartupSequenceState extends State<StartupSequence> {
  static const _durations = <Duration>[
    Duration(milliseconds: 1250),
    Duration(milliseconds: 1750),
    Duration(milliseconds: 1500),
  ];

  int _page = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scheduleNextPage();
  }

  void _scheduleNextPage() {
    if (_page >= _durations.length) return;
    _timer = Timer(_durations[_page], () {
      if (!mounted) return;
      setState(() => _page++);
      _scheduleNextPage();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _pageForIndex() {
    if (_page >= _durations.length) {
      return OnboardingFlow(
        key: const ValueKey('onboarding'),
        onComplete: _finishOnboarding,
      );
    }

    return switch (_page) {
      0 => const LogoIntroPage(key: ValueKey('logo')),
      1 => const LoadingPage(
        key: ValueKey('loading-dots'),
        indicator: _DotOrbit(),
      ),
      2 => const LoadingPage(
        key: ValueKey('loading-ring'),
        indicator: _TwoToneRing(),
      ),
      _ => const SizedBox.shrink(),
    };
  }

  void _finishOnboarding() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You're all set to explore BabyShopHub.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: _sky,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: _page >= _durations.length
                  ? const ColoredBox(color: Colors.white)
                  : const CustomPaint(painter: _CloudPainter()),
            ),
            SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 520),
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.985, end: 1).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
                child: _pageForIndex(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogoIntroPage extends StatelessWidget {
  const LogoIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CenteredStartupPage(
      key: ValueKey('logo-content'),
      child: _BrandLogo(width: 238),
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
          const _BrandLogo(width: 194),
          const SizedBox(height: 18),
          indicator,
          const SizedBox(height: 12),
          const Text(
            'Loading...',
            style: TextStyle(
              color: _ink,
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

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/brand_logo.png',
          width: width * 0.72,
          fit: BoxFit.contain,
          semanticLabel: 'Baby-care logo mark',
        ),
        const SizedBox(height: 2),
        Text.rich(
          const TextSpan(
            children: [
              TextSpan(
                text: 'BabyShop',
                style: TextStyle(color: Color(0xFF7299C1)),
              ),
              TextSpan(
                text: 'Hub',
                style: TextStyle(color: Color(0xFFE88791)),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: width * 0.13,
            height: 1.05,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

class _DotOrbit extends StatefulWidget {
  const _DotOrbit();

  @override
  State<_DotOrbit> createState() => _DotOrbitState();
}

class _DotOrbitState extends State<_DotOrbit>
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
      _blue,
      Color(0xFFF7B1B3),
      _blue,
      Color(0xFFF4C5AA),
      _blue,
      Color(0xFFF7B1B3),
      _blue,
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

class _TwoToneRing extends StatefulWidget {
  const _TwoToneRing();

  @override
  State<_TwoToneRing> createState() => _TwoToneRingState();
}

class _TwoToneRingState extends State<_TwoToneRing>
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
      ..color = _blue
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

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({required this.onComplete, super.key});

  final VoidCallback onComplete;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  static const _slides = <_OnboardingSlideData>[
    _OnboardingSlideData(
      title: 'Everything Your\nBaby Needs',
      description:
          'From diapers to toys, find the best\nfor your little one, all in one place.',
      imagePath: 'assets/images/onboarding_need.jpg',
      imageDescription: 'Teddy bear and colorful baby toys',
    ),
    _OnboardingSlideData(
      title: 'Quality & Trusted\nProducts',
      description:
          'We bring you safe, high-quality\nand trusted products from\nreliable brands.',
      imagePath: 'assets/images/onboarding_quality.jpg',
      imageDescription: 'Baby bottle and organized baby products',
    ),
    _OnboardingSlideData(
      title: 'Shop with Confidence',
      description:
          'Secure payments, fast delivery\nand dedicated support for\nyou and your baby.',
      imagePath: 'assets/images/onboarding_confidence.jpg',
      imageDescription: 'Baby crib with a hanging mobile',
    ),
  ];

  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage == _slides.length - 1) {
      widget.onComplete();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: ColoredBox(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _slides.length,
                    onPageChanged: (page) =>
                        setState(() => _currentPage = page),
                    itemBuilder: (context, index) =>
                        _OnboardingSlide(data: _slides[index]),
                  ),
                ),
                _PageIndicator(
                  count: _slides.length,
                  selectedIndex: _currentPage,
                ),
                const SizedBox(height: 24),
                _OnboardingButton(
                  label: _currentPage == _slides.length - 1
                      ? 'Get Started'
                      : 'Next',
                  isLast: _currentPage == _slides.length - 1,
                  onPressed: _next,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlideData {
  const _OnboardingSlideData({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.imageDescription,
  });

  final String title;
  final String description;
  final String imagePath;
  final String imageDescription;
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.data});

  final _OnboardingSlideData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Center(child: _OnboardingArtwork(data: data)),
        ),
        Text(
          data.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF0751A5),
            fontSize: 23,
            height: 1.15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          data.description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF6383A8),
            fontSize: 14,
            height: 1.45,
            fontWeight: FontWeight.w400,
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}

class _OnboardingArtwork extends StatelessWidget {
  const _OnboardingArtwork({required this.data});

  final _OnboardingSlideData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math
            .min(constraints.maxWidth * 0.82, constraints.maxHeight * 0.78)
            .toDouble();
        return SizedBox.square(
          dimension: size,
          child: Image.asset(
            data.imagePath,
            fit: BoxFit.contain,
            semanticLabel: data.imageDescription,
          ),
        );
      },
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.selectedIndex});

  final int count;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < count; index++) ...[
          if (index > 0) const SizedBox(width: 7),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: index == selectedIndex ? 8 : 6,
            height: index == selectedIndex ? 8 : 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == selectedIndex
                  ? const Color(0xFF218CF2)
                  : const Color(0xFFD8E6F3),
            ),
          ),
        ],
      ],
    );
  }
}

class _OnboardingButton extends StatelessWidget {
  const _OnboardingButton({
    required this.label,
    required this.isLast,
    required this.onPressed,
  });

  final String label;
  final bool isLast;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = isLast
        ? const [Color(0xFFFF8DAA), Color(0xFFFF6D93)]
        : const [Color(0xFF39A5FF), Color(0xFF218CF2)];

    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  const _CloudPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _drawCloud(
      canvas,
      Rect.fromLTWH(-18, -38, 140, 128),
      const Color(0xFFFFF8EA),
    );
    _drawCloud(
      canvas,
      Rect.fromLTWH(-28, size.height - 96, 140, 116),
      const Color(0xFFFFF8EA),
    );
    _drawCloud(
      canvas,
      Rect.fromLTWH(size.width - 132, size.height - 112, 156, 132),
      const Color(0xFFFFE5E4),
      flipHorizontal: true,
    );
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) => false;
}

void _drawCloud(
  Canvas canvas,
  Rect bounds,
  Color color, {
  bool flipHorizontal = false,
}) {
  final width = bounds.width;
  final height = bounds.height;
  final base = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-width * 0.08, height * 0.43, width * 1.16, height * 0.7),
        Radius.circular(height * 0.28),
      ),
    );
  final puffs = <Rect>[
    Rect.fromLTWH(-width * 0.13, height * 0.28, width * 0.44, height * 0.62),
    Rect.fromLTWH(width * 0.08, height * 0.02, width * 0.55, height * 0.75),
    Rect.fromLTWH(width * 0.39, height * 0.14, width * 0.48, height * 0.67),
    Rect.fromLTWH(width * 0.67, height * 0.32, width * 0.43, height * 0.58),
  ];
  var cloud = base;
  for (final puff in puffs) {
    final oval = Path()..addOval(puff);
    cloud = Path.combine(PathOperation.union, cloud, oval);
  }

  canvas.save();
  canvas.translate(bounds.left + (flipHorizontal ? width : 0), bounds.top);
  canvas.scale(flipHorizontal ? -1 : 1, 1);
  canvas.drawPath(cloud, Paint()..color = color);
  canvas.restore();
}
