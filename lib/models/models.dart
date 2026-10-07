DateTime? _date(dynamic v) {
  if (v == null) return null;
  if (v is String) return DateTime.tryParse(v);
  if (v is List && v.length >= 3) {
    final p = v.map((e) => (e as num).toInt()).toList();
    return DateTime(p[0], p[1], p[2], p.length > 3 ? p[3] : 0,
        p.length > 4 ? p[4] : 0, p.length > 5 ? p[5] : 0);
  }
  return null;
}

double _num(dynamic v) => (v as num?)?.toDouble() ?? 0;

class Category {
  const Category({required this.id, required this.name, this.description});
  final int id;
  final String name;
  final String? description;

  factory Category.fromJson(Map<String, dynamic> j) => Category(
        id: j['categoryId'] as int,
        name: j['name'] as String,
        description: j['description'] as String?,
      );
}

class Brand {
  const Brand({required this.id, required this.name});
  final int id;
  final String name;

  factory Brand.fromJson(Map<String, dynamic> j) {
    final id = j['brandId'] ?? j['id'];
    return Brand(id: (id as num).toInt(), name: j['name'] as String);
  }
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stockQty,
    required this.categoryId,
    required this.categoryName,
    required this.brandId,
    required this.brandName,
    this.description,
    this.imageUrls = const [],
    this.active = true,
  });

  final int id;
  final String name;
  final String? description;
  final double price;
  final int stockQty;
  final List<String> imageUrls;
  final int categoryId;
  final String categoryName;
  final int brandId;
  final String brandName;
  final bool active;

  bool get inStock => stockQty > 0;
  String? get imageUrl => imageUrls.isEmpty ? null : imageUrls.first;

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: (j['productId'] as num).toInt(),
        name: j['name'] as String,
        description: j['description'] as String?,
        price: _num(j['price']),
        stockQty: (j['stockQty'] as num?)?.toInt() ?? 0,
        active: j['active'] as bool? ?? true,
        imageUrls: (j['imageUrls'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        categoryId: (j['categoryId'] as num?)?.toInt() ?? 0,
        categoryName: (j['categoryName'] as String?) ?? '',
        brandId: (j['brandId'] as num?)?.toInt() ?? 0,
        brandName: (j['brandName'] as String?) ?? '',
      );
}

class CartLine {
  const CartLine({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });
  final int productId;
  final String name;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  factory CartLine.fromJson(Map<String, dynamic> j) => CartLine(
        productId: (j['productId'] as num).toInt(),
        name: j['name'] as String,
        quantity: (j['quantity'] as num).toInt(),
        unitPrice: _num(j['unitPrice']),
        subtotal: _num(j['subtotal']),
      );
}

class Cart {
  const Cart({this.items = const [], this.total = 0});
  final List<CartLine> items;
  final double total;

  int get count => items.fold(0, (sum, l) => sum + l.quantity);

  factory Cart.fromJson(Map<String, dynamic> j) => Cart(
        items: (j['items'] as List<dynamic>? ?? [])
            .map((e) => CartLine.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: _num(j['total']),
      );
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.status,
    required this.paymentStatus,
    required this.shippingAddress,
    required this.total,
    required this.createdAt,
    required this.items,
  });
  final int id;
  final String status;
  final String paymentStatus;
  final String shippingAddress;
  final double total;
  final DateTime? createdAt;
  final List<CartLine> items;

  int get itemCount => items.fold(0, (sum, l) => sum + l.quantity);

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
        id: (j['orderId'] as num).toInt(),
        status: (j['orderStatus'] as String?) ?? 'CONFIRMED',
        paymentStatus: (j['paymentStatus'] as String?) ?? '',
        shippingAddress: (j['shippingAddress'] as String?) ?? '',
        total: _num(j['totalAmount']),
        createdAt: _date(j['createdAt']),
        items: (j['items'] as List<dynamic>? ?? [])
            .map((e) => CartLine.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class TrackingEvent {
  const TrackingEvent({required this.status, this.note, this.createdAt});
  final String status;
  final String? note;
  final DateTime? createdAt;

  factory TrackingEvent.fromJson(Map<String, dynamic> j) => TrackingEvent(
        status: (j['status'] as String?) ?? '',
        note: j['note'] as String?,
        createdAt: _date(j['createdAt']),
      );
}

class Review {
  const Review({
    required this.id,
    required this.reviewer,
    required this.rating,
    this.comment,
    this.createdAt,
  });
  final int id;
  final String reviewer;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  factory Review.fromJson(Map<String, dynamic> j) => Review(
        id: (j['reviewId'] as num).toInt(),
        reviewer: (j['reviewer'] as String?) ?? 'Customer',
        rating: (j['rating'] as num?)?.toInt() ?? 0,
        comment: j['comment'] as String?,
        createdAt: _date(j['createdAt']),
      );
}

class Address {
  const Address({
    required this.id,
    required this.line1,
    required this.city,
    required this.country,
    this.label,
    this.state,
    this.postalCode,
    this.isDefault = false,
  });
  final int id;
  final String? label;
  final String line1;
  final String city;
  final String? state;
  final String country;
  final String? postalCode;
  final bool isDefault;

  String get oneLine => [line1, city, state, country, postalCode]
      .where((e) => e != null && e.isNotEmpty)
      .join(', ');

  factory Address.fromJson(Map<String, dynamic> j) => Address(
        id: (j['addressId'] as num).toInt(),
        label: j['label'] as String?,
        line1: (j['line1'] as String?) ?? '',
        city: (j['city'] as String?) ?? '',
        state: j['state'] as String?,
        country: (j['country'] as String?) ?? '',
        postalCode: j['postalCode'] as String?,
        isDefault: (j['isDefault'] ?? j['default'] ?? false) as bool,
      );
}

class Profile {
  const Profile({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.dob,
  });
  final int id;
  final String name;
  final String email;
  final String? phoneNumber;
  final DateTime? dob;

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        id: (j['id'] as num).toInt(),
        name: (j['name'] as String?) ?? '',
        email: (j['email'] as String?) ?? '',
        phoneNumber: j['phoneNumber'] as String?,
        dob: _date(j['dob']),
      );
}

class Ticket {
  const Ticket({
    required this.id,
    required this.email,
    required this.subject,
    required this.message,
    required this.status,
    this.adminResponse,
    this.createdAt,
  });
  final int id;
  final String email;
  final String subject;
  final String message;
  final String status;
  final String? adminResponse;
  final DateTime? createdAt;

  factory Ticket.fromJson(Map<String, dynamic> j) => Ticket(
        id: (j['ticketId'] as num).toInt(),
        email: (j['requesterEmail'] as String?) ?? '',
        subject: (j['subject'] as String?) ?? '',
        message: (j['message'] as String?) ?? '',
        status: (j['status'] as String?) ?? 'OPEN',
        adminResponse: j['adminResponse'] as String?,
        createdAt: _date(j['createdAt']),
      );
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.enabled,
    required this.suspended,
    required this.roles,
    this.phoneNumber,
  });
  final int id;
  final String name;
  final String email;
  final String? phoneNumber;
  final bool enabled;
  final bool suspended;
  final List<String> roles;

  bool get isAdmin => roles.contains('ROLE_ADMIN');

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: (j['id'] as num).toInt(),
        name: (j['name'] as String?) ?? '',
        email: (j['email'] as String?) ?? '',
        phoneNumber: j['phoneNumber'] as String?,
        enabled: j['enabled'] as bool? ?? false,
        suspended: j['suspended'] as bool? ?? false,
        roles: (j['roles'] as List<dynamic>? ?? []).map((e) => '$e').toList(),
      );
}