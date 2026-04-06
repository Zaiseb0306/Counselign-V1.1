import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'state/counselor_follow_up_sessions_viewmodel.dart';
import 'widgets/counselor_screen_wrapper.dart';
import 'state/counselor_scheduled_appointments_viewmodel.dart';
import 'widgets/weekly_schedule.dart';
import 'widgets/mini_calendar.dart';
import 'models/completed_appointment.dart';
import 'models/follow_up_session.dart';
import '../../utils/time_utils.dart';

class CounselorFollowUpSessionsScreen extends StatefulWidget {
  const CounselorFollowUpSessionsScreen({super.key});

  @override
  State<CounselorFollowUpSessionsScreen> createState() =>
      _CounselorFollowUpSessionsScreenState();
}

class _CounselorFollowUpSessionsScreenState
    extends State<CounselorFollowUpSessionsScreen> {
  late CounselorFollowUpSessionsViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;
  OverlayEntry? _overlayEntry;

  // Loading states for buttons
  bool _isCancelling = false;
  bool _isCreatingFollowUp = false;
  bool _isUpdatingFollowUp = false;

  @override
  void initState() {
    super.initState();
    _viewModel = CounselorFollowUpSessionsViewModel();
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _insertOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry() {
    final mediaQuery = MediaQuery.of(context);
    final paddingTop = mediaQuery.padding.top;
    final appBarHeight = 40.0; // kAppBarHeight from AppHeader

    return OverlayEntry(
      builder: (context) => Positioned(
        top: paddingTop + appBarHeight + 10,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: FloatingActionButton(
            onPressed: () => _showSchedulesModal(context),
            backgroundColor: const Color(0xFF060E57),
            foregroundColor: Colors.white,
            tooltip: 'View Schedules',
            child: const Icon(Icons.calendar_today),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _overlayEntry == null) {
        _insertOverlay();
      }
    });

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: CounselorScreenWrapper(
        currentBottomNavIndex: 2, // Follow-up Sessions (index 2)
        child: _buildMainContent(context),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return SingleChildScrollView(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: isMobile ? 20 : 30),
            // Container wrapping search bar and appointments list
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF060E57).withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE5E9F2), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(context),
                    const SizedBox(height: 24),
                    _buildCompletedAppointmentsList(context),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 100,
            ), // Add bottom padding for navigation bar
          ],
        ),
      ),
    );
  }

  void _showSchedulesModal(BuildContext context) {
    final localVm = CounselorScheduledAppointmentsViewModel();
    localVm.initialize();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeNotifierProvider.value(
        value: localVm,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF060E57),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Weekly Schedules & Calendar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Consumer<CounselorScheduledAppointmentsViewModel>(
                        builder: (context, vm, child) {
                          return WeeklySchedule(schedule: vm.counselorSchedule);
                        },
                      ),
                      const SizedBox(height: 24),
                      Consumer<CounselorScheduledAppointmentsViewModel>(
                        builder: (context, vm, child) {
                          return MiniCalendar(
                            viewModel: vm,
                            onDateSelected: (date) {
                              debugPrint('Selected date: $date');
                            },
                          );
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
    ).whenComplete(() {
      localVm.dispose();
    });
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
              Icons.event_available,
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
                  'Follow-up Sessions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Manage follow-up sessions for completed appointments',
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

  Widget _buildSearchBar(BuildContext context) {
    return Consumer<CounselorFollowUpSessionsViewModel>(
      builder: (context, viewModel, child) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF060E57).withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  // Trigger rebuild to show/hide clear button
                  setState(() {});

                  // Cancel previous timer
                  _searchDebounceTimer?.cancel();

                  if (value.isEmpty) {
                    viewModel.loadCompletedAppointments();
                  } else {
                    // Debounce search with 300ms delay
                    _searchDebounceTimer = Timer(
                      const Duration(milliseconds: 300),
                      () {
                        if (_searchController.text == value) {
                          viewModel.loadCompletedAppointments(
                            searchTerm: value,
                          );
                        }
                      },
                    );
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search appointments...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchDebounceTimer?.cancel();
                            _searchController.clear();
                            viewModel.loadCompletedAppointments();
                            setState(
                              () {},
                            ); // Trigger rebuild to hide clear button
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCompletedAppointmentsList(BuildContext context) {
    return Consumer<CounselorFollowUpSessionsViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF191970)),
              ),
            ),
          );
        }

        if (viewModel.error != null) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading appointments',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.error!,
                    style: TextStyle(fontSize: 14, color: Colors.red[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Show all appointments (both pending and regular)
        final appointmentsToShow = viewModel.completedAppointments;

        if (appointmentsToShow.isEmpty) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.searchTerm.isNotEmpty
                        ? 'No appointments found'
                        : 'No completed appointments',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.searchTerm.isNotEmpty
                        ? 'Try adjusting your search criteria'
                        : 'Complete some appointments to create follow-up sessions',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 1024
                ? 3
                : MediaQuery.of(context).size.width > 600
                ? 2
                : 1,
            childAspectRatio: 1.00,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: appointmentsToShow.length,
          itemBuilder: (context, index) {
            final appointment = appointmentsToShow[index];
            return _buildCompletedAppointmentCard(context, appointment);
          },
        );
      },
    );
  }

  Widget _buildCompletedAppointmentCard(
    BuildContext context,
    CompletedAppointment appointment,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF191970).withAlpha((0.1 * 255).round()),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191970).withAlpha((0.05 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'COMPLETED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(appointment.preferredDate),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4169E1), Color(0xFF87CEFA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.event_available,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Follow-ups: ${appointment.followUpCount}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                if ((appointment.pendingFollowUpCount) > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Pending',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              appointment.studentName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191970),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              'ID: ${appointment.studentId}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  appointment.preferredTime,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            if (appointment.methodType != null &&
                appointment.methodType!.isNotEmpty)
              const SizedBox(height: 4),
            if (appointment.methodType != null &&
                appointment.methodType!.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.video_call, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      appointment.methodType!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.psychology, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    appointment.consultationType,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (appointment.purpose.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.flag, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      appointment.purpose,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (appointment.description != null &&
                appointment.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      appointment.description!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    _openFollowUpSessionsModal(context, appointment),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF191970),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.update_rounded, size: 16),
                label: const Text(
                  'Follow-up Sessions',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  Future<void> _openFollowUpSessionsModal(
    BuildContext context,
    CompletedAppointment appointment,
  ) async {
    final viewModel = Provider.of<CounselorFollowUpSessionsViewModel>(
      context,
      listen: false,
    );

    // Set current appointment
    viewModel.setCurrentAppointment(appointment.id, appointment.studentId);

    // Load follow-up sessions
    await viewModel.loadFollowUpSessions(appointment.id);

    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFollowUpSessionsModal(context, appointment),
    );
    // When the sessions modal closes, refresh completed appointments so
    // counts/badges/sorting reflect any changes made inside the modal
    if (mounted) {
      await _viewModel.loadCompletedAppointments(
        searchTerm: _viewModel.searchTerm,
      );
    }
  }

  Widget _buildFollowUpSessionsModal(
    BuildContext context,
    CompletedAppointment appointment,
  ) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF191970),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Follow-up Sessions - ${appointment.studentName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Consumer<CounselorFollowUpSessionsViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.followUpSessions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No follow-up sessions found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create a new follow-up session for this appointment',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _showCreateFollowUpModal(context, appointment),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF191970),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Create New Follow-up'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Sessions list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: viewModel.followUpSessions.length,
                          itemBuilder: (context, index) {
                            final session = viewModel.followUpSessions[index];
                            return _buildFollowUpSessionCard(
                              context,
                              session,
                              viewModel,
                            );
                          },
                        ),
                      ),
                      // Action buttons
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border(
                            top: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Row(
                          children: [
                            if (viewModel.canCreateNewFollowUp())
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showCreateFollowUpModal(
                                    context,
                                    appointment,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF191970),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Create New Follow-up'),
                                ),
                              )
                            else if (viewModel.canCreateNextFollowUp())
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showCreateFollowUpModal(
                                    context,
                                    appointment,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF191970),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Create Next Follow-up'),
                                ),
                              )
                            else
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                    foregroundColor: Colors.grey[600],
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Create Next Follow-up'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowUpSessionCard(
    BuildContext context,
    FollowUpSession session,
    CounselorFollowUpSessionsViewModel viewModel,
  ) {
    final statusColor = _getStatusColor(session.status);
    final statusText = _getStatusText(session.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF191970),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Follow-up #${session.followUpSequence}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                _formatDate(session.preferredDate),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                session.preferredTime,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.psychology, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  session.consultationType,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Add purpose field display (conditional)
          if (session.purpose != null && session.purpose!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.flag, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Purpose: ${session.purpose}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          // Add reason field display (conditional)
          if (session.reason != null && session.reason!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!session.isCancelled) ...[
                  Icon(Icons.list_alt, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    session.isCancelled
                        ? session.reason!
                        : 'Reason: ${session.reason}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          // Add description field display (conditional)
          if (session.description != null &&
              session.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.description, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Description: ${session.description}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (session.status == 'pending') ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: viewModel.markingCompletedSessionId == session.id
                        ? null
                        : () => _markSessionCompleted(context, session.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: viewModel.markingCompletedSessionId == session.id
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Mark Completed',
                            style: TextStyle(fontSize: 12),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showEditFollowUpModal(context, session),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.edit, size: 14),
                    label: const Text('Edit', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showCancelFollowUpModal(context, session),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Text(
                    'Status: $statusText',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  Future<void> _markSessionCompleted(
    BuildContext context,
    int sessionId,
  ) async {
    final viewModel = _viewModel;

    try {
      await viewModel.markSessionCompleted(sessionId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session marked as completed'),
            backgroundColor: Colors.green,
          ),
        );
        // Also refresh completed appointments to update counts/badges/sorting
        await viewModel.loadCompletedAppointments(
          searchTerm: viewModel.searchTerm,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCancelFollowUpModal(BuildContext context, FollowUpSession session) {
    // Reset loading state when opening the modal
    setState(() {
      _isCancelling = false;
    });

    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Follow-up Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please provide a reason for cancelling this follow-up session:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter cancellation reason...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          StatefulBuilder(
            builder: (context, setModalState) {
              return ElevatedButton(
                onPressed: _isCancelling
                    ? null
                    : () async {
                        final reason = reasonController.text.trim();
                        if (reason.isEmpty) return;

                        setModalState(() {
                          _isCancelling = true;
                        });

                        await _cancelFollowUp(context, session.id, reason);
                        if (context.mounted) Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: _isCancelling
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Confirm Cancellation'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showEditFollowUpModal(BuildContext context, FollowUpSession session) {
    // Reset loading state when opening the modal
    setState(() {
      _isUpdatingFollowUp = false;
    });

    final dateController = TextEditingController(text: session.preferredDate);
    final timeController = TextEditingController(text: session.preferredTime);
    final consultationTypeController = TextEditingController(
      text: session.consultationType,
    );
    final descriptionController = TextEditingController(
      text: session.description ?? '',
    );
    final reasonController = TextEditingController(text: session.reason ?? '');

    // Load availability for the session's date
    _viewModel.loadCounselorAvailability(session.preferredDate);

    showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: _viewModel,
        child: AlertDialog(
          title: const Text('Edit Follow-up Session'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Preferred Date *',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(
                          const Duration(days: 1),
                        ),
                        firstDate: DateTime.now().add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        dateController.text = date.toIso8601String().split(
                          'T',
                        )[0];
                        // Load availability for selected date
                        await _viewModel.loadCounselorAvailability(
                          dateController.text,
                        );
                        // Clear previous time selection if not valid anymore
                        final rawSlots =
                            _viewModel.counselorAvailability?.timeSlots ??
                            const <String>[];
                        final timeOptions =
                            TimeUtils.generateHalfHourRangeLabelsFromSlots(
                              rawSlots,
                            );
                        if (!timeOptions.contains(timeController.text)) {
                          timeController.text = '';
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Consumer<CounselorFollowUpSessionsViewModel>(
                    builder: (context, viewModel, child) {
                      final rawSlots =
                          viewModel.counselorAvailability?.timeSlots ??
                          const <String>[];
                      // Generate 30-minute increments from time slots
                      final timeOptions =
                          TimeUtils.generateHalfHourRangeLabelsFromSlots(
                            rawSlots,
                          );
                      // Find matching time range for existing value (handles both range and single time formats)
                      final matchedTime = TimeUtils.findMatchingTimeRange(
                        timeController.text,
                        timeOptions,
                      );
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Preferred Time *',
                          border: OutlineInputBorder(),
                        ),
                        items: timeOptions.isEmpty
                            ? [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('No available time slots'),
                                ),
                              ]
                            : timeOptions
                                  .map(
                                    (time) => DropdownMenuItem(
                                      value: time,
                                      child: Text(time),
                                    ),
                                  )
                                  .toList(),
                        initialValue: matchedTime,
                        onChanged: timeOptions.isEmpty
                            ? null
                            : (value) => timeController.text = value ?? '',
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Please select a time'
                            : null,
                        disabledHint: const Text('No available time slots'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Consultation Type *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Individual Counseling',
                        child: Text('Individual Counseling'),
                      ),
                      DropdownMenuItem(
                        value: 'Career Guidance',
                        child: Text('Career Guidance'),
                      ),
                      DropdownMenuItem(
                        value: 'Academic Counseling',
                        child: Text('Academic Counseling'),
                      ),
                      DropdownMenuItem(
                        value: 'Personal Development',
                        child: Text('Personal Development'),
                      ),
                      DropdownMenuItem(
                        value: 'Crisis Intervention',
                        child: Text('Crisis Intervention'),
                      ),
                    ],
                    initialValue: consultationTypeController.text.isNotEmpty
                        ? consultationTypeController.text
                        : null,
                    onChanged: (value) =>
                        consultationTypeController.text = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reasonController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Reason for Follow-up',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            StatefulBuilder(
              builder: (context, setModalState) {
                return ElevatedButton(
                  onPressed: _isUpdatingFollowUp
                      ? null
                      : () async {
                          if (dateController.text.isNotEmpty &&
                              timeController.text.isNotEmpty &&
                              consultationTypeController.text.isNotEmpty) {
                            setModalState(() {
                              _isUpdatingFollowUp = true;
                            });
                            await _updateFollowUp(
                              context,
                              session.id,
                              dateController.text,
                              timeController.text,
                              consultationTypeController.text,
                              descriptionController.text.trim().isEmpty
                                  ? null
                                  : descriptionController.text.trim(),
                              reasonController.text.trim().isEmpty
                                  ? null
                                  : reasonController.text.trim(),
                            );
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                  child: _isUpdatingFollowUp
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Save Changes'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelFollowUp(
    BuildContext context,
    int sessionId,
    String reason,
  ) async {
    final viewModel = _viewModel;

    try {
      await viewModel.cancelFollowUp(sessionId, reason);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Follow-up session cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
        // Refresh the follow-up sessions to show updated state
        await viewModel.loadFollowUpSessions(
          viewModel.currentParentAppointmentId!,
        );
        // Also refresh completed appointments to update counts/badges/sorting
        await viewModel.loadCompletedAppointments(
          searchTerm: viewModel.searchTerm,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  Future<void> _updateFollowUp(
    BuildContext context,
    int sessionId,
    String preferredDate,
    String preferredTime,
    String consultationType,
    String? description,
    String? reason,
  ) async {
    setState(() {
      _isUpdatingFollowUp = true;
    });

    final viewModel = _viewModel;

    try {
      await viewModel.updateFollowUp(
        sessionId: sessionId,
        preferredDate: preferredDate,
        preferredTime: preferredTime,
        consultationType: consultationType,
        description: description,
        reason: reason,
      );
      // Refresh the follow-up sessions to show updated state
      await viewModel.loadFollowUpSessions(
        viewModel.currentParentAppointmentId!,
      );
      // Also refresh completed appointments to update counts/badges/sorting
      await viewModel.loadCompletedAppointments(
        searchTerm: viewModel.searchTerm,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Follow-up session updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingFollowUp = false;
        });
      }
    }
  }

  void _showCreateFollowUpModal(
    BuildContext context,
    CompletedAppointment appointment,
  ) {
    Navigator.pop(context); // Close the sessions modal first

    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final consultationTypeController = TextEditingController();
    final descriptionController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: _viewModel,
        child: AlertDialog(
          title: const Text('Create Follow-up Session'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Preferred Date *',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(
                          const Duration(days: 1),
                        ),
                        firstDate: DateTime.now().add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        dateController.text = date.toIso8601String().split(
                          'T',
                        )[0];
                        // Load availability for selected date
                        await _viewModel.loadCounselorAvailability(
                          dateController.text,
                        );
                        // Clear previous time selection if not valid anymore
                        final rawSlots =
                            _viewModel.counselorAvailability?.timeSlots ??
                            const <String>[];
                        final timeOptions =
                            TimeUtils.generateHalfHourRangeLabelsFromSlots(
                              rawSlots,
                            );
                        if (!timeOptions.contains(timeController.text)) {
                          timeController.text = '';
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Consumer<CounselorFollowUpSessionsViewModel>(
                    builder: (context, viewModel, child) {
                      final rawSlots =
                          viewModel.counselorAvailability?.timeSlots ??
                          const <String>[];
                      // Generate 30-minute increments from time slots
                      final timeOptions =
                          TimeUtils.generateHalfHourRangeLabelsFromSlots(
                            rawSlots,
                          );
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Preferred Time *',
                          border: OutlineInputBorder(),
                        ),
                        items: timeOptions.isEmpty
                            ? [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('No available time slots'),
                                ),
                              ]
                            : timeOptions
                                  .map(
                                    (time) => DropdownMenuItem(
                                      value: time,
                                      child: Text(time),
                                    ),
                                  )
                                  .toList(),
                        initialValue:
                            timeOptions.contains(timeController.text) &&
                                timeController.text.isNotEmpty
                            ? timeController.text
                            : null,
                        onChanged: timeOptions.isEmpty
                            ? null
                            : (value) => timeController.text = value ?? '',
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Please select a time'
                            : null,
                        disabledHint: const Text('No available time slots'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Consultation Type *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Individual Counseling',
                        child: Text('Individual Counseling'),
                      ),
                      DropdownMenuItem(
                        value: 'Career Guidance',
                        child: Text('Career Guidance'),
                      ),
                      DropdownMenuItem(
                        value: 'Academic Counseling',
                        child: Text('Academic Counseling'),
                      ),
                      DropdownMenuItem(
                        value: 'Personal Development',
                        child: Text('Personal Development'),
                      ),
                      DropdownMenuItem(
                        value: 'Crisis Intervention',
                        child: Text('Crisis Intervention'),
                      ),
                    ],
                    onChanged: (value) =>
                        consultationTypeController.text = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reasonController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Reason for Follow-up',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            StatefulBuilder(
              builder: (context, setModalState) {
                return ElevatedButton(
                  onPressed: _isCreatingFollowUp
                      ? null
                      : () async {
                          if (dateController.text.isNotEmpty &&
                              timeController.text.isNotEmpty &&
                              consultationTypeController.text.isNotEmpty) {
                            setState(() {
                              _isCreatingFollowUp = true;
                            });
                            await _createFollowUp(
                              context,
                              appointment,
                              dateController.text,
                              timeController.text,
                              consultationTypeController.text,
                              descriptionController.text.trim().isEmpty
                                  ? null
                                  : descriptionController.text.trim(),
                              reasonController.text.trim().isEmpty
                                  ? null
                                  : reasonController.text.trim(),
                            );
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                  child: _isCreatingFollowUp
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Create Follow-up'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createFollowUp(
    BuildContext context,
    CompletedAppointment appointment,
    String preferredDate,
    String preferredTime,
    String consultationType,
    String? description,
    String? reason,
  ) async {
    final viewModel = _viewModel;

    try {
      await viewModel.createFollowUp(
        parentAppointmentId: appointment.id,
        studentId: appointment.studentId,
        preferredDate: preferredDate,
        preferredTime: preferredTime,
        consultationType: consultationType,
        description: description,
        reason: reason,
      );
      // Refresh lists regardless of dialog context state
      await viewModel.loadFollowUpSessions(appointment.id);
      await viewModel.loadCompletedAppointments(
        searchTerm: viewModel.searchTerm,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Follow-up session created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create follow-up session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingFollowUp = false;
        });
      }
    }
  }
}
