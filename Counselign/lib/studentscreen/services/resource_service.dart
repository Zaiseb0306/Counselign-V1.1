import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../api/config.dart';
import '../../utils/session.dart';
import '../models/resource.dart';

class ResourceService {
  static final Session _session = Session();
  
  static Future<List<Resource>> fetchResources() async {
    try {
      final url = '${ApiConfig.currentBaseUrl}/student/resources/get';
      debugPrint('ResourceService: Fetching from $url');
      
      final response = await _session.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('ResourceService: Response status: ${response.statusCode}');
      debugPrint('ResourceService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        debugPrint('ResourceService: Data success: ${data['success']}');
        debugPrint('ResourceService: Resources count: ${(data['resources'] as List?)?.length ?? 0}');
        
        if (data['success'] == true && data['resources'] is List) {
          final List<dynamic> resourcesJson = data['resources'];
          final resources = resourcesJson
              .map((json) => Resource.fromJson(json as Map<String, dynamic>))
              .toList();
          
          debugPrint('ResourceService: Parsed ${resources.length} resources');
          return resources;
        }
      }
      return [];
    } catch (e, stackTrace) {
      debugPrint('Error fetching resources: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  static String getDownloadUrl(int resourceId) {
    return '${ApiConfig.currentBaseUrl}/student/resources/download/$resourceId';
  }

  static String getFileUrl(String? filePath) {
    if (filePath == null || filePath.isEmpty) return '';
    return '${ApiConfig.currentBaseUrl}/$filePath';
  }
}
