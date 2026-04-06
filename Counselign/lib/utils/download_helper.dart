import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'session.dart';

class DownloadHelper {
  static final Session _session = Session();

  /// Download a file using authenticated session and save it locally
  static Future<String?> downloadFile({
    required String url,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    try {
      debugPrint('DownloadHelper: Starting download from $url');
      debugPrint('DownloadHelper: Filename: $fileName');

      // Get the response with session authentication
      final response = await _session.get(
        url,
        headers: {'Content-Type': 'application/octet-stream'},
      );

      debugPrint('DownloadHelper: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Get the Downloads directory
        Directory? directory;
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
          // Navigate to the Downloads folder on Android
          final downloadPath = '/storage/emulated/0/Download';
          directory = Directory(downloadPath);
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        } else {
          directory = await getDownloadsDirectory();
        }

        if (directory == null) {
          debugPrint('DownloadHelper: Could not find download directory');
          return null;
        }

        // Ensure directory exists
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        // Create file path
        final filePath = '${directory.path}/$fileName';
        debugPrint('DownloadHelper: Saving to $filePath');

        // Write file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        debugPrint('DownloadHelper: File saved successfully');
        return filePath;
      } else {
        debugPrint('DownloadHelper: Download failed with status ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('DownloadHelper: Error downloading file: $e');
      debugPrint('DownloadHelper: Stack trace: $stackTrace');
      return null;
    }
  }

  /// Download and open a file in one step
  static Future<bool> downloadAndOpenFile({
    required String url,
    required String fileName,
  }) async {
    try {
      final filePath = await downloadFile(url: url, fileName: fileName);
      
      if (filePath != null) {
        debugPrint('DownloadHelper: Opening file at $filePath');
        final result = await OpenFile.open(filePath);
        debugPrint('DownloadHelper: OpenFile result: ${result.type} - ${result.message}');
        return result.type == ResultType.done;
      }
      
      return false;
    } catch (e) {
      debugPrint('DownloadHelper: Error opening file: $e');
      return false;
    }
  }

  /// Get the file URL for previewing (images, etc.)
  static String getPreviewUrl(String baseUrl, String filePath) {
    if (filePath.startsWith('http')) {
      return filePath;
    }
    return '$baseUrl/$filePath';
  }
}
