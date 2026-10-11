import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../models/models.dart';
import '../services/shop_api.dart';

/// Who is logged in. The app root listens to this and swaps screens.
class Session extends ChangeNotifier {
  Session._();
  static final instance = Session._();

  /// Lets us close any open screens when the user is logged out.
  static final navigatorKey = GlobalKey<NavigatorState>();

  final _api = ApiClient.instance;
  List<String> roles = [];
  String? email;

  bool get isLoggedIn => _api.token != null;
  bool get isAdmin => roles.contains('ROLE_ADMIN');

  Future<void> restore() async {
    _api.onUnauthorized = () => logout(callServer: false);
    await _api.loadToken();
    if (_api.token == null) return;
    try {
      final p = await _api.get('/account/profile') as Map<String, dynamic>;
      email = p['email'] as String?;
      roles = await _detectRoles();
    } catch (_) {
      await _api.setToken(null);
    }
  }

  Future<void> login(
    String email,
    String password, {
    bool remember = true,
  }) async {
    final body = {'email': email.trim(), 'password': password};
    final cookie = await _api.loginSession('/auth/login', body);
    await _api.setToken(cookie, persist: remember);
    this.email = email.trim();
    roles = await _detectRoles();
    notifyListeners();
  }

  /// The real backend gives no role at login, so ask an admin-only
  /// endpoint: allowed = admin, refused = customer.
  Future<List<String>> _detectRoles() async {
    _api.suppressExpiry = true;
    try {
      await _api.get('/admin/support');
      return ['ROLE_ADMIN'];
    } catch (_) {
      return ['ROLE_CUSTOMER'];
    } finally {
      _api.suppressExpiry = false;
    }
  }

  Future<void> logout({bool callServer = true}) async {
    if (callServer) {
      try {
        await _api.post('/auth/logout');
      } catch (_) {}
    }
    await _api.setToken(null);
    roles = [];
    email = null;
    CartStore.instance.clear();
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
    notifyListeners();
  }
}

/// The shopping cart, shared by every screen (badge, cart tab, checkout).
class CartStore extends ChangeNotifier {
  CartStore._();
  static final instance = CartStore._();

  Cart cart = const Cart();
  bool loading = false;
  String? error;

  int get count => cart.count;

  void clear() {
    cart = const Cart();
    error = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      cart = await ShopApi.cart();
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<void> add(int productId, [int quantity = 1]) async {
    cart = await ShopApi.addToCart(productId, quantity);
    notifyListeners();
  }

  Future<void> setQuantity(int productId, int quantity) async {
    cart = await ShopApi.updateCart(productId, quantity);
    notifyListeners();
  }

  Future<void> remove(int productId) async {
    await ShopApi.removeFromCart(productId);
    cart = await ShopApi.cart();
    notifyListeners();
  }
}
