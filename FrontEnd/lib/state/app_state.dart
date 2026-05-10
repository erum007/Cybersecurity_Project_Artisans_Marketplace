// import 'package:flutter/foundation.dart';
// import 'package:image_picker/image_picker.dart';

// import '../models/models.dart';
// import '../services/admin_service.dart';
// import '../services/api_client.dart';
// import '../services/auth_service.dart';
// import '../services/cart_service.dart';
// import '../services/image_upload_service.dart';
// import '../services/order_service.dart';
// import '../services/product_service.dart';
// import 'session_store.dart';

// class AppState extends ChangeNotifier {
//   AppState()
//       : api = ApiClient(baseUrl: _baseUrl),
//         sessionStore = SessionStore(),
//         products = [],
//         sellerProducts = [],
//         orders = [],
//         artisanOrders = [],
//         cart = CartData(items: const [], total: 0),
//         categories = const ['Rugs', 'Clay Items', 'Crochet/Knit', 'Gift Items', 'Woodwork', 'Textiles', 'General'] {
//     authService = AuthService(api);
//     productService = ProductService(api);
//     cartService = CartService(api);
//     orderService = OrderService(api);
//     adminService = AdminService(api);
//   }

//   static const String _baseUrl = String.fromEnvironment(
//     'API_BASE_URL',
//     defaultValue: 'http://10.0.2.2:8000',
//   );

//   final ApiClient api;
//   final SessionStore sessionStore;
//   late final AuthService authService;
//   late final ProductService productService;
//   late final CartService cartService;
//   late final OrderService orderService;
//   late final AdminService adminService;

//   UserModel? user;
//   String? token;
//   bool isBusy = false;
//   bool isBootstrapping = true;
//   bool isUploadingImage = false;
//   String? error;
//   List<Product> products;
//   List<Product> sellerProducts;
//   List<OrderModel> orders;
//   List<OrderModel> artisanOrders;
//   CartData cart;
//   AdminDashboard? dashboard;
//   List<AdminUser> adminUsers = [];
//   List<ArtisanRevenue> artisanRevenues = [];
//   final List<String> categories;

//   bool get isLoggedIn => token != null && token!.isNotEmpty;
//   bool get isCustomer => user?.role == 'customer';
//   bool get isArtisan => user?.role == 'artisan';
//   bool get isAdmin => user?.role == 'admin';
//   String get baseUrl => _baseUrl;

//   Future<void> bootstrap() async {
//     try {
//       final restored = await sessionStore.restore();
//       token = restored.token;
//       user = restored.user;
//       api.token = token;
//       if (isLoggedIn) {
//         await refreshAll();
//       }
//     } catch (_) {
//       await sessionStore.clear();
//       token = null;
//       user = null;
//       api.token = null;
//     } finally {
//       isBootstrapping = false;
//       notifyListeners();
//     }
//   }

//   Future<void> login(String email, String password) async {
//     await _run(() async {
//       final result = await authService.login(email: email, password: password);
//       token = result.token;
//       user = result.user;
//       api.token = token;
//       await sessionStore.save(token: result.token, user: result.user);
//       await refreshAll();
//     });
//   }

//   Future<void> register({
//     required String fullName,
//     required String email,
//     required String password,
//     required String role,
//     String? phone,
//     String? address,
//     String? city,
//   }) async {
//     await _run(() async {
//       final result = await authService.register(
//         fullName: fullName,
//         email: email,
//         password: password,
//         role: role,
//         phone: phone,
//         address: address,
//         city: city,
//       );
//       token = result.token;
//       user = result.user;
//       api.token = token;
//       await sessionStore.save(token: result.token, user: result.user);
//       await refreshAll();
//     });
//   }

