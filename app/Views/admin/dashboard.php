<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <meta name="description" content="Counselign">
    <title>Counselign</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="icon" href="<?= base_url('Photos/counselign.ico') ?>" type="image/x-icon">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<?= base_url('css/utils/sidebar.css') ?>">
    <link rel="stylesheet" href="<?= base_url('css/admin/admin_dashboard.css') ?>">
    <link rel="stylesheet" href="<?= base_url('css/admin/view_all_appointments.css') ?>">

    <style>

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
                <a href="<?= base_url('admin/dashboard') ?>" class="sidebar-link active" title="Dashboard">
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

    <!-- Main Content Area -->
    <div class="main-wrapper" id="mainWrapper">
        <!-- Top Bar -->
        <header class="top-bar">
            <div class="top-bar-left">
                <h1 class="page-title-header">
                    <i class="fas fa-chart-line me-2"></i>
                    Appointment Reports
                </h1>
            </div>

            <div class="top-bar-right">
                <!-- Quote Modal Button -->
                <button class="top-bar-btn" id="openQuotesModalBtn" title="Manage Quotes">
                    <i class="fas fa-quote-right"></i>
                    <span class="btn-label">Quotes</span>
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

        <!-- Main Content -->
        <main class="main-content">
            <!-- Migrated main content from admin/view_all_appointments -->
            <div class="container report-container">
                <div class="page-header" hidden>
                    <p class="text-muted">View and analyze appointment statistics</p>
                </div>

                <!-- Filter Section -->
                <div class="filter-section">
                    <div class="row g-3 align-items-center">
                        <div class="col-md-8">
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-calendar"></i></span>
                                <select class="form-select" id="timeRange">
                                    <option value="daily">Daily Report</option>
                                    <option value="weekly" selected>Weekly Report</option>
                                    <option value="monthly">Monthly Report</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <a href="<?= base_url('admin/history-reports') ?>" class="btn btn-secondary w-100">
                                <i class="fas fa-history"></i><span class="btn-text"> View Past Reports</span>
                            </a>
                        </div>
                    </div>
                    <div class="mt-3 d-flex align-items-center gap-2">
                        <span id="flaskStatusBadge" class="badge rounded-pill bg-secondary">Middleware</span>
                        <span id="flaskStatusText" class="small text-muted">Checking Flask middleware...</span>
                    </div>
                </div>

                <!-- History Modal -->
                <div class="modal fade" id="historyModal" tabindex="-1" aria-labelledby="historyModalLabel" aria-hidden="true">
                    <div class="modal-dialog modal-lg">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title" id="historyModalLabel">Report History</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead>
                                            <tr>
                                                <th>Date Generated</th>
                                                <th>Report Type</th>
                                                <th>Total Appointments</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody id="historyTableBody"></tbody>
                                    </table>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Statistics Summary -->
                <div class="row stats-summary">
                    <div class="col-md-2">
                        <div class="stat-card completed">
                            <div class="stat-icon"><i class="fas fa-check-circle"></i></div>
                            <div class="stat-details">
                                <h3 id="completedCount">0</h3>
                                <p>Completed</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="stat-card approved">
                            <div class="stat-icon"><i class="fas fa-thumbs-up"></i></div>
                            <div class="stat-details">
                                <h3 id="approvedCount">0</h3>
                                <p>Approved</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="stat-card rescheduled">
                            <div class="stat-icon bg-warning text-white rounded-circle"><i class="fas fa-calendar-alt"></i></div>
                            <div class="stat-details">
                                <h3 id="rescheduledCount">0</h3>
                                <p>Rescheduled</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="stat-card pending">
                            <div class="stat-icon"><i class="fas fa-clock"></i></div>
                            <div class="stat-details">
                                <h3 id="pendingCount">0</h3>
                                <p>Pending</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="stat-card cancelled">
                            <div class="stat-icon"><i class="fas fa-ban"></i></div>
                            <div class="stat-details">
                                <h3 id="cancelledCount">0</h3>
                                <p>Cancelled</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Charts -->
                <div class="row charts-section">
                    <div class="col-md-8">
                        <div class="chart-container trend-chart shadow rounded p-4 bg-white">
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <h4 class="m-0">
                                    <i class="fas fa-chart-line text-primary"></i>
                                    <span class="ms-2 fw-bold">Appointment Trends</span>
                                </h4>
                            </div>
                            <div class="chart-wrapper" style="height: 400px;">
                                <canvas id="appointmentTrendChart"></canvas>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="chart-container pie-chart">
                            <h4><i class="fas fa-chart-pie"></i> Status Distribution</h4>
                            <canvas id="statusPieChart"></canvas>
                        </div>
                    </div>
                </div>

                <div class="container mt-1">
                    <div class="appointment-container">
                        <div class="row mb-2">
                            <div class="col-12">
                                <h2 class="text-center fw-bold" style="color: #0d6efd;">All Appointment Lists</h2>
                            </div>
                        </div>

                        <!-- Navigation Tabs -->
                        <ul class="nav nav-tabs mb-4" id="appointmentTabs" role="tablist">
                            <li class="nav-item col-md-2" role="presentation">
                                <button class="nav-link active" id="all-tab" data-bs-toggle="tab" data-bs-target="#all"
                                    type="button">
                                    <i class="fas fa-list"></i><span class="tab-text"> All Appointments</span>
                                </button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link" id="followup-tab" data-bs-toggle="tab" data-bs-target="#followup"
                                    type="button">
                                    <i class="fas fa-calendar-plus"></i><span class="tab-text"> Follow-up</span>
                                </button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link" id="approved-tab" data-bs-toggle="tab" data-bs-target="#approved"
                                    type="button">
                                    <i class="fas fa-thumbs-up"></i><span class="tab-text"> Approved</span>
                                </button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link" id="rescheduled-tab" data-bs-toggle="tab" data-bs-target="#rescheduled"
                                    type="button">
                                    <i class="fas fa-calendar-alt"></i><span class="tab-text"> Rescheduled</span>
                                </button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link" id="completed-tab" data-bs-toggle="tab" data-bs-target="#completed"
                                    type="button">
                                    <i class="fas fa-check-circle"></i><span class="tab-text"> Completed</span>
                                </button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link" id="cancelled-tab" data-bs-toggle="tab" data-bs-target="#cancelled"
                                    type="button">
                                    <i class="fas fa-ban"></i><span class="tab-text"> Cancelled</span>
                                </button>
                            </li>
                        </ul>

                        <!-- Filter Options -->
                        <div class="row mb-4 appointment-filters">
                            <!-- Filter Line 1: Search and Date (Mobile/Tablet) -->
                            <div class="filter-line-1 d-lg-none">
                                <div class="col-mobile">
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="fas fa-search"></i></span>
                                        <input type="text" class="form-control" id="searchInputMobile" placeholder="Search appointments...">
                                    </div>
                                </div>
                                <div class="col-mobile">
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="fas fa-calendar"></i></span>
                                        <input type="month" class="form-control" id="dateFilterMobile">
                                    </div>
                                </div>
                            </div>

                            <!-- Filter Line 2: Export buttons (Mobile/Tablet) -->
                            <div class="filter-line-2 d-lg-none">
                                <div class="col-mobile">
                                    <div class="btn-group w-100">
                                        <button class="btn btn-primary" id="exportPDFMobile">
                                            <i class="fas fa-file-pdf me-2"></i>Export PDF
                                        </button>
                                        <button class="btn btn-success" id="exportExcelMobile">
                                            <i class="fas fa-file-excel me-2"></i>Export Excel
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <!-- Desktop Layout (Original) -->
                            <div class="col-md-4 d-none d-lg-block">
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fas fa-search"></i></span>
                                    <input type="text" class="form-control" id="searchInput" placeholder="Search appointments...">
                                </div>
                            </div>
                            <div class="col-md-4 d-none d-lg-block">
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fas fa-calendar"></i></span>
                                    <input type="month" class="form-control" id="dateFilter">
                                </div>
                            </div>
                            <div class="col-md-4 d-none d-lg-block">
                                <div class="btn-group w-100">
                                    <button class="btn btn-primary" id="exportPDF">
                                        <i class="fas fa-file-pdf me-2"></i>Export PDF
                                    </button>
                                    <button class="btn btn-success" id="exportExcel">
                                        <i class="fas fa-file-excel me-2"></i>Export Excel
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- Enhanced Export Filters Modal -->
                        <div class="modal fade" id="exportFiltersModal" tabindex="-1" aria-labelledby="exportFiltersModalLabel" aria-hidden="true">
                            <div class="modal-dialog modal-lg modal-dialog-scrollable">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title" id="exportFiltersModalLabel"><i class="fas fa-filter me-2"></i>Export Filters</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body">
                                        <!-- Date Range Filters -->
                                        <div class="row g-3 mb-4">
                                            <div class="col-md-3">
                                                <label for="exportStartDate" class="form-label">Start Date</label>
                                                <input type="date" class="form-control" id="exportStartDate">
                                            </div>
                                            <div class="col-md-3">
                                                <label for="exportEndDate" class="form-label">End Date</label>
                                                <input type="date" class="form-control" id="exportEndDate">
                                            </div>
                                            <div class="col-md-6 d-flex align-items-end">
                                                <small class="text-muted">
                                                    <i class="fas fa-info-circle me-1"></i>
                                                    Leave dates empty to export all appointments from the selected status tab.
                                                </small>
                                            </div>
                                        </div>

                                        <!-- Additional Filters -->
                                        <div class="row g-3 mb-2">
                                            <div class="col-md-6">
                                                <label for="exportCounselorFilter" class="form-label">Counselor</label>
                                                <select class="form-select" id="exportCounselorFilter">
                                                    <option value="">All Counselors</option>
                                                </select>
                                            </div>
                                            <div class="col-md-6">
                                                <label for="exportStudentFilter" class="form-label">Student</label>
                                                <select class="form-select" id="exportStudentFilter">
                                                    <option value="">All Students</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <label for="exportCourseFilter" class="form-label">Course</label>
                                                <select class="form-select" id="exportCourseFilter">
                                                    <option value="">All Courses</option>
                                                    <option value="BSIT">BSIT</option>
                                                    <option value="BSABE">BSABE</option>
                                                    <option value="BSEnE">BSEnE</option>
                                                    <option value="BSHM">BSHM</option>
                                                    <option value="BFPT">BFPT</option>
                                                    <option value="BSA">BSA</option>
                                                    <option value="BTHM">BTHM</option>
                                                    <option value="BSSW">BSSW</option>
                                                    <option value="BSAF">BSAF</option>
                                                    <option value="BTLED">BTLED</option>
                                                    <option value="DAT-BAT">DAT-BAT</option>
                                                </select>
                                            </div>
                                            <div class="col-md-6">
                                                <label for="exportYearLevelFilter" class="form-label">Year Level</label>
                                                <select class="form-select" id="exportYearLevelFilter">
                                                    <option value="">All Year Levels</option>
                                                    <option value="I">I</option>
                                                    <option value="II">II</option>
                                                    <option value="III">III</option>
                                                    <option value="IV">IV</option>
                                                </select>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button class="btn btn-outline-secondary" id="clearAllFilters">
                                            <i class="fas fa-times me-1"></i>Clear All
                                        </button>
                                        <button class="btn btn-outline-primary" id="clearDateRange">
                                            <i class="fas fa-calendar-times me-1"></i>Clear Dates
                                        </button>
                                        <button class="btn btn-primary" id="applyFilters">
                                            <i class="fas fa-check me-1"></i>Apply Filters & Export
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Tab Content with Scrollable Container -->
                        <div class="tab-content" id="appointmentTabContent">
                            <!-- Loading Spinner -->
                            <div class="loading-spinner" style="display: none;">
                                <div class="d-flex justify-content-center align-items-center">
                                    <div class="spinner-border text-primary" role="status">
                                        <span class="visually-hidden">Loading...</span>
                                    </div>
                                </div>
                            </div>

                            <!-- Empty State Message -->
                            <div class="empty-state alert alert-info text-center" style="display: none;">
                                <i class="fas fa-info-circle me-2"></i>
                                No appointments found.
                            </div>

                            <!-- All Appointments Tab -->
                            <div class="tab-pane fade show active" id="all" role="tabpanel">
                                <div class="table-responsive" style="max-height: 500px; overflow-y: auto; overflow-x: auto;">
                                    <table class="table table-hover mb-0" style="min-width: 1250px;">
                                        <thead class="table-light sticky-top">
                                            <tr>
                                                <th>User ID</th>
                                                <th>Full Name</th>
                                                <th>Date</th>
                                                <th>Time</th>
                                                <th>Method Type</th>
                                                <th>Consultation Type</th>
                                                <th>Session Type</th>
                                                <th>Purpose</th>
                                                <th>Counselor</th>
                                                <th>Status</th>
                                                <th style="width: 60%;">Reason for Status</th>
                                            </tr>
                                        </thead>
                                        <tbody id="allAppointmentsTable">
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <!-- Approved Appointments Tab -->
                            <div class="tab-pane fade" id="approved" role="tabpanel">
                                <div class="table-responsive" style="max-height: 500px; overflow-y: auto; overflow-x: auto;">
                                    <table class="table table-hover mb-0" style="min-width: 1250px;">
                                        <thead class="table-light sticky-top">
                                            <tr>
                                                <th>User ID</th>
                                                <th>Full Name</th>
                                                <th>Date</th>
                                                <th>Time</th>
                                                <th>Method Type</th>
                                                <th>Consultation Type</th>
                                                <th>Session Type</th>
                                                <th>Purpose</th>
                                                <th>Counselor</th>
                                                <th>Status</th>
                                            </tr>
                                        </thead>
                                        <tbody id="approvedAppointmentsTable">
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <!-- Rescheduled Appointments Tab -->
                            <div class="tab-pane fade" id="rescheduled" role="tabpanel">
                                <div class="table-responsive" style="max-height: 500px; overflow-y: auto; overflow-x: auto;">
                                    <table class="table table-hover mb-0" style="min-width: 1250px;">
                                        <thead class="table-light sticky-top">
                                            <tr>
                                                <th>User ID</th>
                                                <th>Full Name</th>
                                                <th>Date</th>
                                                <th>Time</th>
                                                <th>Method Type</th>
                                                <th>Consultation Type</th>
                                                <th>Session Type</th>
                                                <th>Purpose</th>
                                                <th>Counselor</th>
                                                <th>Status</th>
                                                <th style="width: 60%;">Reason for Status</th>
                                            </tr>
                                        </thead>
                                        <tbody id="rescheduledAppointmentsTable">
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <!-- Completed Appointments Tab -->
                            <div class="tab-pane fade" id="completed" role="tabpanel">
                                <div class="table-responsive" style="max-height: 500px; overflow-y: auto; overflow-x: auto;">
                                    <table class="table table-hover mb-0" style="min-width: 1250px;">
                                        <thead class="table-light sticky-top">
                                            <tr>
                                                <th>User ID</th>
                                                <th>Full Name</th>
                                                <th>Date</th>
                                                <th>Time</th>
                                                <th>Method Type</th>
                                                <th>Consultation Type</th>
                                                <th>Session Type</th>
                                                <th>Purpose</th>
                                                <th>Counselor</th>
                                                <th>Status</th>
                                            </tr>
                                        </thead>
                                        <tbody id="completedAppointmentsTable">
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <!-- Cancelled Appointments Tab -->
                            <div class="tab-pane fade" id="cancelled" role="tabpanel">
                                <div class="table-responsive" style="max-height: 500px; overflow-y: auto; overflow-x: auto;">
                                    <table class="table table-hover mb-0" style="min-width: 1250px;">
                                        <thead class="table-light sticky-top">
                                            <tr>
                                                <th>User ID</th>
                                                <th>Full Name</th>
                                                <th>Date</th>
                                                <th>Time</th>
                                                <th>Method Type</th>
                                                <th>Consultation Type</th>
                                                <th>Session Type</th>
                                                <th>Purpose</th>
                                                <th>Counselor</th>
                                                <th>Status</th>
                                                <th style="width: 60%;">Reason for Status</th>
                                            </tr>
                                        </thead>
                                        <tbody id="cancelledAppointmentsTable">
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <!-- Follow-up Appointments Tab -->
                            <div class="tab-pane fade" id="followup" role="tabpanel">
                                <div class="table-responsive" style="max-height: 500px; overflow-y: auto; overflow-x: auto;">
                                    <table class="table table-hover mb-0" style="min-width: 1250px;">
                                        <thead class="table-light sticky-top">
                                            <tr>
                                                <th>User ID</th>
                                                <th>Full Name</th>
                                                <th>Date</th>
                                                <th>Time</th>
                                                <th>Method Type</th>
                                                <th>Consultation Type</th>
                                                <th>Session Type</th>
                                                <th>Purpose</th>
                                                <th>Counselor</th>
                                                <th>Status</th>
                                            </tr>
                                        </thead>
                                        <tbody id="followUpAppointmentsTable">
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Quotes Management Modal -->
    <div class="modal fade" id="quotesManagementModal" tabindex="-1" aria-labelledby="quotesManagementModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-xl modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header" style="background: linear-gradient(135deg, #060E57, #0A1875); color: white;">
                    <h5 class="modal-title" id="quotesManagementModalLabel">
                        <i class="fas fa-quote-left me-2"></i>Manage Quotes
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <!-- Navigation Tabs -->
                    <ul class="nav nav-tabs mb-4" id="quoteTabs" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active" id="pending-tab" data-bs-toggle="tab" data-bs-target="#pending-quotes" type="button" role="tab">
                                <i class="fas fa-clock me-1"></i>Pending
                                <span class="badge bg-warning ms-2" id="pending-count">0</span>
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="approved-tab" data-bs-toggle="tab" data-bs-target="#approved-quotes" type="button" role="tab">
                                <i class="fas fa-check-circle me-1"></i>Approved
                                <span class="badge bg-success ms-2" id="approved-count">0</span>
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="rejected-tab" data-bs-toggle="tab" data-bs-target="#rejected-quotes" type="button" role="tab">
                                <i class="fas fa-times-circle me-1"></i>Rejected
                                <span class="badge bg-danger ms-2" id="rejected-count">0</span>
                            </button>
                        </li>
                    </ul>

                    <!-- Tab Content -->
                    <div class="tab-content" id="quoteTabContent">
                        <!-- Pending Quotes Tab -->
                        <div class="tab-pane fade show active" id="pending-quotes" role="tabpanel">
                            <div id="pendingQuotesList" class="d-flex flex-column gap-3">
                                <div class="text-center py-4">
                                    <i class="fas fa-spinner fa-spin fa-2x text-primary"></i>
                                    <p class="mt-2 text-muted">Loading quotes...</p>
                                </div>
                            </div>
                        </div>

                        <!-- Approved Quotes Tab -->
                        <div class="tab-pane fade" id="approved-quotes" role="tabpanel">
                            <div id="approvedQuotesList" class="d-flex flex-column gap-3">
                                <div class="text-center py-4">
                                    <i class="fas fa-spinner fa-spin fa-2x text-primary"></i>
                                    <p class="mt-2 text-muted">Loading quotes...</p>
                                </div>
                            </div>
                        </div>

                        <!-- Rejected Quotes Tab -->
                        <div class="tab-pane fade" id="rejected-quotes" role="tabpanel">
                            <div id="rejectedQuotesList" class="d-flex flex-column gap-3">
                                <div class="text-center py-4">
                                    <i class="fas fa-spinner fa-spin fa-2x text-primary"></i>
                                    <p class="mt-2 text-muted">Loading quotes...</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                        <i class="fas fa-times me-2"></i>Close
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Rejection Reason Modal -->
    <div class="modal fade" id="rejectionReasonModal" tabindex="-1" aria-labelledby="rejectionReasonModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="rejectionReasonModalLabel">
                        <i class="fas fa-times-circle me-2 text-danger"></i>Reject Quote
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p class="text-muted mb-3">Please provide a reason for rejecting this quote:</p>
                    <form id="rejectionReasonForm">
                        <div class="mb-3">
                            <label for="rejectionReason" class="form-label">Rejection Reason <span class="text-danger">*</span></label>
                            <textarea
                                class="form-control"
                                id="rejectionReason"
                                name="rejection_reason"
                                rows="4"
                                maxlength="500"
                                placeholder="Enter the reason for rejection..."
                                required></textarea>
                            <div class="form-text">This reason will be visible to the counselor who submitted the quote.</div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-danger" id="confirmRejectionBtn">
                        <i class="fas fa-times-circle me-2"></i>Reject Quote
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Shared Confirmation Modal -->
    <div class="modal fade" id="confirmationModal" tabindex="-1" aria-labelledby="confirmationModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="confirmationModalLabel">Confirm Action</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" id="confirmationMessageContent">Are you sure?</div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="confirmationConfirmBtn">Confirm</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Shared Alert Modal -->
    <div class="modal fade" id="alertModal" tabindex="-1" aria-labelledby="alertModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="alertModalLabel">Information</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body d-flex align-items-start gap-2">
                    <span id="alertIcon"><i class="fas fa-info-circle text-primary"></i></span>
                    <span id="alertMessageContent">Message</span>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" data-bs-dismiss="modal">OK</button>
                </div>
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
        window.FLASK_MIDDLEWARE_URL = "http://localhost:5000";
    </script>
    <script src="<?= base_url('js/utils/sidebar.js') ?>"></script>
    <script src="<?= base_url('js/admin/admin_dashboard.js') ?>"></script>
    <script src="<?= base_url('js/admin/profile_sync.js') ?>"></script>
    <script src="<?= base_url('js/admin/view_all_appointments.js') ?>"></script>
    <script src="<?= base_url('js/modals/student_dashboard_modals.js') ?>"></script>
    <script src="<?= base_url('js/admin/quotes_management.js') ?>"></script>
    <script src="<?= base_url('js/admin/logout.js') ?>" defer></script>
    <script src="<?= base_url('js/utils/secureLogger.js') ?>"></script>
</body>

</html>

