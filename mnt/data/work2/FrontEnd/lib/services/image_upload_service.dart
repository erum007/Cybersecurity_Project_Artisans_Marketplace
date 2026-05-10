import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class ImageUploadService {
  ImageUploadService({required this.baseUrl, required this.token});

  final String baseUrl;
  final String? token;

  Future<String> uploadProductImage(XFile file) async {
    final uri = Uri.parse('$baseUrl/api/v1/uploads/image');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        if (token != null && token!.isNotEmpty) 'Authorization': 'Bearer ${token!}',
      });

    final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
    final parts = mimeType.split('/');
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType(parts.first, parts.length > 1 ? parts[1] : 'jpeg'),
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode >= 400) {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception((decoded['detail'] ?? 'Image upload failed').toString());
      } catch (_) {
        throw Exception('Image upload failed');
      }
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return (decoded['url'] ?? '').toString();
  }
}
