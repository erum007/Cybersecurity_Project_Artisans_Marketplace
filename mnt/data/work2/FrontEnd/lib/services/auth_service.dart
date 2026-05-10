import '../models/models.dart';
import 'api_client.dart';

class AuthResponse {
  final String token;
  final UserModel user;

  AuthResponse({required this.token, required this.user});
}

class AuthService {
  AuthService(this.api);

  final ApiClient api;

  Future<AuthResponse> login({required String email, required String password}) async {
    final data = await api.postJson('/api/v1/auth/login', {
      'email': email,
      'password': password,
    });
    final token = (data['access_token'] ?? '').toString();
    api.token = token;
    return AuthResponse(
      token: token,
      user: UserModel.fromJson(Map<String, dynamic>.from(data['user'] as Map)),
    );
  }

  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? address,
    String? city,
  }) async {
    final data = await api.postJson('/api/v1/auth/register', {
      'full_name': fullName,
      'email': email,
      'password': password,
      'role': role,
      'phone': phone,
      'address': address,
      'city': city,
    });
    final token = (data['access_token'] ?? '').toString();
    api.token = token;
    return AuthResponse(
      token: token,
      user: UserModel.fromJson(Map<String, dynamic>.from(data['user'] as Map)),
    );
  }
}
