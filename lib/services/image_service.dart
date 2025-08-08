import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Service for handling image operations including selection, conversion to base64,
/// and validation for profile pictures and guide images
class ImageService {
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB limit
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];

  /// Picks an image from gallery or camera and converts it to base64
  static Future<String?> pickAndConvertImage({
    required ImageSource source,
    int maxWidth = 1024,
    int maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (image == null) {
        return null; // User cancelled selection
      }

      // Validate file size
      final file = File(image.path);
      final fileSize = await file.length();

      if (fileSize > maxImageSizeBytes) {
        throw Exception('Image size must be less than 5MB');
      }

      // Validate file extension
      final extension = image.name.split('.').last.toLowerCase();
      if (!allowedExtensions.contains(extension)) {
        throw Exception('Only JPG, JPEG, PNG, and GIF files are allowed');
      }

      // Convert to base64
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);

      // Create data URL with proper MIME type
      final mimeType = _getMimeType(extension);
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      debugPrint('Error picking and converting image: $e');
      rethrow;
    }
  }

  /// Shows image source selection dialog (Camera vs Gallery)
  static Future<String?> showImageSourceDialog(BuildContext context) async {
    final result = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF8F5E3),
          title: const Text(
            'Select Image Source',
            style: TextStyle(fontFamily: 'CenturyGo', color: Color(0xFF233C23)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF233C23)),
                title: const Text(
                  'Camera',
                  style: TextStyle(
                    fontFamily: 'CenturyGo',
                    color: Color(0xFF233C23),
                  ),
                ),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF233C23),
                ),
                title: const Text(
                  'Gallery',
                  style: TextStyle(
                    fontFamily: 'CenturyGo',
                    color: Color(0xFF233C23),
                  ),
                ),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'CenturyGo',
                  color: Color(0xFF233C23),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      try {
        return await pickAndConvertImage(source: result);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
        return null;
      }
    }
    return null;
  }

  /// Converts base64 data URL to Image widget
  static Widget base64ToImage(
    String? base64DataUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
  }) {
    if (base64DataUrl == null || base64DataUrl.isEmpty) {
      return placeholder ?? const Icon(Icons.image, size: 50);
    }

    try {
      // Extract base64 data from data URL
      final base64Data = base64DataUrl.split(',').last;
      final bytes = base64Decode(base64Data);

      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return placeholder ?? const Icon(Icons.broken_image, size: 50);
        },
      );
    } catch (e) {
      debugPrint('Error converting base64 to image: $e');
      return placeholder ?? const Icon(Icons.broken_image, size: 50);
    }
  }

  /// Validates if a string is a valid base64 data URL
  static bool isValidBase64DataUrl(String? dataUrl) {
    if (dataUrl == null || dataUrl.isEmpty) return false;

    try {
      // Check if it's a data URL
      if (!dataUrl.startsWith('data:')) return false;

      // Extract and validate base64 data
      final base64Data = dataUrl.split(',').last;
      base64Decode(base64Data);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gets the appropriate MIME type for a file extension
  static String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }

  /// Compresses and resizes image for profile pictures (smaller size)
  static Future<String?> pickProfileImage(BuildContext context) async {
    return await showImageSourceDialog(context).then((base64) async {
      if (base64 != null) {
        // Additional compression for profile pictures
        return base64; // Could add additional compression here if needed
      }
      return null;
    });
  }

  /// Picks and optimizes image for guide cards
  static Future<String?> pickGuideImage(BuildContext context) async {
    return await showImageSourceDialog(context);
  }

  /// Creates a circular avatar from base64 data
  static Widget buildCircularAvatar({
    required String? base64DataUrl,
    required double radius,
    Widget? placeholder,
  }) {
    if (base64DataUrl != null && isValidBase64DataUrl(base64DataUrl)) {
      try {
        final base64Data = base64DataUrl.split(',').last;
        final bytes = base64Decode(base64Data);

        return CircleAvatar(
          radius: radius,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (e) {
        debugPrint('Error creating circular avatar: $e');
      }
    }

    return CircleAvatar(
      radius: radius,
      child: placeholder ?? const Icon(Icons.person, size: 40),
    );
  }

  /// Creates a card image container from base64 data
  static Widget buildCardImage({
    required String? base64DataUrl,
    required double width,
    required double height,
    Widget? placeholder,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: base64ToImage(
          base64DataUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          placeholder:
              placeholder ??
              Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
        ),
      ),
    );
  }
}
