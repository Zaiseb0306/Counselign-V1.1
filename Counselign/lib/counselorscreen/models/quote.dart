import 'package:flutter/foundation.dart';

class Quote {
  final int id;
  final String quoteText;
  final String authorName;
  final String category;
  final String? source;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final String? submittedAt;
  final String? submittedAtFormatted;
  final String? moderatedAt;
  final String? moderatedAtFormatted;
  final String? moderatedBy;

  Quote({
    required this.id,
    required this.quoteText,
    required this.authorName,
    required this.category,
    this.source,
    required this.status,
    this.rejectionReason,
    this.submittedAt,
    this.submittedAtFormatted,
    this.moderatedAt,
    this.moderatedAtFormatted,
    this.moderatedBy,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    try {
      return Quote(
        id: _parseInt(json['id']),
        quoteText: json['quote_text'] as String? ?? '',
        authorName: json['author_name'] as String? ?? '',
        category: json['category'] as String? ?? '',
        source: json['source'] as String?,
        status: json['status'] as String? ?? 'pending',
        rejectionReason: json['rejection_reason'] as String?,
        submittedAt: json['submitted_at'] as String?,
        submittedAtFormatted: json['submitted_at_formatted'] as String?,
        moderatedAt: json['moderated_at'] as String?,
        moderatedAtFormatted: json['moderated_at_formatted'] as String?,
        moderatedBy: json['moderated_by'] as String?,
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

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  Map<String, dynamic> toJson() {
    return {
      'quote_text': quoteText,
      'author_name': authorName,
      'category': category,
      if (source != null) 'source': source,
    };
  }
}
