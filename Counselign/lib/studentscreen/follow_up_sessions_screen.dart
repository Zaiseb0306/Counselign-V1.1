import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/follow_up_sessions_viewmodel.dart';
import 'widgets/student_screen_wrapper.dart';
import 'models/follow_up_appointment.dart';
import 'models/appointment.dart';

class FollowUpSessionsScreen extends StatefulWidget {
  const FollowUpSessionsScreen({super.key});

  @override
  State<FollowUpSessionsScreen> createState() => _FollowUpSessionsScreenState();
}

class _FollowUpSessionsScreenState extends State<FollowUpSessionsScreen> {
  late FollowUpSessionsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = FollowUpSessionsViewModel();
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
        currentBottomNavIndex: 3, // Follow-up Sessions tab
        child: Stack(
          children: [
            _buildMainContent(context),
            // Follow-up Sessions Modal
            Consumer<FollowUpSessionsViewModel>(
              builder: (context, viewModel, child) {
                return viewModel.showFollowUpSessionsModal
                    ? _buildFollowUpSessionsModal(context, viewModel)
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- MAIN CONTENT ----------------
  Widget _buildMainContent(BuildContext context) {
    return Consumer<FollowUpSessionsViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              // Pending Follow-up Section - Above search bar
              Consumer<FollowUpSessionsViewModel>(
                builder: (context, viewModel, child) {
                  final pendingAppointments = viewModel.pendingAppointments;
                  if (pendingAppointments.isNotEmpty &&
                      viewModel.searchTerm.isEmpty) {
                    return Column(
                      children: [
                        _buildPendingSection(
                          context,
                          viewModel,
                          pendingAppointments,
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
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
                  border: Border.all(
                    color: const Color(0xFFE5E9F2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(context, viewModel),
                      const SizedBox(height: 24),
                      _buildCompletedAppointmentsList(context, viewModel),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 100,
              ), // Add bottom padding for navigation bar
            ],
          ),
        );
      },
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
              Icons.update_rounded,
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
                  'View your completed appointments and their follow-up sessions',
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

  Widget _buildSearchBar(
    BuildContext context,
    FollowUpSessionsViewModel viewModel,
  ) {
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
        controller: viewModel.searchController,
        onChanged: viewModel.searchAppointments,
        decoration: InputDecoration(
          hintText: 'Search appointments...',
          hintStyle: TextStyle(color: const Color(0xFF64748B), fontSize: 14),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: const Color(0xFF64748B),
            size: 20,
          ),
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
  }

  Widget _buildCompletedAppointmentsList(
    BuildContext context,
    FollowUpSessionsViewModel viewModel,
  ) {
    if (viewModel.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF060E57)),
          ),
        ),
      );
    }

    if (viewModel.hasError) {
      return _buildErrorState(context, viewModel);
    }

    final pendingAppointments = viewModel.pendingAppointments;
    final regularAppointments = viewModel.regularAppointments;

    if (pendingAppointments.isEmpty && regularAppointments.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Regular Completed Appointments Section only
        if (regularAppointments.isNotEmpty) ...[
          _buildRegularSection(context, viewModel, regularAppointments),
        ],
      ],
    );
  }

  Widget _buildPendingSection(
    BuildContext context,
    FollowUpSessionsViewModel viewModel,
    List<Appointment> pendingAppointments,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF5F0), Color(0xFFFFE8E0)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF6B35), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Color(0xFFFF6B35),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Appointment with a Pending Follow-up',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                    Text(
                      '${pendingAppointments.length} appointment${pendingAppointments.length == 1 ? '' : 's'} requiring attention',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...pendingAppointments.map(
            (appointment) => _buildAppointmentCard(
              context,
              viewModel,
              appointment,
              isPending: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularSection(
    BuildContext context,
    FollowUpSessionsViewModel viewModel,
    List<Appointment> regularAppointments,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'My Completed Appointments (${regularAppointments.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF060E57),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...regularAppointments.map(
          (appointment) => _buildAppointmentCard(
            context,
            viewModel,
            appointment,
            isPending: false,
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    FollowUpSessionsViewModel viewModel,
    Appointment appointment, {
    bool isPending = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isPending
            ? Border.all(color: const Color(0xFFFF6B35), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isPending
                ? const Color(0xFFFF6B35).withValues(alpha: 0.15)
                : const Color(0xFF060E57).withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
            viewModel.openFollowUpSessionsModal(appointment.id);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status and indicators
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.consultationType ??
                                'General Consultation',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF060E57),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Counselor: ${appointment.counselorName ?? 'No Preference'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Follow-up count and pending indicators
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Follow-up count badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4169E1), Color(0xFF87CEFA)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF4169E1,
                                ).withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add_circle_outline,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Follow-ups: ${appointment.followUpCount ?? 0}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Pending indicator
                        if ((appointment.pendingFollowUpCount ?? 0) > 0) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFFF6B35,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.warning_rounded,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Pending',
                                  style: TextStyle(
                                    fontSize: 11,
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
                  ],
                ),
                const SizedBox(height: 12),
                // Date and time
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appointment.formattedDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appointment.preferredTime ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                // Method Type
                if (appointment.methodType != null &&
                    appointment.methodType!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.video_call_rounded,
                        size: 16,
                        color: const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Method: ${appointment.methodType!}',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                // Purpose
                if (appointment.purpose != null &&
                    appointment.purpose!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.flag_rounded,
                        size: 16,
                        color: const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Purpose: ${appointment.purpose!}',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                // Description
                if (appointment.description != null &&
                    appointment.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    appointment.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                // Follow-up sessions button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF060E57), Color(0xFF4169E1)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Follow-up Sessions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    FollowUpSessionsViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: const Color(0xFFEF4444).withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load appointments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF060E57),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: viewModel.loadCompletedAppointments,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF060E57),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 64,
            color: const Color(0xFF64748B).withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          const Text(
            'No completed appointments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF060E57),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any completed appointments yet.\nFollow-up sessions will appear here once you complete your appointments.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpSessionsModal(
    BuildContext context,
    FollowUpSessionsViewModel viewModel,
  ) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets + const EdgeInsets.all(16),
        duration: const Duration(milliseconds: 250),
        curve: Curves.decelerate,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModalHeader(context, viewModel),
                  _buildModalContent(context, viewModel),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalHeader(
    BuildContext context,
    FollowUpSessionsViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF060E57),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.update_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Follow-up Sessions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Appointment #${viewModel.selectedAppointmentId}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: viewModel.closeFollowUpSessionsModal,
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildModalContent(
    BuildContext context,
    FollowUpSessionsViewModel viewModel,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.65;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (viewModel.isLoadingFollowUpSessions)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF060E57)),
              ),
            )
          else if (viewModel.followUpSessions.isEmpty)
            _buildEmptyFollowUpState(context)
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: viewModel.followUpSessions.length,
                itemBuilder: (context, index) {
                  final session = viewModel.followUpSessions[index];
                  return _buildFollowUpSessionCard(context, session);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyFollowUpState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 48,
            color: const Color(0xFF64748B).withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          const Text(
            'No follow-up sessions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF060E57),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This appointment doesn\'t have any follow-up sessions yet.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpSessionCard(
    BuildContext context,
    FollowUpAppointment session,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF060E57).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getStatusColor(session.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getStatusIcon(session.status),
                  color: _getStatusColor(session.status),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Follow-up #${session.followUpSequence}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF060E57),
                      ),
                    ),
                    Text(
                      session.consultationType,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(session.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  session.statusDisplay,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(session.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: const Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                session.formattedDate,
                style: TextStyle(fontSize: 12, color: const Color(0xFF64748B)),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: const Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                session.formattedTime,
                style: TextStyle(fontSize: 12, color: const Color(0xFF64748B)),
              ),
            ],
          ),
          if (session.description != null &&
              session.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              session.description!,
              style: TextStyle(fontSize: 12, color: const Color(0xFF64748B)),
            ),
          ],
          if (session.reason != null && session.reason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              session.isCancelled
                  ? session.reason!
                  : 'Reason: ${session.reason!}',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF64748B),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'approved':
        return const Color(0xFF10B981);
      case 'rejected':
        return const Color(0xFFEF4444);
      case 'completed':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.help_rounded;
    }
  }
}
