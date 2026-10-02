import 'package:flutter_test/flutter_test.dart';

import 'package:babyshophub/main.dart';

void main() {
  testWidgets('BabyShopHub starts with its animated logo intro', (tester) async {
    await tester.pumpWidget(const BabyShopHubApp());

    expect(find.byType(StartupSequence), findsOneWidget);
    expect(find.byType(LogoIntroPage), findsOneWidget);
  });
}
