import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/schedule_appointment_viewmodel.dart';
import 'widgets/student_screen_wrapper.dart';
import 'widgets/consent_accordion.dart';
import 'widgets/acknowledgment_section.dart';
import 'models/appointment.dart';
import 'models/counselor_availability.dart';
import 'models/counselor_schedule.dart';

class ScheduleAppointmentScreen extends StatefulWidget {
  const ScheduleAppointmentScreen({super.key});

  @override
  State<ScheduleAppointmentScreen> createState() =>
      _ScheduleAppointmentScreenState();
}

class _ScheduleAppointmentScreenState extends State<ScheduleAppointmentScreen> {
  late ScheduleAppointmentViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ScheduleAppointmentViewModel();
    _viewModel.initialize();

    // Add listener to description controller for validation
    _viewModel.descriptionController.addListener(() {
      _viewModel.validateForm();
    });
  }

  @override
  void dispose() {
    // Remove listeners before disposing
    _viewModel.descriptionController.removeListener(() {
      _viewModel.validateForm();
    });
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: StudentScreenWrapper(
        currentBottomNavIndex: 1, // Schedule tab
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

  // ---------------- MAIN CONTENT ----------------
  Widget _buildMainContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile
            ? 16
            : isTablet
                ? 24
                : 32,
        vertical: isMobile ? 20 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(context),
          SizedBox(height: isMobile ? 20 : 30),
          // Appointment form
          _buildAppointmentForm(context),
          SizedBox(height: isMobile ? 20 : 40),

          const SizedBox(height: 100), // Add bottom padding for navigation bar
          // Footer moved to bottomNavigationBar
        ],
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
              Icons.event_available_rounded,
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
                  'Schedule Appointment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Book a new counseling session with our counselors',
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

  // ---------------- APPOINTMENT FORM ----------------
  Widget _buildAppointmentForm(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Consumer<ScheduleAppointmentViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: isMobile ? 500 : 800),
          padding: EdgeInsets.all(
            isMobile
                ? 20
                : isTablet
                ? 30
                : 40,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
            boxShadow: [
              BoxShadow(
                color: const Color(0x14000E57), // Fixed: 0.08 opacity in hex
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: const Color(0x0D000000), // Fixed: 0.05 opacity in hex
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top gradient border
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF060E57), Color(0xFF4169E1)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isMobile ? 16 : 20),
                    topRight: Radius.circular(isMobile ? 16 : 20),
                  ),
                ),
              ),

              SizedBox(height: isMobile ? 10 : 20),

              // Message display - prioritize appointment messages over login messages
              if (viewModel.hasPendingAppointment ||
                  viewModel.hasApprovedAppointment ||
                  viewModel.hasPendingFollowUp)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFF8FAFC),
                  ),
                  child: Text(
                    viewModel.pendingAppointmentMessage ??
                        'You have a pending appointment.',
                    style: TextStyle(
                      color: const Color(0xFF4A5568),
                      fontSize: isMobile ? 14 : 15,
                    ),
                  ),
                )
              else if (viewModel.message != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: viewModel.isMessageError
                        ? const Color(0xFFFED7D7)
                        : const Color(0xFFC6F6D5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    viewModel.message!,
                    style: TextStyle(
                      color: viewModel.isMessageError
                          ? const Color(0xFF9B2C2C)
                          : const Color(0xFF276749),
                      fontSize: isMobile ? 14 : 15,
                    ),
                  ),
                ),

              // Form
              Form(
                child: Column(
                  children: [
                    // Consultation Type (Individual / Group)
                    _buildFormField(
                      context: context,
                      label: 'Consultation Type',
                      child: DropdownButtonFormField<String>(
                        initialValue:
                            viewModel.consultationTypeController.text.isEmpty
                            ? null
                            : viewModel
                                  .consultationTypeController
                                  .text, // Fixed: using initialValue instead of value
                        decoration: InputDecoration(
                          hintText: 'Select consultation type',
                          errorText: viewModel.consultationTypeError,
                          filled:
                              viewModel.hasLoginError ||
                              viewModel.hasPendingAppointment ||
                              viewModel.hasApprovedAppointment ||
                              viewModel.hasPendingFollowUp,
                          fillColor:
                              (viewModel.hasLoginError ||
                                  viewModel.hasPendingAppointment ||
                                  viewModel.hasApprovedAppointment ||
                                  viewModel.hasPendingFollowUp)
                              ? const Color(0xFFF8FAFC)
                              : null,
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
                        onChanged:
                            (viewModel.hasLoginError ||
                                viewModel.hasPendingAppointment ||
                                viewModel.hasApprovedAppointment ||
                                viewModel.hasPendingFollowUp)
                            ? null
                            : (value) {
                                if (value != null) {
                                  viewModel.consultationTypeController.text =
                                      value;
                                  if (viewModel
                                      .dateController
                                      .text
                                      .isNotEmpty) {
                                    viewModel.refreshAvailableTimeSlotsForDate(
                                      viewModel.dateController.text,
                                    );
                                  }
                                  viewModel.validateForm();
                                }
                              },
                      ),
                    ),

                    SizedBox(height: isMobile ? 20 : 25),
                    // Preferred Date
                    _buildFormField(
                      context: context,
                      label: 'Preferred Date',
                      child: TextFormField(
                        controller: viewModel.dateController,
                        enabled:
                            !viewModel.hasLoginError &&
                            !viewModel.hasPendingAppointment &&
                            !viewModel.hasApprovedAppointment &&
                            !viewModel.hasPendingFollowUp,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Select a date',
                          suffixIcon: const Icon(Icons.calendar_today),
                          errorText: viewModel.dateError,
                          helperText:
                              'Select a date at least one day in the future',
                          helperStyle: TextStyle(
                            color: const Color(0xFF718096),
                            fontSize: isMobile ? 11 : 12,
                          ),
                          filled:
                              viewModel.hasLoginError ||
                              viewModel.hasPendingAppointment ||
                              viewModel.hasApprovedAppointment ||
                              viewModel.hasPendingFollowUp,
                          fillColor:
                              (viewModel.hasLoginError ||
                                  viewModel.hasPendingAppointment ||
                                  viewModel.hasApprovedAppointment ||
                                  viewModel.hasPendingFollowUp)
                              ? const Color(0xFFF8FAFC)
                              : null,
                        ),
                        onTap:
                            (viewModel.hasLoginError ||
                                viewModel.hasPendingAppointment ||
                                viewModel.hasApprovedAppointment ||
                                viewModel.hasPendingFollowUp)
                            ? null
                            : () async {
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
                                  viewModel.dateController.text = formattedDate;
                                  viewModel.onDateChanged(formattedDate);
                                  viewModel.validateForm();
                                }
                              },
                      ),
                    ),

                    SizedBox(height: isMobile ? 20 : 25),

                    // Preferred Time (dynamic, 30-min slots)
                    _buildFormField(
                      context: context,
                      label: 'Preferred Time',
                      child: Builder(
                        builder: (_) {
                          final List<String> timeItems =
                              viewModel.isLoadingTimeSlots
                              ? const []
                              : viewModel.availableTimeSlots;
                          final String? selectedValue =
                              timeItems.contains(viewModel.timeController.text)
                              ? viewModel.timeController.text
                              : null;
                          return DropdownButtonFormField<String>(
                            initialValue: selectedValue,
                            decoration: InputDecoration(
                              hintText: 'Select a time slot',
                              errorText: viewModel.timeError,
                              filled:
                                  viewModel.hasLoginError ||
                                  viewModel.hasPendingAppointment ||
                                  viewModel.hasApprovedAppointment ||
                                  viewModel.hasPendingFollowUp,
                              fillColor:
                                  (viewModel.hasLoginError ||
                                      viewModel.hasPendingAppointment ||
                                      viewModel.hasApprovedAppointment ||
                                      viewModel.hasPendingFollowUp)
                                  ? const Color(0xFFF8FAFC)
                                  : null,
                            ),
                            items: viewModel.isLoadingTimeSlots
                                ? const []
                                : (timeItems.isEmpty
                                      ? const [
                                          DropdownMenuItem(
                                            value: null,
                                            child: Text(
                                              'No available time slots for this date',
                                            ),
                                          ),
                                        ]
                                      : timeItems
                                            .map(
                                              (s) => DropdownMenuItem(
                                                value: s,
                                                child: Text(s),
                                              ),
                                            )
                                            .toList()),
                            onChanged:
                                (viewModel.hasLoginError ||
                                    viewModel.hasPendingAppointment ||
                                    viewModel.hasApprovedAppointment ||
                                    viewModel.hasPendingFollowUp)
                                ? null
                                : (value) {
                                    if (value != null && value.isNotEmpty) {
                                      viewModel.timeController.text = value;
                                      viewModel.onTimeChanged(value);
                                      viewModel.validateForm();
                                    }
                                  },
                          );
                        },
                      ),
                    ),

                    SizedBox(height: isMobile ? 20 : 25),

                    // Counselor Preference
                    _buildFormField(
                      context: context,
                      label: 'Counselor Preference',
                      child: viewModel.isLoadingCounselors
                          ? const CircularProgressIndicator()
                          : DropdownButtonFormField<String>(
                              initialValue:
                                  viewModel.counselorController.text.isEmpty
                                  ? null
                                  : viewModel
                                        .counselorController
                                        .text, // Fixed: using initialValue instead of value
                              decoration: InputDecoration(
                                hintText: 'Select a counselor',
                                errorText: viewModel.counselorError,
                                filled: viewModel.hasPendingAppointment,
                                fillColor: viewModel.hasPendingAppointment
                                    ? const Color(0xFFF8FAFC)
                                    : null,
                              ),
                              items: viewModel.counselors.isEmpty
                                  ? [
                                      const DropdownMenuItem(
                                        value: '',
                                        child: Text('No counselors available'),
                                      ),
                                    ]
                                  : viewModel.counselors.map((counselor) {
                                      return DropdownMenuItem(
                                        value: counselor.counselorId.toString(),
                                        child: Text(
                                          counselor
                                              .displayName, // Remove specialization from display
                                        ),
                                      );
                                    }).toList(),
                              onChanged: viewModel.hasPendingAppointment
                                  ? null
                                  : (value) {
                                      if (value != null) {
                                        viewModel.counselorController.text =
                                            value;
                                        if (viewModel
                                            .dateController
                                            .text
                                            .isNotEmpty) {
                                          viewModel
                                              .refreshAvailableTimeSlotsForDate(
                                                viewModel.dateController.text,
                                              );
                                        }
                                        viewModel.validateForm();
                                      }
                                    },
                            ),
                    ),

                    SizedBox(height: isMobile ? 20 : 25),

                    // Method Type (In-person / Online)
                    _buildFormField(
                      context: context,
                      label: 'Method Type',
                      child: DropdownButtonFormField<String>(
                        initialValue:
                            viewModel.methodTypeController.text.isEmpty
                            ? null
                            : viewModel.methodTypeController.text,
                        decoration: InputDecoration(
                          hintText: 'Select a method type',
                          errorText: viewModel.methodTypeError,
                          filled:
                              viewModel.hasLoginError ||
                              viewModel.hasPendingAppointment ||
                              viewModel.hasApprovedAppointment ||
                              viewModel.hasPendingFollowUp,
                          fillColor:
                              (viewModel.hasLoginError ||
                                  viewModel.hasPendingAppointment ||
                                  viewModel.hasApprovedAppointment ||
                                  viewModel.hasPendingFollowUp)
                              ? const Color(0xFFF8FAFC)
                              : null,
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
                        onChanged:
                            (viewModel.hasLoginError ||
                                viewModel.hasPendingAppointment ||
                                viewModel.hasApprovedAppointment ||
                                viewModel.hasPendingFollowUp)
                            ? null
                            : (value) {
                                if (value != null) {
                                  viewModel.methodTypeController.text = value;
                                  viewModel.validateForm();
                                }
                              },
                      ),
                    ),

                    SizedBox(height: isMobile ? 20 : 25),

                    // Purpose of Consultation
                    _buildFormField(
                      context: context,
                      label: 'Purpose of Consultation',
                      child: DropdownButtonFormField<String>(
                        initialValue: viewModel.purposeController.text.isEmpty
                            ? null
                            : viewModel.purposeController.text,
                        decoration: InputDecoration(
                          hintText: 'Select the purpose of your consultation',
                          errorText: viewModel.purposeError,
                          filled:
                              viewModel.hasLoginError ||
                              viewModel.hasPendingAppointment ||
                              viewModel.hasApprovedAppointment ||
                              viewModel.hasPendingFollowUp,
                          fillColor:
                              (viewModel.hasLoginError ||
                                  viewModel.hasPendingAppointment ||
                                  viewModel.hasApprovedAppointment ||
                                  viewModel.hasPendingFollowUp)
                              ? const Color(0xFFF8FAFC)
                              : null,
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
                        onChanged:
                            (viewModel.hasLoginError ||
                                viewModel.hasPendingAppointment ||
                                viewModel.hasApprovedAppointment ||
                                viewModel.hasPendingFollowUp)
                            ? null
                            : (value) {
                                if (value != null) {
                                  viewModel.purposeController.text = value;
                                  viewModel.validateForm();
                                }
                              },
                      ),
                    ),

                    SizedBox(height: isMobile ? 20 : 25),

                    // Brief Description
                    _buildFormField(
                      context: context,
                      label: 'Brief Description (Optional)',
                      isFullWidth: true,
                      child: TextFormField(
                        controller: viewModel.descriptionController,
                        enabled:
                            !viewModel.hasLoginError &&
                            !viewModel.hasPendingAppointment &&
                            !viewModel.hasApprovedAppointment &&
                            !viewModel.hasPendingFollowUp,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'Briefly describe what you\'d like to discuss...',
                          filled:
                              viewModel.hasLoginError ||
                              viewModel.hasPendingAppointment ||
                              viewModel.hasApprovedAppointment ||
                              viewModel.hasPendingFollowUp,
                          fillColor:
                              (viewModel.hasLoginError ||
                                  viewModel.hasPendingAppointment ||
                                  viewModel.hasApprovedAppointment ||
                                  viewModel.hasPendingFollowUp)
                              ? const Color(0xFFF8FAFC)
                              : null,
                        ),
                      ),
                    ),

                    SizedBox(height: isMobile ? 25 : 30),

                    // Consent Accordion
                    const ConsentAccordion(),

                    // Acknowledgment Section
                    AcknowledgmentSection(
                      consentRead: viewModel.consentRead,
                      consentAccept: viewModel.consentAccept,
                      onConsentReadChanged: viewModel.setConsentRead,
                      onConsentAcceptChanged: viewModel.setConsentAccept,
                      showError: viewModel.showConsentError,
                    ),

                    SizedBox(height: isMobile ? 25 : 30),

                    // Submit Button
                    if (!viewModel.hasLoginError &&
                        !viewModel.hasPendingAppointment &&
                        !viewModel.hasApprovedAppointment &&
                        !viewModel.hasPendingFollowUp)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: viewModel.isSubmitting
                              ? null
                              : () => viewModel.submitAppointment(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF060E57),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isMobile ? 14 : 16,
                              horizontal: 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                isMobile ? 8 : 10,
                              ),
                            ),
                            elevation: 2,
                          ),
                          child: viewModel.isSubmitting
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: isMobile ? 18 : 20,
                                      height: isMobile ? 18 : 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: isMobile ? 8 : 12),
                                    Text(
                                      'Processing...',
                                      style: TextStyle(
                                        fontSize: isMobile ? 15 : 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Schedule Appointment',
                                  style: TextStyle(
                                    fontSize: isMobile ? 15 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- FORM FIELD ----------------
  Widget _buildFormField({
    required BuildContext context,
    required String label,
    required Widget child,
    bool isFullWidth = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      width: isFullWidth ? double.infinity : null,
      margin: EdgeInsets.only(bottom: isFullWidth ? 0 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF1A3A5F),
              fontWeight: FontWeight.w500,
              fontSize: isMobile ? 14 : 15,
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          child,
        ],
      ),
    );
  }

  // ---------------- FLOATING CALENDAR TOGGLE ----------------
  Widget _buildFloatingCalendarToggle(BuildContext context) {
    return Consumer<ScheduleAppointmentViewModel>(
      builder: (context, viewModel, child) {
        return Positioned(
          top: 10, // Position closer to the header
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

  // ---------------- COUNSELOR CALENDAR DRAWER ----------------
  Widget _buildCounselorCalendarDrawer(BuildContext context) {
    return Consumer<ScheduleAppointmentViewModel>(
      builder: (context, viewModel, child) {
        debugPrint(
          'Building calendar drawer - isVisible: ${viewModel.isCalendarVisible}',
        );
        if (!viewModel.isCalendarVisible) return const SizedBox.shrink();

        return Positioned.fill(
          child: GestureDetector(
            onTap: () =>
                viewModel.toggleCalendar(), // Close when tapping outside
            child: Container(
              color: Colors.black.withValues(
                alpha: 0.5,
              ), // Semi-transparent overlay
              child: Center(
                child: GestureDetector(
                  onTap:
                      () {}, // Prevent closing when tapping on the calendar itself
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

  Widget _buildCalendar(
    BuildContext context,
    ScheduleAppointmentViewModel viewModel,
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
                  viewModel.fetchCalendarStatsForMonth(newDate);
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
                  viewModel.fetchCalendarStatsForMonth(newDate);
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
    ScheduleAppointmentViewModel viewModel,
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

        final stats = viewModel.getStatsForDate(date);
        final int? approvedCount = stats != null
            ? (stats['count'] as int?)
            : null;
        final bool fullyBooked = stats != null
            ? (stats['fullyBooked'] == true)
            : false;

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
    final viewModel = Provider.of<ScheduleAppointmentViewModel>(
      context,
      listen: false,
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Available Counselors - ${_formatDate(date)}'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: FutureBuilder<List<CounselorAvailability>>(
            future: viewModel.fetchCounselorAvailabilityWithSchedule(date),
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

  // ---------------- COUNSELOR SCHEDULES SECTION ----------------
  Widget _buildCounselorSchedulesSection(
    BuildContext context,
    ScheduleAppointmentViewModel viewModel,
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
              future: viewModel.fetchCounselorSchedules(),
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
