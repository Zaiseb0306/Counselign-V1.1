<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notification History - Counselign</title>
    <link rel="icon" href="<?= base_url('Photos/counselign.ico') ?>" sizes="16x16 32x32" type="image/x-icon">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
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
        <!-- Top Bar -->
        <header class="top-bar">
            <div class="top-bar-left">
                <h1 class="page-title-header">
                    <i class="fas fa-history me-2"></i>
                    Notification History
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
                <div class="appointment-container">
                    <div class="row mb-4">
                        <div class="col-12">
                            <h2 class="text-center fw-bold" style="color: #0d6efd;">Past Notifications</h2>
                            <p class="text-center text-muted">View and manage your notification history</p>
                        </div>
                    </div>

                    <!-- Loading Indicator -->
                    <div id="loadingIndicator" class="text-center py-5">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                        <p class="mt-2">Loading notification history...</p>
                    </div>

                    <!-- Notifications List -->
                    <div id="notificationsListContainer" class="d-none">
                        <div id="notificationsList">
                        </div>

                        <!-- Empty State -->
                        <div id="emptyState" class="text-center py-5 d-none">
                            <i class="fas fa-inbox fa-4x text-muted mb-3"></i>
                            <h4 class="text-muted">No Notifications Found</h4>
                            <p class="text-muted">You have no notification history.</p>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        window.BASE_URL = "<?= base_url() ?>";
    </script>
    <script src="<?= base_url('js/student/notification_history.js') ?>"></script>
    <script src="<?= base_url('js/student/logout.js') ?>"></script>
    <script>
        // Direct sidebar toggle - ensure it works regardless of sidebar.js issues
        document.addEventListener('DOMContentLoaded', function() {
            const sidebarToggle = document.getElementById('sidebarToggle');
            const sidebar = document.getElementById('uniSidebar');
            const sidebarOverlay = document.getElementById('sidebarOverlay');
            const profileDropdownBtn = document.getElementById('profileDropdownBtn');
            const profileDropdownMenu = document.getElementById('profileDropdownMenu');

            if (sidebarToggle) {
                sidebarToggle.addEventListener('click', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    
                    if (window.innerWidth >= 992) {
                        sidebar.classList.toggle('collapsed');
                    } else {
                        sidebar.classList.toggle('active');
                        sidebarOverlay.classList.toggle('active');
                    }
                });
            }

            if (sidebarOverlay) {
                sidebarOverlay.addEventListener('click', function() {
                    sidebar.classList.remove('active');
                    sidebarOverlay.classList.remove('active');
                });
            }

            // Profile dropdown - both hover and click functionality
            if (profileDropdownBtn && profileDropdownMenu) {
                // Remove any existing event listeners by cloning
                const newBtn = profileDropdownBtn.cloneNode(true);
                profileDropdownBtn.parentNode.replaceChild(newBtn, profileDropdownBtn);
                
                // Click handler
                newBtn.addEventListener('click', function(e) {
                    e.stopPropagation();
                    e.preventDefault();
                    profileDropdownMenu.classList.toggle('show');
                });

                // Hover handlers
                newBtn.addEventListener('mouseenter', function() {
                    profileDropdownMenu.classList.add('show');
                });

                newBtn.addEventListener('mouseleave', function() {
                    // Delay hiding to allow user to move mouse to dropdown
                    setTimeout(function() {
                        if (!profileDropdownMenu.matches(':hover')) {
                            profileDropdownMenu.classList.remove('show');
                        }
                    }, 200);
                });

                profileDropdownMenu.addEventListener('mouseenter', function() {
                    // Keep dropdown open when hovering over it
                });

                profileDropdownMenu.addEventListener('mouseleave', function() {
                    profileDropdownMenu.classList.remove('show');
                });

                // Close when clicking outside
                document.addEventListener('click', function(e) {
                    if (!profileDropdownMenu.contains(e.target) && !newBtn.contains(e.target)) {
                        profileDropdownMenu.classList.remove('show');
                    }
                });
            }

            // Load profile picture
            loadProfilePicture();
        });

        function loadProfilePicture() {
            fetch(window.BASE_URL + 'student/dashboard/get-profile-data', {
                method: 'GET',
                credentials: 'include',
                headers: {
                    'Accept': 'application/json'
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.success && data.data) {
                    const profilePicture = data.data.profile_picture;
                    if (profilePicture) {
                        const profileImgTop = document.getElementById('profile-img-top');
                        const profileImgDropdown = document.getElementById('profile-img-dropdown');
                        
                        if (profileImgTop) {
                            profileImgTop.src = profilePicture.startsWith('/') ? window.BASE_URL + profilePicture.substring(1) : profilePicture;
                        }
                        if (profileImgDropdown) {
                            profileImgDropdown.src = profilePicture.startsWith('/') ? window.BASE_URL + profilePicture.substring(1) : profilePicture;
                        }
                    }

                    // Update user name
                    const firstName = data.data.first_name || '';
                    const lastName = data.data.last_name || '';
                    const fullName = (firstName + ' ' + lastName).trim();
                    
                    if (fullName) {
                        const uniNameTop = document.getElementById('uniNameTop');
                        const uniNameDropdown = document.getElementById('uniNameDropdown');
                        
                        if (uniNameTop) uniNameTop.textContent = fullName;
                        if (uniNameDropdown) uniNameDropdown.textContent = fullName;
                    }
                }
            })
            .catch(error => {
                console.error('Error loading profile picture:', error);
            });
        }
    </script>
</body>

</html>
