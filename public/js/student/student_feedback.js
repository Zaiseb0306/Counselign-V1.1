document.addEventListener('DOMContentLoaded', function() {
    const feedbackForm = document.getElementById('feedbackForm');
    const submitBtn = document.getElementById('submitFeedbackBtn');
    const feedbackToast = new bootstrap.Toast(document.getElementById('feedbackToast'));

    // Initialize profile dropdown
    initializeProfileDropdown();

    // Form submission handler
    feedbackForm.addEventListener('submit', function(e) {
        e.preventDefault();

        // Validate all required questions are answered
        const requiredQuestions = [
            'q1_ease_of_use', 'q2_satisfaction', 'q3_timeliness', 'q4_information_clarity',
            'q5_staff_helpfulness', 'q6_technology_reliability', 'q7_privacy_confidence',
            'q8_recommendation', 'q9_overall_experience', 'q10_future_use'
        ];

        let allAnswered = true;
        requiredQuestions.forEach(question => {
            const selectedOption = document.querySelector(`input[name="${question}"]:checked`);
            if (!selectedOption) {
                allAnswered = false;
            }
        });

        if (!allAnswered) {
            showToast('Error', 'Please answer all required questions before submitting.');
            return;
        }

        // Disable submit button
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>Submitting...';

        // Prepare form data
        const formData = new FormData(feedbackForm);

        // Submit feedback
        fetch((window.BASE_URL || '/') + 'student/feedback/submit', {
            method: 'POST',
            body: formData,
            credentials: 'include',
            headers: {
                'X-Requested-With': 'XMLHttpRequest'
            }
        })
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.json();
        })
        .then(data => {
            if (data.status === 'success') {
                showToast('Success', data.message);
                // Redirect to my appointments after successful submission
                setTimeout(() => {
                    window.location.href = (window.BASE_URL || '/') + 'student/my-appointments';
                }, 2000);
            } else {
                throw new Error(data.message || 'Failed to submit feedback');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            showToast('Error', error.message || 'Failed to submit feedback. Please try again.');
            // Re-enable submit button
            submitBtn.disabled = false;
            submitBtn.innerHTML = '<i class="fas fa-paper-plane me-2"></i>Submit Feedback';
        });
    });

    function showToast(title, message) {
        const toastTitle = document.querySelector('#feedbackToast .toast-header strong');
        const toastBody = document.querySelector('#feedbackToast .toast-body');
        const toastTime = document.querySelector('#feedbackToast .toast-header small');

        if (toastTitle) toastTitle.textContent = title;
        if (toastBody) toastBody.textContent = message;
        if (toastTime) toastTime.textContent = 'Just now';

        const toast = bootstrap.Toast.getInstance(document.getElementById('feedbackToast'));
        if (toast) {
            toast.show();
        } else {
            new bootstrap.Toast(document.getElementById('feedbackToast')).show();
        }
    }

    function initializeProfileDropdown() {
        const profileDropdownBtn = document.getElementById('profileDropdownBtn');
        const profileDropdownMenu = document.getElementById('profileDropdownMenu');

        if (profileDropdownBtn && profileDropdownMenu) {
            profileDropdownBtn.addEventListener('click', function(e) {
                e.stopPropagation();
                profileDropdownMenu.classList.toggle('show');
            });

            // Close dropdown when clicking outside
            document.addEventListener('click', function(e) {
                if (!profileDropdownBtn.contains(e.target) && !profileDropdownMenu.contains(e.target)) {
                    profileDropdownMenu.classList.remove('show');
                }
            });

            // Load user profile data
            loadUserProfile();
        }
    }

    function loadUserProfile() {
        fetch((window.BASE_URL || '/') + 'student/profile/get', {
            method: 'GET',
            credentials: 'include',
            headers: {
                'X-Requested-With': 'XMLHttpRequest'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.status === 'success' && data.profile) {
                const profile = data.profile;
                const displayName = profile.first_name && profile.last_name
                    ? `${profile.first_name} ${profile.last_name}`
                    : profile.username || 'Student';

                // Update profile elements
                const nameElements = document.querySelectorAll('#uniNameTop, #uniNameDropdown');
                nameElements.forEach(el => {
                    if (el) el.textContent = displayName;
                });

                // Update profile images if available
                if (profile.profile_picture) {
                    const imgElements = document.querySelectorAll('#profile-img-top, #profile-img-dropdown');
                    imgElements.forEach(el => {
                        if (el) el.src = (window.BASE_URL || '/') + profile.profile_picture;
                    });
                }
            }
        })
        .catch(error => {
            console.error('Error loading profile:', error);
        });
    }
});