//   Future<void> updateProfile({
//     String? fullName,
//     String? phone,
//     String? address,
//     String? city,
//     String? postalCode,
//     String? email,
//     String? password,
//     String? bio,
//     String? profilePicture,
//   }) async {
//     await _run(() async {
//       final updatedUser = await authService.updateMe({
//         if (fullName != null) 'full_name': fullName,
//         if (phone != null) 'phone': phone,
//         if (address != null) 'address': address,
//         if (city != null) 'city': city,
//         if (postalCode != null) 'postal_code': postalCode,
//         if (email != null) 'email': email,
//         if (password != null) 'password': password,
//         if (bio != null) 'bio': bio,
//         if (profilePicture != null) 'profile_picture': profilePicture,
//       });
//       user = updatedUser;
//       await sessionStore.save(token: token!, user: user!);
//       notifyListeners();
//     });
//   }

//   Future<String> uploadProfilePicture(XFile file) async {
//     isUploadingImage = true;
//     error = null;
//     notifyListeners();
//     try {
//       final service = ImageUploadService(baseUrl: _baseUrl, token: token);
//       final relativeUrl = await service.uploadProductImage(file); // Reusing product upload for now or specialized
//       final fullUrl = relativeUrl.startsWith('http') ? relativeUrl : '$_baseUrl$relativeUrl';
//       await updateProfile(profilePicture: fullUrl);
//       return fullUrl;
//     } catch (e) {
//       error = e.toString().replaceFirst('Exception: ', '');
//       rethrow;
//     } finally {
//       isUploadingImage = false;
//       notifyListeners();
//     }
//   }

//   Future<void> loadProfile() async {
//     await _run(() async {
//       user = await authService.getMe();
//       await sessionStore.save(token: token!, user: user!);
//     }, silent: true);
//   }

//   Future<String> uploadProductImage(XFile file) async {
//     isUploadingImage = true;
//     error = null;
//     notifyListeners();
//     try {
//       final service = ImageUploadService(baseUrl: _baseUrl, token: token);
//       final relativeUrl = await service.uploadProductImage(file);
//       if (relativeUrl.startsWith('http')) return relativeUrl;
//       return '$_baseUrl$relativeUrl';
//     } catch (e) {
//       error = e.toString().replaceFirst('Exception: ', '');
//       rethrow;
//     } finally {
//       isUploadingImage = false;
//       notifyListeners();
//     }
//   }

//   Future<void> loadProducts({String? search, String? category}) async {
//     await _run(() async {
//       products = await productService.fetchProducts(search: search, category: category == 'All' ? null : category);
//       if (isArtisan) {
//         sellerProducts = products.where((p) => p.artisanId == user!.id).toList();
//       }
//     }, silent: true);
//   }

//   Future<void> refreshAll() async {
//     final tasks = <Future<void>>[loadProducts()];

//     if (isCustomer) {
//       tasks.add(refreshCart());
//       tasks.add(loadMyOrders());
//     }
//     if (isArtisan) {
//       tasks.add(loadArtisanOrders());
//     }
//     if (isAdmin) {
//       tasks.add(loadAdminDashboard());
//     }

//     await Future.wait(tasks);
//   }

//   Future<void> refreshCart() async {
//     if (!isCustomer && !isAdmin) return;
//     await _run(() async {
//       cart = await cartService.getCart();
//     }, silent: true);
//   }

//   Future<void> addToCart(Product product, {int quantity = 1}) async {
//     await _run(() async {
//       cart = await cartService.addToCart(product.id, quantity: quantity);
//     });
//   }

//   Future<void> removeFromCart(String productId) async {
//     await _run(() async {
//       cart = await cartService.removeFromCart(productId);
//     });
//   }

//   Future<void> checkout({required String paymentMethod, required String shippingAddress}) async {
//     await _run(() async {
//       await orderService.checkout(paymentMethod: paymentMethod, shippingAddress: shippingAddress);
//       cart = CartData(items: const [], total: 0);
//       await loadMyOrders();
//       await refreshCart();
//       await loadProducts();
//     });
//   }

