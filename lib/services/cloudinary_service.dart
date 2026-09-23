import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // Get this from your Cloudinary Dashboard
  static const String cloudName = 'o5czrmxj';

  // This MUST exactly match your screenshot
  static const String uploadPreset = 'studyquest_profile';

  static Future<String?> uploadImage(File imageFile) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest(
        'POST',
        url,
      );

      // UNSIGNED UPLOAD
      request.fields['upload_preset'] = uploadPreset;

      // IMAGE
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      final response = await request.send();

      final responseBody =
          await response.stream.bytesToString();

      debugPrint('================ CLOUDINARY ================');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Cloud Name: $cloudName');
      debugPrint('Upload Preset: $uploadPreset');
      debugPrint('Response: $responseBody');
      debugPrint('============================================');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(responseBody);

        final String? secureUrl =
            data['secure_url']?.toString();

        debugPrint('Cloudinary URL: $secureUrl');

        return secureUrl;
      }

      return null;
    } catch (e) {
      debugPrint('Cloudinary Exception: $e');
      return null;
    }
  }
}