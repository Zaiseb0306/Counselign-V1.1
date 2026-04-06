import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'state/counselor_scheduled_appointments_viewmodel.dart';
import 'widgets/counselor_screen_wrapper.dart';
import 'widgets/appointments_cards.dart';
import 'widgets/weekly_schedule.dart';
import 'widgets/mini_calendar.dart';
import 'widgets/cancellation_reason_dialog.dart';
import 'models/scheduled_appointment.dart';

class CounselorScheduledAppointmentsScreen extends StatefulWidget {
  const CounselorScheduledAppointmentsScreen({super.key});

  @override
  State<CounselorScheduledAppointmentsScreen> createState() =>
      _CounselorScheduledAppointmentsScreenState();
}

class _CounselorScheduledAppointmentsScreenState
    extends State<CounselorScheduledAppointmentsScreen> {
  late CounselorScheduledAppointmentsViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _viewModel = CounselorScheduledAppointmentsViewModel();
    _viewModel.initialize();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    _removeOverlay();
    _viewModel.dispose();
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
            onPressed: () {
              _showSchedulesModal(context);
            },
            backgroundColor: const Color(0xFF060E57),
            foregroundColor: Colors.white,
            tooltip: 'View Schedules',
            child: const Icon(Icons.calendar_today),
          ),
        ),
      ),
    );
  }

  void _onSearchChanged() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _viewModel.setSearchQuery(_searchController.text);
      }
    });
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
        currentBottomNavIndex: 1, // Scheduled Appointments (index 1)
        child: _buildMainContent(context),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile
              ? 16
              : isTablet
              ? 20
              : 24,
          vertical: isMobile ? 16 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: isMobile ? 20 : 30),
            _buildContent(context, isMobile, isTablet, isDesktop),
          ],
        ),
      ),
    );
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
              Icons.calendar_today,
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
                  'Scheduled Consultations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'View and manage scheduled consultation appointments',
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
    return Consumer<CounselorScheduledAppointmentsViewModel>(
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
                  setState(() {});
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
                            _searchController.clear();
                            viewModel.setSearchQuery('');
                            setState(() {});
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

  Widget _buildContent(
    BuildContext context,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    return Consumer<CounselorScheduledAppointmentsViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return _buildLoadingState();
        }

        if (viewModel.error != null) {
          return _buildErrorState(viewModel.error!);
        }

        // Always show appointments section only - sidebar is now a modal
        return _buildAppointmentsSection(
          context,
          viewModel,
          viewModel.filteredAppointments,
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 200,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF060E57)),
              ),
              SizedBox(height: 16),
              Text(
                'Loading appointments...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SizedBox(
      height: 300, // Increased height to accommodate all content
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading appointments',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _viewModel.refresh(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF060E57),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsSection(
    BuildContext context,
    CounselorScheduledAppointmentsViewModel viewModel,
    List<CounselorScheduledAppointment> appointments,
  ) {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(context),
          const SizedBox(height: 24),
          if (appointments.isEmpty)
            _buildEmptyAppointmentsState(viewModel.searchQuery.isNotEmpty)
          else
            AppointmentsCards(
              appointments: appointments,
              onUpdateStatus: (appointment, status) =>
                  _handleUpdateStatus(appointment, status),
              onCancelAppointment: (appointment) =>
                  _handleCancelAppointment(appointment),
              onNavigateToFollowUp: () => _navigateToFollowUpSessions(context),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyAppointmentsState(bool isSearching) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Icon(
                isSearching ? Icons.search_off : Icons.info_outline,
                size: 48,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              Text(
                isSearching
                    ? 'No appointments match your search.'
                    : 'No scheduled appointments found.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToFollowUpSessions(BuildContext context) {
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/counselor/follow-up');
    }
  }

  void _showSchedulesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            // Modal header
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
            // Modal content - using viewModel directly instead of Consumer
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    WeeklySchedule(schedule: _viewModel.counselorSchedule),
                    const SizedBox(height: 24),
                    MiniCalendar(
                      viewModel: _viewModel,
                      onDateSelected: (date) {
                        debugPrint('Selected date: $date');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUpdateStatus(
    CounselorScheduledAppointment appointment,
    String status,
  ) async {
    try {
      await _viewModel.updateAppointmentStatus(
        appointment.id.toString(),
        status,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment ${status.toLowerCase()} successfully'),
            backgroundColor: status == 'completed' ? Colors.green : Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleCancelAppointment(
    CounselorScheduledAppointment appointment,
  ) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => CancellationReasonDialog(
        appointmentId: appointment.id.toString(),
        studentName: appointment.studentName,
        onConfirm: (reason) async {
          try {
            await _viewModel.updateAppointmentStatus(
              appointment.id.toString(),
              'cancelled',
              rejectionReason: reason,
            );

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Appointment cancelled successfully! An email notification has been sent to the user.',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } catch (e) {
            // Re-throw the error so the dialog can handle it
            rethrow;
          }
        },
      ),
    );
  }
}
