<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description"
        content="University Guidance Counseling Services - Your safe space for support and guidance" />
    <meta name="keywords" content="counseling, guidance, university, support, mental health, student wellness" />
    <meta name="csrf-token" content="<?= csrf_hash() ?>">
    <title>Follow-up Sessions - Student - Counselign</title>
    <link rel="icon" href="<?= base_url('Photos/counselign.ico') ?>" sizes="16x16 32x32" type="image/x-icon">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="<?= base_url('css/student/follow_up_sessions.css') ?>">
    <link rel="stylesheet" href="<?= base_url('css/student/header.css') ?>">
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
                <a href="<?= base_url('student/dashboard') ?>" class="sidebar-link" title="Dashboard">
                    <i class="fas fa-home"></i>
                    <span class="sidebar-text">Dashboard</span>
                </a>

                <a href="<?= base_url('student/schedule-appointment') ?>" class="sidebar-link" title="Schedule an Appointment">
                    <i class="fas fa-plus-circle"></i>
                    <span class="sidebar-text">Schedule an Appointment</span>
                </a>

                <a href="<?= base_url('student/my-appointments') ?>" class="sidebar-link" title="My Appointments">
                    <i class="fas fa-list-alt"></i>
                    <span class="sidebar-text">My Appointments</span>
                </a>

                <a href="<?= base_url('student/follow-up-sessions') ?>" class="sidebar-link active" title="Follow-up Sessions">
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
                    <i class="fas fa-clipboard-list me-2"></i>
                    Follow-up Sessions - Student View
                </h1>
            </div>

            <div class="top-bar-right">

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


        <main class="bg-light p-4">
            <div class="container-fluid px-4">
                <div class="row">
                    <div class="col-12">
                        <div class="follow-up-container">
                            <div class="section-header">
                                <p class="section-subtitle">View your completed appointments and their follow-up sessions</p>
                            </div>

                            <!-- Pending Follow-up Appointments Section -->
                            <div class="pending-follow-up-section" id="pendingFollowUpSection" style="display: none;">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <h3 class="subsection-title mb-0">
                                        <i class="fas fa-exclamation-triangle me-2"></i>
                                        Appointment with a Pending Follow-up
                                    </h3>
                                </div>
                                <div id="pendingFollowUpContainer" class="appointments-grid">
                                    <!-- Pending follow-up appointments will be loaded here -->
                                </div>
                            </div>

                            <!-- Completed Appointments Section -->
                            <div class="completed-appointments-section">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <h3 class="subsection-title mb-0">
                                        <i class="fas fa-check-circle me-2"></i>
                                        My Completed Appointments
                                    </h3>
                                    <div class="search-container">
                                        <div class="input-group" style="max-width: 300px;">
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
                                    <p>No completed appointments found. Complete some appointments to view follow-up sessions.</p>
                                </div>
                                <div id="noSearchResults" class="no-data-message" style="display: none;">
                                    <i class="fas fa-search"></i>
                                    <p>No appointments found matching your search criteria.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Follow-up Sessions Modal (Read-Only) -->
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

    <!-- Error Alert -->
    <div class="alert alert-danger alert-dismissible fade" id="errorAlert" role="alert" style="position: fixed; top: 20px; right: 20px; z-index: 9999; max-width: 400px;">
        <i class="fas fa-exclamation-triangle me-2"></i>
        <span id="errorMessage"></span>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>

    <!-- Success Alert -->
    <div class="alert alert-success alert-dismissible fade" id="successAlert" role="alert" style="position: fixed; top: 20px; right: 20px; z-index: 9999; max-width: 400px;">
        <i class="fas fa-check-circle me-2"></i>
        <span id="successMessage"></span>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="<?= base_url('js/student/follow_up_sessions.js') ?>"></script>
    <script src="<?= base_url('js/student/student_drawer.js') ?>"></script>
    <script src="<?= base_url('js/utils/secureLogger.js') ?>"></script>
    <script>
        // Set BASE_URL for JavaScript
        window.BASE_URL = '<?= base_url() ?>';
    </script>
    <script src="<?= base_url('js/student/student_header_drawer.js') ?>"></script>
    <script src="<?= base_url('js/student/logout.js') ?>"></script>
    <script src="<?= base_url('js/utils/sidebar.js') ?>"></script>
</body>

</html>