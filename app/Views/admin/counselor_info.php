<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="University Guidance Counseling Services" />
    <meta name="keywords" content="counseling, guidance, university, support" />
    <title>Counselor's Information - Counselign</title>
    <link rel="icon" href="<?= base_url('Photos/counselign.ico') ?>" sizes="16x16 32x32" type="image/x-icon">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="<?= base_url('css/admin/counselor_info.css') . '?v=' . @filemtime(FCPATH . 'css/admin/counselor_info.css') ?>" rel="stylesheet" />
    <link rel="stylesheet" href="<?= base_url('css/admin/header.css') . '?v=' . @filemtime(FCPATH . 'css/admin/header.css') ?>">
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

    <button class="counselor-sidebar-toggle d-lg-none" type="button" id="counselorSidebarToggler" aria-label="Toggle counselors list">
        <span class="navbar-toggler-icon"><i class="fas fa-users"></i></span>
    </button>

    <!-- Main Content Area -->
    <div class="main-wrapper" id="mainWrapper">
        <!-- Top Bar -->
        <header class="top-bar">
            <div class="top-bar-left">
                <!-- Page Title Header -->
                <h1 class="page-title-header">
                    <i class="fas fa-user-tie me-2"></i>
                    Counselor Information
                </h1>
            </div>

            <div class="top-bar-right">
                <button class="top-bar-btn" onclick="window.location.href='<?= base_url('admin/admins-management') ?>'" title="Management">
                    <i class="fas fa-tasks"></i>
                    <span class="btn-label">Management</span>
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

        <div class="counselor-layout">


            <!-- Sidebar -->
            <div class="counselor-sidebar">
                <h2>Counselors</h2>
                <div class="counselor-list">
                    <!-- Counselors will be dynamically loaded here -->
                </div>
                <button class="add-counselor" hidden>
                    <i class="fas fa-plus"></i> Add New Counselor
                </button>
            </div>

            <!-- Main Content - Counselor Form -->
            <div class="counselor-form-container">
                <div class="counselor-details">
                    <div class="profile-image-container text-center">
                        <img src="<?= base_url('Photos/profile.png') ?>" alt="Counselor Profile" class="profile-image" id="main-profile-image">
                    </div>

                    <div class="details-right">
                        <div class="form-grid">
                            <div class="form-group">
                                <label>Counselor's ID:</label>
                                <div class="info-display" id="counselorId">-</div>
                            </div>

                            <div class="form-group">
                                <label>Name:</label>
                                <div class="info-display" id="name">-</div>
                            </div>

                            <div class="form-group">
                                <label>Degree:</label>
                                <div class="info-display" id="degree">-</div>
                            </div>

                            <div class="form-group">
                                <label>Email:</label>
                                <div class="info-display" id="email">-</div>
                            </div>

                            <div class="form-group">
                                <label>Contact Number:</label>
                                <div class="info-display" id="contactNumber">-</div>
                            </div>

                            <div class="form-group">
                                <label>Address:</label>
                                <div class="info-display" id="address">-</div>
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Availability:</label>
                            <div id="availabilityCards" class="availability-cards" style="display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,2fr));gap:8px;">Loading...</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Overlay for Counselor Sidebar (Small Screens) -->
    <div class="counselor-sidebar-overlay d-lg-none" id="counselorSidebarOverlay"></div>

    

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        window.BASE_URL = "<?= base_url() ?>";
    </script>
    <script src="<?= base_url('js/utils/timeFormatter.js') ?>"></script>
    <script src="<?= base_url('js/admin/counselor_info.js') ?>"></script>
    <script src="<?= base_url('js/admin/logout.js') ?>" defer></script>
    <script src="<?= base_url('js/admin/admin_drawer.js') ?>"></script>
    <script src="<?= base_url('js/utils/secureLogger.js') ?>"></script>
    <script src="<?= base_url('js/admin/counselor_info_mobile.js') . '?v=' . @filemtime(FCPATH . 'js/admin/counselor_info_mobile.js') ?>"></script>
    <script src="<?= base_url('js/utils/sidebar.js') ?>"></script>
</body>

</html>