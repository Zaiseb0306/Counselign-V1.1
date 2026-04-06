import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class EventCarousel extends StatefulWidget {
  const EventCarousel({super.key});

  @override
  State<EventCarousel> createState() => _EventCarouselState();
}

class _EventCarouselState extends State<EventCarousel> {
  List<Event> _events = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _isForward = true;
  Timer? _autoScrollTimer;
  double _dragDistance = 0;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await EventService.fetchEvents();
      if (mounted) {
        setState(() {
          _events = events;
          _isLoading = false;
        });

        if (_events.isNotEmpty) {
          _startAutoScroll();
        }
      }
    } catch (e) {
      debugPrint('Error loading events: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!mounted || _events.isEmpty) {
        return;
      }
      _goToNextEvent();
    });
  }

  void _goToPreviousEvent() {
    if (_events.length <= 1) {
      return;
    }
    setState(() {
      _isForward = false;
      _currentIndex = (_currentIndex - 1 + _events.length) % _events.length;
    });
  }

  void _goToNextEvent() {
    if (_events.length <= 1) {
      return;
    }
    setState(() {
      _isForward = true;
      _currentIndex = (_currentIndex + 1) % _events.length;
    });
  }

  void _handleManualEventNavigation(bool moveForward) {
    if (_events.length <= 1) {
      return;
    }
    if (moveForward) {
      _goToNextEvent();
    } else {
      _goToPreviousEvent();
    }
    _startAutoScroll();
  }

  void _onEventDragUpdate(DragUpdateDetails details) {
    _dragDistance += details.delta.dx;
  }

  void _onEventDragEnd(DragEndDetails details) {
    if (_events.length <= 1) {
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
    _handleManualEventNavigation(moveForward);
  }

  void _resetEventDrag() {
    _dragDistance = 0;
  }

  String _formatEventDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('EEEE, MMM d, yyyy').format(date);
  }

  String _formatEventTime(String? time) {
    if (time == null) return '';
    try {
      final dateTime = DateTime.parse('1970-01-01T$time');
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (_isLoading) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: isMobile ? 16 : 20),
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_events.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: isMobile ? 16 : 20),
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_busy,
              size: isMobile ? 48 : 56,
              color: Colors.grey[400],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              'No upcoming events available right now.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isMobile ? 14 : 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Events',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF060E57),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/student/announcements');
                },
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        color: const Color(0xFF3B82F6),
                        fontSize: isMobile ? 12 : 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Color(0xFF3B82F6),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),

          // Carousel (single card with dynamic height + slide/fade animation)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: _onEventDragUpdate,
            onHorizontalDragEnd: _onEventDragEnd,
            onHorizontalDragCancel: _resetEventDrag,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  final isForward = _isForward;
                  final offsetTween = Tween<Offset>(
                    begin: Offset(isForward ? 0.15 : -0.15, 0),
                    end: Offset.zero,
                  );
                  return SlideTransition(
                    position: animation.drive(offsetTween),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentIndex),
                  child: _buildEventCard(_events[_currentIndex], isMobile),
                ),
              ),
            ),
          ),

          SizedBox(height: isMobile ? 10 : 12),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous button
              IconButton(
                onPressed: _events.length > 1
                    ? () => _handleManualEventNavigation(false)
                    : null,
                icon: const Icon(Icons.chevron_left),
                color: const Color(0xFF060E57),
              ),

              // Dots indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _events.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentIndex ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _currentIndex
                          ? const Color(0xFF060E57)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              // Next button
              IconButton(
                onPressed: _events.length > 1
                    ? () => _handleManualEventNavigation(true)
                    : null,
                icon: const Icon(Icons.chevron_right),
                color: const Color(0xFF060E57),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF060E57).withAlpha((0.1 * 255).round()),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge and title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  event.badgeLabel,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),

          // Title
          Text(
            event.title,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF060E57),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isMobile ? 8 : 12),

          // Meta info
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (event.date != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _formatEventDate(event.date),
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              if (event.time != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatEventTime(event.time),
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              if (event.location != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        event.location!,
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: isMobile ? 6 : 8),

          // Description
          Text(
            event.description,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: const Color(0xFF475569),
              height: 1.5,
            ),
            softWrap: true,
          ),
        ],
      ),
    );
  }
}
