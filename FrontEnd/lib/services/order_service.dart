import '../models/models.dart';
import 'api_client.dart';

class OrderService {
  OrderService(this.api);

  final ApiClient api;

  Future<OrderModel> checkout({required String paymentMethod, required String shippingAddress}) async {
    final data = await api.postJson('/api/v1/orders/checkout', {
      'payment_method': paymentMethod,
      'shipping_address': shippingAddress,
    });
    return OrderModel.fromJson(data);
  }

  Future<List<OrderModel>> myOrders() async {
    final data = await api.getList('/api/v1/orders/me');
    return data.map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<List<OrderModel>> artisanOrders() async {
    final data = await api.getList('/api/v1/orders/artisan');
    return data.map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<OrderModel> updateOrderStatus(String id, String status) async {
    final data = await api.patchJson('/api/v1/orders/$id/status', {'status': status});
    return OrderModel.fromJson(data);
  }
}
