<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <meta name="description" content="University Guidance Counseling System">
    <title>My Appointments - Counselign</title>
    <link rel="icon" href="<?= base_url('Photos/counselign_logo.png') ?>" sizes="16x16 32x32" type="image/png">
    <link rel="shortcut icon" href="<?= base_url('Photos/counselign_logo.png') ?>" type="image/png">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<?= base_url('css/student/my_appointments.css') ?>">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<?= base_url('css/student/header.css') ?>">
    <link rel="stylesheet" href="<?= base_url('css/utils/sidebar.css') ?>">
    <link rel="stylesheet" href="<?= base_url('css/utils/customCalendarPicker.css') ?>">

</head>

<body>
    <!-- Sidebar -->
    <aside class="sidebar" id="uniSidebar">
        <div class="sidebar-content">
            <!-- Logo/Toggle Button -->
            <button class="sidebar-toggle-btn" id="sidebarToggle" title="Toggle Sidebar">
                <img src="<?= base_url('Photos/counselign_logo.png') ?>" alt="Logo" class="sidebar-logo">
                <span class="sidebar-brand-text">Counselign</span>
            </button>

            <!-- Navigation Links -->
            <nav class="sidebar-nav">
                <a href="<?= base_url('student/dashboard') ?>" class="sidebar-link" title="Dashboard">
                    <i class="fas fa-home"></i>
                    <span class="sidebar-text">Dashboard</span>
                </a>

                <a href="<?= base_url('student/schedule-appointment') ?>" class="sidebar-link" title="Schedule an Appointment">
                    <i class="fas fa-plus-circle"></i>
                    <span class="sidebar-text">Schedule an Appointment</span>
                </a>

                <a href="<?= base_url('student/my-appointments') ?>" class="sidebar-link active" title="My Appointments">
                    <i class="fas fa-list-alt"></i>
                    <span class="sidebar-text">My Appointments</span>
                </a>

                <a href="<?= base_url('student/follow-up-sessions') ?>" class="sidebar-link" title="Follow-up Sessions">
                    <i class="fas fa-clipboard-list"></i>
                    <span class="sidebar-text">Follow-up Sessions</span>
                </a>
                <a href="<?= base_url('student/announcements') ?>" class="sidebar-link" title="Announcement">
                    <i class="fas fa-bullhorn"></i>
                    <span class="sidebar-text">Announcement</span>
                </a>
            </nav>
        </div>
    </aside>

    <!-- Sidebar Overlay for Mobile -->
    <div class="sidebar-overlay" id="sidebarOverlay"></div>

    <!-- Floating Sidebar Toggle for Mobile (shows when sidebar is hidden) -->
    <button class="floating-sidebar-toggle" id="floatingSidebarToggle" title="Open Menu">
        <img src="<?= base_url('Photos/counselign_logo.png') ?>" alt="Menu">
    </button>

    <div class="main-wrapper" id="mainWrapper">
        <!-- Interactive Profile Picture Section -->

        <!-- Top Bar -->
        <header class="top-bar">
            <div class="top-bar-left">
                <h1 class="page-title-header">
                    <i class="fas fa-list-alt me-2"></i>
                    My Appointments
                </h1>
            </div>

            <div class="top-bar-right">

                <button class="top-bar-btn" onclick="window.location.href='<?= base_url('student/schedule-appointment') ?>'" title="Schedule an Appointment">
                    <i class="fas fa-plus-circle text-2xl" style="cursor: pointer;"></i>
                    <span class="btn-label">Schedule an Appointment</span>
                </button>

                <!-- Profile Dropdown -->
                <div class="profile-dropdown">
                    <button class="top-bar-btn profile-btn" id="profileDropdownBtn">
                        <img id="profile-img-top" src="<?= base_url('Photos/profile.png') ?>" alt="Profile" class="profile-img-small">
                        <span class="btn-label" id="uniNameTop">Student</span>
                    </button>

                    <div class="profile-dropdown-menu" id="profileDropdownMenu">
                        <div class="profile-dropdown-header">
                            <img id="profile-img-dropdown" src="<?= base_url('Photos/profile.png') ?>" alt="Profile" class="profile-img-large">
                            <div class="profile-info">
                                <div class="profile-name" id="uniNameDropdown">Student</div>
                                <div class="profile-subtitle" id="lastLoginDropdown">Loading...</div>
                            </div>
                        </div>
                        <div class="profile-dropdown-divider"></div>
                        <a href="<?= base_url('student/profile') ?>" class="profile-dropdown-item">
                            <i class="fas fa-user-cog"></i>
                            <span>Profile</span>
                        </a>
                        <div class="profile-dropdown-divider"></div>
                        <button class="profile-dropdown-item" onclick="confirmLogout()">
                            <i class="fas fa-sign-out-alt"></i>
                            <span>Log Out</span>
                        </button>
                    </div>
                </div>
            </div>
        </header>

        <div class="main-content">
            <div class="container appointment-container">
                <div class="page-header">
                    <p class="text-muted">View and manage your counseling appointments</p>
                </div>

                <!-- Approved Appointments Section -->
                <section class="approved-appointments-section mb-4">
                    <div class="section-title"><i class="fas fa-check-circle"></i> Approved Appointment</div>
                    <div id="approvedAppointmentsContainer">
                        <!-- JS will render approved appointment details here -->
                    </div>
                </section>

                <!-- Pending Appointments Section -->
                <section class="pending-appointments-section mb-4">
                    <div class="section-title"><i class="fas fa-hourglass-half"></i> Pending Appointment</div>
                    <div id="pendingAppointmentsFormsContainer">
                        <!-- JS will render pending appointment forms here -->
                    </div>
                </section>

                <!-- Navigation Tabs -->
                <ul class="nav nav-tabs mb-4" id="appointmentTabs" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" id="all-tab" data-bs-toggle="tab" data-bs-target="#all" type="button">
                            All Appointments
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="rescheduled-tab" data-bs-toggle="tab" data-bs-target="#rescheduled" type="button">
                            Rescheduled
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="completed-tab" data-bs-toggle="tab" data-bs-target="#completed" type="button">
                            Completed
                        </button>
                    </li>
                </ul>

                <!-- Filter Options -->
                <div class="row mb-4">
                    <div class="col-md-4">
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-search"></i></span>
                            <input type="text" class="form-control" id="searchInput" placeholder="Search appointments...">
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-calendar"></i></span>
                            <input type="month" class="form-control" id="dateFilter">
                        </div>
                    </div>
                </div>

                <!-- Tab Content -->
                <div class="tab-content" id="appointmentTabContent">
                    <!-- Loading Spinner -->
                    <div class="loading-spinner" style="display: none;">
                        <div class="d-flex justify-content-center align-items-center">
                            <div class="spinner-border text-primary" role="status">
                                <span class="visually-hidden">Loading...</span>
                            </div>
                        </div>
                    </div>

                    <!-- Empty State Message -->
                    <div class="empty-state alert alert-info text-center" style="display: none;">
                        <i class="fas fa-info-circle me-2"></i>
                        No appointments found.
                    </div>

                    <!-- All Appointments Tab -->
                    <div class="tab-pane fade show active" id="all" role="tabpanel">
                        <div class="table-responsive shadow-sm rounded">
                            <table class="table table-hover mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>Date</th>
                                        <th>Time</th>
                                        <th>Consultation Type</th>
                                        <th>Method Type</th>
                                        <th>Purpose</th>
                                        <th>Counselor</th>
                                        <th>Status</th>
                                        <th>Reason for Cancellation or Rescheduled</th>
                                    </tr>
                                </thead>
                                <tbody id="allAppointmentsTable">
                                    <!-- Data will be populated by JavaScript -->
                                </tbody>
                            </table>
                        </div>
                    </div>


                    <!-- Re-Schedule Appointments Tab -->
                    <div class="tab-pane fade" id="rescheduled" role="tabpanel">
                        <div class="table-responsive shadow-sm rounded">
                            <table class="table table-hover mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>Date</th>
                                        <th>Time</th>
                                        <th>Consultation Type</th>
                                        <th>Method Type</th>
                                        <th>Purpose</th>
                                        <th>Counselor</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody id="rescheduledAppointmentsTable">
                                    <!-- Data will be populated by JavaScript -->
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Completed Appointments Tab -->
                    <div class="tab-pane fade" id="completed" role="tabpanel">
                        <div class="table-responsive shadow-sm rounded">
                            <table class="table table-hover mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>Date</th>
                                        <th>Time</th>
                                        <th>Consultation Type</th>
                                        <th>Method Type</th>
                                        <th>Purpose</th>
                                        <th>Counselor</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody id="completedAppointmentsTable">
                                    <!-- Data will be populated by JavaScript -->
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Counselors' Schedules Toggle Button -->
        <button class="calendar-toggle-btn" id="counselorsCalendarToggleBtn" title="View Counselors' Schedules">
            <i class="fas fa-user-md"></i>
            <span>Counselors' Schedules</span>
            <i class="fas fa-chevron-left"></i>
        </button>

        <!-- Counselors' Schedules Calendar Drawer -->
        <div class="calendar-drawer" id="counselorsCalendarDrawer">
            <div class="calendar-drawer-header">
                <h3 class="calendar-drawer-title">
                    <i class="fas fa-user-md me-2"></i>
                    Counselors' Schedules
                </h3>
                <button class="calendar-close-btn" id="counselorsCalendarCloseBtn">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="calendar-drawer-content">
                <div class="calendar-container">
                    <div class="calendar-header">
                        <button id="counselorsPrevMonth" class="calendar-nav-btn">
                            <i class="fas fa-chevron-left"></i>
                        </button>
                        <h4 id="counselorsCurrentMonth" class="calendar-month"></h4>
                        <button id="counselorsNextMonth" class="calendar-nav-btn">
                            <i class="fas fa-chevron-right"></i>
                        </button>
                    </div>
                    <div class="calendar-grid" id="counselorsCalendarGrid">
                        <!-- Calendar will be dynamically generated here -->
                    </div>
                </div>

                <!-- Counselor Schedules Display Section -->
                <div class="counselor-schedules-section">
                    <div class="section-header">
                        <h4><i class="fas fa-user-md me-2"></i>Counselor Schedules</h4>
                        <p class="text-muted">View all counselors and their available time slots by day</p>
                    </div>

                    <div class="schedules-container" id="counselorSchedulesContainer">
                        <div class="loading-schedules">
                            <div class="spinner-border text-primary" role="status">
                                <span class="visually-hidden">Loading...</span>
                            </div>
                            <p class="mt-2">Loading counselor schedules...</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Counselors Calendar Drawer Overlay -->
        <div class="calendar-overlay" id="counselorsCalendarOverlay"></div>


        <!-- Edit Appointment Modal -->
        <div class="modal fade" id="editAppointmentModal" tabindex="-1" aria-labelledby="editAppointmentModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="editAppointmentModalLabel">Edit Appointment</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form id="editAppointmentForm">
                            <input type="hidden" id="editAppointmentId">
                            <div class="mb-3">
                                <label for="editDate" class="form-label">Preferred Date <span class="text-danger">*</span></label>
                                <input type="date" class="form-control" id="editDate" required>
                            </div>
                            <div class="mb-3">
                                <label for="editTime" class="form-label">Preferred Time <span class="text-danger">*</span></label>
                                <select class="form-select" id="editTime" required>
                                    <option value="">Select a time slot</option>
                                </select>
                                <small class="form-text text-muted">Time slots will be filtered based on counselor availability</small>
                            </div>
                            <div class="mb-3">
                                <label for="editConsultationType" class="form-label">Consultation Type <span class="text-danger">*</span></label>
                                <select class="form-select" id="editConsultationType" required>
                                    <option value="">Select consultation type</option>
                                    <option value="Individual Consultation">Individual Consultation</option>
                                    <option value="Group Consultation">Group Consultation</option>
                                </select>
                                <small id="editConsultationTypeHelp" class="form-text text-muted"></small>
                            </div>
                            <div class="mb-3">
                                <label for="editMethodType" class="form-label">Method Type <span class="text-danger">*</span></label>
                                <select class="form-select" id="editMethodType" required>
                                    <option value="">Select a method type</option>
                                    <option value="In-person">In-person</option>
                                    <option value="Online (Video)">Online (Video)</option>
                                    <option value="Online (Audio only)">Online (Audio only)</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label for="editPurpose" class="form-label">Purpose <span class="text-danger">*</span></label>
                                <select class="form-select" id="editPurpose" required>
                                    <option value="">Select purpose...</option>
                                    <option value="Counseling">Counseling</option>
                                    <option value="Psycho-Social Support">Psycho-Social Support</option>
                                    <option value="Initial Interview">Initial Interview</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label for="editCounselorPreference" class="form-label">Counselor Preference <span class="text-danger">*</span></label>
                                <select class="form-select" id="editCounselorPreference" required>
                                    <option value="">Select a counselor</option>
                                    <option value="No preference">No preference</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label for="editDescription" class="form-label">Description (Optional)</label>
                                <textarea class="form-control" id="editDescription" rows="3"></textarea>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary" id="saveEditBtn">Save changes</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Cancel Appointment Modal -->
        <div class="modal fade" id="cancelAppointmentModal" tabindex="-1" aria-labelledby="cancelAppointmentModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="cancelAppointmentModalLabel">Cancel Appointment</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form id="cancelAppointmentForm">
                            <input type="hidden" id="cancelAppointmentId">
                            <div class="mb-3">
                                <label for="cancelReason" class="form-label">Reason for Cancellation</label>
                                <textarea class="form-control" id="cancelReason" rows="3" required></textarea>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-danger" id="confirmCancelBtn">Confirm Cancellation</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Save Changes Confirmation Modal -->
        <div class="modal fade" id="saveChangesModal" tabindex="-1" aria-labelledby="saveChangesModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title" id="saveChangesModalLabel">
                            <i class="fas fa-edit me-2"></i>Confirm Save Changes
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        Are you sure you want to save the changes to this appointment?
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="button" class="btn btn-primary" id="confirmSaveChangesBtn">
                            <i class="fas fa-check me-1"></i>Save Changes
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Cancellation Reason Modal -->
        <div class="modal fade" id="cancellationReasonModal" tabindex="-1" aria-labelledby="cancellationReasonModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header bg-danger text-white">
                        <h5 class="modal-title" id="cancellationReasonModalLabel">
                            <i class="fas fa-times-circle me-2"></i>Cancellation Reason
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form id="cancellationReasonForm">
                            <div class="mb-3">
                                <label for="cancellationReason" class="form-label fw-bold">Please provide a reason for cancelling this appointment:</label>
                                <textarea class="form-control" id="cancellationReason" rows="4" placeholder="Enter the reason for cancellation here..." required></textarea>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-danger" id="confirmCancellationBtn">
                            <i class="fas fa-check me-1"></i>Confirm Cancellation
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Delete Confirmation Modal -->
        <div class="modal fade" id="deleteConfirmationModal" tabindex="-1" aria-labelledby="deleteConfirmationModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header bg-danger text-white">
                        <h5 class="modal-title" id="deleteConfirmationModalLabel">
                            <i class="fas fa-trash me-2"></i>Confirm Delete
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        Are you sure you want to delete this appointment?
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="button" class="btn btn-danger" id="confirmDeleteBtn">
                            <i class="fas fa-check me-1"></i>Delete
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Success Modal -->
        <div class="modal fade" id="successModal" tabindex="-1" aria-labelledby="successModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title" id="successModalLabel">
                            <i class="fas fa-check-circle me-2"></i>Success
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p class="mb-0" id="successModalMessage">Operation completed successfully.</p>
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-success" data-bs-dismiss="modal">
                            <i class="fas fa-check me-1"></i>OK
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>


    <!-- Scripts -->
    <?php echo view('modals/student_dashboard_modals'); ?>
    <script src="<?= base_url('js/modals/student_dashboard_modals.js') ?>"></script>
    <script src="<?= base_url('js/utils/timeFormatter.js') ?>"></script>
    <script src="<?= base_url('js/utils/customCalendarPicker.js') ?>"></script>
    <script src="<?= base_url('js/student/my_appointments.js') ?>"></script>
    <script src="<?= base_url('js/student/logout.js') ?>"></script>
    <script src="<?= base_url('js/utils/sidebar.js') ?>"></script>
    <script src="<?= base_url('js/student/student_header_drawer.js') ?>"></script>
    <script src="<?= base_url('js/utils/secureLogger.js') ?>"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/qrcode-generator@1.4.4/qrcode.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>

    <script>
        window.BASE_URL = "<?= base_url() ?>";
    </script>

</body>

</html>