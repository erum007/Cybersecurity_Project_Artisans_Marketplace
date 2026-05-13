import '../models/models.dart';
import 'api_client.dart';

class AuthResponse {
  final String token;
  final String refreshToken;
  final UserModel user;

  AuthResponse({required this.token, required this.refreshToken, required this.user});
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
    final refreshToken = (data['refresh_token'] ?? '').toString();
    api.token = token;
    return AuthResponse(
      token: token,
      refreshToken: refreshToken,
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
    final refreshToken = (data['refresh_token'] ?? '').toString();
    api.token = token;
    return AuthResponse(
      token: token,
      refreshToken: refreshToken,
      user: UserModel.fromJson(Map<String, dynamic>.from(data['user'] as Map)),
    );
  }

  Future<String?> refreshAccessToken(String refreshToken) async {
    try {
      final data = await api.postJson('/api/v1/auth/token/refresh', {
        'refresh_token': refreshToken,
      });
      return (data['access_token'] ?? '').toString();
    } catch (_) {
      return null;
    }
  }

  Future<void> logout([String? refreshToken]) async {
    try {
      final body = <String, dynamic>{};
      if (refreshToken != null && refreshToken.isNotEmpty) {
        body['refresh_token'] = refreshToken;
      }
      await api.postJson('/api/v1/auth/logout', body);
    } catch (_) {
      // best effort
    }
  }

  Future<List<Map<String, dynamic>>> getSessions() async {
    final res = await api.getList('/api/v1/auth/sessions');
    final sessions = <Map<String, dynamic>>[];
    for (final item in res) {
      sessions.add(Map<String, dynamic>.from(item as Map<String, dynamic>));
    }
    return sessions;
  }

  Future<void> revokeSession(String sessionId) async {
    await api.deleteJson('/api/v1/auth/sessions/$sessionId');
  }

  Future<UserModel> updateMe(Map<String, dynamic> data) async {
    final res = await api.patchJson('/api/v1/auth/me', data);
    return UserModel.fromJson(Map<String, dynamic>.from(res as Map));
  }

  Future<UserModel> getMe() async {
    final res = await api.getJson('/api/v1/auth/me');
    return UserModel.fromJson(Map<String, dynamic>.from(res as Map));
  }
}