//   Future<void> loadMyOrders() async {
//     if (!isCustomer && !isAdmin) return;
//     await _run(() async {
//       orders = await orderService.myOrders();
//     }, silent: true);
//   }

//   Future<void> loadArtisanOrders() async {
//     if (!isArtisan && !isAdmin) return;
//     await _run(() async {
//       artisanOrders = await orderService.artisanOrders();
//     }, silent: true);
//   }

//   Future<void> updateOrderStatus(String orderId, String status) async {
//     await _run(() async {
//       await orderService.updateOrderStatus(orderId, status);
//       await loadArtisanOrders();
//     });
//   }

//   Future<void> createProduct({
//     required String name,
//     required String description,
//     required double price,
//     required int stock,
//     required String category,
//     required List<String> imageUrls,
//   }) async {
//     await _run(() async {
//       await productService.createProduct(
//         name: name,
//         description: description,
//         price: price,
//         stock: stock,
//         category: category,
//         imageUrls: imageUrls,
//       );
//       await loadProducts();
//     });
//   }

//   Future<void> updateProduct({
//     required String id,
//     required String name,
//     required String description,
//     required double price,
//     required int stock,
//     required String category,
//     required List<String> imageUrls,
//   }) async {
//     await _run(() async {
//       await productService.updateProduct(
//         id: id,
//         name: name,
//         description: description,
//         price: price,
//         stock: stock,
//         category: category,
//         imageUrls: imageUrls,
//       );
//       await loadProducts();
//     });
//   }

//   Future<void> deleteProduct(String id) async {
//     await _run(() async {
//       await productService.deleteProduct(id);
//       await loadProducts();
//     });
//   }

//   Future<void> addReview(String productId, {required double rating, required String comment}) async {
//     await _run(() async {
//       await productService.addReview(productId, rating: rating, comment: comment);
//       await loadProducts();
//       await loadMyOrders();
//     });
//   }

//   Future<void> loadAdminDashboard() async {
//     if (!isAdmin) return;
//     await _run(() async {
//       dashboard = await adminService.dashboard();
//       adminUsers = await adminService.listUsers();
//       artisanRevenues = await adminService.artisanRevenue();
//     }, silent: true);
//   }

//   Future<void> logout() async {
//     isBusy = false;
//     error = null;
//     token = null;
//     user = null;
//     api.token = null;
//     products = [];
//     sellerProducts = [];
//     orders = [];
//     artisanOrders = [];
//     cart = CartData(items: const [], total: 0);
//     dashboard = null;
//     adminUsers = [];
//     artisanRevenues = [];
//     await sessionStore.clear();
//     notifyListeners();
//   }

//   Future<void> _run(Future<void> Function() task, {bool silent = false}) async {
//     if (!silent) {
//       isBusy = true;
//       error = null;
//       notifyListeners();
//     }
//     try {
//       await task();
//       error = null;
//     } catch (e) {
//       error = e.toString().replaceFirst('Exception: ', '');
//       rethrow;
//     } finally {
//       isBusy = false;
//       notifyListeners();
//     }
//   }
// }
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../services/admin_service.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/image_upload_service.dart';
import '../services/order_service.dart';
import '../services/product_service.dart';
import 'session_store.dart';

class AppState extends ChangeNotifier {
  AppState()
      : api = ApiClient(baseUrl: _baseUrl),
        sessionStore = SessionStore(),
        products = [],
        sellerProducts = [],
        orders = [],
        artisanOrders = [],
        cart = CartData(items: const [], total: 0),
        categories = const ['Rugs', 'Clay Items', 'Crochet/Knit', 'Gift Items', 'Woodwork', 'Textiles', 'General'] {
    authService = AuthService(api);
    productService = ProductService(api);
    cartService = CartService(api);
    orderService = OrderService(api);
    adminService = AdminService(api);
  }

  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  final ApiClient api;
  final SessionStore sessionStore;
  late final AuthService authService;
  late final ProductService productService;
  late final CartService cartService;
  late final OrderService orderService;
  late final AdminService adminService;

