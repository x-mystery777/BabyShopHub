import 'dart:convert';

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
    if (_api.token != null && !_readClaims(_api.token!)) {
      await _api.setToken(null);
    }
  }

  Future<void> login(String email, String password,
      {bool remember = true}) async {
    final data = await _api.post(
        '/auth/login', {'email': email.trim(), 'password': password});
    final token = (data as Map<String, dynamic>)['accessToken'] as String;
    await _api.setToken(token, persist: remember);
    _readClaims(token);
    notifyListeners();
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

  /// Reads roles/email/expiry from the JWT. Returns false if expired.
  bool _readClaims(String token) {
    try {
      final payload = token.split('.')[1];
      final map = jsonDecode(
              utf8.decode(base64Url.decode(base64Url.normalize(payload))))
          as Map<String, dynamic>;
      roles = (map['roles'] as List<dynamic>? ?? []).map((e) => '$e').toList();
      email = map['sub'] as String?;
      final exp = (map['exp'] as num?)?.toInt();
      if (exp != null &&
          DateTime.fromMillisecondsSinceEpoch(exp * 1000)
              .isBefore(DateTime.now())) {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
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