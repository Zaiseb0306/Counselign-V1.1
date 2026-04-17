// Student Feedback Analytics JavaScript

document.addEventListener('DOMContentLoaded', function() {
    initializeCharts();
    initializeFilters();
});

/**
 * Initialize all charts
 */
function initializeCharts() {
    if (typeof window.analyticsData === 'undefined' || !window.analyticsData.questions) {
        console.error('Analytics data not available');
        return;
    }

    const analytics = window.analyticsData;
    const categoryMeans = window.categoryMeans || {};
    const monthlyTrend = window.monthlyTrend || [];

    // Question Means Bar Chart
    createQuestionMeansChart(analytics.questions);

    // Overall Distribution Pie Chart
    createOverallDistributionChart(analytics.questions);

    // Monthly Trend Line Chart
    createMonthlyTrendChart(monthlyTrend);
}

/**
 * Create Question Means Bar Chart
 */
function createQuestionMeansChart(questions) {
    const ctx = document.getElementById('questionMeansChart');
    if (!ctx) return;

    const labels = [];
    const means = [];
    const colors = [];

    Object.values(questions).forEach((q, index) => {
        // Shorten label for display
        const shortLabel = `Q${index + 1}`;
        labels.push(shortLabel);
        means.push(q.weighted_mean);
        
        // Color based on interpretation
        colors.push(getInterpretationColor(q.interpretation.color));
    });

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Weighted Mean',
                data: means,
                backgroundColor: colors,
                borderColor: colors.map(c => c.replace('0.8', '1')),
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            scales: {
                y: {
                    beginAtZero: true,
                    max: 5,
                    title: {
                        display: true,
                        text: 'Weighted Mean'
                    }
                },
                x: {
                    title: {
                        display: true,
                        text: 'Questions'
                    }
                }
            },
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    callbacks: {
                        title: function(tooltipItems) {
                            const index = tooltipItems[0].dataIndex;
                            const questionKeys = Object.keys(questions);
                            return questions[questionKeys[index]].label;
                        }
                    }
                }
            }
        }
    });
}

/**
 * Create Overall Distribution Pie Chart
 */
function createOverallDistributionChart(questions) {
    const ctx = document.getElementById('overallDistributionChart');
    if (!ctx) return;

    // Aggregate all responses across all questions
    const totalDistribution = {
        1: 0,
        2: 0,
        3: 0,
        4: 0,
        5: 0
    };

    Object.values(questions).forEach(q => {
        totalDistribution[1] += q.frequency[1];
        totalDistribution[2] += q.frequency[2];
        totalDistribution[3] += q.frequency[3];
        totalDistribution[4] += q.frequency[4];
        totalDistribution[5] += q.frequency[5];
    });

    const labels = ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'];
    const data = [
        totalDistribution[1],
        totalDistribution[2],
        totalDistribution[3],
        totalDistribution[4],
        totalDistribution[5]
    ];
    const colors = ['#dc3545', '#fd7e14', '#ffc107', '#0d6efd', '#198754'];

    new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: labels,
            datasets: [{
                data: data,
                backgroundColor: colors,
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    position: 'bottom'
                }
            }
        }
    });
}

/**
 * Create Monthly Trend Line Chart
 */
function createMonthlyTrendChart(monthlyTrend) {
    const ctx = document.getElementById('monthlyTrendChart');
    if (!ctx || !monthlyTrend.length) return;

    const labels = monthlyTrend.map(t => t.month);
    const means = monthlyTrend.map(t => t.overall_mean);
    const counts = monthlyTrend.map(t => t.total_feedbacks);

    new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Overall Mean',
                    data: means,
                    borderColor: '#0d6efd',
                    backgroundColor: 'rgba(13, 110, 253, 0.1)',
                    fill: true,
                    tension: 0.4,
                    yAxisID: 'y'
                },
                {
                    label: 'Total Feedbacks',
                    data: counts,
                    borderColor: '#198754',
                    backgroundColor: 'rgba(25, 135, 84, 0.1)',
                    fill: true,
                    tension: 0.4,
                    yAxisID: 'y1'
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            interaction: {
                mode: 'index',
                intersect: false
            },
            scales: {
                y: {
                    type: 'linear',
                    display: true,
                    position: 'left',
                    beginAtZero: true,
                    max: 5,
                    title: {
                        display: true,
                        text: 'Mean Score'
                    }
                },
                y1: {
                    type: 'linear',
                    display: true,
                    position: 'right',
                    beginAtZero: true,
                    title: {
                        display: true,
                        text: 'Total Feedbacks'
                    },
                    grid: {
                        drawOnChartArea: false
                    }
                }
            }
        }
    });
}

/**
 * Get interpretation color for chart
 */
function getInterpretationColor(colorName) {
    const colors = {
        'success': 'rgba(25, 135, 84, 0.8)',
        'primary': 'rgba(13, 110, 253, 0.8)',
        'warning': 'rgba(255, 193, 7, 0.8)',
        'danger': 'rgba(220, 53, 69, 0.8)',
        'dark': 'rgba(33, 37, 41, 0.8)'
    };
    return colors[colorName] || 'rgba(108, 117, 125, 0.8)';
}

/**
 * Initialize filter form
 */
function initializeFilters() {
    const filterForm = document.getElementById('filterForm');
    const clearFiltersBtn = document.getElementById('clearFilters');

    if (filterForm) {
        filterForm.addEventListener('submit', function(e) {
            e.preventDefault();
            applyFilters();
        });
    }

    if (clearFiltersBtn) {
        clearFiltersBtn.addEventListener('click', function() {
            document.getElementById('counselorFilter').value = '';
            document.getElementById('startDate').value = '';
            document.getElementById('endDate').value = '';
            applyFilters();
        });
    }
}

/**
 * Apply filters and reload data
 */
function applyFilters() {
    const counselorId = document.getElementById('counselorFilter').value;
    const startDate = document.getElementById('startDate').value;
    const endDate = document.getElementById('endDate').value;

    const params = new URLSearchParams();
    if (counselorId) params.append('counselor_id', counselorId);
    if (startDate) params.append('start_date', startDate);
    if (endDate) params.append('end_date', endDate);

    window.location.href = window.baseUrl + '/admin/feedback-analytics?' + params.toString();
}
