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

  Future<String> uploadProductImage(XFile file) async {
    isUploadingImage = true;
    error = null;
    notifyListeners();
    try {
      final service = ImageUploadService(baseUrl: _baseUrl, token: token);
      final relativeUrl = await service.uploadProductImage(file);
      if (relativeUrl.startsWith('http')) return relativeUrl;
      return '$_baseUrl$relativeUrl';
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
    await loadProducts();
    if (isCustomer) {
      await refreshCart();
      await loadMyOrders();
    }
    if (isArtisan) {
      await loadArtisanOrders();
    }
    if (isAdmin) {
      await loadAdminDashboard();
    }
  }

  Future<void> refreshCart() async {
    if (!isCustomer && !isAdmin) return;
    await _run(() async {
      cart = await cartService.getCart();
    }, silent: true);
  }

  Future<void> addToCart(Product product) async {
    await _run(() async {
      cart = await cartService.addToCart(product.id);
    });
  }

  Future<void> removeFromCart(String productId) async {
    await _run(() async {
      cart = await cartService.removeFromCart(productId);
    });
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
    required String imageUrl,
  }) async {
    await _run(() async {
      await productService.createProduct(
        name: name,
        description: description,
        price: price,
        stock: stock,
        category: category,
        imageUrl: imageUrl,
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
    required String imageUrl,
  }) async {
    await _run(() async {
      await productService.updateProduct(
        id: id,
        name: name,
        description: description,
        price: price,
        stock: stock,
        category: category,
        imageUrl: imageUrl,
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

  Future<void> loadAdminDashboard() async {
    if (!isAdmin) return;
    await _run(() async {
      dashboard = await adminService.dashboard();
    }, silent: true);
  }

  Future<void> logout() async {
    token = null;
    user = null;
    api.token = null;
    products = [];
    sellerProducts = [];
    orders = [];
    artisanOrders = [];
    cart = CartData(items: const [], total: 0);
    dashboard = null;
    error = null;
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
