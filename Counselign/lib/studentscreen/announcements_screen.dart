import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'widgets/student_screen_wrapper.dart';
import 'state/announcements_viewmodel.dart';
import 'models/announcement.dart';
import 'models/event.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  late AnnouncementsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AnnouncementsViewModel();
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: StudentScreenWrapper(
        currentBottomNavIndex:
            0, // Announcements is not in bottom nav, so use 0 (Home)
        child: _buildMainContent(context),
      ),
    );
  }

  // header handled by Scaffold.appBar

  // ---------------- MAIN CONTENT ----------------
  Widget _buildMainContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile
                ? 16
                : isTablet
                ? 20
                : 24,
            vertical: isMobile ? 20 : 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Page title
              _buildHeader(context),
              SizedBox(height: isMobile ? 16 : 24),

              // Main content container (buttons + cards / calendar)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000), // ~0.08 opacity
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                  
                ),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Calendar toggle button and refresh button
                      Row(
                        children: [
                          Expanded(child: _buildCalendarToggleButton(context)),
                          const SizedBox(width: 12),
                          _buildRefreshButton(context),
                        ],
                      ),
                      SizedBox(height: isMobile ? 16 : 20),

                      // Calendar view or two-column layout
                      Consumer<AnnouncementsViewModel>(
                        builder: (context, viewModel, child) {
                          if (viewModel.showCalendar) {
                            return _buildCalendarView(context);
                          } else {
                            return isMobile
                                ? Column(
                                    children: [
                                      _buildAnnouncementsSection(context),
                                      const SizedBox(height: 20),
                                      _buildEventsSection(context),
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: _buildAnnouncementsSection(
                                          context,
                                        ),
                                      ),
                                      SizedBox(
                                        width: isTablet ? 20 : 24,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: _buildEventsSection(context),
                                      ),
                                    ],
                                  );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // ---------------- HEADER ----------------
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF060E57), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF060E57).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.campaign,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Announcements and Events',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Stay updated with the latest news and activities',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- ANNOUNCEMENTS SECTION ----------------
  Widget _buildAnnouncementsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Consumer<AnnouncementsViewModel>(
      builder: (context, viewModel, child) {
        return _buildSectionContainer(
          context: context,
          title: 'Announcements',
          icon: Icons.announcement,
          iconColor: const Color(0xFF060E57),
          child: viewModel.isLoadingAnnouncements
              ? Container(
                  padding: EdgeInsets.all(isMobile ? 40 : 60),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF060E57),
                      ),
                    ),
                  ),
                )
              : viewModel.announcementsError != null
              ? Container(
                  padding: EdgeInsets.all(isMobile ? 30 : 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: isMobile ? 48 : 64,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Error loading announcements',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        viewModel.announcementsError!,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          color: const Color(0xFF6C757D),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : viewModel.announcements.isEmpty
              ? Container(
                  padding: EdgeInsets.all(isMobile ? 30 : 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.announcement_outlined,
                        color: const Color(0xFF6C757D),
                        size: isMobile ? 48 : 64,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No announcements available',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          color: const Color(0xFF6C757D),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: viewModel.announcements
                      .map(
                        (announcement) =>
                            _buildAnnouncementCard(context, announcement),
                      )
                      .toList(),
                ),
        );
      },
    );
  }

  // ---------------- EVENTS SECTION ----------------
  Widget _buildEventsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Consumer<AnnouncementsViewModel>(
      builder: (context, viewModel, child) {
        return _buildSectionContainer(
          context: context,
          title: 'Upcoming Events',
          icon: Icons.event,
          iconColor: const Color(0xFF198754),
          child: viewModel.isLoadingEvents
              ? Container(
                  padding: EdgeInsets.all(isMobile ? 40 : 60),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF198754),
                      ),
                    ),
                  ),
                )
              : viewModel.eventsError != null
              ? Container(
                  padding: EdgeInsets.all(isMobile ? 30 : 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: isMobile ? 48 : 64,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Error loading events',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        viewModel.eventsError!,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          color: const Color(0xFF6C757D),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : viewModel.events.isEmpty
              ? Container(
                  padding: EdgeInsets.all(isMobile ? 30 : 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_available_outlined,
                        color: const Color(0xFF6C757D),
                        size: isMobile ? 48 : 64,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No upcoming events',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          color: const Color(0xFF6C757D),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: viewModel.events
                      .map((event) => _buildEventCard(context, event))
                      .toList(),
                ),
        );
      },
    );
  }

  // ---------------- SECTION CONTAINER ----------------
  Widget _buildSectionContainer({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      margin: EdgeInsets.only(bottom: isMobile ? 16 : 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: const Color(0x14000000), // Fixed: 0.08 opacity in hex
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 6 : 8),
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    iconColor.withAlpha(25),
                    Colors.white,
                  ), // Fixed: 0.1 opacity
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: isMobile ? 18 : 20),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF003366),
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),

          // Section content
          child,
        ],
      ),
    );
  }

  // ---------------- ANNOUNCEMENT CARD ----------------
  Widget _buildAnnouncementCard(
    BuildContext context,
    Announcement announcement,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isMobile ? 80 : 100),
      margin: EdgeInsets.only(bottom: isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF060E57).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE3EAFC), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Badge
          Container(
            width: isMobile ? 50 : 60,
            height: isMobile ? 50 : 60,
            margin: EdgeInsets.all(isMobile ? 10 : 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2346C6), Color(0xFF1E3799)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3799).withValues(alpha: 0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getMonthShort(announcement.createdAt),
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  announcement.createdAt.day.toString(),
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 10 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    announcement.title,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF14205A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isMobile ? 4 : 6),

                  // Meta info
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: isMobile ? 12 : 14,
                        color: const Color(0xFF2346C6),
                      ),
                      SizedBox(width: 4),
                      Text(
                        announcement.formattedDate,
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: const Color(0xFF2346C6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 4 : 6),

                  // Description
                  Text(
                    announcement.content,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      color: const Color(0xFF1A1A1A),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- EVENT CARD ----------------
  Widget _buildEventCard(BuildContext context, Event event) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isMobile ? 80 : 100),
      margin: EdgeInsets.only(bottom: isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF060E57).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE3EAFC), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Badge
          Container(
            width: isMobile ? 50 : 60,
            height: isMobile ? 50 : 60,
            margin: EdgeInsets.all(isMobile ? 10 : 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF198754), Color(0xFF146C43)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF198754).withValues(alpha: 0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: event.date != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getMonthShort(event.date!),
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        event.date!.day.toString(),
                        style: TextStyle(
                          fontSize: isMobile ? 24 : 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event,
                        color: Colors.white,
                        size: isMobile ? 20 : 24,
                      ),
                    ],
                  ),
          ),

          // Content
          Flexible(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 10 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF14205A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isMobile ? 4 : 6),

                  // Meta info
                  Wrap(
                    spacing: isMobile ? 8 : 12,
                    runSpacing: 4,
                    children: [
                      if (event.date != null) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: isMobile ? 12 : 14,
                              color: const Color(0xFF198754),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${event.date!.day}/${event.date!.month}/${event.date!.year}',
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 12,
                                color: const Color(0xFF198754),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (event.formattedTime.isNotEmpty) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: isMobile ? 12 : 14,
                              color: const Color(0xFF198754),
                            ),
                            SizedBox(width: 4),
                            Text(
                              event.formattedTime,
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 12,
                                color: const Color(0xFF198754),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  if (event.location != null && event.location!.isNotEmpty) ...[
                    SizedBox(height: isMobile ? 4 : 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: isMobile ? 12 : 14,
                          color: const Color(0xFF198754),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 12,
                              color: const Color(0xFF198754),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: isMobile ? 4 : 6),

                  // Description
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      color: const Color(0xFF1A1A1A),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- HELPER METHODS ----------------
  String _getMonthShort(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[date.month - 1];
  }

  // ---------------- CALENDAR TOGGLE BUTTON ----------------
  Widget _buildCalendarToggleButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Consumer<AnnouncementsViewModel>(
      builder: (context, viewModel, child) {
        return ElevatedButton.icon(
          onPressed: viewModel.toggleCalendar,
          icon: Icon(
            viewModel.showCalendar ? Icons.list : Icons.calendar_today,
            size: isMobile ? 18 : 20,
          ),
          label: Text(
            viewModel.showCalendar ? 'List View' : 'Calendar View',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF060E57),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 24,
              vertical: isMobile ? 12 : 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
            ),
            elevation: 2,
          ),
        );
      },
    );
  }

  // ---------------- REFRESH BUTTON ----------------
  Widget _buildRefreshButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Consumer<AnnouncementsViewModel>(
      builder: (context, viewModel, child) {
        return ElevatedButton(
          onPressed: viewModel.refresh,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF198754),
            foregroundColor: Colors.white,
            padding: EdgeInsets.all(isMobile ? 12 : 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
            ),
            elevation: 2,
          ),
          child: Icon(
            Icons.refresh,
            size: isMobile ? 18 : 20,
          ),
        );
      },
    );
  }

  // ---------------- CALENDAR VIEW ----------------
  Widget _buildCalendarView(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Consumer<AnnouncementsViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            boxShadow: [
              BoxShadow(
                color: const Color(0x14000000),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Column(
            children: [
              // Calendar
              TableCalendar<Event>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: viewModel.focusedDay,
                calendarFormat: viewModel.calendarFormat,
                eventLoader: viewModel.getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(
                    color: const Color(0xFF060E57),
                    fontWeight: FontWeight.w600,
                  ),
                  defaultTextStyle: TextStyle(
                    color: const Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                  selectedTextStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  todayTextStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: const Color(0xFF060E57),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: const Color(0xFF198754),
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 3,
                  markerDecoration: BoxDecoration(
                    color: const Color(0xFF060E57),
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: const Color(0xFF060E57),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  formatButtonTextStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  titleTextStyle: TextStyle(
                    color: const Color(0xFF060E57),
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onDaySelected: viewModel.onDaySelected,
                onPageChanged: viewModel.onPageChanged,
                onFormatChanged: viewModel.onFormatChanged,
                selectedDayPredicate: (day) {
                  return isSameDay(viewModel.selectedDay, day);
                },
              ),
              SizedBox(height: isMobile ? 16 : 20),

              // Selected day items
              if (viewModel.selectedDay != null)
                _buildSelectedDayItems(context, viewModel.selectedDay!),
            ],
          ),
        );
      },
    );
  }

  // ---------------- SELECTED DAY ITEMS ----------------
  Widget _buildSelectedDayItems(BuildContext context, DateTime selectedDay) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Consumer<AnnouncementsViewModel>(
      builder: (context, viewModel, child) {
        final events = viewModel.getEventsForDay(selectedDay);

        if (events.isEmpty) {
          return Container(
            padding: EdgeInsets.all(isMobile ? 20 : 30),
            child: Column(
              children: [
                Icon(
                  Icons.event_available_outlined,
                  color: const Color(0xFF6C757D),
                  size: isMobile ? 40 : 48,
                ),
                SizedBox(height: 12),
                Text(
                  'No events scheduled for this day',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: const Color(0xFF6C757D),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${selectedDay.day}/${selectedDay.month}/${selectedDay.year}',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF060E57),
              ),
            ),
            SizedBox(height: isMobile ? 12 : 16),
            ...events.map((event) => _buildCalendarItemCard(context, event)),
          ],
        );
      },
    );
  }

  // ---------------- CALENDAR ITEM CARD ----------------
  Widget _buildCalendarItemCard(BuildContext context, Event event) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF060E57).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFE3EAFC), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isMobile ? 40 : 48,
            height: isMobile ? 40 : 48,
            margin: EdgeInsets.all(isMobile ? 8 : 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: const [Color(0xFF198754), Color(0xFF146C43)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.event,
              color: Colors.white,
              size: isMobile ? 16 : 18,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 8 : 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 13 : 14,
                      color: const Color(0xFF14205A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: const Color(0xFF1A1A1A),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (event.time != null) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: isMobile ? 10 : 12,
                          color: const Color(0xFF198754),
                        ),
                        SizedBox(width: 4),
                        Text(
                          event.formattedTime,
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 11,
                            color: const Color(0xFF198754),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
