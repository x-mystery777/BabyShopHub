import 'dart:convert';

import 'api_client.dart';

/// A pretend server that lives inside the app. It answers the same URLs and
/// returns the same JSON as the real Spring backend, so every screen works
/// without a server. Data is kept in memory and resets when the app restarts.
///
/// Turn it off later with:  flutter run --dart-define=MOCK=false
class MockBackend {
  MockBackend._();
  static final instance = MockBackend._();

  static const demoEmail = 'demo@babyshophub.com';
  static const demoPassword = 'Demo1234!';
  static const adminEmail = 'admin@babyshophub.com';
  static const adminPassword = 'Admin1234!';
  static const otpCode = '123456';

  static final _strong = RegExp(
      r"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[-@!*()}{#$%,<>/^:;'&+=_~?]).{8,}$");

  // ---------- data ----------
  int _nextUser = 3, _nextProduct = 1, _nextCategory = 1, _nextBrand = 1;
  int _nextOrder = 1001, _nextTrack = 1, _nextReview = 1, _nextAddress = 1;
  int _nextTicket = 1;

  final List<Map<String, dynamic>> _users = [
    {
      'id': 1,
      'name': 'Taiwo Mercy Olamide',
      'email': demoEmail,
      'password': demoPassword,
      'phoneNumber': '+2348010000000',
      'dob': '1998-04-12',
      'enabled': true,
      'suspended': false,
      'roles': ['ROLE_CUSTOMER'],
    },
    {
      'id': 2,
      'name': 'System Admin',
      'email': adminEmail,
      'password': adminPassword,
      'phoneNumber': '08000000000',
      'dob': '1990-01-01',
      'enabled': true,
      'suspended': false,
      'roles': ['ROLE_ADMIN'],
    },
  ];

  late final List<Map<String, dynamic>> _categories = [
    for (final n in [
      'Diapers',
      'Baby Food',
      'Clothing',
      'Toys',
      'Feeding',
      'Skincare',
      'Accessories',
      'Strollers',
    ])
      {
        'categoryId': _nextCategory++,
        'name': n,
        'description': '$n for little ones',
        'active': true,
      },
  ];

  late final List<Map<String, dynamic>> _brands = [
    for (final n in ['Pampers', 'Huggies', 'Molfix', 'Gerber', 'BabyShopHub'])
      {'brandId': _nextBrand++, 'name': n, 'description': null},
  ];

  late final List<Map<String, dynamic>> _products = _seedProducts();

  List<Map<String, dynamic>> _seedProducts() {
    final list = <Map<String, dynamic>>[];
    void add(String name, String desc, double price, int stock, String cat,
        String brand) {
      final c = _categories.firstWhere((e) => e['name'] == cat);
      final b = _brands.firstWhere((e) => e['name'] == brand);
      list.add({
        'productId': _nextProduct++,
        'name': name,
        'description': desc,
        'price': price,
        'stockQty': stock,
        'active': true,
        'createdAt': DateTime.now().toIso8601String(),
        'imageUrls': <String>[],
        'categoryId': c['categoryId'],
        'categoryName': c['name'],
        'brandId': b['brandId'],
        'brandName': b['name'],
      });
    }

    add('Pampers Baby Dry Size 3 (Midi) - 62pcs',
        'Keeps your baby dry and comfortable for up to 12 hours. Soft, breathable and gentle on delicate skin.',
        12500, 40, 'Diapers', 'Pampers');
    add('Huggies Snug & Dry Size 4 - 52pcs',
        'Snug fit with a dry-touch layer for all-day comfort.', 11800, 35,
        'Diapers', 'Huggies');
    add('Molfix Baby Diapers Size 5 - 44pcs',
        'Soft, absorbent diapers with a comfortable stretch waist.', 10800,
        25, 'Diapers', 'Molfix');
    add('Gerber Baby Food - Apple & Banana (6m+)',
        'Smooth fruit puree made for babies from 6 months.', 3800, 60,
        'Baby Food', 'Gerber');
    add('Gerber Rice Cereal - 227g',
        'Iron-fortified single grain cereal for first foods.', 4600, 30,
        'Baby Food', 'Gerber');
    add('Baby Romper (0-6m)', 'Soft cotton romper with easy snap buttons.',
        5500, 20, 'Clothing', 'BabyShopHub');
    add('Cotton Onesie Set (3 pack)',
        'Breathable onesies in soft pastel colors.', 7800, 18, 'Clothing',
        'BabyShopHub');
    add('Soft Teddy Bear Rattle', 'Gentle rattle toy, safe for little hands.',
        4200, 0, 'Toys', 'BabyShopHub');
    add('Anti-Colic Feeding Bottle 260ml',
        'Wide-neck bottle with an anti-colic vent system.', 6500, 45,
        'Feeding', 'BabyShopHub');
    add('Gentle Baby Lotion 300ml',
        'Moisturising lotion for delicate skin. Fragrance free.', 3900, 50,
        'Skincare', 'BabyShopHub');
    return list;
  }

