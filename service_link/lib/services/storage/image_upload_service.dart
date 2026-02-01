import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_link/util/logger.dart';

class ImageUploadService {
  final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery or camera
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      // On Web, camera may fallback to gallery
      if (kIsWeb && source == ImageSource.camera) {
        source = ImageSource.gallery;
      }

      return await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error picking image', e, stackTrace);
      return null;
    }
  }

  /// Show dialog to choose image source
  Future<XFile?> pickImageWithSource(BuildContext context) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return null;
    return await pickImage(source: source);
  }

  /// Upload service image (Web + Mobile)
  Future<String?> uploadServiceImage(XFile imageFile, String serviceId) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Str = base64Encode(bytes);
      final fileUrl =
          'data:image/${imageFile.name.split('.').last};base64,$base64Str';
      return fileUrl; // return base64 data URI
    } catch (e, stackTrace) {
      AppLogger.error('Error uploading service image', e, stackTrace);
      return null;
    }
  }

  /// Upload profile picture (Web + Mobile)
  Future<String?> uploadProfilePicture(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Str = base64Encode(bytes);
      final fileUrl =
          'data:image/${imageFile.name.split('.').last};base64,$base64Str';
      return fileUrl;
    } catch (e, stackTrace) {
      AppLogger.error('Error uploading profile picture', e, stackTrace);
      return null;
    }
  }
}
