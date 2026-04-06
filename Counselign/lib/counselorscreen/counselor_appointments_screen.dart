import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/counselor_appointments_viewmodel.dart';
import 'widgets/counselor_screen_wrapper.dart';
import 'state/counselor_scheduled_appointments_viewmodel.dart';
import 'widgets/weekly_schedule.dart';
import 'widgets/mini_calendar.dart';
import 'models/appointment.dart';

class CounselorAppointmentsScreen extends StatefulWidget {
  const CounselorAppointmentsScreen({super.key});

  @override
  State<CounselorAppointmentsScreen> createState() =>
      _CounselorAppointmentsScreenState();
}

class _CounselorAppointmentsScreenState
    extends State<CounselorAppointmentsScreen> {
  late CounselorAppointmentsViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _viewModel = CounselorAppointmentsViewModel();
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
        currentBottomNavIndex: 1,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 1024;
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            // Status Grid Container
            Container(
              padding: const EdgeInsets.all(16),
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
              ),
              child: _buildStatusGrid(context),
            ),
            const SizedBox(height: 12),
            // Search, Filter, and Appointments Container
            Container(
              padding: const EdgeInsets.all(16),
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
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSearchRow(context),
                  const SizedBox(height: 8),
                  _buildFilterRow(context),
                  const SizedBox(height: 16),
                  _buildList(context),
                ],
              ),
            ),
            const SizedBox(height: 100), // Bottom padding for navigation
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
                  'Manage Appointments',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Review and manage appointment requests from students',
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

  Widget _buildSearchRow(BuildContext context) {
    return Consumer<CounselorAppointmentsViewModel>(
      builder: (context, vm, _) {
        return TextField(
          controller: _searchController,
          onChanged: vm.updateSearchQuery,
          decoration: InputDecoration(
            hintText: 'Search by name, ID, purpose...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
          ),
        );
      },
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return Consumer<CounselorAppointmentsViewModel>(
      builder: (context, vm, _) {
        return Row(
          children: [
            IconButton(
              tooltip: 'Filter by date range',
              onPressed: () async {
                final now = DateTime.now();
                final initialFirst =
                    vm.dateRange?.start ??
                    DateTime(
                      now.year,
                      now.month,
                      now.day,
                    ).subtract(const Duration(days: 30));
                final initialLast = vm.dateRange?.end ?? now;
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(now.year - 5),
                  lastDate: DateTime(now.year + 1),
                  initialDateRange: DateTimeRange(
                    start: initialFirst,
                    end: initialLast,
                  ),
                );
                if (!mounted) return;
                vm.updateDateRange(picked);
              },
              icon: const Icon(Icons.date_range),
            ),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: vm.statusFilter,
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'approved', child: Text('Approved')),
                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                DropdownMenuItem(value: '', child: Text('All')),
              ],
              onChanged: (value) {
                if (value != null) vm.updateStatusFilter(value);
              },
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: vm.loadAppointments,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusGrid(BuildContext context) {
    return Consumer<CounselorAppointmentsViewModel>(
      builder: (context, vm, _) {
        final counts = vm.statusCounts;
        Widget chip(IconData icon, Color color, String label, int count) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: color.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withAlpha((0.2 * 255).round()),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  '$label: $count',
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }

        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3.6,
          ),
          children: [
            chip(
              Icons.hourglass_empty,
              Colors.orange,
              'Pending',
              counts['pending'] ?? 0,
            ),
            chip(
              Icons.check_circle,
              Colors.green,
              'Approved',
              counts['approved'] ?? 0,
            ),
            chip(Icons.cancel, Colors.red, 'Rejected', counts['rejected'] ?? 0),
            chip(
              Icons.task_alt,
              Colors.blue,
              'Completed',
              counts['completed'] ?? 0,
            ),
            chip(
              Icons.remove_circle,
              Colors.deepOrange,
              'Cancelled',
              counts['cancelled'] ?? 0,
            ),
          ],
        );
      },
    );
  }

  Widget _buildList(BuildContext context) {
    return Consumer<CounselorAppointmentsViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF191970)),
            ),
          );
        }
        if (vm.errorMessage != null) {
          return Center(
            child: Text(
              vm.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        if (vm.appointments.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 12),
              Text('No appointments match your filters'),
            ],
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vm.appointments.length,
          itemBuilder: (context, index) {
            final appt = vm.appointments[index];
            return _buildAppointmentTile(context, appt);
          },
        );
      },
    );
  }

  Widget _buildAppointmentTile(
    BuildContext context,
    CounselorAppointment appt,
  ) {
    final statusColor = _statusColor(appt.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha((0.12 * 255).round()),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    appt.status[0].toUpperCase() + appt.status.substring(1),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDateOnly(appt.appointmentDate ?? appt.preferredDate),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Student: ${appt.studentName.isNotEmpty ? appt.studentName : appt.username ?? appt.studentId}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191970),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'ID: ${appt.studentId}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 6),
            Text(
              'Preferred time: ${appt.preferredTime ?? 'N/A'}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            if ((appt.methodType ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Method type: ${appt.methodType}',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
            if ((appt.purpose ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Purpose: ${appt.purpose}',
                style: TextStyle(color: Colors.grey[800]),
              ),
            ],
            if ((appt.notes ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Notes: ${appt.notes}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 12),
            _buildActions(context, appt),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showDetailsDialog(context, appt),
                icon: const Icon(Icons.visibility),
                label: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, CounselorAppointment appt) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Appointment Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailsRow(
                  'Student',
                  appt.studentName.isNotEmpty
                      ? appt.studentName
                      : (appt.username ?? appt.studentId),
                ),
                _detailsRow('ID', appt.studentId),
                _detailsRow('Status', appt.status),
                _detailsRow(
                  'Preferred date',
                  _formatDateOnly(appt.preferredDate),
                ),
                _detailsRow('Preferred time', appt.preferredTime ?? 'N/A'),
                _detailsRow(
                  'Method type',
                  (appt.methodType ?? '').trim().isNotEmpty
                      ? appt.methodType!.trim()
                      : 'N/A',
                ),
                _detailsRow(
                  'Purpose',
                  (appt.purpose ?? '').trim().isNotEmpty
                      ? appt.purpose!.trim()
                      : 'N/A',
                ),
                _detailsRow(
                  'Consultation type',
                  (appt.consultationType ?? '').isNotEmpty
                      ? appt.consultationType!
                      : 'N/A',
                ),
                _detailsRow(
                  'Note/Description',
                  (appt.notes ?? '').trim().isNotEmpty
                      ? appt.notes!.trim()
                      : 'N/A',
                ),
                if (appt.status == 'cancelled' || appt.status == 'rejected')
                  _detailsRow(
                    'Reason',
                    (appt.reason ?? '').trim().isNotEmpty
                        ? appt.reason!.trim()
                        : 'N/A',
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, CounselorAppointment appt) {
    return Consumer<CounselorAppointmentsViewModel>(
      builder: (context, vm, child) {
        if (appt.status == 'pending') {
          return Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: vm.approvingAppointmentId == appt.id
                      ? null
                      : () async {
                          final ok = await vm.approveAppointment(appt.id);
                          if (!mounted) return;
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? 'Appointment approved'
                                      : 'Approval failed',
                                ),
                                backgroundColor: ok ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: vm.approvingAppointmentId == appt.id
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
                      : const Text('Approve'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      _showReasonDialog(context, vm, appt.id, action: 'reject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Reject'),
                ),
              ),
            ],
          );
        }
        if (appt.status == 'approved') {
          return Row(
            children: [
              Expanded(
                child: Text(
                  'No actions available',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: Text(
                'No actions available',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showReasonDialog(
    BuildContext parentContext,
    CounselorAppointmentsViewModel vm,
    String appointmentId, {
    required String action,
  }) {
    final controller = TextEditingController();

    showDialog<void>(
      context: parentContext,
      builder: (dialogContext) {
        return ChangeNotifierProvider.value(
          value: vm,
          child: Consumer<CounselorAppointmentsViewModel>(
            builder: (context, viewModel, child) {
              final isLoading = action == 'reject'
                  ? viewModel.rejectingAppointmentId == appointmentId
                  : viewModel.cancellingAppointmentId == appointmentId;

              return AlertDialog(
                title: Text(
                  action == 'reject'
                      ? 'Reject Appointment'
                      : 'Cancel Appointment',
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Please provide a reason:'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter reason...',
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => Navigator.of(dialogContext).pop(),
                    child: const Text('Close'),
                  ),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final reason = controller.text.trim();
                            if (reason.isEmpty) {
                              if (!parentContext.mounted) return;
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Reason is required'),
                                ),
                              );
                              return;
                            }

                            bool ok = false;
                            if (action == 'reject') {
                              ok = await viewModel.rejectAppointment(
                                appointmentId,
                                reason,
                              );
                            } else {
                              ok = await viewModel.cancelAppointment(
                                appointmentId,
                                reason,
                              );
                            }

                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                            if (parentContext.mounted) {
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ok
                                        ? 'Updated successfully'
                                        : 'Update failed',
                                  ),
                                  backgroundColor: ok
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              );
                            }
                          },
                    child: isLoading
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
                        : Text(
                            action == 'reject'
                                ? 'Submit Rejection'
                                : 'Submit Cancellation',
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String _formatDateOnly(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.orange;
      case 'pending':
      default:
        return Colors.orange;
    }
  }
}
