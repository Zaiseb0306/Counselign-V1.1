<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="University Guidance Counseling Services - Counselor Profile Page" />
    <meta name="keywords"
        content="counseling, guidance, university, support, mental health, counselor wellness, profile" />
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>Counselor Profile - Counselign</title>
    <link rel="icon" href="<?= base_url('Photos/counselign.ico') ?>" sizes="16x16 32x32" type="image/x-icon">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="<?= base_url('css/counselor/counselor_profile.css') ?>" rel="stylesheet" />
    <link rel="stylesheet" href="<?= base_url('css/counselor/header.css') ?>">
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
                <a href="<?= base_url('counselor/dashboard') ?>" class="sidebar-link active" title="Dashboard">
                    <i class="fas fa-home"></i>
                    <span class="sidebar-text">Dashboard</span>
                </a>

                <a href="<?= base_url('counselor/appointments/scheduled') ?>" class="sidebar-link" title="Scheduled Appointments">
                    <i class="fas fa-calendar-alt"></i>
                    <span class="sidebar-text">Scheduled Appointments</span>
                </a>
                <a href="<?= base_url('counselor/pending-feedback') ?>" class="sidebar-link" title="Pending Feedback">
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
        <!-- Interactive Profile Picture Section -->

        <!-- Top Bar -->
        <header class="top-bar">
            <div class="top-bar-left">
                <h1 class="page-title-header">
                    <i class="fas fa-user-cog me-2"></i>
                    Profile
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

        <main>
            <!-- Account ID displayed at the top -->
            <div class="container-fluid">
                <div class="row gy-4 align-items-start">
                    <div class="col-12 col-lg-5">
                        <div class="profile-container">
                            <div class="profile-header">
                                <div class="profile-avatar">
                                    <img id="profile-img" src="<?= base_url('Photos/profile.png') ?>" alt="Counselor Avatar" />
                                </div>
                            </div>

                            <div class="profile-details">
                                <!-- Enhanced form with title and better styling -->
                                <div class="profile-form">
                                    <div class="form-title">Account Settings</div>

                                    <div class="user-name">Account ID: <span class="user-id" id="display-userid"></span></div>

                                    <div class="form-group">
                                        <label class="form-label">Username:</label>
                                        <input type="text" class="form-input" id="display-username" readonly>
                                    </div>

                                    <div class="form-group">
                                        <label class="form-label">Email:</label>
                                        <input type="email" class="form-input" id="display-email" readonly>
                                    </div>

                                    <!-- Enhanced button group -->
                                    <div class="btn-group">
                                        <button class="btn btn-password" data-bs-toggle="modal" data-bs-target="#changePasswordModal">
                                            <i class="fas fa-key"></i> Change Password
                                        </button>
                                        <button class="btn btn-update" data-bs-toggle="modal" data-bs-target="#updateProfileModal">
                                            <i class="fas fa-edit"></i> Update Profile
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Personal Information Section -->
                    <div class="col-12 col-lg-7">
                        <div class="profile-container">
                            <div class="profile-details scroll-inner">
                                <div class="profile-form">
                                    <div class="form-title">Personal Information</div>

                                    <div class="container-fluid p-0">
                                        <div class="row g-3">
                                            <div class="col-12 col-lg-6">
                                                <label class="form-label">Full name</label>
                                                <input type="text" class="form-control" id="pi-fullname" readonly>
                                            </div>
                                            <div class="col-12 col-lg-4">
                                                <label class="form-label">Date of Birth</label>
                                                <input type="date" class="form-control" id="pi-birthdate" readonly>
                                            </div>

                                            <div class="col-12 col-lg-2">
                                                <label class="form-label">Sex</label>
                                                <input type="text" class="form-control" id="pi-sex" readonly>
                                            </div>

                                            <div class="col-12 col-lg-7">
                                                <label class="form-label">Degree</label>
                                                <input type="text" class="form-control" id="pi-degree" readonly>
                                            </div>


                                            <div class="col-12 col-lg-2">
                                                <label class="form-label">Civil Status</label>
                                                <input type="text" class="form-control" id="pi-civil" readonly>
                                            </div>

                                            <div class="col-12 col-lg-3">
                                                <label class="form-label">Contact Number</label>
                                                <input type="text" class="form-control" id="pi-contact" readonly>
                                            </div>

                                            <div class="col-12 col-lg-7">
                                                <label class="form-label">Email</label>
                                                <input type="text" class="form-control" id="pi-email" readonly>
                                            </div>


                                            <div class="col-12">
                                                <label class="form-label">Address</label>
                                                <input type="text" class="form-control" id="pi-address" readonly>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="mt-3">
                                        <button class="btn btn-update" data-bs-toggle="modal" data-bs-target="#updatePersonalInfoModal">
                                            <i class="fas fa-edit"></i> Edit Personal Info
                                        </button>
                                    </div>

                                    <hr class="my-4" />
                                    <div class="form-title">Availability</div>
                                    <div class="container-fluid p-0">
                                        <div id="availability-edit-fields" style="display:none;">
                                            <div class="mb-3">
                                                <label class="form-label">Available Days</label>
                                                <div class="d-flex flex-wrap gap-3" id="availability-days">
                                                    <div class="form-check">
                                                        <input class="form-check-input" type="checkbox" value="Monday" id="day-Monday">
                                                        <label class="form-check-label" for="day-Monday">Monday</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <input class="form-check-input" type="checkbox" value="Tuesday" id="day-Tuesday">
                                                        <label class="form-check-label" for="day-Tuesday">Tuesday</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <input class="form-check-input" type="checkbox" value="Wednesday" id="day-Wednesday">
                                                        <label class="form-check-label" for="day-Wednesday">Wednesday</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <input class="form-check-input" type="checkbox" value="Thursday" id="day-Thursday">
                                                        <label class="form-check-label" for="day-Thursday">Thursday</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <input class="form-check-input" type="checkbox" value="Friday" id="day-Friday">
                                                        <label class="form-check-label" for="day-Friday">Friday</label>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Available Times (per selected day)</label>
                                                <div class="row g-2 align-items-end" id="availability-times">
                                                    <div class="col-12 col-md-5">
                                                        <label class="form-label">From</label>
                                                        <select class="form-select" id="time-from"></select>
                                                    </div>
                                                    <div class="col-12 col-md-5">
                                                        <label class="form-label">To</label>
                                                        <select class="form-select" id="time-to"></select>
                                                    </div>
                                                    <div class="col-12 col-md-2 d-grid">
                                                        <button type="button" class="btn btn-update" id="add-time-slot" style="display:none;">Add</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- Always-visible display of availability chips (day and time) -->
                                        <div class="col-12 mt-2">
                                            <div id="time-slots-list" class="border rounded p-2" style="min-height:40px;"></div>
                                        </div>
                                        <div class="d-flex gap-2 availability-actions">
                                            <button type="button" class="btn btn-password" id="edit-availability"><i class="fas fa-edit"></i> Edit Availability</button>
                                            <button type="button" class="btn btn-password" id="save-availability" style="display:none;"><i class="fas fa-save"></i> Save Availability</button>
                                            <button type="button" class="btn btn-cancel" id="cancel-availability" style="display:none;"><i class="fas fa-times"></i> Cancel</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Update Profile Modal -->
    <div class="modal fade" id="updateProfileModal" tabindex="-1" aria-labelledby="updateProfileModalLabel"
        aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="updateProfileModalLabel">Update Profile Information</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="updateProfileForm">
                        <div class="mb-3">
                            <label for="update-username" class="form-label">Username</label>
                            <input type="text" class="form-control" id="update-username">
                        </div>
                        <div class="mb-3">
                            <label for="update-email" class="form-label">Email</label>
                            <input type="email" class="form-control" id="update-email">
                        </div>
                        <div class="mb-3">
                            <label for="update-picture" class="form-label">Profile Picture</label>
                            <input type="file" class="form-control" id="update-picture" accept="image/*">
                            <div class="mt-2 text-center">
                                <img id="update-picture-preview" src="<?= base_url('Photos/profile.png') ?>" alt="Preview" style="max-width:120px; max-height:120px; border-radius:50%; object-fit:cover; display:none;" />
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" onclick="saveProfileChanges()">Save Changes</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Change Password Modal -->
    <div class="modal fade" id="changePasswordModal" tabindex="-1" aria-labelledby="changePasswordModalLabel"
        aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="changePasswordModalLabel">
                        Change Password
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="changePasswordForm">
                        <div class="password-field mb-4">
                            <label for="current-password" class="form-label">Current Password</label>
                            <div class="password-input-group">
                                <input type="password" class="form-control" id="current-password" required>
                                <i class="fas fa-eye toggle-password" onclick="togglePassword('current-password')"></i>
                            </div>
                        </div>
                        <div class="password-field mb-4">
                            <label for="new-password" class="form-label">New Password</label>
                            <div class="password-input-group">
                                <input type="password" class="form-control" id="new-password" required>
                                <i class="fas fa-eye toggle-password" onclick="togglePassword('new-password')"></i>
                            </div>
                        </div>
                        <div class="password-field mb-4">
                            <label for="confirm-password" class="form-label">Confirm New Password</label>
                            <div class="password-input-group">
                                <input type="password" class="form-control" id="confirm-password" required>
                                <i class="fas fa-eye toggle-password" onclick="togglePassword('confirm-password')"></i>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" onclick="changePassword()">Save Changes</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Update Personal Info Modal -->
    <div class="modal fade" id="updatePersonalInfoModal" tabindex="-1" aria-labelledby="updatePersonalInfoLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="updatePersonalInfoLabel">Update Personal Information</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="updatePersonalInfoForm">
                        <div class="row g-2 mb-3">
                            <div class="col-12 col-md-5">
                                <label for="upi-firstname" class="form-label">First Name</label>
                                <input type="text" class="form-control" id="upi-firstname" placeholder="First name">
                            </div>
                            <div class="col-12 col-md-5">
                                <label for="upi-lastname" class="form-label">Last Name</label>
                                <input type="text" class="form-control" id="upi-lastname" placeholder="Last name">
                            </div>
                            <div class="col-12 col-md-2">
                                <label for="upi-mi" class="form-label">M.I. <small class="text-muted">(opt.)</small></label>
                                <input type="text" class="form-control" id="upi-mi" placeholder="M.I." maxlength="3">
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="upi-birthdate" class="form-label">Birthdate</label>
                            <input type="date" class="form-control" id="upi-birthdate">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Address</label>
                            <select id="upi-region" class="form-select mb-1">
                                <option value="">Select Region</option>
                            </select>
                            <select id="upi-province" class="form-select mb-1" disabled>
                                <option value="">Select Province</option>
                            </select>
                            <select id="upi-city" class="form-select mb-1" disabled>
                                <option value="">Select City/Municipality</option>
                            </select>
                            <select id="upi-barangay" class="form-select mb-1" disabled>
                                <option value="">Select Barangay</option>
                            </select>
                            <input type="text" id="upi-street" class="form-control" placeholder="Street name, building, floor/unit no. (optional)">
                            <input type="hidden" id="upi-address">
                        </div>
                        <div class="mb-3">
                            <label for="upi-degree" class="form-label">Degree</label>
                            <input type="text" class="form-control" id="upi-degree">
                        </div>
                        <div class="row g-3">
                            <div class="col-12 col-md-6">
                                <label for="upi-sex" class="form-label">Sex</label>
                                <select class="form-select" id="upi-sex">
                                    <option value="">Select sex</option>
                                    <option value="Male">Male</option>
                                    <option value="Female">Female</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>
                            <div class="col-12 col-md-6">
                                <label for="upi-civil" class="form-label">Civil Status</label>
                                <select class="form-select" id="upi-civil">
                                    <option value="">Select status</option>
                                    <option value="Single">Single</option>
                                    <option value="Married">Married</option>
                                    <option value="Widowed">Widowed</option>
                                    <option value="Separated">Separated</option>
                                </select>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="upi-email" class="form-label">Email</label>
                            <input type="email" class="form-control" id="upi-email" readonly>
                        </div>
                        <div class="mb-3">
                            <label for="upi-contact" class="form-label">Contact Number</label>
                            <input type="text" class="form-control" id="upi-contact">
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" onclick="savePersonalInfoChanges()">Save</button>
                </div>
            </div>
        </div>
    </div>

    <?php echo view('modals/student_dashboard_modals'); ?>
    <script src="<?= base_url('js/modals/student_dashboard_modals.js') ?>"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        window.BASE_URL = "<?= base_url() ?>";
    </script>
    <script src="<?= base_url('js/utils/psgc_address.js') ?>"></script>
    <script src="<?= base_url('js/utils/timeFormatter.js') ?>"></script>
    <script src="<?= base_url('js/counselor/logout.js') ?>"></script>
    <script src="<?= base_url('js/utils/sidebar.js') ?>"></script>
    <script src="<?= base_url('js/counselor/counselor_profile.js') ?>"></script>
    <script src="<?= base_url('js/counselor/counselor_drawer.js') ?>"></script>
    <script src="<?= base_url('js/utils/secureLogger.js') ?>"></script>
</body>

</html>