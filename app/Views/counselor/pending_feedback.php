<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pending Feedback - Counselign</title>
    <link rel="icon" href="<?= base_url('Photos/counselign.ico') ?>" sizes="16x16 32x32"
        type="image/x-icon">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<?= base_url('css/counselor/appointments.css') ?>">
    <link rel="stylesheet" href="<?= base_url('css/counselor/header.css') ?>">
    <link rel="stylesheet" href="<?= base_url('css/utils/sidebar.css') ?>">
    <style>
        #appointmentsTableBody td {
            color: black !important;
        }
        #appointmentsTableContainer thead {
            background-color: #2c5282 !important;
        }
        #appointmentsTableContainer thead th {
            color: white !important;
            background-color: #2c5282 !important;
            white-space: nowrap;
        }
    </style>
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
                <a href="<?= base_url('counselor/dashboard') ?>" class="sidebar-link" title="Dashboard">
                    <i class="fas fa-home"></i>
                    <span class="sidebar-text">Dashboard</span>
                </a>

                <a href="<?= base_url('counselor/appointments/scheduled') ?>" class="sidebar-link" title="Scheduled Appointments">
                    <i class="fas fa-calendar-alt"></i>
                    <span class="sidebar-text">Scheduled Appointments</span>
                </a>
                <a href="<?= base_url('counselor/pending-feedback') ?>" class="sidebar-link active" title="Pending Feedback">
                    <i class="fas fa-star"></i>
                    <span class="sidebar-text">Pending Feedback</span>
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

    <div class="main-wrapper" id="mainWrapper">
        <!-- Top Bar -->
        <header class="top-bar">
            <div class="top-bar-left">
                <h1 class="page-title-header">
                    <i class="fas fa-star me-2"></i>
                    Pending Feedback
                </h1>
            </div>

            <div class="top-bar-right">
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
                <div class="appointment-container">
                    <div class="row mb-4">
                        <div class="col-12">
                            <h2 class="text-center fw-bold" style="color: #0d6efd;">Appointments Pending Student Feedback</h2>
                            <p class="text-center text-muted">These appointments have been completed and are waiting for student feedback</p>
                        </div>
                    </div>

                    <!-- Loading Indicator -->
                    <div id="loadingIndicator" class="text-center py-5">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                        <p class="mt-2">Loading pending feedback appointments...</p>
                    </div>

                    <!-- Appointments Table -->
                    <div id="appointmentsTableContainer" class="d-none">
                        <div class="table-responsive">
                            <table class="table table-hover table-bordered" style="color: #2c5282;">
                                <thead class="table-dark">
                                    <tr>
                                        <th>Student Name</th>
                                        <th>Date</th>
                                        <th>Time</th>
                                        <th>Purpose</th>
                                        <th>Session Type</th>
                                        <th>Status</th>
                                        <th>Counselor Remarks</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody id="appointmentsTableBody">
                                </tbody>
                            </table>
                        </div>

                        <!-- Empty State -->
                        <div id="emptyState" class="text-center py-5 d-none">
                            <i class="fas fa-inbox fa-4x text-muted mb-3"></i>
                            <h4 class="text-muted">No Pending Feedback Appointments</h4>
                            <p class="text-muted">All completed appointments have received student feedback.</p>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- View Remarks Modal -->
    <div class="modal fade" id="viewRemarksModal" tabindex="-1" aria-labelledby="viewRemarksModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content" style="border-radius: 12px; border: none; box-shadow: 0 10px 40px rgba(0,0,0,0.15);">
                <div class="modal-header" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 12px 12px 0 0; border: none;">
                    <h5 class="modal-title" id="viewRemarksModalLabel" style="font-weight: 600;">
                        <i class="fas fa-comment-dots me-2"></i>Counselor Remarks
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" style="padding: 2rem;">
                    <div class="mb-4">
                        <label class="form-label fw-bold" style="color: #667eea; font-size: 0.9rem; text-transform: uppercase; letter-spacing: 0.5px;">Student</label>
                        <p id="modalStudentName" class="form-control-plaintext" style="font-size: 1.1rem; color: #333; font-weight: 500;"></p>
                    </div>
                    <div class="mb-4">
                        <label class="form-label fw-bold" style="color: #667eea; font-size: 0.9rem; text-transform: uppercase; letter-spacing: 0.5px;">Appointment Date & Time</label>
                        <p id="modalDate" class="form-control-plaintext" style="font-size: 1.1rem; color: #333; font-weight: 500;"></p>
                    </div>
                    <div class="mb-4">
                        <label class="form-label fw-bold" style="color: #667eea; font-size: 0.9rem; text-transform: uppercase; letter-spacing: 0.5px;">Remarks</label>
                        <div id="modalRemarks" class="form-control-plaintext bg-light p-4 rounded" style="font-size: 1rem; color: #555; line-height: 1.6; background-color: #f8f9fa; border-left: 4px solid #667eea;"></div>
                    </div>
                </div>
                <div class="modal-footer" style="border-top: 1px solid #e9ecef; padding: 1.5rem;">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" style="padding: 0.6rem 1.5rem; border-radius: 8px; font-weight: 500;">Close</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Email Sent Success Modal -->
    <div class="modal fade" id="emailSentModal" tabindex="-1" aria-labelledby="emailSentModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content" style="border-radius: 12px; border: none; box-shadow: 0 10px 40px rgba(0,0,0,0.15);">
                <div class="modal-header" style="background: #2c5282; border-radius: 12px 12px 0 0; border: none;">
                    <h5 class="modal-title" id="emailSentModalLabel" style="font-weight: 600; color: black;">
                        <i class="fas fa-check-circle me-2"></i>Email Sent Successfully
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body text-center" style="padding: 3rem 2rem;">
                    <div class="mb-4">
                        <div style="width: 80px; height: 80px; background: #2c5282; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; margin-bottom: 1rem;">
                            <i class="fas fa-envelope-circle-check fa-3x text-white"></i>
                        </div>
                    </div>
                    <h4 style="color: #333; font-weight: 600; margin-bottom: 1rem;">Successfully sent the message via email</h4>
                    <p class="text-muted" style="font-size: 1rem; line-height: 1.6;">The reminder email has been sent to the student. They will receive a notification with a link to complete their feedback.</p>
                </div>
                <div class="modal-footer justify-content-center" style="border-top: 1px solid #e9ecef; padding: 1.5rem;">
                    <button type="button" class="btn" data-bs-dismiss="modal" style="padding: 0.6rem 2rem; border-radius: 8px; font-weight: 500; background: #2c5282; color: white; border: none;">OK</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        window.BASE_URL = "<?= base_url() ?>";
    </script>
    <script src="<?= base_url('js/utils/timeFormatter.js') ?>"></script>
    <script src="<?= base_url('js/counselor/pending_feedback.js') ?>"></script>
    <script src="<?= base_url('js/counselor/logout.js') ?>"></script>
    <script src="<?= base_url('js/utils/sidebar.js') ?>"></script>
</body>

</html>
