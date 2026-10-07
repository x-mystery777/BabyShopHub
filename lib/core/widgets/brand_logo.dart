import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({required this.width, super.key});

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
