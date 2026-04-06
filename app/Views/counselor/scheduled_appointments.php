<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Scheduled Appointments - Counselign</title>
    <link rel="icon" href="<?= base_url('Photos/counselign.ico') ?>" sizes="16x16 32x32" type="image/x-icon">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<?= base_url('css/counselor/scheduled_appointments.css') ?>">
    <link rel="stylesheet" href="<?= base_url('css/counselor/header.css') ?>">
    <link rel="stylesheet" href="<?= base_url('css/utils/sidebar.css') ?>">

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
                <a href="<?= base_url('counselor/dashboard') ?>" class="sidebar-link " title="Dashboard">
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

    <div class="toast-container position-fixed bottom-0 end-0 p-3">
        <div id="statusToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
            <div class="toast-header">
                <strong class="me-auto" id="toastTitle">Notification</strong>
                <small id="toastTime">Just now</small>
                <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
            <div class="toast-body" id="toastMessage">Status updated successfully.</div>
        </div>
    </div>

    <div class="main-wrapper" id="mainWrapper">
        <!-- Interactive Profile Picture Section -->

        <!-- Top Bar -->
        <header class="top-bar">
            <div class="top-bar-left">
                <h1 class="page-title-header">
                    <i class="fas fa-calendar-alt me-2"></i>
                    Consultation Schedule Queries
                </h1>
            </div>

            <div class="top-bar-right">

                <div class="search-container">
                    <div class="input-group" style="max-width: 300px;">
                        <span class="input-group-text bg-white border-end-0">
                            <i class="fas fa-search text-muted"></i>
                        </span>
                        <input type="text" class="form-control border-start-0" id="appointmentsSearchInput" placeholder="Search appointments..." aria-label="Search appointments">
                        <button class="btn btn-outline-secondary" type="button" id="clearSearchBtn" style="display: none;">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                </div>

                <button class="top-bar-btn" onclick="window.location.href='<?= base_url('counselor/appointments') ?>'" title="Appointments">
                    <i class="fa fa-list-alt text-2xl" style="cursor: pointer;"></i>
                    <span class="btn-label">Appointments</span>
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
        <main class="bg-light p-4">
            <div class="container-fluid px-4">
                <div class="csq-layout">
                    <div class="csq-left">
                        <div class="csq-card">
                            <div id="loading-indicator" class="text-center py-5 d-none">
                                <div class="spinner-border text-primary" role="status">
                                    <span class="visually-hidden">Loading...</span>
                                </div>
                                <p class="mt-2">Loading appointments...</p>
                            </div>

                            <div id="empty-message" class="alert alert-info text-center d-none">
                                <i class="fas fa-info-circle me-2"></i> No scheduled appointments found.
                            </div>

                            <div class="table-bordered csq-table-wrap overflow-auto" id="appointments-table-container" style="overflow-x: auto;">
                                <table class="table csq-table" id="appointments-table">
                                    <thead>
                                        <tr>
                                            <th scope="col">Student ID</th>
                                            <th scope="col">Name</th>
                                            <th scope="col">Appointed Date</th>
                                            <th scope="col">Time</th>
                                            <th scope="col">Method</th>
                                            <th scope="col">Consultation Type</th>
                                            <th scope="col">Appointment Type</th>
                                            <th scope="col">Purpose</th>
                                            <th scope="col" class="text-center">Status</th>
                                            <th scope="col" class="text-center">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody id="appointments-body"></tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <aside class="csq-right">
                        <div class="csq-card csq-sidebar-container">
                            <div class="sidebar-card">
                                <h6 class="mb-3">Your Weekly Consultation Schedules</h6>
                                <div class="schedule-list">
                                    <div class="schedule-row"><span>Monday</span><span>8:00am–11:00am</span></div>
                                    <div class="schedule-row"><span>Tuesday</span><span>2:00pm–4:00pm</span></div>
                                    <div class="schedule-row"><span>Thursday</span><span>8:00am–4:00pm</span></div>
                                </div>
                            </div>

                            <div class="sidebar-card mini-calendar-card">
                                <div class="mini-cal-header">
                                    <button class="mini-cal-btn" id="prevMonth"><i class="fas fa-chevron-left"></i></button>
                                    <div class="mini-cal-title" id="monthYear"></div>
                                    <button class="mini-cal-btn" id="nextMonth"><i class="fas fa-chevron-right"></i></button>
                                </div>
                                <div class="mini-cal-week">
                                    <span>S</span><span>M</span><span>T</span><span>W</span><span>T</span><span>F</span><span>S</span>
                                </div>
                                <div class="mini-cal-days" id="calendarDays"></div>
                                <div class="mini-cal-legend">
                                    <div class="legend-item"><span class="legend-dot has-appointment"></span><span>Has Appointments</span></div>
                                    <div class="legend-item"><span class="legend-dot today"></span><span>Today</span></div>
                                </div>
                            </div>
                        </div>
                    </aside>
                </div>
            </div>
        </main>
    </div>

    <div class="modal fade" id="cancellationReasonModal" tabindex="-1" aria-labelledby="cancellationReasonModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-secondary text-white">
                    <h5 class="modal-title" id="cancellationReasonModalLabel"><i class="fas fa-times-circle me-2"></i>Cancellation Reason</h5>
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
                    <button type="button" class="btn btn-secondary" id="confirmCancellationBtn"><i class="fas fa-check me-1"></i>Confirm Cancellation</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        window.BASE_URL = "<?= base_url() ?>";
    </script>
    <script src="<?= base_url('js/utils/timeFormatter.js') ?>"></script>
    <script src="<?= base_url('js/counselor/scheduled_appointments.js') ?>"></script>
    <script src="<?= base_url('js/counselor/counselor_drawer.js') ?>"></script>
    <script src="<?= base_url('js/utils/secureLogger.js') ?>"></script>
    <script src="<?= base_url('js/counselor/logout.js') ?>"></script>
    <script src="<?= base_url('js/utils/sidebar.js') ?>"></script>
</body>

</html>