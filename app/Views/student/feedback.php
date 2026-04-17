<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="Student Feedback - Counselign" />
    <meta name="keywords" content="counseling, feedback, student, university, support" />
    <title>Appointment Feedback - Counselign</title>
    <link rel="icon" href="<?= base_url('Photos/counselign.ico') ?>" sizes="16x16 32x32" type="image/x-icon">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="<?= base_url('css/student/student_feedback.css') ?>">
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

                <a href="<?= base_url('student/my-appointments') ?>" class="sidebar-link active" title="My Appointments">
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
                    <i class="fas fa-star"></i>
                    Appointment Feedback
                </h1>
            </div>

            <div class="top-bar-right">
                <button class="top-bar-btn" onclick="window.location.href='<?= base_url('student/my-appointments') ?>'" title="My Appointments">
                    <i class="fa fa-list-alt text-2xl"></i>
                    <span class="btn-label">My Appointments</span>
                </button>

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
                        <a href="#" class="profile-dropdown-item" onclick="confirmLogout()">
                            <i class="fas fa-sign-out-alt"></i>
                            <span>Log Out</span>
                        </a>
                    </div>
                </div>
            </div>
        </header>

        <main class="bg-light p-4">
            <div class="container-fluid px-4">
                <div class="feedback-container">
                    <div class="feedback-header">
                        <h3 class="text-center mb-4">
                            <i class="fas fa-comments text-primary me-2"></i>
                            Help Us Improve Our Counseling Services
                        </h3>
                        <p class="text-muted text-center mb-4">
                            Your feedback is valuable to us. Please take a few minutes to rate your experience with our counseling system.
                            All responses are anonymous and confidential.
                        </p>
                    </div>

                    <div class="feedback-card">
                        <form id="feedbackForm">
                            <input type="hidden" name="appointment_id" value="<?= $appointmentId ?>">

                            <!-- Likert Scale Legend -->
                            <div class="likert-legend mb-4">
                                <div class="legend-item">
                                    <span class="legend-label">1 = Strongly Disagree</span>
                                    <span class="legend-label">2 = Disagree</span>
                                    <span class="legend-label">3 = Neutral</span>
                                    <span class="legend-label">4 = Agree</span>
                                    <span class="legend-label">5 = Strongly Agree</span>
                                </div>
                            </div>

                            <!-- Question 1 -->
                            <div class="question-item mb-4">
                                <label class="question-label">
                                    1. How easy was it to navigate the appointment scheduling system?
                                    <span class="text-danger">*</span>
                                </label>
                                <div class="likert-scale">
                                    <div class="scale-option">
                                        <input type="radio" id="q1_1" name="q1_ease_of_use" value="1" required>
                                        <label for="q1_1">1</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q1_2" name="q1_ease_of_use" value="2" required>
                                        <label for="q1_2">2</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q1_3" name="q1_ease_of_use" value="3" required>
                                        <label for="q1_3">3</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q1_4" name="q1_ease_of_use" value="4" required>
                                        <label for="q1_4">4</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q1_5" name="q1_ease_of_use" value="5" required>
                                        <label for="q1_5">5</label>
                                    </div>
                                </div>
                            </div>

                            <!-- Question 2 -->
                            <div class="question-item mb-4">
                                <label class="question-label">
                                    2. How satisfied are you with the overall counseling experience?
                                    <span class="text-danger">*</span>
                                </label>
                                <div class="likert-scale">
                                    <div class="scale-option">
                                        <input type="radio" id="q2_1" name="q2_satisfaction" value="1" required>
                                        <label for="q2_1">1</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q2_2" name="q2_satisfaction" value="2" required>
                                        <label for="q2_2">2</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q2_3" name="q2_satisfaction" value="3" required>
                                        <label for="q2_3">3</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q2_4" name="q2_satisfaction" value="4" required>
                                        <label for="q2_4">4</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q2_5" name="q2_satisfaction" value="5" required>
                                        <label for="q2_5">5</label>
                                    </div>
                                </div>
                            </div>

                            <!-- Question 3 -->
                            <div class="question-item mb-4">
                                <label class="question-label">
                                    3. How satisfied are you with the response time to your appointment request?
                                    <span class="text-danger">*</span>
                                </label>
                                <div class="likert-scale">
                                    <div class="scale-option">
                                        <input type="radio" id="q3_1" name="q3_timeliness" value="1" required>
                                        <label for="q3_1">1</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q3_2" name="q3_timeliness" value="2" required>
                                        <label for="q3_2">2</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q3_3" name="q3_timeliness" value="3" required>
                                        <label for="q3_3">3</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q3_4" name="q3_timeliness" value="4" required>
                                        <label for="q3_4">4</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q3_5" name="q3_timeliness" value="5" required>
                                        <label for="q3_5">5</label>
                                    </div>
                                </div>
                            </div>

                            <!-- Question 4 -->
                            <div class="question-item mb-4">
                                <label class="question-label">
                                    4. How clear was the information provided about counseling services?
                                    <span class="text-danger">*</span>
                                </label>
                                <div class="likert-scale">
                                    <div class="scale-option">
                                        <input type="radio" id="q4_1" name="q4_information_clarity" value="1" required>
                                        <label for="q4_1">1</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q4_2" name="q4_information_clarity" value="2" required>
                                        <label for="q4_2">2</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q4_3" name="q4_information_clarity" value="3" required>
                                        <label for="q4_3">3</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q4_4" name="q4_information_clarity" value="4" required>
                                        <label for="q4_4">4</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q4_5" name="q4_information_clarity" value="5" required>
                                        <label for="q4_5">5</label>
                                    </div>
                                </div>
                            </div>

                            <!-- Question 5 -->
                            <div class="question-item mb-4">
                                <label class="question-label">
                                    5. How helpful was the counseling staff in addressing your concerns?
                                    <span class="text-danger">*</span>
                                </label>
                                <div class="likert-scale">
                                    <div class="scale-option">
                                        <input type="radio" id="q5_1" name="q5_staff_helpfulness" value="1" required>
                                        <label for="q5_1">1</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q5_2" name="q5_staff_helpfulness" value="2" required>
                                        <label for="q5_2">2</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q5_3" name="q5_staff_helpfulness" value="3" required>
                                        <label for="q5_3">3</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q5_4" name="q5_staff_helpfulness" value="4" required>
                                        <label for="q5_4">4</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q5_5" name="q5_staff_helpfulness" value="5" required>
                                        <label for="q5_5">5</label>
                                    </div>
                                </div>
                            </div>

                            <!-- Question 6 -->
                            <div class="question-item mb-4">
                                <label class="question-label">
                                    6. How reliable was the technology used for online consultations?
                                    <span class="text-danger">*</span>
                                </label>
                                <div class="likert-scale">
                                    <div class="scale-option">
                                        <input type="radio" id="q6_1" name="q6_technology_reliability" value="1" required>
                                        <label for="q6_1">1</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q6_2" name="q6_technology_reliability" value="2" required>
                                        <label for="q6_2">2</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q6_3" name="q6_technology_reliability" value="3" required>
                                        <label for="q6_3">3</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q6_4" name="q6_technology_reliability" value="4" required>
                                        <label for="q6_4">4</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q6_5" name="q6_technology_reliability" value="5" required>
                                        <label for="q6_5">5</label>
                                    </div>
                                </div>
                            </div>

                            <!-- Question 7 -->
                            <div class="question-item mb-4">
                                <label class="question-label">
                                    7. How confident do you feel about the privacy of your personal information?
                                    <span class="text-danger">*</span>
                                </label>
                                <div class="likert-scale">
                                    <div class="scale-option">
                                        <input type="radio" id="q7_1" name="q7_privacy_confidence" value="1" required>
                                        <label for="q7_1">1</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q7_2" name="q7_privacy_confidence" value="2" required>
                                        <label for="q7_2">2</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q7_3" name="q7_privacy_confidence" value="3" required>
                                        <label for="q7_3">3</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q7_4" name="q7_privacy_confidence" value="4" required>
                                        <label for="q7_4">4</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q7_5" name="q7_privacy_confidence" value="5" required>
                                        <label for="q7_5">5</label>
                                    </div>
                                </div>
                            </div>

                            <!-- Question 8 -->
                            <div class="question-item mb-4">
                                <label class="question-label">
                                    8. How likely are you to recommend our counseling services to others?
                                    <span class="text-danger">*</span>
                                </label>
                                <div class="likert-scale">
                                    <div class="scale-option">
                                        <input type="radio" id="q8_1" name="q8_recommendation" value="1" required>
                                        <label for="q8_1">1</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q8_2" name="q8_recommendation" value="2" required>
                                        <label for="q8_2">2</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q8_3" name="q8_recommendation" value="3" required>
                                        <label for="q8_3">3</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q8_4" name="q8_recommendation" value="4" required>
                                        <label for="q8_4">4</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q8_5" name="q8_recommendation" value="5" required>
                                        <label for="q8_5">5</label>
                                    </div>
                                </div>
                            </div>

                            <!-- Question 9 -->
                            <div class="question-item mb-4">
                                <label class="question-label">
                                    9. How would you rate your overall experience with the counseling system?
                                    <span class="text-danger">*</span>
                                </label>
                                <div class="likert-scale">
                                    <div class="scale-option">
                                        <input type="radio" id="q9_1" name="q9_overall_experience" value="1" required>
                                        <label for="q9_1">1</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q9_2" name="q9_overall_experience" value="2" required>
                                        <label for="q9_2">2</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q9_3" name="q9_overall_experience" value="3" required>
                                        <label for="q9_3">3</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q9_4" name="q9_overall_experience" value="4" required>
                                        <label for="q9_4">4</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q9_5" name="q9_overall_experience" value="5" required>
                                        <label for="q9_5">5</label>
                                    </div>
                                </div>
                            </div>

                            <!-- Question 10 -->
                            <div class="question-item mb-4">
                                <label class="question-label">
                                    10. How likely are you to use our counseling services again in the future?
                                    <span class="text-danger">*</span>
                                </label>
                                <div class="likert-scale">
                                    <div class="scale-option">
                                        <input type="radio" id="q10_1" name="q10_future_use" value="1" required>
                                        <label for="q10_1">1</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q10_2" name="q10_future_use" value="2" required>
                                        <label for="q10_2">2</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q10_3" name="q10_future_use" value="3" required>
                                        <label for="q10_3">3</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q10_4" name="q10_future_use" value="4" required>
                                        <label for="q10_4">4</label>
                                    </div>
                                    <div class="scale-option">
                                        <input type="radio" id="q10_5" name="q10_future_use" value="5" required>
                                        <label for="q10_5">5</label>
                                    </div>
                                </div>
                            </div>

                            <!-- Additional Comments -->
                            <div class="question-item mb-4">
                                <label for="additionalComments" class="question-label">
                                    Additional Comments (Optional)
                                </label>
                                <textarea id="additionalComments" name="additional_comments" class="form-control"
                                    rows="4" placeholder="Please share any additional feedback or suggestions..."></textarea>
                            </div>

                            <!-- Submit Button -->
                            <div class="text-center mt-4">
                                <button type="submit" class="btn btn-primary btn-lg" id="submitFeedbackBtn">
                                    <i class="fas fa-paper-plane me-2"></i>
                                    Submit Feedback
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Toast for notifications -->
    <div class="toast-container position-fixed bottom-0 end-0 p-3">
        <div id="feedbackToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
            <div class="toast-header">
                <strong class="me-auto" id="toastTitle">Notification</strong>
                <small id="toastTime">Just now</small>
                <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
            <div class="toast-body" id="toastMessage"></div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        window.BASE_URL = "<?= base_url() ?>";
    </script>
    <script src="<?= base_url('js/utils/timeFormatter.js') ?>"></script>
    <script src="<?= base_url('js/student/student_feedback.js') ?>"></script>
    <script src="<?= base_url('js/student/logout.js') ?>"></script>
    <script src="<?= base_url('js/utils/sidebar.js') ?>"></script>
</body>

</html>