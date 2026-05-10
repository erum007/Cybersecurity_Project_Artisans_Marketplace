import '../models/models.dart';
import 'api_client.dart';

class AdminService {
  AdminService(this.api);

  final ApiClient api;

  Future<AdminDashboard> dashboard() async {
    final data = await api.getJson('/api/v1/admin/dashboard');
    return AdminDashboard.fromJson(data);
  }

  Future<List<AdminUser>> listUsers() async {
    final data = await api.getList('/api/v1/admin/users');
    return data
        .map((e) => AdminUser.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<ArtisanRevenue>> artisanRevenue() async {
    final data = await api.getList('/api/v1/admin/artisan-revenue');
    return data
        .map((e) => ArtisanRevenue.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}