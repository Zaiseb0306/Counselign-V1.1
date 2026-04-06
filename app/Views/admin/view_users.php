<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="Counselign - User Management" />
    <meta name="keywords" content="counseling, guidance, university, support, users" />
    <title>User Management - Counselign</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="icon" href="<?= base_url('Photos/counselign.ico') ?>" sizes="16x16 32x32" type="image/x-icon">
    <link rel="stylesheet" href="<?= base_url('css/admin/view_users.css') . '?v=' . @filemtime(FCPATH . 'css/admin/view_users.css') ?>">
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



    <!-- Main Content -->
    <div class="main-wrapper" id="mainWrapper">

        <!-- Top Bar -->
        <header class="top-bar">
            <div class="top-bar-left">
                <!-- Page Title Added Here -->
                <h1 class="page-title-header">
                    <i class="fas fa-users me-2"></i>
                    Student User Accounts
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

        <div class="container py-5">
            <div class="users-header">
                <div class="user-stats">
                    <div class="stat-card">
                        <i class="fas fa-users"></i>
                        <div class="stat-info">
                            <h3>Total</h3>
                            <p id="totalUsers">0</p>
                        </div>
                    </div>
                    <div class="stat-card">
                        <i class="fas fa-user-check"></i>
                        <div class="stat-info">
                            <h3>Active</h3>
                            <p id="activeUsers">0</p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="search-filter-container">
                <div class="search-box">
                    <input type="text" id="searchInput" placeholder="Search student users...">
                    <i class="fas fa-search"></i>
                </div>
                <div class="filter-box">
                    <select id="statusFilter">
                        <option value="all">All Status</option>
                        <option value="active">Active</option>
                        <option value="inactive">Inactive</option>
                    </select>
                </div>
            </div>

            <div class="table-container">
                <table class="users-table">
                    <thead>
                        <tr>
                            <th>Action</th>
                            <th>User ID</th>
                            <th>Full Name</th>
                            <th>Username</th>
                            <th>Email</th>
                            <th>Course and Year</th>
                            <th>Created At</th>
                            <th>Active Status</th>
                        </tr>
                    </thead>
                    <tbody id="usersTableBody">
                        <!-- User data will be populated here -->
                    </tbody>
                </table>
            </div>

            <div id="noUsersFound" class="no-users-message" style="display: none;">
                <i class="fas fa-user-slash"></i>
                <p>No student users found</p>
            </div>
        </div>
    </div>

    <!-- Student PDS Modal -->
    <div class="modal fade" id="studentPDSModal" tabindex="-1" aria-labelledby="studentPDSModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-xl modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="studentPDSModalLabel">
                        <i class="fas fa-user-graduate me-2"></i>Student Personal Data Sheet
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-0">
                    <!-- Loading State -->
                    <div id="pdsLoadingState" class="text-center py-5">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                        <p class="mt-3 text-muted">Loading student data...</p>
                    </div>

                    <!-- Error State -->
                    <div id="pdsErrorState" class="text-center py-5" style="display: none;">
                        <i class="fas fa-exclamation-triangle fa-3x text-warning mb-3"></i>
                        <h5 class="text-danger">Error Loading Data</h5>
                        <p class="text-muted" id="pdsErrorMessage">Failed to load student PDS data</p>
                        <button type="button" class="btn btn-primary" onclick="retryLoadPDS()">
                            <i class="fas fa-redo me-2"></i>Retry
                        </button>
                    </div>

                    <!-- PDS Content -->
                    <div id="pdsContent" style="display: none;">
                        <!-- Student Header -->
                        <div class="pds-header bg-light border-bottom p-4">
                            <div class="row align-items-center">
                                <div class="col-auto">
                                    <div class="pds-profile-picture">
                                        <img id="pdsProfilePicture" src="<?= base_url('Photos/profile.png') ?>" 
                                             alt="Student Profile" class="rounded-circle border border-3 border-primary" 
                                             style="width: 80px; height: 80px; object-fit: cover;">
                                    </div>
                                </div>
                                <div class="col">
                                    <h4 class="mb-1" id="pdsStudentName">Student Name</h4>
                                    <p class="text-muted mb-1">
                                        <i class="fas fa-id-card me-2"></i>
                                        <span id="pdsStudentId">Student ID</span>
                                    </p>
                                    <p class="text-muted mb-0">
                                        <i class="fas fa-envelope me-2"></i>
                                        <span id="pdsStudentEmail">Email Address</span>
                                    </p>
                                </div>
                            </div>
                        </div>

                        <!-- PDS Tabs -->
                        <div class="pds-tabs-container">
                            <ul class="nav nav-tabs nav-fill" id="pdsTabs" role="tablist">
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link active" id="personal-bg-tab" data-bs-toggle="tab" 
                                            data-bs-target="#pds-personal-bg" type="button" role="tab">
                                        <i class="fas fa-user me-2"></i>Personal Background
                                    </button>
                                </li>
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link" id="family-bg-tab" data-bs-toggle="tab" 
                                            data-bs-target="#pds-family-bg" type="button" role="tab">
                                        <i class="fas fa-users me-2"></i>Family Background
                                    </button>
                                </li>
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link" id="other-info-tab" data-bs-toggle="tab" 
                                            data-bs-target="#pds-other-info" type="button" role="tab">
                                        <i class="fas fa-info-circle me-2"></i>Other Information
                                    </button>
                                </li>
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link" id="awards-tab" data-bs-toggle="tab" 
                                            data-bs-target="#pds-awards" type="button" role="tab">
                                        <i class="fas fa-trophy me-2"></i>Awards
                                    </button>
                                </li>
                            </ul>

                            <div class="tab-content p-4" id="pdsTabContent">
                                <!-- Personal Background Tab -->
                                <div class="tab-pane fade show active" id="pds-personal-bg" role="tabpanel">
                                    <!-- Academic Information -->
                                    <div class="mb-4">
                                        <h6 class="text-primary border-bottom pb-2 mb-3">
                                            <i class="fas fa-graduation-cap me-2"></i>Academic Information
                                        </h6>
                                        <div class="row g-3">
                                            <div class="col-md-3">
                                                <div class="info-item">
                                                    <label class="info-label">Course</label>
                                                    <div class="info-value" id="pdsCourse">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="info-item">
                                                    <label class="info-label">Major or Strand</label>
                                                    <div class="info-value" id="pdsMajorOrStrand">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="info-item">
                                                    <label class="info-label">Year Level</label>
                                                    <div class="info-value" id="pdsYearLevel">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="info-item">
                                                    <label class="info-label">Academic Status</label>
                                                    <div class="info-value" id="pdsAcademicStatus">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">School Last Attended</label>
                                                    <div class="info-value" id="pdsSchoolLastAttended">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">Location of School</label>
                                                    <div class="info-value" id="pdsLocationOfSchool">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">Previous Course/Grade</label>
                                                    <div class="info-value" id="pdsPreviousCourseGrade">Not specified</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Personal Information -->
                                    <div class="mb-4">
                                        <h6 class="text-primary border-bottom pb-2 mb-3">
                                            <i class="fas fa-id-card me-2"></i>Personal Information
                                        </h6>
                                        <div class="row g-3">
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">Last Name</label>
                                                    <div class="info-value" id="pdsLastName">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">First Name</label>
                                                    <div class="info-value" id="pdsFirstName">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">Middle Name</label>
                                                    <div class="info-value" id="pdsMiddleName">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="info-item">
                                                    <label class="info-label">Sex</label>
                                                    <div class="info-value" id="pdsSex">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="info-item">
                                                    <label class="info-label">Date of Birth</label>
                                                    <div class="info-value" id="pdsDateOfBirth">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-2">
                                                <div class="info-item">
                                                    <label class="info-label">Age</label>
                                                    <div class="info-value" id="pdsAge">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">Place of Birth</label>
                                                    <div class="info-value" id="pdsPlaceOfBirth">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">Civil Status</label>
                                                    <div class="info-value" id="pdsCivilStatus">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">Religion</label>
                                                    <div class="info-value" id="pdsReligion">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">Contact Number</label>
                                                    <div class="info-value" id="pdsContactNumber">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">Email Address</label>
                                                    <div class="info-value" id="pdsPersonalEmail">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">Facebook Account</label>
                                                    <div class="info-value" id="pdsFbAccount">Not specified</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Address Information -->
                                    <div class="mb-4">
                                        <h6 class="text-primary border-bottom pb-2 mb-3">
                                            <i class="fas fa-map-marker-alt me-2"></i>Permanent Home Address
                                        </h6>
                                        <div class="row g-3">
                                            <div class="col-md-3">
                                                <div class="info-item">
                                                    <label class="info-label">Zone</label>
                                                    <div class="info-value" id="pdsPermanentZone">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="info-item">
                                                    <label class="info-label">Barangay</label>
                                                    <div class="info-value" id="pdsPermanentBarangay">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="info-item">
                                                    <label class="info-label">City</label>
                                                    <div class="info-value" id="pdsPermanentCity">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="info-item">
                                                    <label class="info-label">Province</label>
                                                    <div class="info-value" id="pdsPermanentProvince">Not specified</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="mb-4">
                                        <h6 class="text-primary border-bottom pb-2 mb-3">
                                            <i class="fas fa-home me-2"></i>Present Address
                                        </h6>
                                        <div class="row g-3">
                                            <div class="col-md-3">
                                                <div class="info-item">
                                                    <label class="info-label">Zone</label>
                                                    <div class="info-value" id="pdsPresentZone">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="info-item">
                                                    <label class="info-label">Barangay</label>
                                                    <div class="info-value" id="pdsPresentBarangay">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="info-item">
                                                    <label class="info-label">City</label>
                                                    <div class="info-value" id="pdsPresentCity">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="info-item">
                                                    <label class="info-label">Province</label>
                                                    <div class="info-value" id="pdsPresentProvince">Not specified</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                </div>

                                <!-- Family Background Tab -->
                                <div class="tab-pane fade" id="pds-family-bg" role="tabpanel">
                                    <!-- Father's Information -->
                                    <div class="mb-4">
                                        <h6 class="text-primary border-bottom pb-2 mb-3">
                                            <i class="fas fa-male me-2"></i>Father's Information
                                        </h6>
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <div class="info-item">
                                                    <label class="info-label">Father's Name</label>
                                                    <div class="info-value" id="pdsFatherName">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="info-item">
                                                    <label class="info-label">Father's Occupation</label>
                                                    <div class="info-value" id="pdsFatherOccupation">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">Father's Educational Attainment</label>
                                                    <div class="info-value" id="pdsFatherEducation">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">Father's Age</label>
                                                    <div class="info-value" id="pdsFatherAge">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">Father's Contact No.</label>
                                                    <div class="info-value" id="pdsFatherContact">Not specified</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Mother's Information -->
                                    <div class="mb-4">
                                        <h6 class="text-primary border-bottom pb-2 mb-3">
                                            <i class="fas fa-female me-2"></i>Mother's Information
                                        </h6>
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <div class="info-item">
                                                    <label class="info-label">Mother's Name</label>
                                                    <div class="info-value" id="pdsMotherName">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="info-item">
                                                    <label class="info-label">Mother's Occupation</label>
                                                    <div class="info-value" id="pdsMotherOccupation">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">Mother's Educational Attainment</label>
                                                    <div class="info-value" id="pdsMotherEducation">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">Mother's Age</label>
                                                    <div class="info-value" id="pdsMotherAge">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">Mother's Contact No.</label>
                                                    <div class="info-value" id="pdsMotherContact">Not specified</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Parents' Contact Information -->
                                    <div class="mb-4">
                                        <h6 class="text-primary border-bottom pb-2 mb-3">
                                            <i class="fas fa-address-book me-2"></i>Parents' Contact Information
                                        </h6>
                                        <div class="row g-3">
                                            <div class="col-md-8">
                                                <div class="info-item">
                                                    <label class="info-label">Parents' Permanent Address</label>
                                                    <div class="info-value" id="pdsParentsAddress">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">Parents' Contact No.</label>
                                                    <div class="info-value" id="pdsParentsContact">Not specified</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Spouse Information -->
                                    <div class="mb-4">
                                        <h6 class="text-primary border-bottom pb-2 mb-3">
                                            <i class="fas fa-ring me-2"></i>Spouse Information (If Married)
                                        </h6>
                                        <div class="row g-3">
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">Husband/Wife Name</label>
                                                    <div class="info-value" id="pdsSpouse">Not applicable</div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">Spouse's Occupation</label>
                                                    <div class="info-value" id="pdsSpouseOccupation">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">Spouse's Educational Attainment</label>
                                                    <div class="info-value" id="pdsSpouseEducation">Not specified</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Guardian Information -->
                                    <div class="mb-4">
                                        <h6 class="text-primary border-bottom pb-2 mb-3">
                                            <i class="fas fa-user-shield me-2"></i>Guardian Information (If Applicable)
                                        </h6>
                                        <div class="row g-3">
                                            <div class="col-md-4">
                                                <div class="info-item">
                                                    <label class="info-label">Name of Guardian</label>
                                                    <div class="info-value" id="pdsGuardianName">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-2">
                                                <div class="info-item">
                                                    <label class="info-label">Guardian's Age</label>
                                                    <div class="info-value" id="pdsGuardianAge">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="info-item">
                                                    <label class="info-label">Guardian's Occupation</label>
                                                    <div class="info-value" id="pdsGuardianOccupation">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="info-item">
                                                    <label class="info-label">Guardian's Contact No.</label>
                                                    <div class="info-value" id="pdsGuardianContact">Not specified</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Other Information Tab -->
                                <div class="tab-pane fade" id="pds-other-info" role="tabpanel">
                                    <!-- Course Choice -->
                                    <div class="mb-4">
                                        <h6 class="text-primary border-bottom pb-2 mb-3">
                                            <i class="fas fa-question-circle me-2"></i>Course Selection
                                        </h6>
                                        <div class="row g-3">
                                            <div class="col-md-12">
                                                <div class="info-item">
                                                    <label class="info-label">Why did you choose this course/program?</label>
                                                    <div class="info-value" id="pdsCourseReason">Not specified</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Family Description -->
                                    <div class="mb-4">
                                        <h6 class="text-primary border-bottom pb-2 mb-3">
                                            <i class="fas fa-home me-2"></i>Family Description
                                        </h6>
                                        <div class="row g-3">
                                            <div class="col-md-12">
                                                <div class="info-item">
                                                    <label class="info-label">Family Description</label>
                                                    <div class="info-value" id="pdsFamilyDescription">Not specified</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Living Arrangement -->
                                    <div class="mb-4">
                                        <h6 class="text-primary border-bottom pb-2 mb-3">
                                            <i class="fas fa-building me-2"></i>Living Arrangement & Condition
                                        </h6>
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <div class="info-item">
                                                    <label class="info-label">Current Residence</label>
                                                    <div class="info-value" id="pdsResidence">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="info-item">
                                                    <label class="info-label">Living Condition</label>
                                                    <div class="info-value" id="pdsLivingCondition">Not specified</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Physical/Health Condition -->
                                    <div class="mb-4">
                                        <h6 class="text-primary border-bottom pb-2 mb-3">
                                            <i class="fas fa-heartbeat me-2"></i>Physical/Health Condition
                                        </h6>
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <div class="info-item">
                                                    <label class="info-label">Physical/Health Condition</label>
                                                    <div class="info-value" id="pdsHealthCondition">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="info-item">
                                                    <label class="info-label">Psychological Treatment</label>
                                                    <div class="info-value" id="pdsPsychTreatment">Not specified</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- Special Circumstances -->
                                    <div class="mb-4">
                                        <h6 class="text-primary border-bottom pb-2 mb-3">
                                            <i class="fas fa-exclamation-triangle me-2"></i>Special Circumstances
                                        </h6>
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <div class="info-item">
                                                    <label class="info-label">Solo Parent</label>
                                                    <div class="info-value" id="pdsSoloParent">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="info-item">
                                                    <label class="info-label">Indigenous People</label>
                                                    <div class="info-value" id="pdsIndigenous">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="info-item">
                                                    <label class="info-label">Breastfeeding Mother</label>
                                                    <div class="info-value" id="pdsBreastfeeding">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="info-item">
                                                    <label class="info-label">Person with Disability</label>
                                                    <div class="info-value" id="pdsPWD">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-12" id="pwdDetailsSection" style="display: none;">
                                                <div class="info-item">
                                                    <label class="info-label">PWD Disability Type</label>
                                                    <div class="info-value" id="pdsPWDType">Not specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-12" id="pwdProofSection" style="display: none;">
                                                <div class="info-item">
                                                    <label class="info-label">PWD Proof Document</label>
                                                    <div class="pwd-proof-container" id="pdsPWDProofContainer">
                                                        <div class="pwd-proof-placeholder" id="pdsPWDProofPlaceholder">
                                                            <i class="fas fa-file-alt fa-2x text-muted mb-2"></i>
                                                            <p class="text-muted mb-0">No document uploaded</p>
                                                        </div>
                                                        <div class="pwd-proof-file" id="pdsPWDProofFile" style="display: none;">
                                                            <div class="pwd-proof-preview">
                                                                <div class="pwd-proof-icon" id="pwdProofIcon">
                                                                    <i class="fas fa-file-alt fa-3x"></i>
                                                                </div>
                                                                <div class="pwd-proof-info">
                                                                    <h6 class="pwd-proof-name mb-1" id="pwdProofFileName">Document Name</h6>
                                                                    <small class="text-muted" id="pwdProofFileType">File Type</small>
                                                                </div>
                                                            </div>
                                                            <div class="pwd-proof-actions">
                                                                <button type="button" class="btn btn-outline-primary btn-sm" id="viewPwdProofBtn">
                                                                    <i class="fas fa-eye me-1"></i>View
                                                                </button>
                                                                <a href="#" class="btn btn-outline-secondary btn-sm" id="downloadPwdProofBtn" download>
                                                                    <i class="fas fa-download me-1"></i>Download
                                                                </a>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Services Information -->
                                    <div class="mb-4">
                                        <h6 class="text-primary border-bottom pb-2 mb-3">
                                            <i class="fas fa-hands-helping me-2"></i>Services Information
                                        </h6>
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <div class="info-item">
                                                    <label class="info-label">Services Needed</label>
                                                    <div class="info-value" id="pdsServicesNeeded">None specified</div>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="info-item">
                                                    <label class="info-label">Services Availed</label>
                                                    <div class="info-value" id="pdsServicesAvailed">None specified</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- GCS Activities -->
                                    <div class="mb-4">
                                        <h6 class="text-primary border-bottom pb-2 mb-3">
                                            <i class="fas fa-chalkboard-teacher me-2"></i>GCS Seminars/Activities to Avail
                                        </h6>
                                        <div class="row g-3">
                                            <div class="col-md-12">
                                                <div class="info-item">
                                                    <label class="info-label">Selected Activities</label>
                                                    <div class="info-value" id="pdsGCSActivities">None specified</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Consent -->
                                    <div class="mb-4">
                                        <h6 class="text-primary border-bottom pb-2 mb-3">
                                            <i class="fas fa-check-circle me-2"></i>Consent
                                        </h6>
                                        <div class="row g-3">
                                            <div class="col-md-12">
                                                <div class="info-item">
                                                    <label class="info-label">Consent to Participate</label>
                                                    <div class="info-value" id="pdsConsent">Not specified</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Awards Tab -->
                                <div class="tab-pane fade" id="pds-awards" role="tabpanel">
                                    <div class="mb-4">
                                        <h6 class="text-primary border-bottom pb-2 mb-3">
                                            <i class="fas fa-trophy me-2"></i>Awards and Recognition
                                        </h6>
                                        <div class="row g-3" id="pdsAwardsContainer">
                                            <div class="col-12">
                                                <div class="info-item">
                                                    <div class="info-value">No awards recorded</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                        <i class="fas fa-times me-2"></i>Close
                    </button>
                    <button type="button" class="btn btn-primary" id="pdsPreviewBtn" onclick="openPDSPreview()" style="display: none;">
                        <i class="fas fa-file-pdf me-2"></i>Preview PDS
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- PWD Proof Preview Modal -->
    <div class="modal fade" id="pwdProofPreviewModal" tabindex="-1" aria-labelledby="pwdProofPreviewModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="pwdProofPreviewModalLabel">
                        <i class="fas fa-file-alt me-2"></i>PWD Proof Document
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-0">
                    <div id="pwdProofPreviewContent" class="text-center p-4">
                        <!-- Content will be loaded here -->
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                        <i class="fas fa-times me-1"></i>Close
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="<?= base_url('js/admin/view_users.js') ?>" defer></script>
    <script>
        window.BASE_URL = "<?= base_url() ?>";
    </script>
    <script src="<?= base_url('js/admin/profile_sync.js') ?>"></script>
    <script src="<?= base_url('js/admin/logout.js') ?>" defer></script>
    <script src="<?= base_url('js/admin/admin_drawer.js') ?>"></script>
    <script src="<?= base_url('js/utils/secureLogger.js') ?>"></script>
    <script src="<?= base_url('js/utils/sidebar.js') ?>"></script>
</body>

</html>