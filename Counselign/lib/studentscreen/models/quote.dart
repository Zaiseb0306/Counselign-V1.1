import 'package:flutter/foundation.dart';

class Quote {
  final int id;
  final String quoteText;
  final String? authorName;
  final String? category;
  final String? icon;

  Quote({
    required this.id,
    required this.quoteText,
    this.authorName,
    this.category,
    this.icon,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    try {
      return Quote(
        id: _parseInt(json['id']),
        quoteText: json['quote_text'] as String? ?? json['text'] as String? ?? '',
        authorName: json['author_name'] as String? ?? json['author'] as String?,
        category: json['category'] as String?,
        icon: json['icon'] as String?,
      );
    } catch (e) {
      debugPrint('Error parsing quote from JSON: $e');
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

  String get displayIcon {
    if (icon != null && icon!.isNotEmpty) return icon!;
    return _getCategoryIcon(category ?? '');
  }

  static String _getCategoryIcon(String category) {
    const icons = {
      'Inspirational': '✨',
      'Motivational': '💪',
      'Wisdom': '🦉',
      'Life': '🌱',
      'Success': '🎯',
      'Education': '📚',
      'Perseverance': '🏔️',
      'Courage': '🦁',
      'Hope': '🌟',
      'Kindness': '💝',
    };
    return icons[category] ?? '📝';
  }
}
