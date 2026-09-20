import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'o5czrmxj';
  static const String uploadPreset = 'studyquest_profile';

  static Future<String?> uploadProfileImage(
    File image,
  ) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/'
        '$cloudName/image/upload',
      );

      final request = http.MultipartRequest(
        'POST',
        url,
      );

      request.fields['upload_preset'] =
          uploadPreset;

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
        ),
      );

      final response = await request.send();

      final responseBody =
          await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);

        return data['secure_url'];
      }

      print(
        'Cloudinary upload failed: $responseBody',
      );

      return null;
    } catch (e) {
      print('Cloudinary error: $e');
      return null;
    }
  }
}