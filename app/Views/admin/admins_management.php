<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="University Guidance Counseling Services" />
    <meta name="keywords" content="counseling, guidance, university, support" />
    <title>Admin's Management - Counselign</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="icon" href="<?= base_url('Photos/counselign.ico') ?>" sizes="16x16 32x32" type="image/x-icon">
    <link rel="stylesheet" href="<?= base_url('css/admin/admins_management.css') ?>">
    <link rel="stylesheet" href="<?= base_url('css/admin/header.css') ?>">
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
                <a href="<?= base_url('admin/dashboard') ?>" class="sidebar-link" title="Dashboard">
                    <i class="fas fa-home"></i>
                    <span class="sidebar-text">Dashboard</span>
                </a>
                <a href="<?= base_url('admin/admins-management') ?>" class="sidebar-link active" title="Management">
                    <i class="fas fa-users-cog"></i>
                    <span class="sidebar-text">Management</span>
                </a>
                <a href="<?= base_url('admin/appointments') ?>" class="sidebar-link" title="Recent Appointments">
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

    <!-- Main Content -->
    <div class="main-wrapper" id="mainWrapper">

        <!-- Top Bar -->
        <header class="top-bar">
            <div class="top-bar-left">
                <!-- Page Title Added Here -->
                <h1 class="page-title-header">
                    <i class="fas fa-calendar-days me-2"></i>
                    Counselor Weekly Schedule
                </h1>
            </div>

            <div class="top-bar-right">
                <button class="top-bar-btn" id="refreshScheduleBtn" type="button" aria-label="Refresh schedule">
                    <i class="fas fa-sync-alt"></i>
                </button>
                <button class="top-bar-btn" onclick="window.location.href='<?= base_url('admin/counselor-info') ?>'" title="Counselor Accounts">
                    <i class="fa fa-user-tie"></i>
                    <span class="btn-label">Counselor Accounts</span>
                </button>

                <button class="top-bar-btn" onclick="window.location.href='<?= base_url('admin/view-users') ?>'" title="Student Accounts">
                    <i class="fa fa-users"></i>
                    <span class="btn-label">Student Accounts</span>
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


        <div class="container py-5">

            <div class="schedule-grid-container">
                <div class="schedule-grid">
                    <!-- Monday -->
                    <div class="day-column" data-day="Monday">
                        <div class="day-header">
                            <i class="fas fa-calendar-day"></i>
                            <span>Monday</span>
                        </div>
                        <div class="counselor-cards-container" id="monday-schedule">
                            <div class="loading-placeholder">
                                <i class="fas fa-spinner fa-spin"></i>
                                <p>Loading schedule...</p>
                            </div>
                        </div>
                    </div>

                    <!-- Tuesday -->
                    <div class="day-column" data-day="Tuesday">
                        <div class="day-header">
                            <i class="fas fa-calendar-day"></i>
                            <span>Tuesday</span>
                        </div>
                        <div class="counselor-cards-container" id="tuesday-schedule">
                            <div class="loading-placeholder">
                                <i class="fas fa-spinner fa-spin"></i>
                                <p>Loading schedule...</p>
                            </div>
                        </div>
                    </div>

                    <!-- Wednesday -->
                    <div class="day-column" data-day="Wednesday">
                        <div class="day-header">
                            <i class="fas fa-calendar-day"></i>
                            <span>Wednesday</span>
                        </div>
                        <div class="counselor-cards-container" id="wednesday-schedule">
                            <div class="loading-placeholder">
                                <i class="fas fa-spinner fa-spin"></i>
                                <p>Loading schedule...</p>
                            </div>
                        </div>
                    </div>

                    <!-- Thursday -->
                    <div class="day-column" data-day="Thursday">
                        <div class="day-header">
                            <i class="fas fa-calendar-day"></i>
                            <span>Thursday</span>
                        </div>
                        <div class="counselor-cards-container" id="thursday-schedule">
                            <div class="loading-placeholder">
                                <i class="fas fa-spinner fa-spin"></i>
                                <p>Loading schedule...</p>
                            </div>
                        </div>
                    </div>

                    <!-- Friday -->
                    <div class="day-column" data-day="Friday">
                        <div class="day-header">
                            <i class="fas fa-calendar-day"></i>
                            <span>Friday</span>
                        </div>
                        <div class="counselor-cards-container" id="friday-schedule">
                            <div class="loading-placeholder">
                                <i class="fas fa-spinner fa-spin"></i>
                                <p>Loading schedule...</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        window.BASE_URL = "<?= base_url() ?>";
    </script>
    <script src="<?= base_url('js/utils/timeFormatter.js') ?>"></script>
    <script src="<?= base_url('js/admin/admin_drawer.js') ?>"></script>
    <script src="<?= base_url('js/admin/profile_sync.js') ?>"></script>
    <script src="<?= base_url('js/admin/logout.js') ?>" defer></script>
    <script src="<?= base_url('js/admin/admins_management.js') ?>"></script>
    <script src="<?= base_url('js/utils/secureLogger.js') ?>"></script>
    <script src="<?= base_url('js/utils/sidebar.js') ?>"></script>
</body>

</html>