  final Map<int, List<Map<String, dynamic>>> _reviews = {};
  final Map<String, Map<int, int>> _carts = {};
  final List<Map<String, dynamic>> _orders = [];
  final Map<int, List<Map<String, dynamic>>> _tracking = {};
  final Map<String, List<Map<String, dynamic>>> _addresses = {};
  final List<Map<String, dynamic>> _tickets = [];

  // ---------- helpers ----------
  Never _fail(String message, [int code = 400]) =>
      throw ApiException(message, code);

  String _now() => DateTime.now().toIso8601String();

  String _jwt(Map<String, dynamic> u) {
    String enc(Object m) =>
        base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
    final exp = DateTime.now()
            .add(const Duration(hours: 24))
            .millisecondsSinceEpoch ~/
        1000;
    return '${enc({'alg': 'none', 'typ': 'JWT'})}.'
        '${enc({'sub': u['email'], 'roles': u['roles'], 'exp': exp})}.mock';
  }

  String? _tokenEmail() {
    final t = ApiClient.instance.token;
    if (t == null) return null;
    try {
      final payload = t.split('.')[1];
      final map = jsonDecode(
              utf8.decode(base64Url.decode(base64Url.normalize(payload))))
          as Map<String, dynamic>;
      return map['sub'] as String?;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _me() {
    final email = _tokenEmail();
    if (email == null) _fail('Please log in to continue.', 401);
    return _users.firstWhere((u) => u['email'] == email, orElse: () {
      // The demo data resets when the app restarts, so an old login can
      // point at a user that no longer exists. Log out cleanly.
      ApiClient.instance.onUnauthorized?.call();
      _fail('Your session expired. Please log in again.', 401);
    });
  }

  Map<String, dynamic> _admin() {
    final u = _me();
    if (!(u['roles'] as List).contains('ROLE_ADMIN')) {
      _fail('You are not allowed to do that.', 403);
    }
    return u;
  }

  Map<String, dynamic> _findProduct(int id) => _products.firstWhere(
      (p) => p['productId'] == id,
      orElse: () => _fail('Product not found', 404));

  Map<String, dynamic> _body(Object? b) =>
      (b is Map) ? Map<String, dynamic>.from(b) : <String, dynamic>{};

  // ---------- entry point ----------
  Future<dynamic> handle(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final seg = path.split('/').where((s) => s.isNotEmpty).toList();
    final q = query ?? const <String, String>{};
    final b = _body(body);
    int? idAt(int i) => seg.length > i ? int.tryParse(seg[i]) : null;
    bool route(String m, int length) => method == m && seg.length == length;

    switch (seg.isEmpty ? '' : seg[0]) {
      case 'auth':
        return _auth(method, seg.length > 1 ? seg[1] : '', b);

      case 'categories':
        return _categories.where((c) => c['active'] == true).toList();

      case 'brands':
        return _brands;

      case 'products':
        if (route('GET', 1)) return _searchProducts(q);
        if (route('GET', 2)) return _findProduct(idAt(1) ?? -1);
        if (seg.length == 3 && seg[2] == 'reviews') {
          final pid = idAt(1) ?? -1;
          if (method == 'GET') return _reviews[pid] ?? [];
          return _addReview(pid, b);
        }
        break;

      case 'cart':
        return _cart(method, seg, b);

      case 'orders':
        return _orderRoutes(method, seg, b);

      case 'account':
        return _account(method, seg, b);

      case 'support':
        if (route('POST', 1)) return _createTicket(b);
        if (route('GET', 2) && seg[1] == 'me') {
          final email = _me()['email'];
          return _tickets.where((t) => t['requesterEmail'] == email).toList();
        }
        break;

      case 'admin':
        _admin();
        return _adminRoutes(method, seg, b);
    }
    _fail('Not found: $method $path', 404);
  }

  // ---------- auth ----------
  dynamic _auth(String method, String action, Map<String, dynamic> b) {
    String email() => (b['email'] as String? ?? '').trim().toLowerCase();

    switch (action) {
      case 'register':
        final name = (b['name'] as String? ?? '').trim();
        final password = b['password'] as String? ?? '';
        final phone = (b['phoneNumber'] as String? ?? '').trim();
        if (name.isEmpty) _fail('name: Name is required');
        if (email().isEmpty) _fail('email: Email is required');
        if (password.length < 6) {
          _fail('password: Password must be at least 6 characters');
        }
        if (phone.isEmpty) _fail('phoneNumber: Phone number is required');
        if (b['dob'] == null) _fail('dob: Date of birth is required');
        if (_users.any((u) => u['email'] == email())) {
          _fail('An account with this email already exists.');
        }
        _users.add({
          'id': _nextUser++,
          'name': name,
          'email': email(),
          'password': password,
          'phoneNumber': phone,
          'dob': b['dob'],
          'enabled': false,
          'suspended': false,
          'roles': ['ROLE_CUSTOMER'],
        });
        return 'Registration successful. Your verification code is $otpCode '
            '(demo mode).';

      case 'verify':
        final u = _users.firstWhere((u) => u['email'] == email(),
            orElse: () => _fail('Account not found'));
        if (b['verificationCode'] != otpCode) {
          _fail('Invalid or expired verification code.');
        }
        u['enabled'] = true;
        return 'Email verified. You can now log in.';

      case 'resend-otp':
        return 'A new code has been sent. Demo code: $otpCode';

      case 'forgot-password':
        return 'A reset code has been sent. Demo code: $otpCode';

      case 'reset-password':
        final u = _users.firstWhere((u) => u['email'] == email(),
            orElse: () => _fail('Account not found'));
        if (b['resetCode'] != otpCode) _fail('Invalid or expired reset code.');
        final pw = b['newPassword'] as String? ?? '';
        if (!_strong.hasMatch(pw)) {
          _fail('Password must be at least 8 characters long and contain an '
              'uppercase letter, a lowercase letter, a number and a symbol.');
        }
        if (pw != b['confirmPassword']) _fail('Passwords do not match.');
        u['password'] = pw;
        return 'Password reset. You can now log in.';

      case 'login':
        final u = _users.firstWhere(
            (u) => u['email'] == email() && u['password'] == b['password'],
            orElse: () => _fail('Invalid email or password.', 401));
        if (u['enabled'] != true) {
          _fail('Account not verified. Please verify your email.', 403);
        }
        if (u['suspended'] == true) {
          _fail('This account has been suspended.', 403);
        }
        return {
          'accessToken': _jwt(u),
          'tokenType': 'Bearer',
          'expiresInSeconds': 86400,
        };

      case 'logout':
        return null;
    }
    _fail('Not found', 404);
  }

  // ---------- catalog ----------
  Map<String, dynamic> _searchProducts(Map<String, String> q) {
    final keyword = (q['keyword'] ?? '').toLowerCase();
    final categoryId = int.tryParse(q['categoryId'] ?? '');
    final brandId = int.tryParse(q['brandId'] ?? '');
    final sortBy = q['sortBy'] ?? 'productId';
    final desc = (q['direction'] ?? 'asc').toLowerCase() == 'desc';
    final size = int.tryParse(q['size'] ?? '') ?? 10;

    var list = _products.where((p) {
      if (p['active'] != true) return false;
      if (categoryId != null && p['categoryId'] != categoryId) return false;
      if (brandId != null && p['brandId'] != brandId) return false;
      if (keyword.isEmpty) return true;
      return [p['name'], p['description'], p['brandName'], p['categoryName']]
          .any((v) => '$v'.toLowerCase().contains(keyword));
    }).toList();

    int cmp(Map<String, dynamic> a, Map<String, dynamic> b) {
      final x = a[sortBy], y = b[sortBy];
      if (x is num && y is num) return x.compareTo(y);
      return '$x'.toLowerCase().compareTo('$y'.toLowerCase());
    }

    list.sort((a, b) => desc ? cmp(b, a) : cmp(a, b));
    return {
      'content': list.take(size).toList(),
      'totalElements': list.length,
    };
  }

  dynamic _addReview(int productId, Map<String, dynamic> b) {
    final u = _me();
    _findProduct(productId);
    final rating = (b['rating'] as num?)?.toInt() ?? 0;
    if (rating < 1 || rating > 5) _fail('rating: Choose 1 to 5 stars');
    final review = {
      'reviewId': _nextReview++,
      'reviewer': u['name'],
      'rating': rating,
      'comment': b['comment'],
      'createdAt': _now(),
    };
    _reviews.putIfAbsent(productId, () => []).insert(0, review);
    return review;
  }

  // ---------- cart ----------
  Map<String, dynamic> _cartJson(String email) {
    final cart = _carts[email] ?? {};
    var total = 0.0;
    final items = <Map<String, dynamic>>[];
    cart.forEach((pid, qty) {
      final p = _findProduct(pid);
      final price = (p['price'] as num).toDouble();
      total += price * qty;
      items.add({
        'productId': pid,
        'name': p['name'],
        'quantity': qty,
        'unitPrice': price,
        'subtotal': price * qty,
      });
    });
    return {'items': items, 'total': total};
  }

  dynamic _cart(String method, List<String> seg, Map<String, dynamic> b) {
    final email = _me()['email'] as String;
    final cart = _carts.putIfAbsent(email, () => {});

    if (method == 'GET' && seg.length == 1) return _cartJson(email);

    if (method == 'POST' && seg.length == 2) {
      final productId = (b['productId'] as num?)?.toInt() ?? -1;
      final qty = (b['quantity'] as num?)?.toInt() ?? 1;
      final p = _findProduct(productId);
      final want = (cart[productId] ?? 0) + qty;
      if ((p['stockQty'] as int) <= 0) _fail('This product is out of stock.');
      if (want > (p['stockQty'] as int)) {
        _fail('Only ${p['stockQty']} left in stock.');
      }
      cart[productId] = want;
      return _cartJson(email);
    }

    final pid = seg.length == 3 ? int.tryParse(seg[2]) : null;
    if (pid != null && method == 'PATCH') {
      final qty = (b['quantity'] as num?)?.toInt() ?? 1;
      final p = _findProduct(pid);
      if (qty < 1) _fail('quantity: Must be at least 1');
      if (qty > (p['stockQty'] as int)) {
        _fail('Only ${p['stockQty']} left in stock.');
      }
      cart[pid] = qty;
      return _cartJson(email);
    }
    if (pid != null && method == 'DELETE') {
      cart.remove(pid);
      return null;
    }
    _fail('Not found', 404);
  }

  // ---------- orders ----------
  dynamic _orderRoutes(String method, List<String> seg, Map<String, dynamic> b) {
    final me = _me();
    final email = me['email'] as String;

    if (method == 'POST' && seg.length == 1) {
      final cart = _carts[email] ?? {};
      if (cart.isEmpty) _fail('Your cart is empty.');
      final addr = (_addresses[email] ?? []).firstWhere(
          (a) => a['addressId'] == b['addressId'],
          orElse: () => _fail('Choose a delivery address.'));
      final cartJson = _cartJson(email);
      for (final e in cart.entries) {
        final p = _findProduct(e.key);
        if (e.value > (p['stockQty'] as int)) {
          _fail('Not enough stock for ${p['name']}.');
        }
      }
      for (final e in cart.entries) {
        final p = _findProduct(e.key);
        p['stockQty'] = (p['stockQty'] as int) - e.value;
      }
      final newId = _nextOrder++;
      final order = {
        'orderId': newId,
        'email': email,
        'orderStatus': 'CONFIRMED',
        'paymentStatus': 'PAID',
        'shippingAddress': [
          addr['line1'],
          addr['city'],
          addr['state'],
          addr['country'],
          addr['postalCode'],
        ].where((e) => e != null && '$e'.isNotEmpty).join(', '),
        'totalAmount': cartJson['total'],
        'createdAt': _now(),
        'items': cartJson['items'],
      };
      _orders.insert(0, order);
      _track(newId, 'CONFIRMED', 'Order placed; dummy payment recorded.');
      _carts[email] = {};
      return order;
    }

    if (method == 'GET' && seg.length == 2 && seg[1] == 'me') {
      return _orders.where((o) => o['email'] == email).toList();
    }

    final id = seg.length >= 2 ? int.tryParse(seg[1]) : null;
    if (id != null) {
      final order = _orders.firstWhere(
          (o) => o['orderId'] == id && o['email'] == email,
          orElse: () => _fail('Order not found', 404));
      if (method == 'GET' && seg.length == 2) return order;
      if (method == 'GET' && seg.length == 3 && seg[2] == 'tracking') {
        return _tracking[id] ?? [];
      }
    }
    _fail('Not found', 404);
  }

  void _track(int orderId, String status, String note) {
    _tracking.putIfAbsent(orderId, () => []).add({
      'trackingId': _nextTrack++,
      'status': status,
      'note': note,
      'createdAt': _now(),
    });
  }

  // ---------- account ----------
  dynamic _account(String method, List<String> seg, Map<String, dynamic> b) {
    final me = _me();
    final email = me['email'] as String;
    final addrs = _addresses.putIfAbsent(email, () => []);
    final sub = seg.length > 1 ? seg[1] : '';

    Map<String, dynamic> profile() => {
          'id': me['id'],
          'name': me['name'],
          'email': me['email'],
          'phoneNumber': me['phoneNumber'],
          'dob': me['dob'],
        };

    if (sub == 'profile') {
      if (method == 'GET') return profile();
      if (method == 'PUT') {
        final name = (b['name'] as String? ?? '').trim();
        final phone = (b['phoneNumber'] as String? ?? '').trim();
        if (name.isEmpty) _fail('name: Name is required');
        if (phone.isEmpty) _fail('phoneNumber: Phone number is required');
        me['name'] = name;
        me['phoneNumber'] = phone;
        me['dob'] = b['dob'] ?? me['dob'];
        return profile();
      }
    }

    if (sub == 'change-password' && method == 'POST') {
      if (b['currentPassword'] != me['password']) {
        _fail('Current password is incorrect.');
      }
      final next = b['newPassword'] as String? ?? '';
      if (!_strong.hasMatch(next)) {
        _fail('Password must be at least 8 characters long and contain an '
            'uppercase letter, a lowercase letter, a number and a symbol.');
      }
      if (next != b['confirmPassword']) _fail('Passwords do not match.');
      me['password'] = next;
      return 'Password changed.';
    }

    if (sub == 'addresses') {
      if (seg.length == 2 && method == 'GET') return addrs;
      if (seg.length == 2 && method == 'POST') {
        final a = _addressFrom(b, _nextAddress++);
        if (addrs.isEmpty) a['isDefault'] = true;
        if (a['isDefault'] == true) _clearDefault(addrs);
        addrs.add(a);
        return a;
      }
      final id = seg.length == 3 ? int.tryParse(seg[2]) : null;
      if (id != null && method == 'PUT') {
        final i = addrs.indexWhere((a) => a['addressId'] == id);
        if (i < 0) _fail('Address not found', 404);
        final a = _addressFrom(b, id);
        if (a['isDefault'] == true) _clearDefault(addrs);
        addrs[i] = a;
        return a;
      }
      if (id != null && method == 'DELETE') {
        addrs.removeWhere((a) => a['addressId'] == id);
        if (addrs.isNotEmpty && !addrs.any((a) => a['isDefault'] == true)) {
          addrs.first['isDefault'] = true;
        }
        return null;
      }
    }
    _fail('Not found', 404);
  }

  Map<String, dynamic> _addressFrom(Map<String, dynamic> b, int id) {
    final line1 = (b['line1'] as String? ?? '').trim();
    final city = (b['city'] as String? ?? '').trim();
    final country = (b['country'] as String? ?? '').trim();
    if (line1.isEmpty) _fail('line1: Address is required');
    if (city.isEmpty) _fail('city: City is required');
    if (country.isEmpty) _fail('country: Country is required');
    return {
      'addressId': id,
      'label': b['label'],
      'line1': line1,
      'city': city,
      'state': b['state'],
      'country': country,
      'postalCode': b['postalCode'],
      'isDefault': (b['isDefault'] ?? b['default'] ?? false) == true,
    };
  }

  void _clearDefault(List<Map<String, dynamic>> addrs) {
    for (final a in addrs) {
      a['isDefault'] = false;
    }
  }

  // ---------- support ----------
  dynamic _createTicket(Map<String, dynamic> b) {
    final me = _me();
    final subject = (b['subject'] as String? ?? '').trim();
    final message = (b['message'] as String? ?? '').trim();
    if (subject.isEmpty) _fail('subject: Subject is required');
    if (message.isEmpty) _fail('message: Message is required');
    final t = {
      'ticketId': _nextTicket++,
      'requesterEmail': me['email'],
      'subject': subject,
      'message': message,
      'adminResponse': null,
      'status': 'OPEN',
      'createdAt': _now(),
    };
    _tickets.insert(0, t);
    return t;
  }

  // ---------- admin ----------
  dynamic _adminRoutes(String method, List<String> seg, Map<String, dynamic> b) {
    final area = seg.length > 1 ? seg[1] : '';
    final id = seg.length > 2 ? int.tryParse(seg[2]) : null;

    switch (area) {
      case 'products':
        if (method == 'GET' && seg.length == 2) return _products;
        if (method == 'POST' && seg.length == 2) return _saveProduct(null, b);
        if (id != null && method == 'PUT') return _saveProduct(id, b);
        if (id != null && method == 'DELETE') {
          _findProduct(id)['active'] = false;
          return null;
        }
        break;

      case 'categories':
        if (method == 'POST') {
          final name = (b['name'] as String? ?? '').trim();
          if (name.isEmpty) _fail('name: Category name is required');
          if (_categories.any((c) =>
              '${c['name']}'.toLowerCase() == name.toLowerCase())) {
            _fail('The request conflicts with existing data.', 409);
          }
          final c = {
            'categoryId': _nextCategory++,
            'name': name,
            'description': b['description'],
            'active': true,
          };
          _categories.add(c);
          return c;
        }
        break;

      case 'users':
        if (method == 'GET' && seg.length == 2) {
          return _users
              .map((u) => {
                    'id': u['id'],
                    'name': u['name'],
                    'email': u['email'],
                    'phoneNumber': u['phoneNumber'],
                    'enabled': u['enabled'],
                    'suspended': u['suspended'],
                    'roles': u['roles'],
                  })
              .toList();
        }
        if (id != null && method == 'PATCH') {
          final u = _users.firstWhere((u) => u['id'] == id,
              orElse: () => _fail('User not found', 404));
          if ((u['roles'] as List).contains('ROLE_ADMIN')) {
            _fail('Administrators cannot be suspended.');
          }
          u['suspended'] = b['suspended'] == true;
          return {
            'id': u['id'],
            'name': u['name'],
            'email': u['email'],
            'phoneNumber': u['phoneNumber'],
            'enabled': u['enabled'],
            'suspended': u['suspended'],
            'roles': u['roles'],
          };
        }
        break;

      case 'orders':
        if (method == 'GET' && seg.length == 2) return _orders;
        if (id != null && method == 'PATCH') {
          return _setOrderStatus(id, b['status'] as String?);
        }
        break;

      case 'support':
        if (method == 'GET' && seg.length == 2) return _tickets;
        if (id != null && method == 'PATCH') {
          final status = (b['status'] as String? ?? '').toUpperCase();
          if (!['OPEN', 'IN_PROGRESS', 'CLOSED'].contains(status)) {
            _fail('Unsupported ticket status');
          }
          final t = _tickets.firstWhere((t) => t['ticketId'] == id,
              orElse: () => _fail('Ticket not found', 404));
          t['status'] = status;
          if (b['adminResponse'] != null) t['adminResponse'] = b['adminResponse'];
          return t;
        }
        break;
    }
    _fail('Not found', 404);
  }

  /// The real backend sends the product JSON as a multipart part; the API
  /// client hands it over as a plain map, so create and update look alike.
  Map<String, dynamic> _saveProduct(int? id, Map<String, dynamic> b) {
    final name = (b['name'] as String? ?? '').trim();
    final price = (b['price'] as num?)?.toDouble();
    final stock = (b['stockQty'] as num?)?.toInt();
    if (name.isEmpty) _fail('name: Name is required');
    if (price == null || price < 0) _fail('price: Enter a valid price');
    if (stock == null || stock < 0) _fail('stockQty: Enter a valid stock');

    final category = _categories.firstWhere(
        (c) => c['categoryId'] == (b['categoryId'] as num?)?.toInt(),
        orElse: () => _fail('Category not found'));
    final brand = _brands.firstWhere(
        (c) => c['brandId'] == (b['brandId'] as num?)?.toInt(),
        orElse: () => _fail('Brand not found'));

    final Map<String, dynamic> p;
    if (id == null) {
      p = {
        'productId': _nextProduct++,
        'active': true,
        'createdAt': _now(),
        'imageUrls': <String>[
          ...((b['imageUrls'] as List<dynamic>?) ?? []).map((e) => '$e'),
        ],
      };
      _products.add(p);
    } else {
      p = _findProduct(id);
    }
    p['name'] = name;
    p['description'] = b['description'];
    p['price'] = price;
    p['stockQty'] = stock;
    p['categoryId'] = category['categoryId'];
    p['categoryName'] = category['name'];
    p['brandId'] = brand['brandId'];
    p['brandName'] = brand['name'];
    return p;
  }

  Map<String, dynamic> _setOrderStatus(int id, String? raw) {
    final status = (raw ?? '').trim().toUpperCase();
    const flow = ['CONFIRMED', 'PACKED', 'SHIPPED', 'DELIVERED'];
    if (![...flow, 'CANCELLED'].contains(status)) {
      _fail('Unsupported order status');
    }
    final order = _orders.firstWhere((o) => o['orderId'] == id,
        orElse: () => _fail('Order not found', 404));
    final current = order['orderStatus'] as String;
    if (status == current) return order;

    if (status == 'CANCELLED') {
      if (!['CONFIRMED', 'PACKED'].contains(current)) {
        _fail('Only confirmed or packed orders can be cancelled');
      }
      for (final line in order['items'] as List) {
        final p = _findProduct(line['productId'] as int);
        p['stockQty'] = (p['stockQty'] as int) + (line['quantity'] as int);
      }
    } else if (flow.indexOf(status) != flow.indexOf(current) + 1) {
      _fail('Order statuses must advance one step at a time');
    }
    order['orderStatus'] = status;
    _track(id, status, 'Order status updated by administrator.');
    return order;
  }
}