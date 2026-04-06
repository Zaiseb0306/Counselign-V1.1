// Logout function - directly logs out without confirmation modal
window.confirmLogout = function confirmLogout() {
    const baseUrl = window.BASE_URL || '/';
    window.location.href = baseUrl + 'auth/logout';
};

