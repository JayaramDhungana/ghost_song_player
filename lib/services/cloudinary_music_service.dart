import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class CloudinaryMusicService {
  static const String cloudName = 'gl3ydn8a';

  // Cloudinary Settings → Upload → Upload presets
  // बाट बनाएको UNSIGNED preset को नाम यहाँ राख्ने।
  static const String uploadPreset = 'ghost_music';

  const CloudinaryMusicService();

  String buildAudioUrl(String publicId) {
    return 'https://res.cloudinary.com/$cloudName/video/upload/$publicId';
  }

  String extractFolder(String fileName) {
  final normalized = fileName.replaceAll('\\', '/');

  final parts = normalized.split('/');

  if (parts.length < 2) {
    return 'Unknown';
  }

  return parts.first;
}

String extractTitle(String fileName) {
  final normalized = fileName.replaceAll('\\', '/');

  final fileNameOnly = normalized.split('/').last;

  final withoutExtension = fileNameOnly.replaceFirst(
    RegExp(r'\.[^.]+$'),
    '',
  );

  return withoutExtension
      .replaceAll('_', ' ')
      .trim();
}

  Future<String> uploadSong({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/video/upload',
    );

    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = uploadPreset;

    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: fileName),
    );

    final response = await request.send();

    final body = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Cloudinary upload failed: ${response.statusCode}\n$body',
      );
    }

    final data = jsonDecode(body) as Map<String, dynamic>;

    final secureUrl = data['secure_url'] as String?;

    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary did not return secure_url');
    }

    return secureUrl;
  }
}
