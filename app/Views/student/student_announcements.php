<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="University Guidance Counseling Services - Announcements and Events" />
    <meta name="keywords" content="counseling, guidance, university, support, mental health, counselor wellness" />
    <title>Announcements and Events - Counselign</title>
    <link rel="icon" href="<?= base_url('Photos/counselign.ico') ?>" sizes="16x16 32x32" type="image/x-icon">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="<?= base_url('css/student/student_announcements.css') ?>">
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
                <a href="<?= base_url('student/dashboard') ?>" class="sidebar-link " title="Dashboard">
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

                <a href="<?= base_url('student/follow-up-sessions') ?>" class="sidebar-link" title="Follow-up Sessions">
                    <i class="fas fa-clipboard-list"></i>
                    <span class="sidebar-text">Follow-up Sessions</span>
                </a>
                <a href="<?= base_url('student/announcements') ?>" class="sidebar-link active" title="Announcement">
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
                    <i class="fas fa-bullhorn me-2"></i>
                    Announcements and Events
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

        <main>
            <!-- Announcements and Events Section -->
            <div class="announcements-container">
            <h2 class="section-title">Announcements and Events</h2>

                <!-- Announcements Section -->
                <div class="announcements-section">
                    <h3 class="subsection-title">Announcements</h3>
                    <div class="scrollable-container">
                        <div class="announcements-list" id="announcementsList">
                            <!-- Announcements will be dynamically loaded here -->
                        </div>
                    </div>
                </div>

                <!-- Inline Calendar Section -->
                <div class="calendar-section">
                    <h3 class="subsection-title">Calendar</h3>
                    <div class="calendar-container">
                        <div class="calendar-header">
                            <button id="prevMonth" class="calendar-nav-btn">
                                <i class="fas fa-chevron-left"></i>
                            </button>
                            <h4 id="currentMonth" class="calendar-month"></h4>
                            <button id="nextMonth" class="calendar-nav-btn">
                                <i class="fas fa-chevron-right"></i>
                            </button>
                        </div>
                        <div class="calendar-grid" id="calendarGrid">
                            <!-- Calendar will be dynamically generated here -->
                        </div>
                    </div>
                </div>

                <!-- Upcoming Events List (full width) -->
                <div class="upcoming-events-section">
                    <h3 class="subsection-title">Upcoming Events</h3>
                    <div class="scrollable-container">
                        <div class="events-list" id="eventsList">
                            <!-- Events will be dynamically loaded here -->
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <?php echo view('modals/student_dashboard_modals'); ?>
    <script src="<?= base_url('js/modals/student_dashboard_modals.js') ?>"></script>
    <script src="<?= base_url('js/student/student_announcements.js') ?>" defer></script>
    <script src="<?= base_url('js/student/student_header_drawer.js') ?>"></script>
    <script src="<?= base_url('js/utils/secureLogger.js') ?>"></script>
    <script src="<?= base_url('js/student/logout.js') ?>"></script>
    <script src="<?= base_url('js/utils/sidebar.js') ?>"></script>
    <script>
        window.BASE_URL = "<?= base_url() ?>";
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>

</html>