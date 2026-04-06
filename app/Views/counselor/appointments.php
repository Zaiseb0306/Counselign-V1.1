<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Appointments Management - Counselign</title>
    <link rel="icon" href="<?= base_url('Photos/counselign.ico') ?>" sizes="16x16 32x32"
        type="image/x-icon">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<?= base_url('css/counselor/appointments.css') ?>">
    <link rel="stylesheet" href="<?= base_url('css/counselor/header.css') ?>">
    <link rel="stylesheet" href="<?= base_url('css/utils/sidebar.css') ?>">
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
                <a href="<?= base_url('counselor/dashboard') ?>" class="sidebar-link" title="Dashboard">
                    <i class="fas fa-home"></i>
                    <span class="sidebar-text">Dashboard</span>
                </a>

                <a href="<?= base_url('counselor/appointments/scheduled') ?>" class="sidebar-link active" title="Scheduled Appointments">
                    <i class="fas fa-calendar-alt"></i>
                    <span class="sidebar-text">Scheduled Appointments</span>
                </a>
                <a href="<?= base_url('counselor/follow-up') ?>" class="sidebar-link" title="Follow-up Sessions">
                    <i class="fas fa-clipboard-list"></i>
                    <span class="sidebar-text">Follow-up Sessions</span>
                </a>
                <a href="<?= base_url('counselor/announcements') ?>" class="sidebar-link" title="Announcement">
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
                    <i class="fas fa-boxes me-2"></i>
                    Appointments Management
                </h1>
            </div>

            <div class="top-bar-right">

                <button class="top-bar-btn" onclick="window.location.href='<?= base_url('counselor/appointments/scheduled') ?>'" title="Scheduled Appointments">
                    <i class="fa fa-calendar-alt text-2xl" style="cursor: pointer;"></i>
                    <span class="btn-label">Scheduled Appointments</span>
                </button>


                <!-- Profile Dropdown -->
                <div class="profile-dropdown">
                    <button class="top-bar-btn profile-btn" id="profileDropdownBtn">
                        <img id="profile-img-top" src="<?= base_url('Photos/profile.png') ?>" alt="Profile" class="profile-img-small">
                        <span class="btn-label" id="uniNameTop">Counselor</span>
                    </button>

                    <div class="profile-dropdown-menu" id="profileDropdownMenu">
                        <div class="profile-dropdown-header">
                            <img id="profile-img-dropdown" src="<?= base_url('Photos/profile.png') ?>" alt="Profile" class="profile-img-large">
                            <div class="profile-info">
                                <div class="profile-name" id="uniNameDropdown">Counselor</div>
                                <div class="profile-subtitle" id="lastLoginDropdown">Loading...</div>
                            </div>
                        </div>
                        <div class="profile-dropdown-divider"></div>
                        <a href="<?= base_url('counselor/profile') ?>" class="profile-dropdown-item">
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

        <main>
            <div class="container-fluid px-4">
                <div class="dashboard-header my-4">
                    <div class="row">
                        <div class="col-md-8">
                            <h2 class="page-title"><i class="fas fa-boxes me-2"></i>Appointments Management</h2>
                        </div>
                    </div>
                </div>

                <div class="row status-cards mb-4">
                    <div class="col-md-2 col-sm-6 mb-3">
                        <div class="status-card bg-white rounded shadow-sm">
                            <div class="status-card-body p-3">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="status-title">Pending</h6>
                                        <h3 class="status-count" id="pendingCount">-</h3>
                                    </div>
                                    <div class="status-icon bg-warning text-white rounded-circle">
                                        <i class="fas fa-clock"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2 col-sm-6 mb-3">
                        <div class="status-card bg-white rounded shadow-sm">
                            <div class="status-card-body p-3">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="status-title">Approved</h6>
                                        <h3 class="status-count" id="approvedCount">-</h3>
                                    </div>
                                    <div class="status-icon bg-success text-white rounded-circle">
                                        <i class="fas fa-check"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2 col-sm-6 mb-3">
                        <div class="status-card bg-white rounded shadow-sm">
                            <div class="status-card-body p-3">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="status-title">Completed</h6>
                                        <h3 class="status-count" id="completedCount">-</h3>
                                    </div>
                                    <div class="status-icon bg-primary text-white rounded-circle">
                                        <i class="fas fa-check-double"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2 col-sm-6 mb-3">
                        <div class="status-card bg-white rounded shadow-sm">
                            <div class="status-card-body p-3">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="status-title">Rescheduled</h6>
                                        <h3 class="status-count" id="rescheduledCount">-</h3>
                                    </div>
                                    <div class="status-icon bg-warning text-white rounded-circle">
                                        <i class="fas fa-calendar-alt"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2 col-sm-6 mb-3">
                        <div class="status-card bg-white rounded shadow-sm">
                            <div class="status-card-body p-3">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="status-title">Cancelled</h6>
                                        <h3 class="status-count" id="cancelledCount">-</h3>
                                    </div>
                                    <div class="status-icon bg-secondary text-white rounded-circle">
                                        <i class="fas fa-ban"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="appointments-container bg-white rounded shadow-sm">
                    <div class="appointments-header">
                        <h5 class="mb-0"><i class="fas fa-list-alt me-2"></i>Appointments List</h5>
                        <div class="filter-controls d-flex align-items-center">
                            <label for="dateRangeFilter" class="me-2">Date:</label>
                            <select class="form-select" id="dateRangeFilter">
                                <option value="all">All Dates</option>
                                <option value="today">Today</option>
                                <option value="thisWeek">This Week</option>
                                <option value="nextWeek">Next Week</option>
                                <option value="nextMonth">Next Month</option>
                                <option value="past">Past Appointments</option>
                            </select>
                            <label for="statusFilter" class="me-2">Status:</label>
                            <select id="statusFilter" class="form-select form-select-sm">
                                <option value="all">All Statuses</option>
                                <option value="pending">Pending</option>
                                <option value="approved">Approved</option>
                                <option value="rescheduled">Rescheduled</option>
                                <option value="completed">Completed</option>
                                <option value="cancelled">Cancelled</option>
                            </select>
                        </div>
                    </div>

                    <div id="loadingIndicator" class="text-center py-5">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                        <p class="mt-2">Loading appointments...</p>
                    </div>

                    <div id="noAppointmentsMessage" class="text-center py-5 d-none">
                        <i class="fas fa-calendar-times fa-3x text-muted mb-3"></i>
                        <p>No appointments found.</p>
                    </div>

                    <div id="appointmentsList" class="appointments-list d-none"></div>
                </div>
            </div>
        </main>
    </div>

    <div class="modal fade" id="appointmentDetailsModal" tabindex="-1" aria-labelledby="appointmentDetailsModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content appointment-modal-content">
                <div class="modal-header appointment-modal-header">
                    <h5 class="modal-title" id="appointmentDetailsModalLabel">
                        <i class="fas fa-calendar-check me-2"></i>Appointment Details
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body appointment-modal-body">
                    <div class="appointment-info-grid">
                        <div class="info-section">
                            <div class="info-item">
                                <i class="fas fa-user-circle info-icon"></i>
                                <div class="info-content">
                                    <span class="info-label">User ID</span>
                                    <span class="info-value" id="modalStudentId"></span>
                                </div>
                            </div>
                            <div class="info-item">
                                <i class="fas fa-user info-icon"></i>
                                <div class="info-content">
                                    <span class="info-label">Student Name</span>
                                    <span class="info-value" id="modalStudentName"></span>
                                </div>
                            </div>
                            <div class="info-item">
                                <i class="fas fa-envelope info-icon"></i>
                                <div class="info-content">
                                    <span class="info-label">Email</span>
                                    <span class="info-value" id="modalEmail"></span>
                                </div>
                            </div>
                        </div>
                        <div class="info-section">
                            <div class="info-item">
                                <i class="fas fa-calendar-alt info-icon"></i>
                                <div class="info-content">
                                    <span class="info-label">Date</span>
                                    <span class="info-value" id="modalDate"></span>
                                </div>
                            </div>
                            <div class="info-item">
                                <i class="fas fa-clock info-icon"></i>
                                <div class="info-content">
                                    <span class="info-label">Time</span>
                                    <span class="info-value" id="modalTime"></span>
                                </div>
                            </div>
                            <div class="info-item">
                                <i class="fas fa-check-circle info-icon"></i>
                                <div class="info-content">
                                    <span class="info-label">Status</span>
                                    <span id="modalStatus" class="badge"></span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="appointment-info-grid mt-3">
                        <div class="info-section">
                            <div class="info-item">
                                <i class="fas fa-users info-icon"></i>
                                <div class="info-content">
                                    <span class="info-label">Consultation Type</span>
                                    <span class="info-value" id="modalConsultationType"></span>
                                </div>
                            </div>
                            <div class="info-item">
                                <i class="fas fa-laptop info-icon"></i>
                                <div class="info-content">
                                    <span class="info-label">Method Type</span>
                                    <span class="info-value" id="modalMethodType"></span>
                                </div>
                            </div>
                        </div>
                        <div class="info-section">
                            <div class="info-item">
                                <i class="fas fa-bullseye info-icon"></i>
                                <div class="info-content">
                                    <span class="info-label">Purpose</span>
                                    <span class="info-value" id="modalPurpose"></span>
                                </div>
                            </div>
                            <div class="info-item" hidden>
                                <i class="fas fa-user-md info-icon"></i>
                                <div class="info-content">
                                    <span class="info-label">Counselor Preference</span>
                                    <span class="info-value" id="modalCounselorPreference"></span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="description-section mt-3">
                        <div class="description-header">
                            <i class="fas fa-file-alt me-2"></i>
                            <span>Description</span>
                        </div>
                        <div id="modalDescription" class="description-content"></div>
                    </div>
                    <div id="modalReasonContainer" class="description-section mt-3" style="display: none;">
                        <div class="description-header">
                            <i class="fas fa-exclamation-circle me-2"></i>
                            <span>Reason</span>
                        </div>
                        <div id="modalReason" class="description-content"></div>
                    </div>
                    <div class="timestamp-info mt-3">
                        <small class="text-muted">
                            <i class="fas fa-clock me-1"></i>
                            Created: <span id="modalCreated"></span>
                        </small>
                        <span id="modalUpdated" style="display: none;"></span>
                    </div>
                    <input type="hidden" id="modalAppointmentId">
                </div>
                <div class="modal-footer appointment-modal-footer justify-content-between">
                    <div>
                        <button type="button" class="btn btn-warning btn-sm" id="rescheduleAppointmentBtn">
                            <i class="fas fa-calendar-alt me-1"></i> Re-schedule
                        </button>
                    </div>
                    <div>
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary btn-sm" id="approveAppointmentBtn">
                            <i class="fas fa-check me-1"></i> Approve
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="rescheduleModal" tabindex="-1" aria-labelledby="rescheduleModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-warning">
                    <h5 class="modal-title" id="rescheduleModalLabel">
                        <i class="fas fa-calendar-alt me-2"></i>Re-schedule Appointment
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="rescheduleForm">
                        <div class="mb-3">
                            <label for="rescheduleDate" class="form-label fw-bold">New Date:</label>
                            <input type="date" class="form-control" id="rescheduleDate" required>
                        </div>
                        <div class="mb-3">
                            <label for="rescheduleTime" class="form-label fw-bold">New Time:</label>
                            <select class="form-select" id="rescheduleTime" required>
                                <option value="">Select available time</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="rescheduleReason" class="form-label fw-bold">Reason for rescheduling:</label>
                            <textarea class="form-control" id="rescheduleReason" rows="3"
                                placeholder="Enter the reason for rescheduling..." required></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-warning" id="confirmRescheduleBtn">
                        <i class="fas fa-check me-1"></i>Confirm Re-schedule
                    </button>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="confirmationModal" tabindex="-1" aria-labelledby="confirmationModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="confirmationModalTitle">Confirm Action</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" id="confirmationModalBody"></div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="confirmActionBtn">Confirm</button>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="successModal" tabindex="-1" aria-labelledby="successModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title" id="successModalTitle">Success</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" id="successModalBody"></div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-success" data-bs-dismiss="modal">OK</button>
                </div>
            </div>
        </div>
    </div>

    <footer>
        <div class="footer-content">
            <div class="copyright">
                <b>© 2025 Counselign Team. All rights reserved.</b>
            </div>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        window.BASE_URL = "<?= base_url() ?>";
    </script>
    <script src="<?= base_url('js/counselor/appointments.js') ?>" defer></script>
    <script src="<?= base_url('js/counselor/counselor_drawer.js') ?>"></script>
    <script src="<?= base_url('js/utils/secureLogger.js') ?>"></script>
    <script src="<?= base_url('js/counselor/logout.js') ?>"></script>
    <script src="<?= base_url('js/utils/sidebar.js') ?>"></script>
</body>

</html>
