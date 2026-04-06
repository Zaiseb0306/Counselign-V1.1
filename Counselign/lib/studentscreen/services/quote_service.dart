import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../api/config.dart';
import '../../utils/session.dart';
import '../models/quote.dart';

class QuoteService {
  static final Session _session = Session();
  
  static Future<List<Quote>> fetchApprovedQuotes() async {
    try {
      final url = '${ApiConfig.currentBaseUrl}/student/quotes/approved-quotes';
      debugPrint('QuoteService: Fetching from $url');
      
      final response = await _session.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('QuoteService: Response status: ${response.statusCode}');
      debugPrint('QuoteService: Response body length: ${response.body.length}');
      debugPrint('QuoteService: Full Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        debugPrint('QuoteService: Data keys: ${data.keys}');
        debugPrint('QuoteService: Data success: ${data['success']}');
        debugPrint('QuoteService: Quotes count: ${(data['quotes'] as List?)?.length ?? 0}');
        
        if (data['success'] == true && data['quotes'] is List) {
          final List<dynamic> quotesJson = data['quotes'];
          
          if (quotesJson.isEmpty) {
            debugPrint('QuoteService: API returned empty quotes list - using fallback');
            return _getFallbackQuotes();
          }
          
          final List<Quote> quotes = [];
          for (var i = 0; i < quotesJson.length; i++) {
            try {
              final quote = Quote.fromJson(quotesJson[i] as Map<String, dynamic>);
              quotes.add(quote);
              if (i < 2) {
                debugPrint('QuoteService: Parsed quote $i: ${quote.quoteText.length > 50 ? quote.quoteText.substring(0, 50) : quote.quoteText}... by ${quote.authorName}');
              }
            } catch (e) {
              debugPrint('QuoteService: Error parsing quote at index $i: $e');
              debugPrint('QuoteService: Failed quote data: ${quotesJson[i]}');
            }
          }
          
          if (quotes.isEmpty) {
            debugPrint('QuoteService: No quotes could be parsed - using fallback');
            return _getFallbackQuotes();
          }
          
          debugPrint('QuoteService: Successfully parsed ${quotes.length} quotes from API');
          return quotes;
        } else {
          debugPrint('QuoteService: Invalid response format - success: ${data['success']}, quotes is List: ${data['quotes'] is List}');
        }
      } else {
        debugPrint('QuoteService: HTTP error ${response.statusCode}');
        debugPrint('QuoteService: Response body: ${response.body}');
      }
      debugPrint('QuoteService: Using fallback quotes due to error');
      return _getFallbackQuotes();
    } catch (e, stackTrace) {
      debugPrint('Error fetching quotes: $e');
      debugPrint('Stack trace: $stackTrace');
      return _getFallbackQuotes();
    }
  }

  static List<Quote> _getFallbackQuotes() {
    return [
      Quote(
        id: 1,
        quoteText: 'Growth begins at the end of your comfort zone. Every step you take towards healing matters.',
        authorName: 'Daily Inspiration',
        category: 'Life',
        icon: '🌱',
      ),
      Quote(
        id: 2,
        quoteText: 'You are stronger than you think. Seeking support shows courage and self-awareness.',
        authorName: 'Counseling Wisdom',
        category: 'Motivational',
        icon: '💪',
      ),
      Quote(
        id: 3,
        quoteText: 'Take your journey one day at a time. Celebrate every small victory.',
        authorName: 'Mindful Living',
        category: 'Hope',
        icon: '🌟',
      ),
    ];
  }
}
