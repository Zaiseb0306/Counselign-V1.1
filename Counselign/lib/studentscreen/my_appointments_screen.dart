import 'package:flutter/material.dart';
import 'state/my_appointments_viewmodel.dart' show MyAppointmentsViewModel;
import 'package:provider/provider.dart';
import 'widgets/student_screen_wrapper.dart';
import 'widgets/appointment_card.dart';
import 'models/appointment.dart';
import 'models/counselor_availability.dart';
import 'models/counselor_schedule.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late MyAppointmentsViewModel _viewModel;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _viewModel = MyAppointmentsViewModel();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      _viewModel.updateSelectedTab(_tabController.index);
    });
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: StudentScreenWrapper(
        currentBottomNavIndex: 2, // My Appointments tab
        child: Stack(
          children: [
            _buildMainContent(context),
            // Floating calendar toggle button
            _buildFloatingCalendarToggle(context),
            // Calendar drawer overlay
            _buildCounselorCalendarDrawer(context),
          ],
        ),
      ),
    );
  }

  // header handled by Scaffold.appBar

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
            _buildPageHeader(context),
            SizedBox(height: isMobile ? 20 : 30),
            _buildApprovedAppointmentsSection(context),
            SizedBox(height: isMobile ? 20 : 30),
            _buildPendingAppointmentsSection(context),
            SizedBox(height: isMobile ? 20 : 30),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.05 * 255).round()),
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
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTabBar(context),
                    SizedBox(height: isMobile ? 12 : 16),
                    _buildFilterOptions(context),
                    SizedBox(height: isMobile ? 12 : 16),
                    _buildTabContent(context),
                  ],
                ),
              ),
            ),
            SizedBox(height: isMobile ? 24 : 32),
            // Add bottom padding to ensure content doesn't get cut off
            SizedBox(height: isMobile ? 80 : 100),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
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
              Icons.calendar_month,
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
                  'My Appointments',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'View and manage your counseling appointments',
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

  Widget _buildApprovedAppointmentsSection(BuildContext context) {
    return Consumer<MyAppointmentsViewModel>(
      builder: (context, viewModel, child) {
        final approvedAppointments = viewModel.getApprovedAppointments();
        debugPrint(
          'Approved appointments count: ${approvedAppointments.length}',
        );
        if (approvedAppointments.isEmpty) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF28A745).withAlpha((0.3 * 255).round()),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF28A745),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Approved Appointment',
                    style: TextStyle(
                      color: Color(0xFF28A745),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _buildApprovedAppointmentTicket(
                context,
                approvedAppointments.first,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingAppointmentsSection(BuildContext context) {
    return Consumer<MyAppointmentsViewModel>(
      builder: (context, viewModel, child) {
        final pendingAppointments = viewModel.getPendingAppointments();
        debugPrint('Pending appointments count: ${pendingAppointments.length}');
        if (pendingAppointments.isEmpty) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFF9800).withAlpha((0.3 * 255).round()),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    color: const Color(0xFFFF9800),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Pending Appointment',
                    style: TextStyle(
                      color: Color(0xFFFF9800),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              ...pendingAppointments.map(
                (appointment) =>
                    _buildPendingAppointmentForm(context, appointment),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: isMobile,
        tabs: [
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.list_alt, size: isMobile ? 14 : 16),
                  const SizedBox(width: 4),
                  Text('All', style: TextStyle(fontSize: isMobile ? 12 : 14)),
                ],
              ),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.task_alt, size: isMobile ? 14 : 16),
                  const SizedBox(width: 4),
                  Text(
                    'Completed',
                    style: TextStyle(fontSize: isMobile ? 12 : 14),
                  ),
                ],
              ),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel_outlined, size: isMobile ? 14 : 16),
                  const SizedBox(width: 4),
                  Text(
                    'Cancelled',
                    style: TextStyle(fontSize: isMobile ? 12 : 14),
                  ),
                ],
              ),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel, size: isMobile ? 14 : 16),
                  const SizedBox(width: 4),
                  Text(
                    'Rejected',
                    style: TextStyle(fontSize: isMobile ? 12 : 14),
                  ),
                ],
              ),
            ),
          ),
        ],
        labelColor: const Color(0xFF0D6EFD),
        unselectedLabelColor: const Color(0xFF6C757D),
        indicatorColor: const Color(0xFF0D6EFD),
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    );
  }

  // ----------------- MISSING METHODS -----------------

  Widget _buildFilterOptions(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Consumer<MyAppointmentsViewModel>(
      builder: (context, viewModel, child) {
        return Row(
          children: [
            // Search input
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: viewModel.searchController,
                onChanged: (value) => viewModel.updateSearchTerm(value),
                decoration: InputDecoration(
                  labelText: 'Search appointments...',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: isMobile ? 8 : 12,
                  ),
                ),
              ),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            // Date filter icon-only button
            Container(
              decoration: BoxDecoration(
                color: viewModel.dateFilter.isNotEmpty
                    ? const Color(0xFF0D6EFD).withValues(alpha: 0.1)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: viewModel.dateFilter.isNotEmpty
                      ? const Color(0xFF0D6EFD)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: IconButton(
                tooltip: viewModel.dateFilter.isNotEmpty
                    ? 'Clear month filter (${viewModel.dateFilter})'
                    : 'Filter by month',
                icon: Icon(
                  viewModel.dateFilter.isNotEmpty
                      ? Icons.close_rounded
                      : Icons.calendar_today,
                  color: viewModel.dateFilter.isNotEmpty
                      ? const Color(0xFF0D6EFD)
                      : const Color(0xFF64748B),
                  size: isMobile ? 20 : 22,
                ),
                onPressed: () async {
                  if (viewModel.dateFilter.isNotEmpty) {
                    // Clear filter
                    viewModel.dateFilterController.clear();
                    viewModel.updateDateFilter('');
                    return;
                  }

                  final initial = viewModel.dateFilter.isNotEmpty
                      ? DateTime.parse('${viewModel.dateFilter}-01')
                      : DateTime.now();

                  final DateTime? picked =
                      await _showMonthYearPicker(context, initial);
                  if (picked != null) {
                    final formattedDate =
                        '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
                    viewModel.dateFilterController.text = formattedDate;
                    viewModel.updateDateFilter(formattedDate);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<DateTime?> _showMonthYearPicker(
    BuildContext context,
    DateTime initialDate,
  ) async {
    const monthNames = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return showDialog<DateTime>(
      context: context,
      builder: (context) {
        int year = initialDate.year;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => setState(() => year--),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text('$year'),
                  IconButton(
                    onPressed: () => setState(() => year++),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              content: SizedBox(
                width: 300,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(12, (index) {
                    final month = index + 1;
                    final label = monthNames[index];
                    return ChoiceChip(
                      label: Text(label),
                      selected: year == initialDate.year &&
                          month == initialDate.month,
                      onSelected: (_) {
                        Navigator.of(context)
                            .pop(DateTime(year, month, 1));
                      },
                    );
                  }),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTabContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Consumer<MyAppointmentsViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoadingAppointments) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final appointments = viewModel.getFilteredAppointments();

        // Debug information
        debugPrint('=== My Appointments Debug ===');
        debugPrint('Total appointments: ${viewModel.allAppointments.length}');
        debugPrint('Filtered appointments: ${appointments.length}');
        debugPrint(
          'Pending appointments: ${viewModel.getPendingAppointments().length}',
        );
        debugPrint(
          'Approved appointments: ${viewModel.getApprovedAppointments().length}',
        );
        debugPrint('Search term: "${viewModel.searchTerm}"');
        debugPrint('Date filter: "${viewModel.dateFilter}"');
        debugPrint('Selected tab: ${viewModel.selectedTabIndex}');
        debugPrint('============================');

        if (appointments.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No appointments found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your appointments will appear here once scheduled',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: appointments.map((appointment) {
            return AppointmentCard(
              appointment: appointment,
              showReason:
                  viewModel.selectedTabIndex == 0 ||
                  viewModel.selectedTabIndex == 2 ||
                  viewModel.selectedTabIndex == 3,
              isMobile: isMobile,
              isTablet: isTablet,
              onEdit: () => _handleEditAppointment(context, appointment),
              onCancel: () => _handleCancelAppointment(context, appointment),
              onDelete: () => _handleDeleteAppointment(context, appointment),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPendingAppointmentForm(
    BuildContext context,
    Appointment appointment,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Consumer<MyAppointmentsViewModel>(
      builder: (context, viewModel, child) {
        final isEditing = viewModel.isEditing(appointment.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFF9800).withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form fields
              if (isMobile) ...[
                _buildMobileFormField(
                  label: 'Consultation Type',
                  child: DropdownButtonFormField<String>(
                    initialValue: _getValidDropdownValue(
                      appointment.consultationType,
                      const ['Individual Consultation', 'Group Consultation'],
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Select consultation type',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Individual Consultation',
                        child: Text('Individual Consultation'),
                      ),
                      DropdownMenuItem(
                        value: 'Group Consultation',
                        child: Text('Group Consultation'),
                      ),
                    ],
                    onChanged: isEditing
                        ? (value) {
                            if (value != null) {
                              viewModel
                                      .getPendingController(
                                        appointment.id,
                                        'consultation_type',
                                        '',
                                      )
                                      .text =
                                  value;
                            }
                          }
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                _buildMobileFormField(
                  label: 'Preferred Date',
                  child: TextFormField(
                    controller: viewModel.getPendingController(
                      appointment.id,
                      'preferred_date',
                      appointment.preferredDate ?? '',
                    ),
                    enabled: isEditing,
                    decoration: const InputDecoration(
                      hintText: 'Select date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: isEditing
                        ? () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now().add(
                                const Duration(days: 1),
                              ),
                              firstDate: DateTime.now().add(
                                const Duration(days: 1),
                              ),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (picked != null) {
                              final formattedDate =
                                  '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                              viewModel
                                      .getPendingController(
                                        appointment.id,
                                        'preferred_date',
                                        '',
                                      )
                                      .text =
                                  formattedDate;
                              // Trigger counselor filtering based on new date
                              viewModel.onPendingDateChanged(
                                appointment.id,
                                formattedDate,
                              );
                            }
                          }
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMobileFormField(
                  label: 'Preferred Time',
                  child: Builder(
                    builder: (context) {
                      final date = viewModel
                          .getPendingController(
                            appointment.id,
                            'preferred_date',
                            appointment.preferredDate ?? '',
                          )
                          .text;
                      final selectedTime = viewModel
                          .getPendingController(
                            appointment.id,
                            'preferred_time',
                            appointment.preferredTime ?? '',
                          )
                          .text;
                      final counselorId =
                          appointment.counselorPreference ?? 'No preference';
                      final consultationType = viewModel
                          .getPendingController(
                            appointment.id,
                            'consultation_type',
                            appointment.consultationType ?? '',
                          )
                          .text;
                      return FutureBuilder<List<String>>(
                        future: isEditing && date.isNotEmpty
                            ? viewModel.fetchAvailableHalfHourSlots(
                                date: date,
                                counselorId: counselorId,
                                consultationType: consultationType,
                                selectedTime: selectedTime,
                              )
                            : Future.value(
                                selectedTime.isNotEmpty
                                    ? [selectedTime]
                                    : <String>[],
                              ),
                        builder: (context, snapshot) {
                          final items = snapshot.data ?? <String>[];
                          return DropdownButtonFormField<String>(
                            initialValue:
                                items.contains(selectedTime) &&
                                    selectedTime.isNotEmpty
                                ? selectedTime
                                : null,
                            decoration: const InputDecoration(
                              hintText: 'Select time',
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('Select a time slot'),
                              ),
                              ...items.map(
                                (slot) => DropdownMenuItem(
                                  value: slot,
                                  child: Text(slot),
                                ),
                              ),
                            ],
                            onChanged: isEditing
                                ? (value) {
                                    if (value != null) {
                                      viewModel
                                              .getPendingController(
                                                appointment.id,
                                                'preferred_time',
                                                '',
                                              )
                                              .text =
                                          value;
                                      viewModel.onPendingTimeChanged(
                                        appointment.id,
                                        value,
                                      );
                                    }
                                  }
                                : null,
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                _buildMobileFormField(
                  label: 'Counselor Preference',
                  child: viewModel.isLoadingCounselors
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          initialValue: _getValidCounselorDropdownValue(
                            appointment.counselorPreference,
                            viewModel.counselors,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Select counselor',
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 'No preference',
                              child: Text('No preference'),
                            ),
                            ...viewModel.counselors.map(
                              (counselor) => DropdownMenuItem(
                                value: counselor.counselorId.toString(),
                                child: Text(counselor.displayName),
                              ),
                            ),
                          ],
                          onChanged: null,
                        ),
                ),
                const SizedBox(height: 16),

                _buildMobileFormField(
                  label: 'Method Type',
                  child: DropdownButtonFormField<String>(
                    initialValue: _getValidDropdownValue(
                      appointment.methodType,
                      const [
                        'In-person',
                        'Online (Video)',
                        'Online (Audio only)',
                      ],
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Select a method type',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'In-person',
                        child: Text('In-person'),
                      ),
                      DropdownMenuItem(
                        value: 'Online (Video)',
                        child: Text('Online (Video)'),
                      ),
                      DropdownMenuItem(
                        value: 'Online (Audio only)',
                        child: Text('Online (Audio only)'),
                      ),
                    ],
                    onChanged: isEditing
                        ? (value) {
                            if (value != null) {
                              viewModel
                                      .getPendingController(
                                        appointment.id,
                                        'method_type',
                                        appointment.methodType ?? '',
                                      )
                                      .text =
                                  value;
                            }
                          }
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMobileFormField(
                  label: 'Purpose',
                  child: DropdownButtonFormField<String>(
                    initialValue: _getValidDropdownValue(
                      appointment.purpose,
                      const [
                        'Counseling',
                        'Psycho-Social Support',
                        'Initial Interview',
                      ],
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Select purpose',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Counseling',
                        child: Text('Counseling'),
                      ),
                      DropdownMenuItem(
                        value: 'Psycho-Social Support',
                        child: Text('Psycho-Social Support'),
                      ),
                      DropdownMenuItem(
                        value: 'Initial Interview',
                        child: Text('Initial Interview'),
                      ),
                    ],
                    onChanged: isEditing
                        ? (value) {
                            if (value != null) {
                              viewModel
                                      .getPendingController(
                                        appointment.id,
                                        'purpose',
                                        '',
                                      )
                                      .text =
                                  value;
                            }
                          }
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                _buildMobileFormField(
                  label: 'Description (Optional)',
                  child: TextFormField(
                    controller: viewModel.getPendingController(
                      appointment.id,
                      'description',
                      appointment.description ?? '',
                    ),
                    enabled: isEditing,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Brief description...',
                    ),
                  ),
                ),
              ] else ...[
                // Desktop layout
                Row(
                  children: [
                    Expanded(
                      child: _buildFormField(
                        label: 'Preferred Date',
                        child: TextFormField(
                          controller: viewModel.getPendingController(
                            appointment.id,
                            'preferred_date',
                            appointment.preferredDate ?? '',
                          ),
                          enabled: isEditing,
                          decoration: const InputDecoration(
                            hintText: 'Select date',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: isEditing
                              ? () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now().add(
                                      const Duration(days: 1),
                                    ),
                                    firstDate: DateTime.now().add(
                                      const Duration(days: 1),
                                    ),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 365),
                                    ),
                                  );
                                  if (picked != null) {
                                    final formattedDate =
                                        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                                    viewModel
                                            .getPendingController(
                                              appointment.id,
                                              'preferred_date',
                                              '',
                                            )
                                            .text =
                                        formattedDate;
                                    // Trigger counselor filtering based on new date
                                    viewModel.onPendingDateChanged(
                                      appointment.id,
                                      formattedDate,
                                    );
                                  }
                                }
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFormField(
                        label: 'Preferred Time',
                        child: Builder(
                          builder: (context) {
                            final date = viewModel
                                .getPendingController(
                                  appointment.id,
                                  'preferred_date',
                                  appointment.preferredDate ?? '',
                                )
                                .text;
                            final selectedTime = viewModel
                                .getPendingController(
                                  appointment.id,
                                  'preferred_time',
                                  appointment.preferredTime ?? '',
                                )
                                .text;
                            final counselorId =
                                appointment.counselorPreference ??
                                'No preference';
                            final consultationType = viewModel
                                .getPendingController(
                                  appointment.id,
                                  'consultation_type',
                                  appointment.consultationType ?? '',
                                )
                                .text;
                            return FutureBuilder<List<String>>(
                              future: isEditing && date.isNotEmpty
                                  ? viewModel.fetchAvailableHalfHourSlots(
                                      date: date,
                                      counselorId: counselorId,
                                      consultationType: consultationType,
                                      selectedTime: selectedTime,
                                    )
                                  : Future.value(
                                      selectedTime.isNotEmpty
                                          ? [selectedTime]
                                          : <String>[],
                                    ),
                              builder: (context, snapshot) {
                                final items = snapshot.data ?? <String>[];
                                return DropdownButtonFormField<String>(
                                  initialValue:
                                      items.contains(selectedTime) &&
                                          selectedTime.isNotEmpty
                                      ? selectedTime
                                      : null,
                                  decoration: const InputDecoration(
                                    hintText: 'Select time',
                                  ),
                                  items: [
                                    const DropdownMenuItem(
                                      value: '',
                                      child: Text('Select a time slot'),
                                    ),
                                    ...items.map(
                                      (slot) => DropdownMenuItem(
                                        value: slot,
                                        child: Text(slot),
                                      ),
                                    ),
                                  ],
                                  onChanged: isEditing
                                      ? (value) {
                                          if (value != null) {
                                            viewModel
                                                    .getPendingController(
                                                      appointment.id,
                                                      'preferred_time',
                                                      '',
                                                    )
                                                    .text =
                                                value;
                                            viewModel.onPendingTimeChanged(
                                              appointment.id,
                                              value,
                                            );
                                          }
                                        }
                                      : null,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildFormField(
                        label: 'Consultation Type',
                        child: DropdownButtonFormField<String>(
                          initialValue: _getValidDropdownValue(
                            appointment.consultationType,
                            const [
                              'In-person',
                              'Online (Video)',
                              'Online (Audio only)',
                            ],
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Select consultation type',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'In-person',
                              child: Text('In-person'),
                            ),
                            DropdownMenuItem(
                              value: 'Online (Video)',
                              child: Text('Online (Video)'),
                            ),
                            DropdownMenuItem(
                              value: 'Online (Audio only)',
                              child: Text('Online (Audio only)'),
                            ),
                          ],
                          onChanged: isEditing
                              ? (value) {
                                  if (value != null) {
                                    viewModel
                                            .getPendingController(
                                              appointment.id,
                                              'consultation_type',
                                              '',
                                            )
                                            .text =
                                        value;
                                  }
                                }
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFormField(
                        label: 'Method Type',
                        child: DropdownButtonFormField<String>(
                          initialValue: _getValidDropdownValue(
                            appointment.methodType,
                            const [
                              'In-person',
                              'Online (Video)',
                              'Online (Audio only)',
                            ],
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Select a method type',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'In-person',
                              child: Text('In-person'),
                            ),
                            DropdownMenuItem(
                              value: 'Online (Video)',
                              child: Text('Online (Video)'),
                            ),
                            DropdownMenuItem(
                              value: 'Online (Audio only)',
                              child: Text('Online (Audio only)'),
                            ),
                          ],
                          onChanged: isEditing
                              ? (value) {
                                  if (value != null) {
                                    viewModel
                                            .getPendingController(
                                              appointment.id,
                                              'method_type',
                                              appointment.methodType ?? '',
                                            )
                                            .text =
                                        value;
                                  }
                                }
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFormField(
                        label: 'Purpose',
                        child: DropdownButtonFormField<String>(
                          initialValue: _getValidDropdownValue(
                            appointment.purpose,
                            const [
                              'Counseling',
                              'Psycho-Social Support',
                              'Initial Interview',
                            ],
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Select purpose',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Counseling',
                              child: Text('Counseling'),
                            ),
                            DropdownMenuItem(
                              value: 'Psycho-Social Support',
                              child: Text('Psycho-Social Support'),
                            ),
                            DropdownMenuItem(
                              value: 'Initial Interview',
                              child: Text('Initial Interview'),
                            ),
                          ],
                          onChanged: isEditing
                              ? (value) {
                                  if (value != null) {
                                    viewModel
                                            .getPendingController(
                                              appointment.id,
                                              'purpose',
                                              '',
                                            )
                                            .text =
                                        value;
                                  }
                                }
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildFormField(
                        label: 'Counselor Preference',
                        child: viewModel.isLoadingCounselors
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : DropdownButtonFormField<String>(
                                initialValue: _getValidCounselorDropdownValue(
                                  appointment.counselorPreference,
                                  viewModel.counselors,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Select counselor',
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: 'No preference',
                                    child: Text('No preference'),
                                  ),
                                  ...viewModel.counselors.map(
                                    (counselor) => DropdownMenuItem(
                                      value: counselor.counselorId.toString(),
                                      child: Text(counselor.displayName),
                                    ),
                                  ),
                                ],
                                onChanged: null,
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFormField(
                        label: 'Description (Optional)',
                        child: TextFormField(
                          controller: viewModel.getPendingController(
                            appointment.id,
                            'description',
                            appointment.description ?? '',
                          ),
                          enabled: isEditing,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Brief description...',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),

              // Action buttons
              LayoutBuilder(
                builder: (context, constraints) {
                  // Always use horizontal layout for edit mode buttons to keep them in one row
                  if (isEditing) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          flex: 1,
                          child: TextButton.icon(
                            onPressed: () =>
                                viewModel.toggleEditing(appointment.id),
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Cancel Edit'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF6C757D),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 1,
                          child: ElevatedButton.icon(
                            onPressed: viewModel.isUpdatingAppointment
                                ? null
                                : () => _savePendingAppointment(
                                    context,
                                    appointment,
                                  ),
                            icon: viewModel.isUpdatingAppointment
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.save, size: 18),
                            label: Text(
                              viewModel.isUpdatingAppointment
                                  ? 'Updating...'
                                  : 'Update',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: viewModel.isUpdatingAppointment
                                  ? const Color(
                                      0xFF28A745,
                                    ).withValues(alpha: 0.6)
                                  : const Color(0xFF28A745),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  // For non-editing mode, always use horizontal layout to keep buttons in one row
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextButton.icon(
                          onPressed: () =>
                              viewModel.toggleEditing(appointment.id),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Enable Edit'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF0D6EFD),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 1,
                        child: TextButton.icon(
                          onPressed: () =>
                              _showCancellationDialog(context, appointment),
                          icon: const Icon(Icons.cancel, size: 18),
                          label: const Text('Cancel'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFDC3545),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1A3A5F),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _buildMobileFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1A3A5F),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  void _showCancellationDialog(BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Cancel Appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please provide a reason for cancelling this appointment:',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _viewModel.cancellationReasonController,
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
              onPressed: _viewModel.isCancellingAppointment
                  ? null
                  : () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: _viewModel.isCancellingAppointment
                  ? null
                  : () async {
                      debugPrint('Cancel button pressed');
                      debugPrint(
                        'Cancellation reason: "${_viewModel.cancellationReasonController.text}"',
                      );
                      if (_viewModel.cancellationReasonController.text
                          .trim()
                          .isNotEmpty) {
                        debugPrint(
                          'Calling cancelAppointment with appointment ID: ${appointment.id}',
                        );

                        // Set loading state
                        _viewModel.setCancellingAppointment(true);
                        setState(() {}); // Trigger dialog rebuild

                        try {
                          // Call the cancellation method
                          final success = await _viewModel.cancelAppointment(
                            context,
                            appointment.id,
                            _viewModel.cancellationReasonController.text,
                          );

                          if (success) {
                            // Close dialog on success
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          } else {
                            // Show error message if cancellation failed
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Failed to cancel appointment. Please try again.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } finally {
                          // Always clear loading state
                          _viewModel.setCancellingAppointment(false);
                          setState(() {}); // Trigger dialog rebuild
                        }
                      } else {
                        debugPrint(
                          'Cancellation reason is empty, showing error',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please provide a cancellation reason',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _viewModel.isCancellingAppointment
                    ? const Color(0xFFDC3545).withValues(alpha: 0.6)
                    : const Color(0xFFDC3545),
                foregroundColor: Colors.white,
              ),
              child: _viewModel.isCancellingAppointment
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Cancelling...'),
                      ],
                    )
                  : const Text('Confirm Cancellation'),
            ),
          ],
        ),
      ),
    );
  }

  void _savePendingAppointment(
    BuildContext context,
    Appointment appointment,
  ) async {
    // Set loading state
    _viewModel.setUpdatingAppointment(true);

    try {
      // Validate required fields
      final dateController = _viewModel.getPendingController(
        appointment.id,
        'preferred_date',
        appointment.preferredDate ?? '',
      );
      final timeController = _viewModel.getPendingController(
        appointment.id,
        'preferred_time',
        appointment.preferredTime ?? '',
      );
      final consultationTypeController = _viewModel.getPendingController(
        appointment.id,
        'consultation_type',
        appointment.consultationType ?? '',
      );
      final methodTypeController = _viewModel.getPendingController(
        appointment.id,
        'method_type',
        appointment.methodType ?? '',
      );
      final purposeController = _viewModel.getPendingController(
        appointment.id,
        'purpose',
        appointment.purpose ?? '',
      );
      final counselorPreferenceController = _viewModel.getPendingController(
        appointment.id,
        'counselor_preference',
        appointment.counselorPreference ?? '',
      );

      // Check if required fields are empty
      if (dateController.text.trim().isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a preferred date'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (timeController.text.trim().isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a preferred time'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (consultationTypeController.text.trim().isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a consultation type'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (purposeController.text.trim().isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a purpose'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (methodTypeController.text.trim().isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a method type'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (counselorPreferenceController.text.trim().isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a counselor preference'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final formData = {
        'preferred_date': dateController.text,
        'preferred_time': timeController.text,
        'consultation_type': consultationTypeController.text,
        'method_type': methodTypeController.text,
        'purpose': purposeController.text,
        'counselor_preference': counselorPreferenceController.text,
        'description': _viewModel
            .getPendingController(
              appointment.id,
              'description',
              appointment.description ?? '',
            )
            .text,
      };

      final success = await _viewModel.updatePendingAppointment(
        context,
        appointment.id,
        formData,
      );

      if (success) {
        _viewModel.toggleEditing(appointment.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update appointment. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      // Always clear loading state
      _viewModel.setUpdatingAppointment(false);
    }
  }

  Widget _buildCalendar(
    BuildContext context,
    MyAppointmentsViewModel viewModel,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  final newDate = DateTime(
                    viewModel.currentCalendarDate.year,
                    viewModel.currentCalendarDate.month - 1,
                  );
                  viewModel.setCalendarDate(newDate);
                  // Load month stats when navigating months
                  try {
                    // ignore: invalid_use_of_protected_member
                    // optional if implemented in view model
                    // dynamic call is not allowed; rely on method presence
                    // so we call directly; if missing, this will be a compile error
                    viewModel.fetchCalendarStatsForMonth(newDate);
                  } catch (_) {}
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                '${_getMonthName(viewModel.currentCalendarDate.month)} ${viewModel.currentCalendarDate.year}',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  final newDate = DateTime(
                    viewModel.currentCalendarDate.year,
                    viewModel.currentCalendarDate.month + 1,
                  );
                  viewModel.setCalendarDate(newDate);
                  try {
                    viewModel.fetchCalendarStatsForMonth(newDate);
                  } catch (_) {}
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Calendar grid
          Expanded(child: _buildCalendarGrid(context, viewModel)),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    MyAppointmentsViewModel viewModel,
  ) {
    final firstDayOfMonth = DateTime(
      viewModel.currentCalendarDate.year,
      viewModel.currentCalendarDate.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      viewModel.currentCalendarDate.year,
      viewModel.currentCalendarDate.month + 1,
      0,
    );
    final firstWeekday = firstDayOfMonth.weekday % 7;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: firstWeekday + lastDayOfMonth.day,
      itemBuilder: (context, index) {
        if (index < firstWeekday) {
          return const SizedBox.shrink();
        }

        final day = index - firstWeekday + 1;
        final date = DateTime(
          viewModel.currentCalendarDate.year,
          viewModel.currentCalendarDate.month,
          day,
        );

        final isToday = _isSameDay(date, DateTime.now());
        final isPast = date.isBefore(
          DateTime.now().subtract(const Duration(days: 1)),
        );

        // Optional month daily stats (badge + fully booked styling)
        Map<String, dynamic>? stats;
        int? approvedCount;
        bool fullyBooked = false;
        try {
          stats = viewModel.getStatsForDate(date);
          approvedCount = stats != null ? (stats['count'] as int?) : null;
          fullyBooked = stats != null ? (stats['fullyBooked'] == true) : false;
        } catch (_) {
          approvedCount = null;
          fullyBooked = false;
        }

        return GestureDetector(
          onTap: isPast
              ? null
              : () => _showCounselorAvailability(context, date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isPast
                  ? Colors.grey[200]
                  : isToday
                  ? const Color(0xFF060E57)
                  : (fullyBooked ? const Color(0xFFFDE2E1) : Colors.white),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isToday
                    ? const Color(0xFF060E57)
                    : (fullyBooked
                          ? const Color(0xFFF8B4B4)
                          : Colors.grey[300]!),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      color: isPast
                          ? Colors.grey[400]
                          : isToday
                          ? Colors.white
                          : Colors.black,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (approvedCount != null && approvedCount > 0)
                  Positioned(
                    top: 4,
                    right: 6,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D6EFD),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        approvedCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                if (fullyBooked && !isToday)
                  Positioned(
                    bottom: 4,
                    left: 0,
                    right: 0,
                    child: Text(
                      'Fully booked',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFB91C1C),
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCounselorAvailability(BuildContext context, DateTime date) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Available Counselors - ${_formatDate(date)}'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: FutureBuilder<List<CounselorAvailability>>(
            future: _viewModel.fetchCounselorAvailabilityForDate(date),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final counselors = snapshot.data!;
                if (counselors.isEmpty) {
                  return const Center(
                    child: Text('No counselors available on this date.'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: counselors.length,
                    itemBuilder: (context, index) {
                      final counselor = counselors[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: const Icon(
                            Icons.person,
                            color: Color(0xFF060E57),
                          ),
                          title: Text(
                            counselor
                                .displayName, // Use displayName without specialization
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (counselor.formattedTimeSchedule != null &&
                                  counselor.formattedTimeSchedule!.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF060E57,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Schedule: ${counselor.formattedTimeSchedule}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF060E57),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              else if (counselor.specialization.isNotEmpty)
                                Text(
                                  counselor.specialization,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              } else {
                return const Center(child: Text('No data available.'));
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildApprovedAppointmentTicket(
    BuildContext context,
    Appointment appointment,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF28A745), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF28A745).withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 25,
                        decoration: BoxDecoration(
                          color: const Color(0xFF28A745),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.confirmation_num,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ticket Details',
                          style: TextStyle(
                            color: const Color(0xFF28A745),
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF28A745),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'APPROVED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Details Grid
            _buildTicketDetailsGrid(context, appointment),

            const SizedBox(height: 20),

            // Footer with QR Code and Download
            Column(
              children: [
                // QR Code and Download in a row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // QR Code
                    Container(
                      width: 88, // Increased to accommodate larger QR code
                      height: 88, // Increased to accommodate larger QR code
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF28A745),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: QrImageView(
                          data: _generateQRCodeData(appointment),
                          version: QrVersions.auto,
                          size: 80, // Increased size for better scannability
                          backgroundColor: Colors.white,
                          gapless: false,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.black,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black,
                          ),
                          padding: const EdgeInsets.all(
                            4,
                          ), // Add padding for quiet zone
                          errorStateBuilder: (context, error) {
                            return const Center(
                              child: Text(
                                'QR\nERROR',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 6,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFDC3545),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Download Button
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _downloadAppointmentTicket(context, appointment),
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text('Download Ticket'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF28A745),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Ticket ID below
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF28A745).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'Ticket ID: TICKET-${appointment.id}-${DateTime.now().millisecondsSinceEpoch}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6C757D),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketDetailsGrid(
    BuildContext context,
    Appointment appointment,
  ) {
    return Column(
      children: [
        // First row - Date and Time
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                icon: Icons.calendar_today,
                label: 'Date',
                value: appointment.formattedDate,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildDetailItem(
                icon: Icons.access_time,
                label: 'Time',
                value: appointment.preferredTime ?? 'Not specified',
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Second row - Counselor and Consultation Type
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                icon: Icons.person,
                label: 'Counselor',
                value: appointment.counselorName ?? 'Not assigned',
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildDetailItem(
                icon: Icons.chat,
                label: 'Consultation Type',
                value: appointment.consultationType ?? 'Not specified',
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Third row - Method Type and Purpose
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                icon: Icons.laptop,
                label: 'Method Type',
                value: appointment.methodType ?? 'Not specified',
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildDetailItem(
                icon: Icons.flag,
                label: 'Purpose',
                value: appointment.purpose ?? 'Not specified',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    bool isStatus = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isStatus ? const Color(0xFF28A745) : const Color(0xFF28A745),
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF28A745), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF6C757D),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: isStatus
                        ? const Color(0xFF28A745)
                        : const Color(0xFF212529),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCalendarToggle(BuildContext context) {
    return Consumer<MyAppointmentsViewModel>(
      builder: (context, viewModel, child) {
        return Positioned(
          top: 10,
          right: 16,
          child: FloatingActionButton(
            onPressed: () => viewModel.toggleCalendar(),
            backgroundColor: const Color(0xFF060E57),
            foregroundColor: Colors.white,
            tooltip: 'View Counselors\' Schedules',
            child: const Icon(Icons.calendar_today),
          ),
        );
      },
    );
  }

  Widget _buildCounselorCalendarDrawer(BuildContext context) {
    return Consumer<MyAppointmentsViewModel>(
      builder: (context, viewModel, child) {
        if (!viewModel.isCalendarVisible) return const SizedBox.shrink();

        return Positioned.fill(
          child: GestureDetector(
            onTap: () => viewModel.toggleCalendar(),
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x14000E57),
                          blurRadius: 25,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Counselors\' Schedules',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () => viewModel.toggleCalendar(),
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Calendar and Counselor Schedules
                        Expanded(
                          child: Column(
                            children: [
                              // Calendar - Full height priority
                              Expanded(
                                flex: 3,
                                child: _buildCalendar(context, viewModel),
                              ),
                              // Counselor Schedules Section - Compact
                              Expanded(
                                flex: 2,
                                child: _buildCounselorSchedulesSection(
                                  context,
                                  viewModel,
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
            ),
          ),
        );
      },
    );
  }

  // Helper method to get valid dropdown value
  String? _getValidDropdownValue(
    String? appointmentValue,
    List<String> validValues,
  ) {
    if (appointmentValue == null || appointmentValue.isEmpty) {
      return null;
    }

    // Check if the appointment value matches any of the valid dropdown values
    for (String validValue in validValues) {
      if (appointmentValue == validValue) {
        return validValue;
      }
    }

    // If no exact match found, return null to avoid assertion error
    return null;
  }

  // Helper method to get valid counselor dropdown value
  String? _getValidCounselorDropdownValue(
    String? appointmentValue,
    List<dynamic> counselors,
  ) {
    if (appointmentValue == null || appointmentValue.isEmpty) {
      return null;
    }

    // Check if it's "No preference"
    if (appointmentValue == 'No preference') {
      return 'No preference';
    }

    // Check if it matches any counselor ID
    for (var counselor in counselors) {
      if (appointmentValue == counselor.counselorId.toString()) {
        return counselor.counselorId.toString();
      }
    }

    // If no match found, return null to avoid assertion error
    return null;
  }

  // Generate QR code data for appointment ticket
  String _generateQRCodeData(Appointment appointment) {
    final ticketId =
        'TICKET-${appointment.id}-${DateTime.now().millisecondsSinceEpoch}';

    // Debug original data before encoding
    debugPrint('Original counselor name: "${appointment.counselorName}"');
    debugPrint(
      'Original counselor name length: ${appointment.counselorName?.length}',
    );

    final qrData = {
      'appointmentId': appointment.id,
      'studentId': appointment.studentId,
      'date': appointment.preferredDate,
      'time': appointment.preferredTime,
      'counselor': appointment.counselorName,
      'type': appointment.consultationType,
      'methodType': appointment.methodType,
      'purpose': appointment.purpose,
      'ticketId': ticketId,
    };

    final jsonString = json.encode(qrData);
    debugPrint('QR Code JSON: $jsonString');
    debugPrint('QR Code JSON length: ${jsonString.length}');

    // Test decoding to verify integrity
    try {
      final decoded = json.decode(jsonString);
      debugPrint('Decoded counselor name: "${decoded['counselor']}"');
    } catch (e) {
      debugPrint('Error decoding QR data: $e');
    }

    return jsonString;
  }

  // Download appointment ticket as PDF
  Future<void> _downloadAppointmentTicket(
    BuildContext context,
    Appointment appointment,
  ) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final ticketId =
          'TICKET-${appointment.id}-${DateTime.now().millisecondsSinceEpoch}';
      final qrCodeData = _generateQRCodeData(appointment);

      // Create PDF document
      final pdf = pw.Document();

      // Generate images beforehand
      final logoBytes = await _loadLogoImage();
      final qrCodeBytes = await _generateQRCodeImage(qrCodeData);

      debugPrint('Logo bytes length: ${logoBytes.length}');
      debugPrint('QR code bytes length: ${qrCodeBytes.length}');

      // Test if logo is actually loaded
      if (logoBytes.isEmpty) {
        debugPrint('WARNING: Logo bytes are empty, will show fallback');
      } else {
        debugPrint('Logo loaded successfully with ${logoBytes.length} bytes');
      }

      // Add page to PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildTicketPDFSync(
              appointment,
              ticketId,
              logoBytes,
              qrCodeBytes,
            );
          },
        ),
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show success message and open PDF
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment ticket generated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Save PDF to device storage
        try {
          final bytes = await pdf.save();
          final filename = 'Appointment_Ticket_${appointment.id}_$ticketId.pdf';

          // Try multiple approaches to save the file
          bool fileSaved = false;
          String? savedPath;

          // Method 1: Try to save to Downloads directory
          try {
            final downloadsDir = await getDownloadsDirectory();
            if (downloadsDir != null) {
              final file = File('${downloadsDir.path}/$filename');
              await file.writeAsBytes(bytes);
              savedPath = file.path;
              fileSaved = true;
              debugPrint('PDF saved to Downloads: ${file.path}');
            }
          } catch (e) {
            debugPrint('Failed to save to Downloads: $e');
          }

          // Method 2: Try to save to external storage (Android)
          if (!fileSaved) {
            try {
              final externalDir = await getExternalStorageDirectory();
              if (externalDir != null) {
                final downloadsPath = '${externalDir.path}/Download';
                final downloadsDir = Directory(downloadsPath);
                if (!await downloadsDir.exists()) {
                  await downloadsDir.create(recursive: true);
                }
                final file = File('${downloadsDir.path}/$filename');
                await file.writeAsBytes(bytes);
                savedPath = file.path;
                fileSaved = true;
                debugPrint('PDF saved to external Downloads: ${file.path}');
              }
            } catch (e) {
              debugPrint('Failed to save to external Downloads: $e');
            }
          }

          // Method 3: Fallback to app documents directory
          if (!fileSaved) {
            try {
              final documentsDir = await getApplicationDocumentsDirectory();
              final file = File('${documentsDir.path}/$filename');
              await file.writeAsBytes(bytes);
              savedPath = file.path;
              fileSaved = true;
              debugPrint('PDF saved to Documents: ${file.path}');
            } catch (e) {
              debugPrint('Failed to save to Documents: $e');
            }
          }

          // Show success message
          if (context.mounted) {
            if (fileSaved) {
              // Show detailed success message with file location
              final locationInfo = _getLocationInfo(savedPath);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✅ Ticket saved successfully!'),
                      const SizedBox(height: 4),
                      Text(
                        '📁 Location: $locationInfo',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: 'Share',
                    textColor: Colors.white,
                    onPressed: () async {
                      try {
                        await Printing.sharePdf(
                          bytes: bytes,
                          filename: filename,
                        );
                      } catch (e) {
                        debugPrint('Failed to share PDF: $e');
                      }
                    },
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('❌ Failed to save ticket to device storage'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (e) {
          // Show error message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save ticket: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate ticket: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Build PDF content for appointment ticket (synchronous version)
  pw.Widget _buildTicketPDFSync(
    Appointment appointment,
    String ticketId,
    List<int> logoBytes,
    List<int> qrCodeBytes,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 40,
                    height: 40,
                    child: logoBytes.isNotEmpty
                        ? pw.Image(
                            pw.MemoryImage(Uint8List.fromList(logoBytes)),
                            fit: pw.BoxFit.contain,
                          )
                        : pw.Container(
                            width: 40,
                            height: 40,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.green,
                              borderRadius: pw.BorderRadius.circular(8),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                'CG',
                                style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Text(
                    'Appointment Ticket',
                    style: pw.TextStyle(
                      color: PdfColors.green,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green,
                  borderRadius: pw.BorderRadius.circular(16),
                ),
                child: pw.Text(
                  'APPROVED',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // Details Grid (3 rows x 2 columns)
          pw.Column(
            children: [
              // Row 1: Date | Time
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _buildPDFDetailItem(
                      'DATE',
                      appointment.formattedDate,
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: _buildPDFDetailItem(
                      'TIME',
                      appointment.preferredTime ?? 'Not specified',
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 15),
              // Row 2: Counselor | Consultation Type
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _buildPDFDetailItem(
                      'COUNSELOR',
                      appointment.counselorName ?? 'Not assigned',
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: _buildPDFDetailItem(
                      'CONSULTATION TYPE',
                      appointment.consultationType ?? 'Not specified',
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 15),
              // Row 3: Method Type | Purpose
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _buildPDFDetailItem(
                      'METHOD TYPE',
                      appointment.methodType ?? 'Not specified',
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: _buildPDFDetailItem(
                      'PURPOSE',
                      appointment.purpose ?? 'Not specified',
                    ),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 30),

          // Footer
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // Ticket ID and instructions
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Ticket ID: $ticketId',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Please bring this ticket to your appointment',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Generated on: ${DateTime.now().toLocal().toString()}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              // QR Code (no border)
              pw.Container(
                width: 80,
                height: 80,
                child: pw.Center(
                  child: qrCodeBytes.isNotEmpty
                      ? pw.Image(
                          pw.MemoryImage(Uint8List.fromList(qrCodeBytes)),
                          fit: pw.BoxFit.contain,
                        )
                      : pw.Text(
                          'QR CODE\n$ticketId',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build PDF detail item
  pw.Widget _buildPDFDetailItem(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border(
          left: pw.BorderSide(color: PdfColors.green, width: 3),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey600,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.black,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get user-friendly location info
  String _getLocationInfo(String? savedPath) {
    if (savedPath == null) return 'Unknown location';

    if (savedPath.contains('/Download')) {
      return 'Downloads folder';
    } else if (savedPath.contains('/Documents')) {
      return 'Documents folder';
    } else if (savedPath.contains('/storage/emulated/0')) {
      return 'Device storage';
    } else {
      return 'App storage';
    }
  }

  // Load logo image from assets
  Future<List<int>> _loadLogoImage() async {
    try {
      // Try multiple possible paths
      final possiblePaths = [
        'Photos/ticket_logo_green.png',
        'assets/Photos/ticket_logo_green.png',
        'ticket_logo_green.png',
        'Photos/counselign_logo.png', // Try alternative logo
        'Photos/ABPS LOGO.png', // Try another logo
      ];

      for (final logoPath in possiblePaths) {
        try {
          debugPrint('Attempting to load logo from: $logoPath');
          final logoData = await rootBundle.load(logoPath);
          final bytes = logoData.buffer.asUint8List();

          if (bytes.isNotEmpty) {
            debugPrint(
              'Logo loaded successfully from $logoPath, bytes: ${bytes.length}',
            );
            return bytes;
          } else {
            debugPrint('Logo data is empty for path: $logoPath');
          }
        } catch (e) {
          debugPrint('Failed to load logo from $logoPath: $e');
        }
      }

      debugPrint('All logo paths failed, using fallback');
      return [];
    } catch (e) {
      debugPrint('Failed to load logo: $e');
      return [];
    }
  }

  // Generate QR code image for PDF
  Future<List<int>> _generateQRCodeImage(String qrData) async {
    try {
      debugPrint('Generating QR code with data: $qrData');

      // Test with simple data first to verify QR generation works
      final testData = 'TEST: Princess Grace Marie Sitoy';
      debugPrint('Testing QR with simple data: $testData');

      // Use qr_flutter to generate QR code with higher resolution and proper quiet zone
      final qrImage = await QrPainter(
        data: qrData,
        version: QrVersions.auto,
        gapless: false,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
      ).toImageData(400); // Increased to 400x400 pixels for better scannability

      debugPrint('QR code generated successfully');
      return qrImage!.buffer.asUint8List();
    } catch (e) {
      debugPrint('Failed to generate QR code: $e');
      // Return empty bytes as fallback
      return [];
    }
  }

  void _handleEditAppointment(BuildContext context, Appointment appointment) {
    // Implement edit functionality
    debugPrint('Edit appointment: ${appointment.id}');
    // You can add edit logic here or call existing edit methods from viewModel
  }

  void _handleCancelAppointment(BuildContext context, Appointment appointment) {
    // Implement cancel functionality
    debugPrint('Cancel appointment: ${appointment.id}');
    // You can add cancel logic here or call existing cancel methods from viewModel
  }

  void _handleDeleteAppointment(BuildContext context, Appointment appointment) {
    // Implement delete functionality
    debugPrint('Delete appointment: ${appointment.id}');
    // You can add delete logic here or call existing delete methods from viewModel
  }

  // ---------------- COUNSELOR SCHEDULES SECTION ----------------
  Widget _buildCounselorSchedulesSection(
    BuildContext context,
    MyAppointmentsViewModel viewModel,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: const Color(0xFF060E57),
                size: isMobile ? 18 : 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Counselor Schedules',
                style: TextStyle(
                  color: const Color(0xFF060E57),
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Counselor Schedules List
          Expanded(
            child: FutureBuilder<Map<String, List<CounselorSchedule>>>(
              future: viewModel.getCounselorSchedulesFuture(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF060E57),
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[400],
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error loading schedules',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasData) {
                  final schedules = snapshot.data!;
                  if (schedules.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            color: Colors.grey[400],
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No schedules available',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Weekday order (Monday-Friday only)
                  const weekdays = [
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday',
                  ];

                  return ListView.builder(
                    itemCount: weekdays.length,
                    itemBuilder: (context, index) {
                      final day = weekdays[index];
                      final daySchedules = schedules[day] ?? [];

                      return _buildWeekdayScheduleCard(
                        context,
                        day,
                        daySchedules,
                        isMobile,
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayScheduleCard(
    BuildContext context,
    String day,
    List<CounselorSchedule> schedules,
    bool isMobile,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day Header with gradient colors
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: _getDayGradient(day),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              day,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Schedules List
          if (schedules.isEmpty)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                'No counselors available',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isMobile ? 11 : 12,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...schedules.map(
              (schedule) =>
                  _buildCounselorScheduleItem(context, schedule, isMobile),
            ),
        ],
      ),
    );
  }

  // Helper method to get gradient colors for each weekday
  LinearGradient _getDayGradient(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'tuesday':
        return const LinearGradient(
          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'wednesday':
        return const LinearGradient(
          colors: [Color(0xFF45B7D1), Color(0xFF96C93D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'thursday':
        return const LinearGradient(
          colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'friday':
        return const LinearGradient(
          colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF060E57), Color(0xFF4169E1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Widget _buildCounselorScheduleItem(
    BuildContext context,
    CounselorSchedule schedule,
    bool isMobile,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Counselor Info
          Expanded(
            child: Text(
              schedule.displayNameWithDegree,
              style: TextStyle(
                color: const Color(0xFF060E57),
                fontSize: isMobile ? 11 : 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Time Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F5FF),
              border: Border.all(color: const Color(0xFFD0EBFF), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              schedule.formattedTimeSlots,
              style: TextStyle(
                color: const Color(0xFF0B7285),
                fontSize: isMobile ? 9 : 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
