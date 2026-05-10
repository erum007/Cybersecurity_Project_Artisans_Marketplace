class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? phone;
  final String? address;
  final String? city;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.city,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        fullName: (json['full_name'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        role: (json['role'] ?? 'customer').toString(),
        phone: json['phone']?.toString(),
        address: json['address']?.toString(),
        city: json['city']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'full_name': fullName,
        'email': email,
        'role': role,
        'phone': phone,
        'address': address,
        'city': city,
      };
}

class Product {
  final String id;
  final String artisanId;
  final String artisanName;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String imageUrl;
  final bool isActive;

  Product({
    required this.id,
    required this.artisanId,
    required this.artisanName,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.imageUrl,
    required this.isActive,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: (json['_id'] ?? '').toString(),
        artisanId: (json['artisan_id'] ?? '').toString(),
        artisanName: (json['artisan_name'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        description: (json['description'] ?? '').toString(),
        price: ((json['price'] ?? 0) as num).toDouble(),
        stock: (json['stock'] ?? 0) as int,
        category: (json['category'] ?? 'General').toString(),
        imageUrl: (json['image_url'] ?? '').toString(),
        isActive: (json['is_active'] ?? true) as bool,
      );
}

class CartItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final double lineTotal;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.lineTotal,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        productId: (json['product_id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        price: ((json['price'] ?? 0) as num).toDouble(),
        quantity: (json['quantity'] ?? 0) as int,
        lineTotal: ((json['line_total'] ?? 0) as num).toDouble(),
      );
}

class CartData {
  final List<CartItem> items;
  final double total;

  CartData({required this.items, required this.total});

  factory CartData.fromJson(Map<String, dynamic> json) => CartData(
        items: ((json['items'] ?? []) as List)
            .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        total: ((json['total'] ?? 0) as num).toDouble(),
      );
}

class OrderItem {
  final String productId;
  final String name;
  final String artisanId;
  final int quantity;
  final double price;
  final double lineTotal;

  OrderItem({
    required this.productId,
    required this.name,
    required this.artisanId,
    required this.quantity,
    required this.price,
    required this.lineTotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        productId: (json['product_id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        artisanId: (json['artisan_id'] ?? '').toString(),
        quantity: (json['quantity'] ?? 0) as int,
        price: ((json['price'] ?? 0) as num).toDouble(),
        lineTotal: ((json['line_total'] ?? 0) as num).toDouble(),
      );
}

class OrderModel {
  final String id;
  final String customerName;
  final List<OrderItem> items;
  final double totalAmount;
  final String paymentMethod;
  final String shippingAddress;
  final String status;
  final DateTime? placedAt;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.shippingAddress,
    required this.status,
    this.placedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: (json['_id'] ?? '').toString(),
        customerName: (json['customer_name'] ?? '').toString(),
        items: ((json['items'] ?? []) as List)
            .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        totalAmount: ((json['total_amount'] ?? 0) as num).toDouble(),
        paymentMethod: (json['payment_method'] ?? '').toString(),
        shippingAddress: (json['shipping_address'] ?? '').toString(),
        status: (json['status'] ?? 'pending').toString(),
        placedAt: json['placed_at'] == null
            ? null
            : DateTime.tryParse(json['placed_at'].toString()),
      );
}

class AdminDashboard {
  final int users;
  final int artisans;
  final int customers;
  final int products;
  final int orders;
  final double revenue;

  AdminDashboard({
    required this.users,
    required this.artisans,
    required this.customers,
    required this.products,
    required this.orders,
    required this.revenue,
  });

  factory AdminDashboard.fromJson(Map<String, dynamic> json) => AdminDashboard(
        users: (json['users'] ?? 0) as int,
        artisans: (json['artisans'] ?? 0) as int,
        customers: (json['customers'] ?? 0) as int,
        products: (json['products'] ?? 0) as int,
        orders: (json['orders'] ?? 0) as int,
        revenue: ((json['revenue'] ?? 0) as num).toDouble(),
      );
}
