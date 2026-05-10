import '../models/models.dart';
import 'api_client.dart';

class AdminService {
  AdminService(this.api);

  final ApiClient api;

  Future<AdminDashboard> dashboard() async {
    final data = await api.getJson('/api/v1/admin/dashboard');
    return AdminDashboard.fromJson(data);
  }
}
