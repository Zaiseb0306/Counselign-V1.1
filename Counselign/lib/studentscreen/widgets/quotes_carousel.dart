import 'dart:async';
import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../services/quote_service.dart';

class QuotesCarousel extends StatefulWidget {
  const QuotesCarousel({super.key});

  @override
  State<QuotesCarousel> createState() => _QuotesCarouselState();
}

class _QuotesCarouselState extends State<QuotesCarousel> {
  List<Quote> _quotes = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  Timer? _rotationTimer;
  bool _isVisible = true;
  bool _isTransitioning = false;
  double _dragDistance = 0;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuotes() async {
    try {
      debugPrint('QuotesCarousel: Starting to load quotes');
      final quotes = await QuoteService.fetchApprovedQuotes();
      debugPrint('QuotesCarousel: Received ${quotes.length} quotes');

      if (mounted) {
        setState(() {
          _quotes = quotes;
          _isLoading = false;
        });

        if (_quotes.isNotEmpty) {
          debugPrint(
            'QuotesCarousel: Starting rotation with ${_quotes.length} quotes',
          );
          _startRotation();
        } else {
          debugPrint('QuotesCarousel: No quotes loaded, showing fallback');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('QuotesCarousel: Error loading quotes: $e');
      debugPrint('QuotesCarousel: Stack trace: $stackTrace');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startRotation() {
    _rotationTimer?.cancel();
    if (_quotes.length <= 1) {
      return;
    }
    // Rotate every 15 seconds
    _rotationTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_quotes.length <= 1) return;
      _animateQuoteChange(_getNextIndex());
    });
  }

  int _getNextIndex() {
    if (_quotes.isEmpty) return 0;
    return (_currentIndex + 1) % _quotes.length;
  }

  int _getPreviousIndex() {
    if (_quotes.isEmpty) return 0;
    return (_currentIndex - 1 + _quotes.length) % _quotes.length;
  }

  void _animateQuoteChange(int targetIndex) {
    if (!mounted || _isTransitioning || _quotes.isEmpty) {
      return;
    }
    if (targetIndex == _currentIndex) {
      return;
    }
    _isTransitioning = true;
    setState(() => _isVisible = false);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) {
        _isTransitioning = false;
        return;
      }
      setState(() {
        _currentIndex = targetIndex;
        _isVisible = true;
      });
      _isTransitioning = false;
    });
  }

  void _handleQuoteSwipe(bool moveForward) {
    if (_quotes.length <= 1) return;
    final targetIndex = moveForward ? _getNextIndex() : _getPreviousIndex();
    _animateQuoteChange(targetIndex);
    _startRotation();
  }

  void _onQuoteDragUpdate(DragUpdateDetails details) {
    _dragDistance += details.delta.dx;
  }

  void _onQuoteDragEnd(DragEndDetails details) {
    if (_quotes.length <= 1) {
      _dragDistance = 0;
      return;
    }
    const distanceThreshold = 30;
    const velocityThreshold = 300;
    bool? moveForward;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() > velocityThreshold) {
      moveForward = velocity < 0;
    } else if (_dragDistance.abs() > distanceThreshold) {
      moveForward = _dragDistance < 0;
    }
    _dragDistance = 0;
    if (moveForward == null) return;
    _handleQuoteSwipe(moveForward);
  }

  void _resetQuoteDrag() {
    _dragDistance = 0;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (_isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_quotes.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentQuote = _quotes[_currentIndex];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: _onQuoteDragUpdate,
      onHorizontalDragEnd: _onQuoteDragEnd,
      onHorizontalDragCancel: _resetQuoteDrag,
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 24 : 32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF060E57).withAlpha((0.05 * 255).round()),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: isMobile ? 56 : 64,
                height: isMobile ? 56 : 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF060E57), Color(0xFF3B82F6)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF060E57,
                      ).withAlpha((0.2 * 255).round()),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    currentQuote.displayIcon,
                    style: TextStyle(fontSize: isMobile ? 28 : 32),
                  ),
                ),
              ),

              SizedBox(height: isMobile ? 20 : 24),

              // Quote text
              Text(
                currentQuote.quoteText,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF1E293B),
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              if (currentQuote.authorName != null &&
                  currentQuote.authorName!.isNotEmpty) ...[
                SizedBox(height: isMobile ? 16 : 20),
                Text(
                  '— ${currentQuote.authorName}',
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              if (_quotes.length > 1) ...[
                SizedBox(height: isMobile ? 16 : 20),
                // Indicator dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _quotes.length > 5 ? 5 : _quotes.length,
                    (index) {
                      final actualIndex = _quotes.length > 5
                          ? (_currentIndex ~/ (_quotes.length / 5)).toInt()
                          : _currentIndex;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: index == actualIndex
                              ? const Color(0xFF060E57)
                              : const Color(
                                  0xFF060E57,
                                ).withAlpha((0.2 * 255).round()),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
