import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'category_tab.dart';

class _StoreCategory {
  const _StoreCategory(this.name, this.icon, this.color);

  final String name;
  final IconData icon;
  final Color color;
}

class _StoreProduct {
  const _StoreProduct({
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.color,
  });

  final String name;
  final String category;
  final String price;
  final String image;
  final Color color;
}

class GuestStorefront extends StatefulWidget {
  const GuestStorefront({
    required this.onBackToGateway,
    required this.onRequireAccount,
    super.key,
  });

  final VoidCallback onBackToGateway;
  final ValueChanged<bool> onRequireAccount;

  @override
  State<GuestStorefront> createState() => _GuestStorefrontState();
}

class _GuestStorefrontState extends State<GuestStorefront> {
  static const _categories = <_StoreCategory>[
    _StoreCategory('Diapers', Icons.child_friendly_rounded, Color(0xFFE6DFFF)),
    _StoreCategory('Baby Food', Icons.restaurant_rounded, Color(0xFFFFE8D7)),
    _StoreCategory('Clothing', Icons.checkroom_rounded, Color(0xFFDDF2FF)),
    _StoreCategory('Toys', Icons.toys_rounded, Color(0xFFFFE2DC)),
    _StoreCategory('Bath', Icons.bathtub_outlined, Color(0xFFE4F3E7)),
  ];

  static const _products = <_StoreProduct>[
    _StoreProduct(
      name: 'Premium Soft Diapers',
      category: 'Diapers',
      price: '₦12,500',
      image: 'assets/images/onboarding_quality.jpg',
      color: Color(0xFFE7F1F8),
    ),
    _StoreProduct(
      name: 'Organic Baby Food',
      category: 'Baby Food',
      price: '₦3,800',
      image: 'assets/images/onboarding_need.jpg',
      color: Color(0xFFFFF0D9),
    ),
    _StoreProduct(
      name: 'Soft Cotton Onesie',
      category: 'Clothing',
      price: '₦9,200',
      image: 'assets/images/onboarding_confidence.jpg',
      color: Color(0xFFE9F3FB),
    ),
    _StoreProduct(
      name: 'Cuddly Teddy Toy',
      category: 'Toys',
      price: '₦6,500',
      image: 'assets/images/onboarding_need.jpg',
      color: Color(0xFFFFECE8),
    ),
    _StoreProduct(
      name: 'Gentle Baby Bottle',
      category: 'Feeding',
      price: 'NGN 4,200',
      image: 'assets/images/onboarding_quality.jpg',
      color: Color(0xFFEAF5FC),
    ),
    _StoreProduct(
      name: 'Baby Skin Care Set',
      category: 'Skincare',
      price: 'NGN 7,600',
      image: 'assets/images/onboarding_quality.jpg',
      color: Color(0xFFFFF0E5),
    ),
    _StoreProduct(
      name: 'Everyday Baby Accessories',
      category: 'Accessories',
      price: 'NGN 5,400',
      image: 'assets/images/onboarding_need.jpg',
      color: Color(0xFFF1EDFA),
    ),
    _StoreProduct(
      name: 'Comfy Travel Stroller',
      category: 'Strollers',
      price: 'NGN 48,000',
      image: 'assets/images/onboarding_confidence.jpg',
      color: Color(0xFFE7F4F4),
    ),
    _StoreProduct(
      name: 'Little One Essentials',
      category: 'Others',
      price: 'NGN 6,900',
      image: 'assets/images/onboarding_need.jpg',
      color: Color(0xFFFFEEF2),
    ),
    _StoreProduct(
      name: 'Gentle Bath Wash',
      category: 'Bath',
      price: 'NGN 5,100',
      image: 'assets/images/onboarding_quality.jpg',
      color: Color(0xFFE4F3E7),
    ),
  ];

