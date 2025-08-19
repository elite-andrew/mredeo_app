import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mredeo_app/core/utils/app_logger.dart';

class ImageCacheManager {
  static const String key = 'profileImageCache';

  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7), // Cache for 7 days
      maxNrOfCacheObjects: 200, // Maximum number of cached images
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

  /// Clear all cached profile images
  static Future<void> clearCache() async {
    await instance.emptyCache();
  }

  /// Clear cache for a specific image URL
  static Future<void> clearImageCache(String url) async {
    await instance.removeFile(url);
  }

  /// Get cache info for debugging
  static Future<void> printCacheInfo() async {
    final files = await instance.getFileFromCache(key);
    AppLogger.info('Cache info: $files', 'ImageCacheManager');
  }

  /// Pre-cache an image
  static Future<void> precacheImage(String url) async {
    try {
      await instance.downloadFile(url);
    } catch (e) {
      AppLogger.warning('Failed to precache image: $e', 'ImageCacheManager');
    }
  }
}
