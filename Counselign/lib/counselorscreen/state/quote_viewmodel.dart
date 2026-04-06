import 'package:flutter/foundation.dart';
import '../models/quote.dart';
import '../services/quote_service.dart';

class QuoteViewModel extends ChangeNotifier {
  List<Quote> _quotes = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<Quote> get quotes => _quotes;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<void> loadMyQuotes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final quotes = await QuoteService.getMyQuotes();
      _quotes = quotes;
      _errorMessage = null;
    } catch (e) {
      debugPrint('Error loading quotes: $e');
      _errorMessage = 'Failed to load quotes. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitQuote(Quote quote) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await QuoteService.submitQuote(quote);
      _isSubmitting = false;

      if (result['success'] == true) {
        await loadMyQuotes();
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            result['message'] as String? ??
            'Failed to submit quote. Please try again.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error submitting quote: $e');
      _isSubmitting = false;
      _errorMessage = 'An error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateQuote(int quoteId, Quote quote) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await QuoteService.updateQuote(quoteId, quote);
      _isSubmitting = false;

      if (result['success'] == true) {
        await loadMyQuotes();
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            result['message'] as String? ??
            'Failed to update quote. Please try again.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error updating quote: $e');
      _isSubmitting = false;
      _errorMessage = 'An error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteQuote(int quoteId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await QuoteService.deleteQuote(quoteId);
      _isLoading = false;

      if (result['success'] == true) {
        await loadMyQuotes();
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            result['message'] as String? ??
            'Failed to delete quote. Please try again.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting quote: $e');
      _isLoading = false;
      _errorMessage = 'An error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
