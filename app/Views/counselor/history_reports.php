<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <meta name="description" content="Counselign">
    <title>Report History - Counselign</title>
    <link rel="icon" href="<?= base_url('Photos/counselign.ico') ?>" sizes="16x16 32x32" type="image/x-icon">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<?= base_url('css/counselor/history_reports.css') ?>">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
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
                    <i class="fas fa-history me-2"></i>
                    Report History
                </h1>
            </div>

            <div class="top-bar-right">

                <button class="top-bar-btn" onclick="window.location.href='<?= base_url('counselor/appointments/view-all') ?>'" title="Current Reports">
                    <i class="fa fa-chart-line text-2xl" style="cursor: pointer;"></i>
                    <span class="btn-label">Current Reports</span>
                </button>

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

        <div class="main-content">
            <div class="container report-container">
                <div class="page-header">
                    <p class="text-muted">View your past appointment reports and statistics</p>
                </div>

                <!-- Filter Section -->
                <div class="filter-section">
                    <div class="row g-3 align-items-center">
                        <div class="col-md-4">
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-calendar"></i></span>
                                <input type="month" class="form-control" id="monthFilter" max="<?= date('Y-m') ?>">
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-filter"></i></span>
                                <select class="form-select" id="reportTypeFilter">
                                    <option value="daily">Daily Reports</option>
                                    <option value="weekly">Weekly Reports</option>
                                    <option value="yearly">Yearly Reports</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <button class="btn btn-primary w-100" onclick="loadHistoricalReport()">
                                <i class="fas fa-search"></i> View Report
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Statistics Summary -->
                <div class="row stats-summary">
                    <div class="col-md-2">
                        <div class="stat-card completed">
                            <div class="stat-icon">
                                <i class="fas fa-check-circle"></i>
                            </div>
                            <div class="stat-details">
                                <h3 id="completedCount">0</h3>
                                <p>Completed</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="stat-card approved">
                            <div class="stat-icon">
                                <i class="fas fa-thumbs-up"></i>
                            </div>
                            <div class="stat-details">
                                <h3 id="approvedCount">0</h3>
                                <p>Approved</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="stat-card rescheduled">
                            <div class="stat-icon bg-warning text-white rounded-circle">
                                <i class="fas fa-calendar-alt"></i>
                            </div>
                            <div class="stat-details">
                                <h3 id="rescheduledCount">0</h3>
                                <p>Rescheduled</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="stat-card pending">
                            <div class="stat-icon">
                                <i class="fas fa-clock"></i>
                            </div>
                            <div class="stat-details">
                                <h3 id="pendingCount">0</h3>
                                <p>Pending</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="stat-card cancelled">
                            <div class="stat-icon">
                                <i class="fas fa-ban"></i>
                            </div>
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
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        window.BASE_URL = "<?= base_url() ?>";
    </script>
    <script src="<?= base_url('js/counselor/history_reports.js') ?>"></script>
    <script src="<?= base_url('js/counselor/counselor_drawer.js') ?>"></script>
    <script src="<?= base_url('js/utils/secureLogger.js') ?>"></script>
    <script src="<?= base_url('js/counselor/logout.js') ?>"></script>
    <script src="<?= base_url('js/utils/sidebar.js') ?>"></script>
</body>

</html>