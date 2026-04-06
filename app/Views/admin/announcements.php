<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Announcements - Counselign</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="icon" href="<?= base_url('Photos/counselign.ico') ?>" type="image/x-icon">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<?= base_url('css/admin/admin_announcements.css') ?>">
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
                <a href="<?= base_url('admin/follow-up-sessions') ?>" class="sidebar-link" title="Follow-up Sessions">
                    <i class="fas fa-calendar-days"></i>
                    <span class="sidebar-text">Follow-up Sessions</span>
                </a>
                <a href="<?= base_url('admin/resources') ?>" class="sidebar-link" title="Resources">
                    <i class="fas fa-folder-open"></i>
                    <span class="sidebar-text">Resources</span>
                </a>
                <a href="<?= base_url('admin/announcements') ?>" class="sidebar-link active" title="Announcements">
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

    <!-- Main Content Area -->
    <div class="main-wrapper" id="mainWrapper">
        <header class="top-bar">
            <div class="top-bar-left">
                <!-- Page Title Added Here -->
                <h1 class="page-title-header">
                    <i class="fas fa-bullhorn me-2"></i>
                    Announcements and Events
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

            <div class="row">
                <!-- Announcements Column -->
                <div class="col-lg-6 col-12">
                    <div class="section-header">
                        <i class="fas fa-bullhorn me-2 text-primary fs-3"></i>
                        <h2 class="fw-bold text-primary">Announcements</h2>
                    </div>
                    <div class="card">
                        <div class="card-body">
                            <div class="d-flex justify-content-end mb-3">
                                <button type="button" class="btn btn-add-announcement" onclick="openAnnouncementModal()">
                                    <i class="fas fa-plus me-1"></i> Add Announcement
                                </button>
                            </div>
                            <div class="category-container">
                                <div id="announcements-list" class="scrollable-list">
                                    <!-- Announcement items will be loaded here -->
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Events Column -->
                <div class="col-lg-6 col-12">
                    <div class="section-header">
                        <i class="fas fa-calendar-alt me-2 text-primary fs-3"></i>
                        <h2 class="fw-bold text-primary">Events</h2>
                    </div>
                    <div class="card">
                        <div class="card-body">
                            <div class="d-flex justify-content-end mb-3">
                                <button type="button" class="btn btn-add-announcement" onclick="openEventModal()">
                                    <i class="fas fa-calendar-plus me-1"></i> Add Event
                                </button>
                            </div>
                            <div class="category-container">
                                <div id="events-list" class="scrollable-list">
                                    <!-- Event items will be loaded here -->
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>


    <!-- Event Modal -->
    <div id="eventModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeEventModal()">&times;</span>
            <h2>Add New Event</h2>
            <form id="eventForm">
                <div class="mb-3">
                    <label for="eventTitle" class="form-label">Event Title</label>
                    <input type="text" class="form-control" id="eventTitle" required>
                </div>
                <div class="mb-3">
                    <label for="eventDescription" class="form-label">Description</label>
                    <textarea class="form-control" id="eventDescription" rows="3" required></textarea>
                </div>
                <div class="row mb-3">
                    <div class="col-md-6">
                        <label for="eventDate" class="form-label">Date</label>
                        <input type="date" class="form-control" id="eventDate" required>
                    </div>
                    <div class="col-md-6">
                        <label for="eventTime" class="form-label">Time</label>
                        <input type="time" class="form-control" id="eventTime" required>
                    </div>
                </div>
                <div class="mb-3">
                    <label for="eventLocation" class="form-label">Location</label>
                    <input type="text" class="form-control" id="eventLocation" required>
                </div>
                <div class="text-end">
                    <button type="submit" class="btn btn-add-announcement">
                        <i class="fas fa-plus me-1"></i> Save
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Announcement Modal -->
    <div id="announcementModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeAnnouncementModal()">&times;</span>
            <h2>Add Announcement</h2>
            <form id="announcement-form" class="row g-3">
                <div class="mb-3">
                    <label for="announcement-title" class="form-label">Announcement Title</label>
                    <input type="text" id="announcement-title" class="form-control" placeholder="Enter title here"
                        required>
                </div>
                <div class="mb-3">
                    <label for="announcement-content" class="form-label">Announcement Content</label>
                    <textarea id="announcement-content" class="form-control" rows="3" placeholder="Enter content here"
                        required></textarea>
                </div>
                <div class="text-end">
                    <button type="submit" class="btn btn-add-announcement">
                        <i class="fas fa-plus me-1"></i> Save
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Edit Announcement Modal -->
    <div id="editAnnouncementModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeEditAnnouncementModal()">&times;</span>
            <h2>Edit Announcement</h2>
            <form id="edit-announcement-form" class="row g-3">
                <div class="mb-3">
                    <label for="edit-announcement-title" class="form-label">Announcement Title</label>
                    <input type="text" id="edit-announcement-title" class="form-control" placeholder="Enter title here"
                        required>
                </div>
                <div class="mb-3">
                    <label for="edit-announcement-content" class="form-label">Announcement Content</label>
                    <textarea id="edit-announcement-content" class="form-control" rows="3"
                        placeholder="Enter content here" required></textarea>
                </div>
                <div class="text-end">
                    <button type="submit" class="btn btn-add-announcement">
                        <i class="fas fa-plus me-1"></i> Save
                    </button>
                </div>
            </form>
        </div>
    </div>


    <!-- Edit Event Modal -->
    <div id="editEventModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeEditEventModal()">&times;</span>
            <h2>Edit Event</h2>
            <form id="edit-event-form" class="row g-3">
                <div class="mb-3">
                    <label for="editEventTitle" class="form-label">Event Title</label>
                    <input type="text" class="form-control" id="editEventTitle" required>
                </div>
                <div class="mb-3">
                    <label for="editEventDescription" class="form-label">Description</label>
                    <textarea class="form-control" id="editEventDescription" rows="3" required></textarea>
                </div>
                <div class="row mb-3">
                    <div class="col-md-6">
                        <label for="editEventDate" class="form-label">Date</label>
                        <input type="date" class="form-control" id="editEventDate" required>
                    </div>
                    <div class="col-md-6">
                        <label for="editEventTime" class="form-label">Time</label>
                        <input type="time" class="form-control" id="editEventTime" required>
                    </div>
                </div>
                <div class="mb-3">
                    <label for="editEventLocation" class="form-label">Location</label>
                    <input type="text" class="form-control" id="editEventLocation" required>
                </div>
                <div class="text-end">
                    <button type="submit" class="btn btn-add-announcement">
                        <i class="fas fa-plus me-1"></i> Save
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Confirm Delete Modal (reusable) -->
    <div id="confirmDeleteModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeConfirmDeleteModal()">&times;</span>
            <h2>Confirm Deletion</h2>
            <p id="confirmDeleteMessage">Are you sure you want to delete this item? This action cannot be undone.</p>
            <div class="text-end">
                <button type="button" class="btn btn-secondary me-2" onclick="closeConfirmDeleteModal()">Cancel</button>
                <button type="button" class="btn btn-danger" id="confirmDeleteBtn"><i class="fas fa-trash-alt me-1"></i> Delete</button>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.28/jspdf.plugin.autotable.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        window.BASE_URL = "<?= base_url() ?>";
    </script>
    <script src="<?= base_url('js/admin/admin_drawer.js') ?>"></script>
    <script src="<?= base_url('js/admin/admin_announcements.js') ?>"></script>
    <script src="<?= base_url('js/admin/logout.js') ?>" defer></script>
    <script src="<?= base_url('js/utils/secureLogger.js') ?>"></script>
    <script src="<?= base_url('js/utils/sidebar.js') ?>"></script>
</body>

</html>