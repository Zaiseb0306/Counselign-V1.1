import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../api/config.dart';
import '../../utils/session.dart';
import '../models/quote.dart';

class QuoteService {
  static final Session _session = Session();

  static Future<List<Quote>> getMyQuotes() async {
    try {
      final url = '${ApiConfig.currentBaseUrl}/counselor/quotes/my-quotes';
      debugPrint('QuoteService: Fetching from $url');

      final response = await _session.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('QuoteService: Response status: ${response.statusCode}');
      debugPrint('QuoteService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        debugPrint('QuoteService: Data success: ${data['success']}');
        debugPrint(
          'QuoteService: Quotes count: ${(data['quotes'] as List?)?.length ?? 0}',
        );

        if (data['success'] == true && data['quotes'] is List) {
          final List<dynamic> quotesJson = data['quotes'];
          final quotes = quotesJson
              .map((json) => Quote.fromJson(json as Map<String, dynamic>))
              .toList();

          debugPrint('QuoteService: Parsed ${quotes.length} quotes');
          return quotes;
        }
      }
      return [];
    } catch (e, stackTrace) {
      debugPrint('Error fetching quotes: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  static Future<Map<String, dynamic>> submitQuote(Quote quote) async {
    try {
      final url = '${ApiConfig.currentBaseUrl}/counselor/quotes/submit';
      debugPrint('QuoteService: Submitting quote to $url');

      final json = quote.toJson();
      final fields = <String, String>{
        for (var entry in json.entries) entry.key: entry.value.toString(),
      };

      final response = await _session.post(
        url,
        fields: fields,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      debugPrint(
        'QuoteService: Submit response status: ${response.statusCode}',
      );
      debugPrint('QuoteService: Submit response body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e, stackTrace) {
      debugPrint('Error submitting quote: $e');
      debugPrint('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> updateQuote(
    int quoteId,
    Quote quote,
  ) async {
    try {
      final url =
          '${ApiConfig.currentBaseUrl}/counselor/quotes/update/$quoteId';
      debugPrint('QuoteService: Updating quote $quoteId at $url');

      final json = quote.toJson();
      final fields = <String, String>{
        for (var entry in json.entries) entry.key: entry.value.toString(),
      };

      final response = await _session.put(
        url,
        fields: fields,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      debugPrint(
        'QuoteService: Update response status: ${response.statusCode}',
      );
      debugPrint('QuoteService: Update response body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e, stackTrace) {
      debugPrint('Error updating quote: $e');
      debugPrint('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteQuote(int quoteId) async {
    try {
      final url =
          '${ApiConfig.currentBaseUrl}/counselor/quotes/delete/$quoteId';
      debugPrint('QuoteService: Deleting quote $quoteId at $url');

      final response = await _session.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint(
        'QuoteService: Delete response status: ${response.statusCode}',
      );
      debugPrint('QuoteService: Delete response body: ${response.body}');

      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } catch (e, stackTrace) {
      debugPrint('Error deleting quote: $e');
      debugPrint('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }
}
