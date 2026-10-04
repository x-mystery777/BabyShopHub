import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/babyshophub_app.dart';
import 'core/theme/app_colors.dart';

export 'app/babyshophub_app.dart' show BabyShopHubApp, StartupSequence;
export 'features/splash/presentation/splash_widgets.dart' show LogoIntroPage;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.sky,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const BabyShopHubApp());
}
