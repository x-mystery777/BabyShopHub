import '../core/api_client.dart';
import '../core/format.dart';
import '../models/models.dart';

/// Every backend call the app makes, in one place.
class ShopApi {
  ShopApi._();
  static final _c = ApiClient.instance;

  static List<T> _list<T>(dynamic data, T Function(Map<String, dynamic>) f) =>
      (data as List<dynamic>).map((e) => f(e as Map<String, dynamic>)).toList();

  static String _text(dynamic data, String fallback) =>
      data is String && data.isNotEmpty ? data : fallback;

  // ---------- auth ----------
  static Future<String> register({
    required String name,
    required String email,
    required String password,
    required DateTime dob,
    required String phone,
  }) async =>
      _text(
          await _c.post('/auth/register', {
            'name': name,
            'email': email,
            'password': password,
            'dob': isoDate(dob),
            'phoneNumber': phone,
          }),
          'Registration successful. Check your email for the code.');

  static Future<String> verify(String email, String code) async => _text(
      await _c.post(
          '/auth/verify', {'email': email, 'verificationCode': code}),
      'Email verified. You can now log in.');

  static Future<String> resendCode(String email) async => _text(
      await _c.post('/auth/resend-otp', {'email': email}),
      'A new code has been sent.');

  static Future<String> forgotPassword(String email) async => _text(
      await _c.post('/auth/forgot-password', {'email': email}),
      'A reset code has been sent to your email.');

  static Future<String> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async =>
      _text(
          await _c.post('/auth/reset-password', {
            'email': email,
            'resetCode': code,
            'newPassword': password,
            'confirmPassword': password,
          }),
          'Password reset. You can now log in.');

  // ---------- catalog ----------
  static Future<List<Category>> categories() async =>
      _list(await _c.get('/categories'), Category.fromJson);

  static Future<List<Brand>> brands() async =>
      _list(await _c.get('/brands'), Brand.fromJson);

  static Future<List<Product>> products({
    String? keyword,
    int? categoryId,
    int? brandId,
    String sortBy = 'productId',
    String direction = 'asc',
    int size = 50,
  }) async {
    final q = <String, String>{
      'size': '$size',
      'sortBy': sortBy,
      'direction': direction,
      if (keyword != null && keyword.trim().isNotEmpty)
        'keyword': keyword.trim(),
      if (categoryId != null) 'categoryId': '$categoryId',
      if (brandId != null) 'brandId': '$brandId',
    };
    final data = await _c.get('/products', query: q) as Map<String, dynamic>;
    return _list(data['content'], Product.fromJson);
  }

  static Future<Product> product(int id) async =>
      Product.fromJson(await _c.get('/products/$id') as Map<String, dynamic>);

  // ---------- reviews ----------
  static Future<List<Review>> reviews(int productId) async =>
      _list(await _c.get('/products/$productId/reviews'), Review.fromJson);

  static Future<void> addReview(int productId, int rating, String comment) =>
      _c.post('/products/$productId/reviews',
          {'rating': rating, 'comment': comment});

  // ---------- cart ----------
  static Future<Cart> cart() async =>
      Cart.fromJson(await _c.get('/cart') as Map<String, dynamic>);

  static Future<Cart> addToCart(int productId, int quantity) async =>
      Cart.fromJson(await _c.post('/cart/items',
          {'productId': productId, 'quantity': quantity}) as Map<String, dynamic>);

  static Future<Cart> updateCart(int productId, int quantity) async =>
      Cart.fromJson(await _c.patch(
          '/cart/items/$productId', {'quantity': quantity}) as Map<String, dynamic>);

  static Future<void> removeFromCart(int productId) =>
      _c.delete('/cart/items/$productId');

  // ---------- orders ----------
  static Future<OrderModel> checkout(int addressId) async =>
      OrderModel.fromJson(
          await _c.post('/orders', {'addressId': addressId}) as Map<String, dynamic>);

