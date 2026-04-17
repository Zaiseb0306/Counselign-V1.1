<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>Student Feedback Analytics - Counselign</title>
    <link rel="icon" href="<?= base_url('Photos/counselign.ico') ?>" sizes="16x16 32x32" type="image/x-icon">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<?= base_url('css/admin/feedback_analytics.css') ?>">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>

<body>
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
                <div class="page-header">
                    <h1><i class="fas fa-chart-bar me-2"></i>Student Feedback Analytics</h1>
                    <p class="text-muted">Descriptive Statistical Analysis of Student Feedback</p>
                </div>

                <!-- Filters -->
                <div class="card mb-4">
                    <div class="card-body">
                        <form id="filterForm" class="row g-3">
                            <div class="col-md-3">
                                <label class="form-label">Counselor</label>
                                <select class="form-select" id="counselorFilter" name="counselor_id">
                                    <option value="">All Counselors</option>
                                    <?php foreach ($counselors as $counselor): ?>
                                        <option value="<?= $counselor['counselor_id'] ?>" 
                                            <?= isset($filters['counselor_id']) && $filters['counselor_id'] == $counselor['counselor_id'] ? 'selected' : '' ?>>
                                            <?= $counselor['name'] ?>
                                        </option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Start Date</label>
                                <input type="date" class="form-control" id="startDate" name="start_date" 
                                    value="<?= $filters['start_date'] ?? '' ?>">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">End Date</label>
                                <input type="date" class="form-control" id="endDate" name="end_date"
                                    value="<?= $filters['end_date'] ?? '' ?>">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">&nbsp;</label>
                                <div class="btn-group w-100">
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-filter me-1"></i>Apply Filters
                                    </button>
                                    <button type="button" class="btn btn-outline-secondary" id="clearFilters">
                                        <i class="fas fa-times me-1"></i>Clear
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Overall Statistics -->
                <div class="row mb-4">
                    <div class="col-md-3">
                        <div class="stat-card overall-mean">
                            <div class="stat-icon"><i class="fas fa-star"></i></div>
                            <div class="stat-details">
                                <h3><?= $analytics['overall_mean'] ?></h3>
                                <p>Overall Mean</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card interpretation">
                            <div class="stat-icon"><i class="fas fa-smile"></i></div>
                            <div class="stat-details">
                                <h3><?= $analytics['overall_interpretation']['label'] ?></h3>
                                <p>Overall Interpretation</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card total-responses">
                            <div class="stat-icon"><i class="fas fa-users"></i></div>
                            <div class="stat-details">
                                <h3><?= $analytics['total_feedbacks'] ?></h3>
                                <p>Total Feedbacks</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card questions-count">
                            <div class="stat-icon"><i class="fas fa-list-ol"></i></div>
                            <div class="stat-details">
                                <h3>10</h3>
                                <p>Total Questions</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Category Means -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="fas fa-layer-group me-2"></i>Category Means</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered">
                                <thead class="table-light">
                                    <tr>
                                        <th>Category</th>
                                        <th>Mean</th>
                                        <th>Interpretation</th>
                                        <th>Questions Count</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($category_means as $category => $data): ?>
                                        <tr>
                                            <td><?= $category ?></td>
                                            <td><span class="badge bg-primary"><?= $data['mean'] ?></span></td>
                                            <td><span class="badge bg-<?= $data['interpretation']['color'] ?>">
                                                <?= $data['interpretation']['label'] ?>
                                            </span></td>
                                            <td><?= $data['question_count'] ?></td>
                                        </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Question Analytics Table -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="fas fa-table me-2"></i>Question Analytics</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover" id="questionsTable">
                                <thead class="table-light">
                                    <tr>
                                        <th style="width: 30%;">Question</th>
                                        <th>Strongly<br>Disagree<br>(1)</th>
                                        <th>Disagree<br>(2)</th>
                                        <th>Neutral<br>(3)</th>
                                        <th>Agree<br>(4)</th>
                                        <th>Strongly<br>Agree<br>(5)</th>
                                        <th>Total</th>
                                        <th>Weighted<br>Mean</th>
                                        <th>Interpretation</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($analytics['questions'] as $field => $data): ?>
                                        <tr>
                                            <td><?= $data['label'] ?></td>
                                            <td class="text-center"><?= $data['frequency'][1] ?></td>
                                            <td class="text-center"><?= $data['frequency'][2] ?></td>
                                            <td class="text-center"><?= $data['frequency'][3] ?></td>
                                            <td class="text-center"><?= $data['frequency'][4] ?></td>
                                            <td class="text-center"><?= $data['frequency'][5] ?></td>
                                            <td class="text-center"><strong><?= $data['total_responses'] ?></strong></td>
                                            <td class="text-center"><span class="badge bg-primary"><?= $data['weighted_mean'] ?></span></td>
                                            <td class="text-center">
                                                <span class="badge bg-<?= $data['interpretation']['color'] ?>">
                                                    <?= $data['interpretation']['label'] ?>
                                                </span>
                                            </td>
                                        </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Charts Section -->
                <div class="row mb-4">
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0"><i class="fas fa-chart-bar me-2"></i>Question Means</h5>
                            </div>
                            <div class="card-body">
                                <canvas id="questionMeansChart"></canvas>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0"><i class="fas fa-chart-pie me-2"></i>Overall Distribution</h5>
                            </div>
                            <div class="card-body">
                                <canvas id="overallDistributionChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Monthly Trend Chart -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="fas fa-chart-line me-2"></i>Monthly Trend</h5>
                    </div>
                    <div class="card-body">
                        <canvas id="monthlyTrendChart"></canvas>
                    </div>
                </div>

                <!-- Export Buttons -->
                <div class="card mb-4">
                    <div class="card-body">
                        <div class="btn-group">
                            <a href="<?= base_url('admin/feedback-analytics/export-pdf') ?>?<?= http_build_query($filters) ?>" 
                               class="btn btn-danger">
                                <i class="fas fa-file-pdf me-1"></i>Export PDF
                            </a>
                            <a href="<?= base_url('admin/feedback-analytics/export-excel') ?>?<?= http_build_query($filters) ?>" 
                               class="btn btn-success">
                                <i class="fas fa-file-excel me-1"></i>Export Excel
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="<?= base_url('js/admin/feedback_analytics.js') ?>"></script>
    <script>
        // Pass PHP data to JavaScript
        window.analyticsData = <?= json_encode($analytics) ?>;
        window.categoryMeans = <?= json_encode($category_means) ?>;
        window.monthlyTrend = <?= json_encode($monthly_trend) ?>;
        window.baseUrl = "<?= base_url() ?>";
    </script>
</body>

</html>
