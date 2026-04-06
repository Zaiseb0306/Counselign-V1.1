<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Scheduled Appointments - Counselign</title>
    <link rel="icon" href="<?= base_url('Photos/counselign.ico') ?>" sizes="16x16 32x32" type="image/x-icon">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<?= base_url('css/admin/scheduled_appointments.css') ?>">
    <link rel="stylesheet" href="<?= base_url('css/admin/header.css') ?>">
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
                <a href="<?= base_url('admin/dashboard') ?>" class="sidebar-link " title="Dashboard">
                    <i class="fas fa-home"></i>
                    <span class="sidebar-text">Dashboard</span>
                </a>
                <a href="<?= base_url('admin/admins-management') ?>" class="sidebar-link" title="Management">
                    <i class="fas fa-users-cog"></i>
                    <span class="sidebar-text">Management</span>
                </a>
                <a href="<?= base_url('admin/appointments') ?>" class="sidebar-link active" title="Recent Appointments">
                    <i class="fas fa-calendar-check"></i>
                    <span class="sidebar-text">Recent Appointments</span>
                </a>
                <a href="<?= base_url('admin/follow-up-sessions') ?>" class="sidebar-link" title="Follow-up Sessions">
                    <i class="fas fa-calendar-days"></i>
                    <span class="sidebar-text">Follow-up Sessions</span>
                </a>
                <a href="<?= base_url('admin/resources') ?>" class="sidebar-link" title="Resources">
                    <i class="fas fa-folder-open"></i>
                    <span class="sidebar-text">Resources</span>
                </a>
                <a href="<?= base_url('admin/announcements') ?>" class="sidebar-link" title="Announcements">
                    <i class="fa-solid fa-bullhorn"></i>
                    <span class="sidebar-text">Announcements</span>
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

    <!-- Toast notification -->
    <div class="toast-container position-fixed bottom-0 end-0 p-3">
        <div id="statusToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
            <div class="toast-header">
                <strong class="me-auto" id="toastTitle">Notification</strong>
                <small id="toastTime">Just now</small>
                <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
            <div class="toast-body" id="toastMessage">
                Status updated successfully.
            </div>
        </div>
    </div>

    <!-- Main Content Section -->
    <div class="main-wrapper" id="mainWrapper">
        <header class="top-bar">
            <div class="top-bar-left">
                <!-- Page Title Added Here -->
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
                <!-- Quote Modal Button -->
                <button class="top-bar-btn" onclick="window.location.href='<?= base_url('admin/appointments') ?>'" title="Appointments">
                    <i class="fas fa-list-alt"></i>
                    <span class="btn-label">Appointments</span>
                </button>

                <!-- Profile Dropdown -->
                <div class="profile-dropdown">
                    <button class="top-bar-btn profile-btn" id="profileDropdownBtn">
                        <img id="profile-img-top" src="<?= base_url('Photos/UGC-Logo.png') ?>" alt="Profile" class="profile-img-small">
                        <span class="btn-label" id="uniNameTop">Admin</span>
                    </button>

                    <div class="profile-dropdown-menu" id="profileDropdownMenu">
                        <div class="profile-dropdown-header">
                            <img id="profile-img-dropdown" src="<?= base_url('Photos/UGC-Logo.png') ?>" alt="Profile" class="profile-img-large">
                            <div class="profile-info">
                                <div class="profile-name" id="uniNameDropdown">Admin</div>
                                <div class="profile-subtitle" id="lastLoginDropdown">Loading...</div>
                            </div>
                        </div>
                        <div class="profile-dropdown-divider"></div>
                        <a href="<?= base_url('admin/account-settings') ?>" class="profile-dropdown-item">
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
                            <!-- Loading Indicator -->
                            <div id="loading-indicator" class="text-center py-5 d-none">
                                <div class="spinner-border text-primary" role="status">
                                    <span class="visually-hidden">Loading...</span>
                                </div>
                                <p class="mt-2">Loading appointments...</p>
                            </div>

                            <!-- Empty Message -->
                            <div id="empty-message" class="alert alert-info text-center d-none">
                                <i class="fas fa-info-circle me-2"></i> No scheduled appointments found.
                            </div>

                            <div class="table-bordered csq-table-wrap" id="appointments-table-container">
                                <!-- Table Section -->
                                <table class="table csq-table" id="appointments-table">
                                    <thead>
                                        <tr>
                                            <th scope="col">Student ID</th>
                                            <th scope="col">Student Name</th>
                                            <th scope="col">Appointed Date</th>
                                            <th scope="col">Time</th>
                                            <th scope="col">Consultation Type</th>
                                            <th scope="col">Purpose</th>
                                            <th scope="col">Appointed Counselor</th>
                                            <th scope="col" class="text-center">Status</th>
                                        </tr>
                                    </thead>
                                    <tbody id="appointments-body"></tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <aside class="csq-right">
                        <div class="csq-card csq-sidebar-container">
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


    <!-- Cancellation Reason Modal -->
    <div class="modal fade" id="cancellationReasonModal" tabindex="-1" aria-labelledby="cancellationReasonModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-secondary text-white">
                    <h5 class="modal-title" id="cancellationReasonModalLabel">
                        <i class="fas fa-times-circle me-2"></i>Cancellation Reason
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="cancellationReasonForm">
                        <div class="mb-3">
                            <label for="cancellationReason" class="form-label fw-bold">Please provide a reason for cancelling this appointment:</label>
                            <textarea class="form-control" id="cancellationReason" rows="4"
                                placeholder="Enter the reason for cancellation here..." required></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary" id="confirmCancellationBtn">
                        <i class="fas fa-check me-1"></i>Confirm Cancellation
                    </button>
                </div>
            </div>
        </div>
    </div>


    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        window.BASE_URL = "<?= base_url() ?>";
    </script>
    <script src="<?= base_url('js/admin/admin_drawer.js') ?>"></script>
    <script src="<?= base_url('js/admin/scheduled_appointments.js') ?>"></script>
    <script src="<?= base_url('js/admin/logout.js') ?>" defer></script>
    <script src="<?= base_url('js/utils/secureLogger.js') ?>"></script>
    <script src="<?= base_url('js/utils/sidebar.js') ?>"></script>
</body>

</html>