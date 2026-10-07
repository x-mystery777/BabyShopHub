import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_colors.dart';
import '../core/format.dart';
import '../models/models.dart';
import '../services/shop_api.dart';
import '../state/session.dart';
import '../widgets/common.dart';
import 'main_shell.dart';
import 'profile_screens.dart';

/// Cart tab.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _store = CartStore.instance;

  @override
    void initState() {
    super.initState();
    // Wait until the first frame is drawn before refreshing the cart.
    WidgetsBinding.instance.addPostFrameCallback((_) => _store.refresh());
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (mounted) showMessage(context, e.toString(), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final cart = _store.cart;
        Widget body;
        if (_store.loading && cart.items.isEmpty) {
          body = const Center(
              child: CircularProgressIndicator(color: AppColors.blue));
        } else if (_store.error != null && cart.items.isEmpty) {
          body = ErrorView(_store.error!, onRetry: _store.refresh);
        } else if (cart.items.isEmpty) {
          body = const EmptyView('Your cart is empty.\nAdd something for your little one!',
              icon: Icons.shopping_cart_outlined);
        } else {
          body = RefreshIndicator(
            onRefresh: _store.refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              itemCount: cart.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _line(cart.items[i]),
            ),
          );
        }
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('My Cart',
                  style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
            ),
            Expanded(child: body),
            if (cart.items.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                decoration: const BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(color: Color(0x14000000), blurRadius: 10)
                ]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text('Total (${cart.count} items)',
                            style: const TextStyle(color: AppColors.slate)),
                        const Spacer(),
                        Text(naira(cart.total),
                            style: const TextStyle(
                                color: AppColors.navy,
                                fontSize: 18,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Proceed to Checkout',
                      pink: true,
                      onPressed: () => pushPage(context, const CheckoutScreen()),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _line(CartLine l) => SoftCard(
        child: Row(
          children: [
            const ProductImage(null, size: 64, iconSize: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(naira(l.subtotal),
                      style: const TextStyle(
                          color: AppColors.navy, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      QuantityStepper(
                        value: l.quantity,
                        onChanged: (v) =>
                            _run(() => _store.setQuantity(l.productId, v)),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Remove',
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.error),
                        onPressed: () => _run(() => _store.remove(l.productId)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

const paymentMethods = ['Card (Dummy)', 'Cash on Delivery', 'Pay with Wallet'];
const paymentPrefKey = 'preferred_payment';

/// Checkout: address, payment method, review, place order.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<Address> _addresses = [];
  int? _addressId;
  String _payment = paymentMethods.first;
  bool _loading = true;
  bool _placing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
    SharedPreferences.getInstance().then((p) {
      final saved = p.getString(paymentPrefKey);
      if (saved != null && paymentMethods.contains(saved) && mounted) {
        setState(() => _payment = saved);
      }
    });
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ShopApi.addresses();
      if (!mounted) return;
      setState(() {
        _addresses = list;
        final def = list.where((a) => a.isDefault);
        _addressId = def.isNotEmpty
            ? def.first.id
            : (list.isNotEmpty ? list.first.id : null);
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _addAddress() async {
    final saved = await pushPage<bool>(context, const AddressFormScreen());
    if (saved == true) _loadAddresses();
  }

  Future<void> _place() async {
    if (_addressId == null) {
      showMessage(context, 'Add a delivery address first.', error: true);
      return;
    }
    setState(() => _placing = true);
    try {
      final order = await ShopApi.checkout(_addressId!);
      await CartStore.instance.refresh();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(order: order)));
    } catch (e) {
      if (mounted) {
        setState(() => _placing = false);
        showMessage(context, e.toString(), error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartStore.instance.cart;
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.blue))
          : _error != null
              ? ErrorView(_error!, onRetry: _loadAddresses)
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        children: [
                          const _Steps(),
                          SectionTitle('Delivery Address',
                              action: 'Add New Address', onAction: _addAddress),
                          if (_addresses.isEmpty)
                            const SoftCard(
                                child: Text(
                                    'You have no saved address yet. Tap "Add New Address".',
                                    style: TextStyle(color: AppColors.slate)))
                          else
                            for (final a in _addresses)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: SoftCard(
                                  onTap: () => setState(() => _addressId = a.id),
                                  child: Row(
                                    children: [
                                      Icon(
                                          _addressId == a.id
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_off,
                                          color: AppColors.blue),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if ((a.label ?? '').isNotEmpty)
                                              Text(a.label!,
                                                  style: const TextStyle(
                                                      color: AppColors.navy,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                            Text(a.oneLine,
                                                style: const TextStyle(
                                                    color: AppColors.slate)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          const SectionTitle('Payment Method'),
                          for (final m in paymentMethods)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SoftCard(
                                onTap: () => setState(() => _payment = m),
                                child: Row(
                                  children: [
                                    Icon(
                                        _payment == m
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_off,
                                        color: AppColors.blue),
                                    const SizedBox(width: 10),
                                    Text(m,
                                        style: const TextStyle(
                                            color: AppColors.navy,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          const Text(
                              'Payment is simulated: no card details are collected.',
                              style: TextStyle(
                                  color: AppColors.hint, fontSize: 12)),
                          const SectionTitle('Order Summary'),
                          SoftCard(
                            child: Column(
                              children: [
                                for (final l in cart.items)
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Text('${l.quantity} × ${l.name}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    color: AppColors.ink))),
                                        Text(naira(l.subtotal),
                                            style: const TextStyle(
                                                color: AppColors.navy,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                const Divider(),
                                Row(
                                  children: [
                                    const Text('Total',
                                        style: TextStyle(
                                            color: AppColors.navy,
                                            fontWeight: FontWeight.w800)),
                                    const Spacer(),
                                    Text(naira(cart.total),
                                        style: const TextStyle(
                                            color: AppColors.navy,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                      color: Colors.white,
                      child: SafeArea(
                        top: false,
                        child: PrimaryButton(
                            label: 'Place Order',
                            loading: _placing,
                            onPressed: _place),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps();

  @override
  Widget build(BuildContext context) {
    Widget dot(String label) => Column(
          children: [
            const Icon(Icons.circle, size: 12, color: AppColors.blue),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(color: AppColors.slate, fontSize: 11)),
          ],
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          dot('Shipping'),
          const Expanded(child: Divider(color: AppColors.blue)),
          dot('Payment'),
          const Expanded(child: Divider(color: AppColors.blue)),
          dot('Review'),
        ],
      ),
    );
  }
}

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final from = (order.createdAt ?? DateTime.now()).add(const Duration(days: 3));
    final to = (order.createdAt ?? DateTime.now()).add(const Duration(days: 5));
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const OrderSuccessArtwork(),
              const SizedBox(height: 20),
              const Text('Order Placed!',
                  style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 26,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Your order has been successfully placed.',
                  style: TextStyle(color: AppColors.slate)),
              const SizedBox(height: 20),
              Text('Order ${orderNumber(order.id)}',
                  style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(naira(order.total),
                  style: const TextStyle(color: AppColors.slate)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.blueTint,
                    borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    const Text('Estimated Delivery',
                        style: TextStyle(color: AppColors.slate, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('${formatDate(from)} - ${formatDate(to)}',
                        style: const TextStyle(
                            color: AppColors.navy, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                  label: 'View Order Details',
                  pink: true,
                  onPressed: () => MainShell.goTo(context, 3)),
              const SizedBox(height: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: const StadiumBorder(),
                  side: const BorderSide(color: AppColors.blue),
                ),
                onPressed: () => MainShell.goTo(context, 0),
                child: const Text('Continue Shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/// Order-confirmation artwork: a parcel with a check badge and a few
/// floating hearts/sparkles, drawn with plain widgets so it needs no asset.
/// Fits the same 110-logical-pixel footprint the icon used before.
class OrderSuccessArtwork extends StatelessWidget {
  const OrderSuccessArtwork({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft halo behind the parcel.
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
                color: AppColors.blueTint, shape: BoxShape.circle),
          ),
          // Floating accents.
          const Positioned(
            top: 10,
            left: 22,
            child: Icon(Icons.favorite, size: 16, color: AppColors.pink),
          ),
          const Positioned(
            top: 2,
            right: 34,
            child:
                Icon(Icons.star_rounded, size: 18, color: AppColors.warning),
          ),
          const Positioned(
            bottom: 12,
            right: 20,
            child: Icon(Icons.favorite, size: 13, color: AppColors.pinkLight),
          ),
          const Positioned(
            bottom: 20,
            left: 14,
            child: Icon(Icons.auto_awesome,
                size: 15, color: AppColors.blueLight),
          ),
          // The parcel.
          const _ParcelBox(),
          // Check badge on the corner.
          Positioned(
            right: 24,
            bottom: 24,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(Icons.check_rounded,
                  size: 22, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// A simple isometric-ish shipping box with a lid seam and tape.
class _ParcelBox extends StatelessWidget {
  const _ParcelBox();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 76,
      child: Stack(
        children: [
          // Box body.
          Positioned(
            left: 6,
            top: 18,
            child: Container(
              width: 72,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF0C79A),
                borderRadius: BorderRadius.circular(6),
                border:
                    Border.all(color: const Color(0xFFD9A86F), width: 1.5),
              ),
            ),
          ),
          // Lid.
          Positioned(
            left: 6,
            top: 8,
            child: Container(
              width: 72,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFFF7D6B0),
                borderRadius: BorderRadius.circular(6),
                border:
                    Border.all(color: const Color(0xFFD9A86F), width: 1.5),
              ),
            ),
          ),
          // Tape strip down the front.
          Positioned(
            left: 38,
            top: 8,
            child: Container(
              width: 8,
              height: 66,
              decoration: BoxDecoration(
                color: AppColors.blueLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Label on the box.
          Positioned(
            left: 14,
            top: 44,
            child: Container(
              width: 20,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
