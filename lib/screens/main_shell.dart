import 'package:flutter/material.dart';

import '../state/session.dart';
import 'cart_screens.dart';
import 'catalog_screens.dart';
import 'home_screen.dart';
import 'orders_screens.dart';
import 'profile_screens.dart';

/// Bottom-navigation shell shown after login.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  /// Any screen can switch tab with MainShell.goTo(context, 3).
  static final ValueNotifier<int> tab = ValueNotifier(0);

  static void goTo(BuildContext context, int index) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    tab.value = index;
  }

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    MainShell.tab.value = 0;
    CartStore.instance.refresh();
  }

  Widget _page(int i) => switch (i) {
        0 => const HomeScreen(),
        1 => const CategoriesScreen(),
        2 => const CartScreen(),
        3 => const OrdersScreen(),
        _ => const ProfileScreen(),
      };

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: MainShell.tab,
      builder: (context, index, _) => Scaffold(
        body: SafeArea(child: KeyedSubtree(key: ValueKey(index), child: _page(index))),
        bottomNavigationBar: ListenableBuilder(
          listenable: CartStore.instance,
          builder: (context, _) {
            final count = CartStore.instance.count;
            return NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => MainShell.tab.value = i,
              destinations: [
                const NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home'),
                const NavigationDestination(
                    icon: Icon(Icons.grid_view_outlined),
                    selectedIcon: Icon(Icons.grid_view),
                    label: 'Categories'),
                NavigationDestination(
                    icon: Badge(
                        isLabelVisible: count > 0,
                        label: Text('$count'),
                        child: const Icon(Icons.shopping_cart_outlined)),
                    selectedIcon: Badge(
                        isLabelVisible: count > 0,
                        label: Text('$count'),
                        child: const Icon(Icons.shopping_cart)),
                    label: 'Cart'),
                const NavigationDestination(
                    icon: Icon(Icons.receipt_long_outlined),
                    selectedIcon: Icon(Icons.receipt_long),
                    label: 'Orders'),
                const NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Profile'),
              ],
            );
          },
        ),
      ),
    );
  }
}