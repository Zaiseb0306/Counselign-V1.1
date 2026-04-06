import 'package:flutter/foundation.dart';
import '../../api/config.dart';

class ImageUrlHelper {
  /// Constructs a full URL for profile images
  /// Handles both relative and absolute paths
  static String getProfileImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      // Return default profile image as asset
      return 'Photos/profile.png';
    }

    // If it's already a full URL, return as is
    if (imagePath.startsWith('http')) {
      debugPrint('🖼️ ImageUrlHelper: Already full URL: $imagePath');
      return imagePath;
    }

    // Normalize the path - remove leading slash if present
    String normalizedPath = imagePath.startsWith('/')
        ? imagePath.substring(1)
        : imagePath;

    // Clean the base URL - remove /index.php if it exists
    String cleanBaseUrl = ApiConfig.currentBaseUrl;
    if (cleanBaseUrl.endsWith('/index.php')) {
      cleanBaseUrl = cleanBaseUrl.replaceAll('/index.php', '');
      debugPrint('🖼️ ImageUrlHelper: Removed /index.php from base URL');
    }

    // Ensure base URL doesn't end with slash and path doesn't start with slash
    cleanBaseUrl = cleanBaseUrl.replaceAll(RegExp(r'/$'), '');
    if (normalizedPath.startsWith('/')) {
      normalizedPath = normalizedPath.substring(1);
    }

    // Construct the full URL
    final fullUrl = '$cleanBaseUrl/$normalizedPath';
    debugPrint('🖼️ ImageUrlHelper: Base URL: $cleanBaseUrl');
    debugPrint('🖼️ ImageUrlHelper: Normalized path: $normalizedPath');
    debugPrint('🖼️ ImageUrlHelper: Full URL: $fullUrl');

    return fullUrl;
  }

  /// Constructs a full URL for any image path
  static String getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      debugPrint('🖼️ ImageUrlHelper: Already full URL: $imagePath');
      return imagePath;
    }

    // Clean the base URL - remove /index.php if it exists
    String cleanBaseUrl = ApiConfig.currentBaseUrl;
    if (cleanBaseUrl.endsWith('/index.php')) {
      cleanBaseUrl = cleanBaseUrl.replaceAll('/index.php', '');
    }

    // Ensure base URL doesn't end with slash
    cleanBaseUrl = cleanBaseUrl.replaceAll(RegExp(r'/$'), '');

    // Remove leading slash from image path if present
    String normalizedPath = imagePath.startsWith('/')
        ? imagePath.substring(1)
        : imagePath;

    final fullUrl = '$cleanBaseUrl/$normalizedPath';
    debugPrint('🖼️ ImageUrlHelper: Image URL: $fullUrl');

    return fullUrl;
  }
}