  UserModel? user;
  String? token;
  bool isBusy = false;
  bool isBootstrapping = true;
  bool isUploadingImage = false;
  String? error;
  List<Product> products;
  List<Product> sellerProducts;
  List<OrderModel> orders;
  List<OrderModel> artisanOrders;
  CartData cart;
  AdminDashboard? dashboard;
  // Admin-specific lists
  List<AdminUser> adminUsers = [];
  List<ArtisanRevenue> artisanRevenues = [];
  final List<String> categories;

  bool get isLoggedIn => token != null && token!.isNotEmpty;
  bool get isCustomer => user?.role == 'customer';
  bool get isArtisan => user?.role == 'artisan';
  bool get isAdmin => user?.role == 'admin';
  String get baseUrl => _baseUrl;

  Future<void> bootstrap() async {
    try {
      final restored = await sessionStore.restore();
      token = restored.token;
      user = restored.user;
      api.token = token;
      if (isLoggedIn) {
        await refreshAll();
      }
    } catch (_) {
      await sessionStore.clear();
      token = null;
      user = null;
      api.token = null;
    } finally {
      isBootstrapping = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    await _run(() async {
      final result = await authService.login(email: email, password: password);
      token = result.token;
      user = result.user;
      api.token = token;
      await sessionStore.save(token: result.token, user: result.user);
      await refreshAll();
    });
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? address,
    String? city,
  }) async {
    await _run(() async {
      final result = await authService.register(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
        phone: phone,
        address: address,
        city: city,
      );
      token = result.token;
      user = result.user;
      api.token = token;
      await sessionStore.save(token: result.token, user: result.user);
      await refreshAll();
    });
  }

  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
    String? email,
    String? password,
    String? bio,
    String? profilePicture,
  }) async {
    await _run(() async {
      final updatedUser = await authService.updateMe({
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (postalCode != null) 'postal_code': postalCode,
        if (email != null) 'email': email,
        if (password != null) 'password': password,
        if (bio != null) 'bio': bio,
        if (profilePicture != null) 'profile_picture': profilePicture,
      });
      user = updatedUser;
      await sessionStore.save(token: token!, user: user!);
      notifyListeners();
    });
  }

  Future<String> uploadProfilePicture(XFile file) async {
    isUploadingImage = true;
    error = null;
    notifyListeners();
    try {
      final service = ImageUploadService(baseUrl: _baseUrl, token: token);
      final relativeUrl = await service.uploadProductImage(file);
      final fullUrl = relativeUrl.startsWith('http') ? relativeUrl : '$_baseUrl$relativeUrl';
      // Always store 127.0.0.1 in the database regardless of the environment
      final dbUrl = fullUrl.replaceAll('10.0.2.2', '127.0.0.1');
      await updateProfile(profilePicture: dbUrl);
      return dbUrl;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      isUploadingImage = false;
      notifyListeners();
    }
  }

  Future<void> loadProfile() async {
    await _run(() async {
      user = await authService.getMe();
      await sessionStore.save(token: token!, user: user!);
    }, silent: true);
  }

  Future<String> uploadProductImage(XFile file) async {
    isUploadingImage = true;
    error = null;
    notifyListeners();
    try {
      final service = ImageUploadService(baseUrl: _baseUrl, token: token);
      final relativeUrl = await service.uploadProductImage(file);
      final fullUrl = relativeUrl.startsWith('http') ? relativeUrl : '$_baseUrl$relativeUrl';
      // Always store 127.0.0.1 in the database regardless of the environment
      return fullUrl.replaceAll('10.0.2.2', '127.0.0.1');
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      isUploadingImage = false;
      notifyListeners();
    }
  }

  Future<void> loadProducts({String? search, String? category}) async {
    await _run(() async {
      products = await productService.fetchProducts(search: search, category: category == 'All' ? null : category);
      if (isArtisan) {
        sellerProducts = products.where((p) => p.artisanId == user!.id).toList();
      }
    }, silent: true);
  }

  Future<void> refreshAll() async {
    final tasks = <Future<void>>[loadProducts()];

    if (isCustomer) {
      tasks.add(refreshCart());
      tasks.add(loadMyOrders());
    }
    if (isArtisan) {
      tasks.add(loadArtisanOrders());
    }
    if (isAdmin) {
      tasks.add(loadAdminDashboard());
    }

    await Future.wait(tasks);
  }

  Future<void> refreshCart() async {
    if (!isCustomer && !isAdmin) return;
    await _run(() async {
      cart = await cartService.getCart();
    }, silent: true);
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    await _run(() async {
      cart = await cartService.addToCart(product.id, quantity: quantity);
    });
  }

  Future<void> removeFromCart(String productId) async {
    await _run(() async {
      cart = await cartService.removeFromCart(productId);
    });
  }

  Future<void> updateCartQuantity(String productId, int quantity) async {
    await _run(() async {
      if (quantity <= 0) {
        cart = await cartService.removeFromCart(productId);
      } else {
        cart = await cartService.updateCartItemQuantity(productId, quantity);
      }
    }, silent: true);
  }

  Future<void> checkout({required String paymentMethod, required String shippingAddress}) async {
    await _run(() async {
      await orderService.checkout(paymentMethod: paymentMethod, shippingAddress: shippingAddress);
      cart = CartData(items: const [], total: 0);
      await loadMyOrders();
      await refreshCart();
      await loadProducts();
    });
  }

  Future<void> loadMyOrders() async {
    if (!isCustomer && !isAdmin) return;
    await _run(() async {
      orders = await orderService.myOrders();
    }, silent: true);
  }

  Future<void> loadArtisanOrders() async {
    if (!isArtisan && !isAdmin) return;
    await _run(() async {
      artisanOrders = await orderService.artisanOrders();
    }, silent: true);
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _run(() async {
      await orderService.updateOrderStatus(orderId, status);
      await loadArtisanOrders();
    });
  }

  Future<void> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    required List<String> imageUrls,
  }) async {
    await _run(() async {
      await productService.createProduct(
        name: name,
        description: description,
        price: price,
        stock: stock,
        category: category,
        imageUrls: imageUrls,
      );
      await loadProducts();
    });
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    required List<String> imageUrls,
  }) async {
    await _run(() async {
      await productService.updateProduct(
        id: id,
        name: name,
        description: description,
        price: price,
        stock: stock,
        category: category,
        imageUrls: imageUrls,
      );
      await loadProducts();
    });
  }

  Future<void> deleteProduct(String id) async {
    await _run(() async {
      await productService.deleteProduct(id);
      await loadProducts();
    });
  }

  Future<void> addReview(String productId, {required double rating, required String comment}) async {
    await _run(() async {
      await productService.addReview(productId, rating: rating, comment: comment);
      await loadProducts();
      await loadMyOrders();
    });
  }

  Future<void> loadAdminDashboard() async {
    if (!isAdmin) return;
    await _run(() async {
      dashboard = await adminService.dashboard();
      adminUsers = await adminService.listUsers();
      artisanRevenues = await adminService.artisanRevenue();
    }, silent: true);
  }

  Future<void> logout() async {
    isBusy = false;
    error = null;
    token = null;
    user = null;
    api.token = null;
    products = [];
    sellerProducts = [];
    orders = [];
    artisanOrders = [];
    cart = CartData(items: const [], total: 0);
    dashboard = null;
    adminUsers = [];
    artisanRevenues = [];
    await sessionStore.clear();
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() task, {bool silent = false}) async {
    if (!silent) {
      isBusy = true;
      error = null;
      notifyListeners();
    }
    try {
      await task();
      error = null;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }
}