import '../models/models.dart';
import 'api_client.dart';

class ProductService {
  ProductService(this.api);

  final ApiClient api;

  Future<List<Product>> fetchProducts({String? search, String? category}) async {
    final data = await api.getJson(
      '/api/v1/products',
      query: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (category != null && category.trim().isNotEmpty) 'category': category.trim(),
      },
    );
    return ((data['items'] ?? []) as List)
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Product> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    required String imageUrl,
  }) async {
    final data = await api.postJson('/api/v1/products', {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'image_url': imageUrl,
    });
    return Product.fromJson(data);
  }

  Future<Product> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    required String imageUrl,
  }) async {
    final data = await api.putJson('/api/v1/products/$id', {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'image_url': imageUrl,
    });
    return Product.fromJson(data);
  }

  Future<void> deleteProduct(String id) async {
    await api.deleteJson('/api/v1/products/$id');
  }
}