  static Future<List<OrderModel>> myOrders() async =>
      _list(await _c.get('/orders/me'), OrderModel.fromJson);

  static Future<OrderModel> order(int id) async =>
      OrderModel.fromJson(await _c.get('/orders/$id') as Map<String, dynamic>);

  static Future<List<TrackingEvent>> tracking(int id) async =>
      _list(await _c.get('/orders/$id/tracking'), TrackingEvent.fromJson);

  // ---------- account ----------
  static Future<Profile> profile() async => Profile.fromJson(
      await _c.get('/account/profile') as Map<String, dynamic>);

  static Future<void> updateProfile(
          String name, String phone, DateTime dob) =>
      _c.put('/account/profile',
          {'name': name, 'phoneNumber': phone, 'dob': isoDate(dob)});

  static Future<String> changePassword(String current, String next) async =>
      _text(
          await _c.post('/account/change-password', {
            'currentPassword': current,
            'newPassword': next,
            'confirmPassword': next,
          }),
          'Password changed.');

  static Future<List<Address>> addresses() async =>
      _list(await _c.get('/account/addresses'), Address.fromJson);

  static Map<String, dynamic> _addressBody(Map<String, dynamic> a) =>
      {...a, 'isDefault': a['default']}; // send both spellings

  static Future<void> addAddress(Map<String, dynamic> body) =>
      _c.post('/account/addresses', _addressBody(body));

  static Future<void> updateAddress(int id, Map<String, dynamic> body) =>
      _c.put('/account/addresses/$id', _addressBody(body));

  static Future<void> deleteAddress(int id) =>
      _c.delete('/account/addresses/$id');

  // ---------- support ----------
  static Future<void> createTicket(String subject, String message) =>
      _c.post('/support', {'subject': subject, 'message': message});

  static Future<List<Ticket>> myTickets() async =>
      _list(await _c.get('/support/me'), Ticket.fromJson);

  // ---------- admin ----------
  static Future<List<Product>> adminProducts() async =>
      _list(await _c.get('/admin/products'), Product.fromJson);

  static Future<void> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required int categoryId,
    required int brandId,
    String? imageUrl,
  }) =>
      _c.postMultipart(
        '/admin/products',
        fields: {'categoryId': '$categoryId', 'brandId': '$brandId'},
        partName: 'product',
        partJson: {
          'name': name,
          'description': description,
          'price': price,
          'stockQty': stock,
          'imageUrls': [
            if (imageUrl != null && imageUrl.trim().isNotEmpty) imageUrl.trim()
          ],
        },
      );

  static Future<void> updateProduct(
    int id, {
    required String name,
    required String description,
    required double price,
    required int stock,
    required int categoryId,
    required int brandId,
  }) =>
      _c.put('/admin/products/$id', {
        'name': name,
        'description': description,
        'price': price,
        'stockQty': stock,
        'categoryId': categoryId,
        'brandId': brandId,
      });

  static Future<void> deactivateProduct(int id) =>
      _c.delete('/admin/products/$id');

  static Future<void> createCategory(String name, String description) =>
      _c.post('/admin/categories', {'name': name, 'description': description});

  static Future<List<AppUser>> adminUsers() async =>
      _list(await _c.get('/admin/users'), AppUser.fromJson);

  static Future<void> setSuspended(int id, bool suspended) =>
      _c.patch('/admin/users/$id/status', {'suspended': suspended});

  static Future<List<OrderModel>> adminOrders() async =>
      _list(await _c.get('/admin/orders'), OrderModel.fromJson);

  static Future<void> setOrderStatus(int id, String status) =>
      _c.patch('/admin/orders/$id/status', {'status': status});

  static Future<List<Ticket>> adminTickets() async =>
      _list(await _c.get('/admin/support'), Ticket.fromJson);

  static Future<void> setTicketStatus(int id, String status, String reply) =>
      _c.patch('/admin/support/$id/status',
          {'status': status, 'adminResponse': reply});
}