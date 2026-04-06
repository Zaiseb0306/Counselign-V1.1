import 'package:flutter/foundation.dart';

class Resource {
  final int id;
  final String title;
  final String? description;
  final String resourceType; // 'file' or 'link'
  final String? category;
  final String? tags;
  final String? filePath;
  final String? fileName;
  final String? fileType;
  final String? fileSizeFormatted;
  final String? externalUrl;
  final String? uploaderName;
  final String? createdAtFormatted;

  Resource({
    required this.id,
    required this.title,
    this.description,
    required this.resourceType,
    this.category,
    this.tags,
    this.filePath,
    this.fileName,
    this.fileType,
    this.fileSizeFormatted,
    this.externalUrl,
    this.uploaderName,
    this.createdAtFormatted,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    try {
      return Resource(
        id: _parseInt(json['id']),
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        resourceType: json['resource_type'] as String? ?? 'file',
        category: json['category'] as String?,
        tags: json['tags'] as String?,
        filePath: json['file_path'] as String?,
        fileName: json['file_name'] as String?,
        fileType: json['file_type'] as String?,
        fileSizeFormatted: json['file_size_formatted'] as String?,
        externalUrl: json['external_url'] as String?,
        uploaderName: json['uploader_name'] as String?,
        createdAtFormatted: json['created_at_formatted'] as String?,
      );
    } catch (e) {
      debugPrint('Error parsing resource from JSON: $e');
      debugPrint('JSON data: $json');
      rethrow;
    }
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  bool get isFile => resourceType == 'file';
  bool get isLink => resourceType == 'link';

  bool get isPdf => fileType?.toLowerCase().contains('pdf') ?? false;
  bool get isImage => fileType?.toLowerCase().contains('image') ?? false;
  bool get isVideo => fileType?.toLowerCase().contains('video') ?? false;
  bool get isWord => fileType?.toLowerCase().contains('word') ?? 
                     fileType?.toLowerCase().contains('doc') ?? false;
  bool get isExcel => fileType?.toLowerCase().contains('excel') ?? 
                      fileType?.toLowerCase().contains('sheet') ?? false;
  bool get isPowerPoint => fileType?.toLowerCase().contains('presentation') ?? false;

  String get fileIconName {
    if (!isFile) return 'link';
    
    final type = fileType?.toLowerCase() ?? '';
    if (type.contains('pdf')) return 'file-pdf';
    if (type.contains('word') || type.contains('doc')) return 'file-word';
    if (type.contains('excel') || type.contains('sheet')) return 'file-excel';
    if (type.contains('presentation')) return 'file-powerpoint';
    if (type.contains('image')) return 'file-image';
    if (type.contains('video')) return 'file-video';
    if (type.contains('zip') || type.contains('rar')) return 'file-archive';
    return 'file-alt';
  }
}
