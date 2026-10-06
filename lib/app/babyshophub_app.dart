import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/cloud_painter.dart';
import '../features/auth/presentation/shopper_account_flow.dart';
import '../features/gateway/presentation/gateway_screen.dart';
import '../features/onboarding/presentation/onboarding_flow.dart';
import '../features/splash/presentation/splash_widgets.dart';
import '../features/store/presentation/guest_storefront.dart';

class BabyShopHubApp extends StatelessWidget {
  const BabyShopHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BabyShopHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.sky,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.pink),
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
  bool _showShopperAccount = false;
  bool _showGuestStore = false;
  bool _openRegistration = false;
  bool _returnToGuest = false;
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
      if (_showGuestStore) {
        return GuestStorefront(
          key: const ValueKey('guest-storefront'),
          onBackToGateway: () => setState(() => _showGuestStore = false),
          onRequireAccount: (registration) =>
              _openAccountFlow(registration: registration),
        );
      }
      if (_showShopperAccount) {
        return ShopperAccountFlow(
          key: const ValueKey('shopper-account-access'),
          initiallyShowRegistration: _openRegistration,
          onBackToOnboarding: () => setState(() {
            _showShopperAccount = false;
            _showGuestStore = _returnToGuest;
            _openRegistration = false;
            _returnToGuest = false;
          }),
        );
      }
      if (_page == _durations.length) {
        return OnboardingFlow(
          key: const ValueKey('onboarding'),
          onComplete: () => setState(() => _page++),
        );
      }
      return GatewayScreen(
        key: const ValueKey('gateway'),
        onBack: () => setState(() => _page = _durations.length),
        onBrowseAsGuest: () => setState(() => _showGuestStore = true),
        onLogin: () => _openAccountFlow(registration: false),
        onSignUp: () => _openAccountFlow(registration: true),
      );
    }

    return switch (_page) {
      0 => const LogoIntroPage(key: ValueKey('logo')),
      1 => const LoadingPage(
        key: ValueKey('loading-dots'),
        indicator: SplashDotOrbit(),
      ),
      2 => const LoadingPage(
        key: ValueKey('loading-ring'),
        indicator: SplashTwoToneRing(),
      ),
      _ => const SizedBox.shrink(),
    };
  }

  void _openAccountFlow({required bool registration}) {
    setState(() {
      _returnToGuest = _showGuestStore;
      _showGuestStore = false;
      _showShopperAccount = true;
      _openRegistration = registration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.sky,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: _page >= _durations.length
                  ? const ColoredBox(color: Colors.white)
                  : const CustomPaint(painter: CloudPainter()),
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
