import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../../core/widgets/cloud_painter.dart';

class GatewayScreen extends StatelessWidget {
  const GatewayScreen({
    required this.onBack,
    required this.onBrowseAsGuest,
    required this.onLogin,
    required this.onSignUp,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onBrowseAsGuest;
  final VoidCallback onLogin;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC6E7F4),
      body: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: CloudPainter())),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 650;
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 28,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            tooltip: 'Back to onboarding',
                            onPressed: onBack,
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Image.asset(
                              'assets/images/splash_illustration.png',
                              height: compact ? 190 : 230,
                              fit: BoxFit.contain,
                              semanticLabel: 'Baby bottle and teddy bear',
                            ),
                            const SizedBox(height: 4),
                            const BrandLogo(width: 210),
                            const SizedBox(height: 12),
                            const Text(
                              'Gentle essentials for little ones',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.ink,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Column(
                            children: [
                              _GatewayButton(
                                label: 'Browse As Guest',
                                icon: Icons.storefront_outlined,
                                onPressed: onBrowseAsGuest,
                                primary: true,
                              ),
                              const SizedBox(height: 12),
                              _GatewayButton(
                                label: 'Login',
                                icon: Icons.login_rounded,
                                onPressed: onLogin,
                              ),
                              const SizedBox(height: 12),
                              _GatewayButton(
                                label: 'Sign Up',
                                icon: Icons.person_add_alt_1_rounded,
                                onPressed: onSignUp,
                                pink: true,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Create an account anytime to save your favorites and shop.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GatewayButton extends StatelessWidget {
  const _GatewayButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
    this.pink = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool primary;
  final bool pink;

  @override
  Widget build(BuildContext context) {
    final color = pink ? const Color(0xFFFF7697) : const Color(0xFF218CF2);
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: primary || pink
          ? FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.78),
                foregroundColor: const Color(0xFF0751A5),
                side: const BorderSide(color: Color(0xFF91BADD)),
                shape: const StadiumBorder(),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }
}
