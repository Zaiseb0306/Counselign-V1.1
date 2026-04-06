import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/counselor_announcements_viewmodel.dart';
import 'package:table_calendar/table_calendar.dart';
import '../studentscreen/models/announcement.dart';
import '../studentscreen/models/event.dart';
import 'widgets/counselor_screen_wrapper.dart';

class CounselorAnnouncementsScreen extends StatefulWidget {
  const CounselorAnnouncementsScreen({super.key});

  @override
  State<CounselorAnnouncementsScreen> createState() =>
      _CounselorAnnouncementsScreenState();
}

class _CounselorAnnouncementsScreenState
    extends State<CounselorAnnouncementsScreen> {
  late CounselorAnnouncementsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CounselorAnnouncementsViewModel();
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
      child: CounselorScreenWrapper(
        currentBottomNavIndex: -1, // Not in bottom nav
        child: _buildMainContent(context),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Padding(
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
          _buildHeader(context),
          SizedBox(height: isMobile ? 16 : 24),
          // Content Container wrapping everything except header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF060E57).withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFE5E9F2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Toggle + Refresh
                Row(
                  children: [
                    Expanded(child: _buildCalendarToggleButton(context)),
                    SizedBox(width: 12),
                    _buildRefreshButton(context),
                  ],
                ),
                SizedBox(height: isMobile ? 16 : 20),
                // Main content
                Consumer<CounselorAnnouncementsViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.showCalendar) {
                      return _buildCalendarView(context);
                    } else {
                      return isMobile
                          ? Column(
                              children: [
                                _buildAnnouncementsSection(context),
                                SizedBox(height: 20),
                                _buildEventsSection(context),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildAnnouncementsSection(context),
                                ),
                                SizedBox(width: isTablet ? 20 : 24),
                                Expanded(child: _buildEventsSection(context)),
                              ],
                            );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
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
            blurRadius: 8,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Announcements and Events',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'View and manage campus announcements and upcoming events',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
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

  Widget _buildAnnouncementsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    return Consumer<CounselorAnnouncementsViewModel>(
      builder: (context, viewModel, child) {
        return _buildSectionContainer(
          context: context,
          title: 'Announcements',
          icon: Icons.announcement,
          iconColor: const Color(0xFF060E57),
          child: viewModel.isLoadingAnnouncements
              ? Container(
                  padding: EdgeInsets.all(isMobile ? 40 : 60),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF060E57),
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
                      const SizedBox(height: 16),
                      Text(
                        'Error loading announcements',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
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
                    children: [
                      Icon(
                        Icons.announcement_outlined,
                        size: isMobile ? 48 : 64,
                        color: const Color(0xFF6C757D),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No announcements available',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          color: const Color(0xFF6C757D),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: viewModel.announcements
                      .map((a) => _buildAnnouncementCard(context, a))
                      .toList(),
                ),
        );
      },
    );
  }

  Widget _buildAnnouncementCard(
    BuildContext context,
    Announcement announcement,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isMobile ? 80 : 100),
      margin: EdgeInsets.only(bottom: isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF060E57).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E9F2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Flexible(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 10 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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

  // Events section
  Widget _buildEventsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    return Consumer<CounselorAnnouncementsViewModel>(
      builder: (context, viewModel, child) {
        return _buildSectionContainer(
          context: context,
          title: 'Upcoming Events',
          icon: Icons.event,
          iconColor: const Color(0xFF198754),
          child: viewModel.isLoadingEvents
              ? Container(
                  padding: EdgeInsets.all(isMobile ? 40 : 60),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF198754),
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
                      const SizedBox(height: 16),
                      Text(
                        'Error loading events',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
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
                    children: [
                      Icon(
                        Icons.event_available_outlined,
                        size: isMobile ? 48 : 64,
                        color: const Color(0xFF6C757D),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No upcoming events',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          color: const Color(0xFF6C757D),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: viewModel.events
                      .map((e) => _buildEventCard(context, e))
                      .toList(),
                ),
        );
      },
    );
  }

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
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF060E57).withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE5E9F2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 6 : 8),
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    iconColor.withAlpha(25),
                    Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: isMobile ? 18 : 20),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF060E57),
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          child,
        ],
      ),
    );
  }

  // Toggle & refresh buttons
  Widget _buildCalendarToggleButton(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Consumer<CounselorAnnouncementsViewModel>(
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
          ),
        );
      },
    );
  }

  Widget _buildRefreshButton(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Consumer<CounselorAnnouncementsViewModel>(
      builder: (context, viewModel, child) {
        return ElevatedButton(
          onPressed: viewModel.refresh,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF198754),
            foregroundColor: Colors.white,
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Icon(Icons.refresh, size: isMobile ? 18 : 20),
        );
      },
    );
  }

  // Calendar view
  Widget _buildCalendarView(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Consumer<CounselorAnnouncementsViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFD),
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF060E57).withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFE5E9F2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              TableCalendar<Event>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: viewModel.focusedDay,
                calendarFormat: viewModel.calendarFormat,
                eventLoader: viewModel.getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                ),
                onDaySelected: viewModel.onDaySelected,
                onPageChanged: viewModel.onPageChanged,
                onFormatChanged: viewModel.onFormatChanged,
                selectedDayPredicate: (d) =>
                    isSameDay(viewModel.selectedDay, d),
              ),
              SizedBox(height: isMobile ? 16 : 20),
              if (viewModel.selectedDay != null)
                _buildSelectedDayItems(context, viewModel.selectedDay!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedDayItems(BuildContext context, DateTime selectedDay) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Consumer<CounselorAnnouncementsViewModel>(
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
                const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            ...events.map((event) => _buildCalendarItemCard(context, event)),
          ],
        );
      },
    );
  }

  Widget _buildCalendarItemCard(BuildContext context, Event event) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF060E57).withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E9F2), width: 1),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 13 : 14,
                      color: const Color(0xFF14205A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: const Color(0xFF1A1A1A),
                      height: 1.3,
                    ),
                  ),
                  if (event.time != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: Color(0xFF198754),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.formattedTime,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF198754),
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

  Widget _buildEventCard(BuildContext context, Event event) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF060E57).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E9F2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            ),
            child: event.date != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getMonthShort(event.date!),
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 12,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        event.date!.day.toString(),
                        style: TextStyle(
                          fontSize: isMobile ? 24 : 28,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ],
                  )
                : const Icon(Icons.event, color: Colors.white),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 10 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF14205A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: isMobile ? 8 : 12,
                    runSpacing: 4,
                    children: [
                      if (event.date != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Color(0xFF198754),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${event.date!.day}/${event.date!.month}/${event.date!.year}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF198754),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      if (event.formattedTime.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Color(0xFF198754),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.formattedTime,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF198754),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (event.location != null && event.location!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Color(0xFF198754),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF198754),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1A1A1A),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
}
