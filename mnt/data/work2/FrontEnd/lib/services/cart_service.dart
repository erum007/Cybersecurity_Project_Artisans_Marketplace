import '../models/models.dart';
import 'api_client.dart';

class CartService {
  CartService(this.api);

  final ApiClient api;

  Future<CartData> getCart() async {
    final data = await api.getJson('/api/v1/cart');
    return CartData.fromJson(data);
  }

  Future<CartData> addToCart(String productId, {int quantity = 1}) async {
    final data = await api.postJson('/api/v1/cart/items', {
      'product_id': productId,
      'quantity': quantity,
    });
    return CartData.fromJson(data);
  }

  Future<CartData> removeFromCart(String productId) async {
    final data = await api.deleteJson('/api/v1/cart/items/$productId');
    return CartData.fromJson(data);
  }
}