  final _searchController = TextEditingController();
  String? _selectedCategory;
  int _selectedTab = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _requireAccount(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.lock_outline_rounded,
          color: Color(0xFF218CF2),
          size: 32,
        ),
        title: const Text('Join BabyShopHub'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$message Sign up or log in to continue.'),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onRequireAccount(true);
                },
                child: const Text('Sign Up'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onRequireAccount(false);
                },
                child: const Text('Login'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep browsing'),
            ),
          ],
        ),
      ),
    );
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = _selectedCategory == category ? null : category;
      _selectedTab = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final products = _products.where((product) {
      final matchesCategory =
          _selectedCategory == null || product.category == _selectedCategory;
      final matchesQuery =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFA),
      body: SafeArea(
        bottom: false,
        child: _selectedTab == 1
            ? CategoryTab(onCategorySelected: _selectCategory)
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 14, 0),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/brand_logo.png',
                            width: 31,
                            height: 31,
                            fit: BoxFit.contain,
                            semanticLabel: 'BabyShopHub logo',
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text.rich(
                              const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'BabyShop',
                                    style: TextStyle(color: Color(0xFF5683B3)),
                                  ),
                                  TextSpan(
                                    text: 'Hub',
                                    style: TextStyle(color: Color(0xFFE88791)),
                                  ),
                                ],
                              ),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Notifications',
                            onPressed: () => _requireAccount(
                              'Sign up to receive shopping updates.',
                            ),
                            icon: const Icon(Icons.notifications_none_rounded),
                          ),
                          IconButton(
                            tooltip: 'Back to welcome screen',
                            onPressed: widget.onBackToGateway,
                            icon: const Icon(Icons.logout_rounded, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 5, 14, 10),
                    sliver: SliverToBoxAdapter(
                      child: SizedBox(
                        height: 43,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search for products, brands...',
                            hintStyle: const TextStyle(fontSize: 12),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF0F3F8),
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 13),
                    sliver: SliverToBoxAdapter(
                      child: _PromotionBanner(
                        onPressed: () => _selectCategory('Baby Food'),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 1, 14, 5),
                    sliver: SliverToBoxAdapter(
                      child: SizedBox(
                        height: 75,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (final category in _categories)
                              _CategoryShortcut(
                                category: category,
                                selected: _selectedCategory == category.name,
                                onTap: () => _selectCategory(category.name),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 5, 12, 4),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Popular Products',
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() {
                              _selectedCategory = null;
                              _selectedTab = 1;
                            }),
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (products.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(28),
                        child: Center(child: Text('No products found.')),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
                      sliver: SliverGrid.builder(
                        itemCount: products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.91,
                            ),
                        itemBuilder: (context, index) => _ProductCard(
                          product: products[index],
                          onOpen: () => _requireAccount(
                            'Create an account to view product details.',
                          ),
                          onAdd: () => _requireAccount(
                            'Sign up to add products to your cart.',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        selectedItemColor: const Color(0xFFE88791),
        unselectedItemColor: const Color(0xFF777777),
        onTap: (index) {
          if (index == 2 || index == 3 || index == 4) {
            final message = switch (index) {
              2 => 'Sign up to use your cart.',
              3 => 'Sign up to view your orders.',
              _ => 'Sign up to manage your profile.',
            };
            _requireAccount(message);
            return;
          }
          setState(() => _selectedTab = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _PromotionBanner extends StatelessWidget {
  const _PromotionBanner({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(17),
      child: SizedBox(
        height: 116,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/baby_b.jpg', fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFB6C2).withValues(alpha: 0.98),
                    const Color(0xFFFFB6C2).withValues(alpha: 0.70),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.48, 1],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 9),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 142,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Happy Babies\nHappy Parents',
                        style: TextStyle(
                          color: Color(0xFFCB4663),
                          height: 1.05,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 27,
                        child: FilledButton(
                          onPressed: onPressed,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6F98),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 13),
                            textStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Shop Now'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryShortcut extends StatelessWidget {
  const _CategoryShortcut({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final _StoreCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 37,
              height: 37,
              decoration: BoxDecoration(
                color: category.color,
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(color: const Color(0xFF6CAFE3), width: 2)
                    : null,
              ),
              child: Icon(
                category.icon,
                size: 19,
                color: const Color(0xFF5683A9),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9, color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onOpen,
    required this.onAdd,
  });

  final _StoreProduct product;
  final VoidCallback onOpen;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFF1EAE6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                      child: ColoredBox(
                        color: product.color,
                        child: Image.asset(product.image, fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: InkWell(
                        onTap: onAdd,
                        customBorder: const CircleBorder(),
                        child: const CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.add_rounded,
                            color: Color(0xFF2F9BFF),
                            size: 19,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.price,
                      style: const TextStyle(
                        color: Color(0xFF25517D),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
