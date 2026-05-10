class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? phone;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? bio;
  final String? profilePicture;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.city,
    this.postalCode,
    this.bio,
    this.profilePicture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        fullName: (json['full_name'] ?? json['name'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        role: (json['role'] ?? 'customer').toString(),
        phone: (json['phone'] ?? json['phoneNumber'])?.toString(),
        address: json['address']?.toString(),
        city: json['city']?.toString(),
        postalCode: (json['postal_code'] ?? json['postalCode'])?.toString(),
        bio: json['bio']?.toString(),
        profilePicture: (json['profile_picture'] ?? json['profilePicture'])?.toString(),
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'full_name': fullName,
        'email': email,
        'role': role,
        'phone': phone,
        'address': address,
        'city': city,
        'postal_code': postalCode,
        'bio': bio,
        'profile_picture': profilePicture,
      };

  // Compatibility for older screens
  String get name => fullName;
  String get bioText => bio ?? 'No bio provided.';
  String get badge => 'New Member';
  String? get phoneNumber => phone;
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
  final List<String> imageUrls;
  final bool isActive;
  final List<Review> reviews;
  
  // Additional fields for UI compatibility
  final double rating;
  final int reviewCount;
  final String currency;
  final List<String> sizes;
  final List<String> categories;
  final String shopId;

  Product({
    required this.id,
    required this.artisanId,
    required this.artisanName,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.imageUrls,
    required this.isActive,
    this.reviews = const [],
    this.rating = 4.5,
    this.reviewCount = 0,
    this.currency = 'Rs. ',
    this.sizes = const ['S', 'M', 'L'],
    this.categories = const [],
    this.shopId = '',
  });

  String get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> urls = [];
    if (json['image_urls'] != null) {
      urls = List<String>.from(json['image_urls']);
    } else if (json['image_url'] != null && json['image_url'].toString().isNotEmpty) {
      urls = [json['image_url'].toString()];
    }

    return Product(
      id: (json['_id'] ?? '').toString(),
      artisanId: (json['artisan_id'] ?? '').toString(),
      artisanName: (json['artisan_name'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: ((json['price'] ?? 0) as num).toDouble(),
      stock: (json['stock'] ?? 0) as int,
      category: (json['category'] ?? 'General').toString(),
      imageUrls: urls,
      isActive: (json['is_active'] ?? true) as bool,
      reviews: (json['reviews'] as List?)?.map((e) => Review.fromJson(Map<String, dynamic>.from(e as Map))).toList() ?? [],
      rating: ((json['rating'] ?? 4.5) as num).toDouble(),
      reviewCount: (json['review_count'] ?? 0) as int,
      currency: (json['currency'] ?? 'Rs. ').toString(),
      sizes: (json['sizes'] as List?)?.map((e) => e.toString()).toList() ?? const ['S', 'M', 'L'],
      categories: (json['categories'] as List?)?.map((e) => e.toString()).toList() ?? [],
      shopId: (json['shop_id'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'price': price,
    'stock': stock,
    'category': category,
    'image_urls': imageUrls,
    'is_active': isActive,
  };
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

class AdminUser {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String phone;
  final String city;
  final String profilePicture;

  AdminUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.phone,
    required this.city,
    required this.profilePicture,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
        id: (json['id'] ?? '').toString(),
        fullName: (json['full_name'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        role: (json['role'] ?? 'customer').toString(),
        phone: (json['phone'] ?? '').toString(),
        city: (json['city'] ?? '').toString(),
        profilePicture: (json['profile_picture'] ?? '').toString(),
      );
}

class ArtisanRevenue {
  final String id;
  final String fullName;
  final String email;
  final String city;
  final String profilePicture;
  final int productCount;
  final int orderCount;
  final double revenue;

  ArtisanRevenue({
    required this.id,
    required this.fullName,
    required this.email,
    required this.city,
    required this.profilePicture,
    required this.productCount,
    required this.orderCount,
    required this.revenue,
  });

  factory ArtisanRevenue.fromJson(Map<String, dynamic> json) => ArtisanRevenue(
        id: (json['id'] ?? '').toString(),
        fullName: (json['full_name'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        city: (json['city'] ?? '').toString(),
        profilePicture: (json['profile_picture'] ?? '').toString(),
        productCount: (json['product_count'] ?? 0) as int,
        orderCount: (json['order_count'] ?? 0) as int,
        revenue: ((json['revenue'] ?? 0) as num).toDouble(),
      );
}

class Shop {
  final String id;
  final String name;
  final String imageUrl;
  final String ownerImageUrl;
  final String bio;

  Shop({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.ownerImageUrl,
    required this.bio,
  });
}

class Review {
  final String title;
  final double rating;
  final String userName;
  final DateTime date;
  final String comment;

  Review({
    required this.title,
    required this.rating,
    required this.userName,
    required this.date,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        title: (json['title'] ?? '').toString(),
        rating: ((json['rating'] ?? 0) as num).toDouble(),
        userName: (json['user_name'] ?? json['user']?['full_name'] ?? 'Anonymous').toString(),
        date: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
        comment: (json['comment'] ?? '').toString(),
      );
}

class Order {
  final String id;
  final DateTime date;
  final String status;
  final String deliveryStatus;
  final double progress;

  Order({
    required this.id,
    required this.date,
    required this.status,
    required this.deliveryStatus,
    required this.progress,
  });
}

class SampleData {
  static final currentUser = UserModel(
    id: '1',
    fullName: 'Julian Rivers',
    email: 'julian@example.com',
    role: 'Artisan',
    phone: '+1 234 567 890',
    address: '123 Artisan Lane',
    city: 'Craftsville',
    postalCode: '12345',
  );

  static final categories = ['Rugs', 'Crockery', 'Mugs', 'Wall Art'];

  static final products = [
    Product(
      id: 'p1',
      artisanId: 'a1',
      artisanName: 'Artisan 1',
      name: 'Red Persian Rug',
      description: 'A beautiful hand-woven red Persian rug.',
      price: 70000,
      stock: 5,
      category: 'Rugs',
      imageUrls: ['https://images.unsplash.com/photo-1600166898405-da9535204843?w=400'],
      isActive: true,
      rating: 4.8,
      reviewCount: 12,
      categories: ['Rugs'],
      shopId: 's1',
    ),
    Product(
      id: 'p2',
      artisanId: 'a2',
      artisanName: 'Artisan 2',
      name: 'Crockery Set',
      description: 'Elegant ceramic crockery set.',
      price: 10000,
      stock: 10,
      category: 'Crockery',
      imageUrls: ['https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=400'],
      isActive: true,
      rating: 4.5,
      reviewCount: 8,
      categories: ['Crockery'],
      shopId: 's2',
    ),
  ];

  static final shops = [
    Shop(
      id: 's1',
      name: 'Persian Weaves',
      imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400',
      ownerImageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
      bio: 'Authentic hand-woven rugs from the heart of Persia.',
    ),
    Shop(
      id: 's2',
      name: 'Ceramic Haven',
      imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
      ownerImageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      bio: 'Handcrafted ceramics for your modern home.',
    ),
  ];

  static final reviews = [
    Review(
      title: 'Excellent Quality',
      rating: 5,
      userName: 'Jane Cooper',
      date: DateTime.now().subtract(const Duration(days: 2)),
      comment: 'Loved it!! Ordering Again!!',
    ),
    Review(
      title: 'Beautiful Design',
      rating: 4.5,
      userName: 'James Harrid',
      date: DateTime.now().subtract(const Duration(days: 5)),
      comment: 'Slightly Late Delivery, but Loved it...',
    ),
  ];

  static final orders = [
    Order(
      id: 'ORD123',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: 'In Progress',
      deliveryStatus: 'On its way',
      progress: 0.6,
    ),
    Order(
      id: 'ORD456',
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: 'Completed',
      deliveryStatus: 'Delivered',
      progress: 1.0,
    ),
  ];
}