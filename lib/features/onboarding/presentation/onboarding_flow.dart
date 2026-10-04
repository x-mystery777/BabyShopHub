import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
