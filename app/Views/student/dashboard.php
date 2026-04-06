<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="University Guidance Counseling Services - Your safe space for support and guidance" />
    <meta name="keywords" content="counseling, guidance, university, support, mental health, student wellness" />
    <title>Counselign</title>
    <link rel="icon" href="<?= base_url('Photos/counselign.ico') ?>" sizes="16x16 32x32" type="image/x-icon">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="<?= base_url('css/student/student_dashboard.css') ?>">
    <link rel="stylesheet" href="<?= base_url('css/student/header.css') ?>">
    <link rel="stylesheet" href="<?= base_url('css/utils/resources.css') ?>">
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
                <a href="<?= base_url('student/dashboard') ?>" class="sidebar-link active" title="Dashboard">
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
        <!-- Interactive Profile Picture Section -->

        <!-- Top Bar -->
        <header class="top-bar">
            <div class="top-bar-left">
                <h1 class="page-title-header">
                    <i class="fas fa-user me-2"></i>
                    Student Dashboard
                </h1>
            </div>

            <div class="top-bar-right">

                <div class="message-icon-container">
                    <button class="top-bar-btn" onclick="window.location.href='<?= base_url('student/messages') ?>'" title="Messages">

                        <i class="fas fa-comments text-2xl" style="cursor: pointer;"></i>
                        <span id="messageBadge" class="message-badge hidden"></span>

                    </button>
                </div>
                <div class="relative notification-icon-container">
                    <button class="top-bar-btn" id="notificationIcon" title="Notifications">
                        <i class="fas fa-bell text-2xl" style="cursor: pointer;"></i>
                        <span id="notificationBadge" class="notification-badge">0</span>
                    </button>
                </div>

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

        <div class="dashboard-enhanced-content">
            <!-- Events Carousel -->
            <section class="carousel-section" id="eventsCarouselSection">
                <div class="carousel-header">
                    <h4 class="carousel-title">Upcoming Events</h4>
                    <a href="<?= base_url('student/announcements') ?>" class="view-all">View All →</a>
                </div>

                <div class="carousel-wrapper">
                    <div class="carousel-track" id="eventsCarouselTrack">
                        <!-- Slides rendered via JS -->
                    </div>
                </div>

                <div class="carousel-controls" id="eventsCarouselControls">
                    <button class="carousel-btn" id="eventsCarouselPrev" type="button" aria-label="Previous event">‹</button>
                    <div class="carousel-dots" id="eventsCarouselDots"></div>
                    <button class="carousel-btn" id="eventsCarouselNext" type="button" aria-label="Next event">›</button>
                </div>

                <div class="carousel-empty-state" id="eventsCarouselEmpty" hidden>
                    <i class="fas fa-calendar-times"></i>
                    <p>No upcoming events available right now.</p>
                </div>
            </section>

            <!-- Welcome Section with Quotes -->
            <section class="welcome-section" id="quotesSection">
                <h3 class=" welcome-title text-2xl font-extrabold mb-4">Welcome to Your Safe Space</h3>

                <div class="main-message">
                    <span class="quote-marks open">"</span>
                    <p>
                        At our University Guidance Counseling, we understand that opening up can be challenging. However, we
                        want to assure you that you are not alone. We are here to listen and support you without judgment.
                    </p>
                    <span class="quote-marks close">"</span>
                </div>

                <div class="quotes-container" id="quoteCards">
                    <div class="quote-card" data-quote-group="0">
                        <div class="quote-icon" aria-hidden="true">🌱</div>
                        <p class="quote-text">Loading inspirational messages...</p>
                        <p class="quote-author"></p>
                    </div>

                    <div class="quote-card" data-quote-group="1">
                        <div class="quote-icon" aria-hidden="true">💪</div>
                        <p class="quote-text">Please wait while we prepare something uplifting.</p>
                        <p class="quote-author"></p>
                    </div>

                    <div class="quote-card" data-quote-group="2">
                        <div class="quote-icon" aria-hidden="true">🌟</div>
                        <p class="quote-text">Your safe space quotes are on the way.</p>
                        <p class="quote-author"></p>
                    </div>
                </div>

                <div class="wave-decoration" aria-hidden="false"></div>
            </section>

            <!-- Resources Accordion Section -->
            <section class="resources-section mt-5 mb-4">
                <div class="container-fluid px-0">
                    <div class="accordion" id="resourcesParentAccordion">
                        <div class="accordion-item">
                            <h2 class="accordion-header" id="resourcesParentHeading">
                                <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#resourcesParentCollapse" aria-expanded="true" aria-controls="resourcesParentCollapse">
                                    <i class="fas fa-folder-open me-2"></i>
                                    <span class="fw-bold">Resources</span>
                                </button>
                            </h2>
                            <div id="resourcesParentCollapse" class="accordion-collapse collapse show" aria-labelledby="resourcesParentHeading" data-bs-parent="#resourcesParentAccordion">
                                <div class="accordion-body">
                                    <div class="accordion" id="resourcesAccordion">
                                        <div id="resourcesAccordionContent">
                                            <div class="text-center py-4">
                                                <div class="spinner-border text-primary" role="status">
                                                    <span class="visually-hidden">Loading resources...</span>
                                                </div>
                                                <p class="mt-2 text-muted">Loading resources...</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </div>

        <!-- Notifications Dropdown -->
        <div id="notificationsDropdown" class="absolute bg-white rounded-lg shadow-lg border">
            <div class="p-3 border-b border-gray-200 flex justify-between items-center">
                <h3 class="text-lg font-bold text-blue-800">Notifications</h3>
                <button id="markAllReadBtn" class="btn btn-sm btn-outline-primary" title="Mark all as read">
                    <i class="fas fa-check-double"></i> Clear All
                </button>
            </div>
            <div class="notifications-list max-h-64 overflow-y-auto">
                <!-- Notifications will be dynamically populated here -->
            </div>
        </div>


    </div>



    <!-- Appointment Details Modal -->
    <div class="modal fade" id="appointmentDetailsModal" tabindex="-1" aria-labelledby="appointmentDetailsLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="appointmentDetailsLabel">Appointment Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" id="appointmentDetailsBody">
                    <!-- Appointment details will be injected here -->
                </div>
                <div class="d-flex justify-content-end mt-3 gap-2 p-3" style="position: relative; z-index: 10;">
                    <a href="<?= base_url('student/my-appointments') ?>" class="btn btn-primary" style="pointer-events: auto;">
                        <i class="fas fa-clipboard-list me-1"></i> Manage
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- PDS Reminder Popup Modal -->
    <div id="pdsReminderModal" class="modal fade" tabindex="-1" aria-labelledby="pdsReminderLabel" aria-hidden="true" data-bs-backdrop="false" data-bs-keyboard="false">
        <div class="modal-dialog pds-reminder-dialog">
            <div class="modal-content pds-reminder-modal">
                <div class="modal-header pds-reminder-header">
                    <h5 class="modal-title" id="pdsReminderLabel">
                        <i class="fas fa-clipboard-list me-2"></i>
                        PDS Reminder
                    </h5>
                    <button type="button" class="btn-close btn-close-white" id="closePdsReminder" aria-label="Close"></button>
                </div>
                <div class="modal-body pds-reminder-body">
                    <div class="pds-reminder-content">
                        <div class="pds-reminder-icon">
                            <i class="fas fa-user-edit"></i>
                        </div>
                        <div class="pds-reminder-text">
                            <h6 class="pds-reminder-title">Update Your PDS!</h6>
                            <p class="pds-reminder-message">
                                Keep your Personal Data Sheet updated for timely counseling services.
                            </p>
                        </div>
                    </div>
                    <div class="pds-reminder-timer">
                        <div class="timer-bar">
                            <div class="timer-progress" id="timerProgress"></div>
                        </div>
                        <span class="timer-text">Auto-close in <span id="timerCountdown">20</span>s</span>
                    </div>
                </div>
                <div class="modal-footer pds-reminder-footer">
                    <a href="<?= base_url('student/profile') ?>" class="btn btn-primary pds-reminder-btn">
                        <i class="fas fa-user-edit me-1"></i>
                        Update Now
                    </a>
                    <button type="button" class="btn btn-secondary pds-reminder-btn" id="dismissPdsReminder">
                        <i class="fas fa-times me-1"></i>
                        Dismiss
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Preview Modal -->
    <div class="modal fade" id="previewModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-xl">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="previewModalTitle">Resource Preview</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" id="previewModalBody" style="min-height: 400px;">
                    <!-- Preview content will be loaded here -->
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/mammoth/1.6.0/mammoth.browser.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>

    <!-- ADDED: Shared Resource Preview Module -->
    <script src="<?= base_url('js/utils/resource-preview.js') ?>"></script>

    <?php echo view('modals/student_dashboard_modals'); ?>
    <script src="<?= base_url('js/modals/student_dashboard_modals.js') ?>"></script>
    <script src="<?= base_url('js/student/student_dashboard.js') ?>"></script>
    <script src="<?= base_url('js/student/logout.js') ?>"></script>
    <script src="<?= base_url('js/utils/sidebar.js') ?>"></script>
    <script src="<?= base_url('js/utils/secureLogger.js') ?>"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        window.BASE_URL = "<?= base_url() ?>";
    </script>
</body>

</html>