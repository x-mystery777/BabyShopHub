import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:babyshophub/main.dart';
import 'package:babyshophub/models/models.dart';
import 'package:babyshophub/screens/cart_screens.dart';
import 'package:babyshophub/screens/home_screen.dart';

void main() {
  testWidgets('BabyShopHub starts with its animated logo intro', (tester) async {
    await tester.pumpWidget(const BabyShopHubApp());

    expect(find.byType(StartupSequence), findsOneWidget);
    expect(find.byType(LogoIntroPage), findsOneWidget);
  });

  testWidgets('Order confirmation renders its artwork, summary and actions',
      (tester) async {
    const order = OrderModel(
      id: 42,
      status: 'CONFIRMED',
      paymentStatus: 'PAID',
      shippingAddress: '12 Baby Lane, Lagos',
      total: 25500,
      createdAt: null,
      items: [],
    );

    await tester.pumpWidget(const MaterialApp(
      home: OrderSuccessScreen(order: order),
    ));

    // The parcel/check illustration must be present (not the old plain icon).
    expect(find.byType(OrderSuccessArtwork), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);

    // Copy and the two actions still render, unchanged.
    expect(find.text('Order Placed!'), findsOneWidget);
    expect(find.text('Your order has been successfully placed.'), findsOneWidget);
    expect(find.text('View Order Details'), findsOneWidget);
    expect(find.text('Continue Shopping'), findsOneWidget);
    expect(find.text('Estimated Delivery'), findsOneWidget);
  });

  testWidgets('Home header shows the brand logo and the promo banner uses '
      'the baby_b image', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: HomeScreen()),
    ));
    // The screen loads its data before the header/banner appear, so let the
    // pending futures settle before asserting.
    await tester.pumpAndSettle();

    // Header: logo mark sits beside the "BabyShopHub" wordmark.
    expect(find.bySemanticsLabel('BabyShopHub logo'), findsOneWidget);
    expect(find.text('Happy Babies\nHappy Parents'), findsOneWidget);

    // Banner: the baby_b.jpg asset is the artwork behind the promo copy.
    final images = tester
        .widgetList<Image>(find.byType(Image))
        .where((i) => i.image is AssetImage)
        .map((i) => (i.image as AssetImage).assetName)
        .toList();
    expect(images, contains('assets/images/baby_b.jpg'));
  });
}
