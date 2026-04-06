<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description"
        content="University Guidance Counseling Services - Your safe space for support and guidance" />
    <meta name="keywords" content="counseling, guidance, university, support, mental health, student wellness" />
    <meta name="csrf-token" content="<?= csrf_hash() ?>">
    <title>Follow-up Sessions - Admin - Counselign</title>
    <link rel="icon" href="<?= base_url('Photos/counselign.ico') ?>" sizes="16x16 32x32" type="image/x-icon">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="<?= base_url('css/admin/follow_up_sessions.css') ?>">
    <link rel="stylesheet" href="<?= base_url('css/admin/header.css') ?>">
    <link rel="stylesheet" href="<?= base_url('css/utils/sidebar.css') ?>">
</head>

<body>
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
                <a href="<?= base_url('admin/appointments') ?>" class="sidebar-link" title="Recent Appointments">
                    <i class="fas fa-calendar-check"></i>
                    <span class="sidebar-text">Recent Appointments</span>
                </a>
                <a href="<?= base_url('admin/follow-up-sessions') ?>" class="sidebar-link active" title="Follow-up Sessions">
                    <i class="fas fa-calendar-days"></i>
                    <span class="sidebar-text">Follow-up Sessions</span>
                </a>
                <a href="<?= base_url('admin/resources') ?>" class="sidebar-link" title="Resources">
                    <i class="fas fa-folder-open"></i>
                    <span class="sidebar-text">Resources</span>
                </a>
                <a href="<?= base_url('admin/announcements') ?>" class="sidebar-link " title="Announcements">
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


    <main class="main-wrapper" id="mainWrapper">
        <header class="top-bar">
            <div class="top-bar-left">
                <!-- Page Title Added Here -->
                <h1 class="page-title-header">
                    <i class="fas fa-calendar-check me-2"></i>
                    Follow-up Sessions - Admin View
                </h1>
            </div>

            <div class="top-bar-right">

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

        <div class="container py-5">
            <!-- Removed section-header div - title now in top bar -->

            <!-- Completed Appointments Section -->
            <div class="completed-appointments-section">
                <div class="section-header-bar">
                    <div class="section-title-wrapper">
                        <h3 class="subsection-title mb-0">
                            <i class="fas fa-check-circle me-2"></i>
                            All Completed Appointments
                        </h3>
                        <p class="section-description">View and manage follow-up sessions for all completed appointments</p>
                    </div>
                    <div class="search-container">
                        <div class="input-group search-wrapper">
                            <span class="input-group-text"><i class="fas fa-search"></i></span>
                            <input type="text" class="form-control" id="searchInput" placeholder="Search appointments...">
                            <button class="btn btn-outline-secondary" type="button" id="clearSearchBtn" style="display: none;">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                    </div>
                </div>
                <div id="completedAppointmentsContainer" class="appointments-grid">
                    <!-- Completed appointments will be loaded here -->
                </div>
                <div id="noCompletedAppointments" class="no-data-message" style="display: none;">
                    <i class="fas fa-info-circle"></i>
                    <p>No completed appointments found.</p>
                </div>
                <div id="noSearchResults" class="no-data-message" style="display: none;">
                    <i class="fas fa-search"></i>
                    <p>No appointments found matching your search criteria.</p>
                </div>
            </div>
        </div>
    </main>

    <!-- Follow-up Sessions Modal -->
    <div class="modal fade" id="followUpSessionsModal" tabindex="-1" aria-labelledby="followUpSessionsModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="followUpSessionsModalLabel">
                        <i class="fas fa-calendar-alt me-2"></i>
                        Follow-up Sessions
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div id="followUpSessionsContainer">
                        <!-- Follow-up sessions will be loaded here -->
                    </div>
                    <div id="noFollowUpSessions" class="no-data-message" style="display: none;">
                        <i class="fas fa-info-circle"></i>
                        <p>No follow-up sessions found for this appointment.</p>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Success Modal -->
    <div class="modal fade" id="successModal" tabindex="-1" aria-labelledby="successModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title" id="successModalTitle">
                        <i class="fas fa-check-circle me-2"></i>
                        Success
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" id="successModalBody">
                    <!-- Success message will be displayed here -->
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-success" data-bs-dismiss="modal">OK</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Error Modal -->
    <div class="modal fade" id="errorModal" tabindex="-1" aria-labelledby="errorModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title" id="errorModalTitle">
                        <i class="fas fa-exclamation-circle me-2"></i>
                        Error
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" id="errorModalBody">
                    <!-- Error message will be displayed here -->
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-danger" data-bs-dismiss="modal">OK</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        window.BASE_URL = "<?= base_url() ?>";
    </script>
    <script src="<?= base_url('js/admin/admin_dashboard.js') ?>"></script>
    <script src="<?= base_url('js/admin/follow_up_sessions.js') ?>" defer></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="<?= base_url('js/admin/admin_drawer.js') ?>"></script>
    <script src="<?= base_url('js/utils/secureLogger.js') ?>"></script>
    <script src="<?= base_url('js/utils/sidebar.js') ?>"></script>
</body>

</html>