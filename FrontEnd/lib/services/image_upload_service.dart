// import 'dart:convert';
// import 'dart:developer'; // For logging
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:mime/mime.dart';



// class ImageUploadService {
//   ImageUploadService({required this.baseUrl, required this.token});

//   final String baseUrl;
//   final String? token;

//   Future<String> uploadProductImage(XFile file) async {
//     final uri = Uri.parse('$baseUrl/api/v1/uploads/image');

//     // 1. Log the attempt for transparency
//     log('Attempting POST to: $uri');

//     final request = http.MultipartRequest('POST', uri)
//       ..headers.addAll({
//         if (token != null && token!.isNotEmpty) 'Authorization': 'Bearer $token',
//         'Accept': 'application/json', // Explicitly ask for JSON
//       });

//     final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
//     final parts = mimeType.split('/');

//     request.files.add(
//       await http.MultipartFile.fromPath(
//         'file', // Ensure this matches your FastAPI argument name
//         file.path,
//         filename: file.name,
//         contentType: MediaType(parts.first, parts.length > 1 ? parts[1] : 'jpeg'),
//       ),
//     );

//     final streamed = await request.send();
//     final response = await http.Response.fromStream(streamed);

//     // 2. Comprehensive Error Handling
//     if (response.statusCode >= 400) {
//       log('Upload failed with status: ${response.statusCode}');
//       log('Response body: ${response.body}');

//       if (response.statusCode == 405) {
//         throw Exception(
//             'Method Not Allowed (405): Check if your URL is correct and lacks a trailing slash. '
//                 'Attempted URL: $uri'
//         );
//       }

//       try {
//         final decoded = jsonDecode(response.body) as Map<String, dynamic>;
//         // This will now capture your FastAPI detail: "Only JPG, PNG..." etc.
//         final detail = decoded['detail'];

//         if (detail is String) {
//           throw Exception('Server Error: $detail');
//         } else if (detail is List) {
//           // FastAPI validation errors (pydantic) are often lists
//           throw Exception('Validation Error: ${jsonEncode(detail)}');
//         }

//         throw Exception('Image upload failed (${response.statusCode})');
//       } catch (e) {
//         if (e is Exception) rethrow;
//         throw Exception('Upload failed: ${response.body}');
//       }
//     }

//     final decoded = jsonDecode(response.body) as Map<String, dynamic>;
//     return (decoded['url'] ?? '').toString();
//   }
// }

// // import 'package:http/http.dart' as http;
// // import 'package:http_parser/http_parser.dart';
// // import 'package:image_picker/image_picker.dart';

// // Future<String> uploadImage(XFile file) async {
// //   final uri = Uri.parse('http://127.0.0.1:8000/upload');

// //   final request = http.MultipartRequest('POST', uri);

// //   final bytes = await file.readAsBytes();

// //   request.files.add(
// //     http.MultipartFile.fromBytes(
// //       'file',
// //       bytes,
// //       filename: file.name,
// //       contentType: MediaType('image', 'jpeg'),
// //     ),
// //   );

// //   final response = await request.send();

// //   if (response.statusCode != 200) {
// //     throw Exception('Upload failed');
// //   }

// //   final responseData = await response.stream.bytesToString();
// //   return responseData; // usually URL
// // }

import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data'; // <--- Add this line
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

    log('Attempting POST to: $uri');

    // 1. Read file as bytes (Works on Web and Mobile)
    final Uint8List fileBytes = await file.readAsBytes();

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        if (token != null && token!.isNotEmpty) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

    // 2. Determine MimeType
    // Note: lookupMimeType might return null on web for some files, 
    // so we provide a sensible fallback.
    final mimeType = lookupMimeType(file.name) ?? 'image/jpeg';
    final parts = mimeType.split('/');

    // 3. Use fromBytes instead of fromPath
    request.files.add(
      http.MultipartFile.fromBytes(
        'file', 
        fileBytes,
        filename: file.name,
        contentType: MediaType(parts.first, parts.last),
      ),
    );

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      // 4. Comprehensive Error Handling
      if (response.statusCode >= 400) {
        log('Upload failed with status: ${response.statusCode}');
        log('Response body: ${response.body}');

        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final detail = decoded['detail'];

        if (detail is String) {
          throw Exception(detail);
        } else if (detail is List) {
          throw Exception('Validation Error: ${jsonEncode(detail)}');
        }
        
        throw Exception('Image upload failed (${response.statusCode})');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return (decoded['url'] ?? '').toString();
      
    } catch (e) {
      log('Error during upload: $e');
      rethrow;
    }
  }
}