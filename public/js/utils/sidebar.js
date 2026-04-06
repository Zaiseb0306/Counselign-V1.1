/**
 * Universal Sidebar and Profile Dropdown Functionality
 * Works for Admin, Counselor, and Student dashboards
 * Enhanced with hover functionality for profile dropdown
 */

(function() {
    'use strict';

    // Configuration for different roles
    const ROLE_ENDPOINTS = {
        admin: 'admin/dashboard/data',
        counselor: 'counselor/profile/get',
        student: 'student/dashboard/get-profile-data'
    };

    // Global state
    let currentUserRole = null;
    let currentUserData = null;
    let dropdownHideTimer = null;
    const DROPDOWN_HIDE_DELAY = 5000; // 5 seconds

    document.addEventListener('DOMContentLoaded', function() {
        // Initialize role detection and profile loading
        detectUserRole();
        
        // Sidebar elements
        const sidebar = document.getElementById('uniSidebar');
        const sidebarToggle = document.getElementById('sidebarToggle');
        const floatingSidebarToggle = document.getElementById('floatingSidebarToggle');
        const sidebarOverlay = document.getElementById('sidebarOverlay');
        const mainWrapper = document.getElementById('mainWrapper');

        // Profile dropdown elements
        const profileDropdownBtn = document.getElementById('profileDropdownBtn');
        const profileDropdownMenu = document.getElementById('profileDropdownMenu');

        // Load sidebar state from localStorage
        const sidebarCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';
        if (sidebarCollapsed && window.innerWidth >= 992) {
            sidebar.classList.add('collapsed');
        }

        // Function to toggle sidebar
        function toggleSidebar(e) {
            e.stopPropagation();
            e.preventDefault();
            
            if (window.innerWidth >= 992) {
                // Desktop: collapse/expand
                sidebar.classList.toggle('collapsed');
                localStorage.setItem('sidebarCollapsed', sidebar.classList.contains('collapsed'));
            } else {
                // Mobile: toggle visibility
                const isActive = sidebar.classList.contains('active');
                if (isActive) {
                    // Close sidebar
                    sidebar.classList.remove('active');
                    sidebarOverlay.classList.remove('active');
                } else {
                    // Open sidebar
                    sidebar.classList.add('active');
                    sidebarOverlay.classList.add('active');
                }
            }
        }

        // Sidebar toggle (works for both desktop and mobile)
        if (sidebarToggle) {
            sidebarToggle.addEventListener('click', toggleSidebar);
        }

        // Floating sidebar toggle for mobile
        if (floatingSidebarToggle) {
            floatingSidebarToggle.addEventListener('click', toggleSidebar);
        }

        // Close sidebar when clicking overlay
        if (sidebarOverlay) {
            sidebarOverlay.addEventListener('click', function() {
                sidebar.classList.remove('active');
                sidebarOverlay.classList.remove('active');
            });
        }

        // Close sidebar when clicking a link on mobile
        const sidebarLinks = document.querySelectorAll('.sidebar-link');
        sidebarLinks.forEach(link => {
            link.addEventListener('click', function() {
                if (window.innerWidth < 992) {
                    sidebar.classList.remove('active');
                    sidebarOverlay.classList.remove('active');
                }
            });
        });

        // ===================================
        // ENHANCED PROFILE DROPDOWN FUNCTIONALITY
        // ===================================

        /**
         * Show the dropdown menu
         */
        function showDropdown() {
            if (profileDropdownMenu) {
                clearTimeout(dropdownHideTimer);
                profileDropdownMenu.classList.add('show');
            }
        }

        /**
         * Hide the dropdown menu after delay
         */
        function hideDropdownWithDelay() {
            clearTimeout(dropdownHideTimer);
            dropdownHideTimer = setTimeout(() => {
                if (profileDropdownMenu) {
                    profileDropdownMenu.classList.remove('show');
                }
            }, DROPDOWN_HIDE_DELAY);
        }

        /**
         * Hide the dropdown immediately
         */
        function hideDropdownImmediately() {
            clearTimeout(dropdownHideTimer);
            if (profileDropdownMenu) {
                profileDropdownMenu.classList.remove('show');
            }
        }

        // Profile dropdown button - hover events
        if (profileDropdownBtn) {
            // Click event (toggle)
            profileDropdownBtn.addEventListener('click', function(e) {
                e.stopPropagation();
                const isShown = profileDropdownMenu.classList.contains('show');
                
                if (isShown) {
                    hideDropdownImmediately();
                } else {
                    showDropdown();
                }
            });

            // Mouse enter - show dropdown
            profileDropdownBtn.addEventListener('mouseenter', function() {
                showDropdown();
            });

            // Mouse leave - start hide timer
            profileDropdownBtn.addEventListener('mouseleave', function() {
                hideDropdownWithDelay();
            });
        }

        // Profile dropdown menu - hover events
        if (profileDropdownMenu) {
            // Mouse enter - cancel hide timer
            profileDropdownMenu.addEventListener('mouseenter', function() {
                clearTimeout(dropdownHideTimer);
            });

            // Mouse leave - start hide timer
            profileDropdownMenu.addEventListener('mouseleave', function() {
                hideDropdownWithDelay();
            });

            // Ensure dropdown items remain functional
            const dropdownItems = profileDropdownMenu.querySelectorAll('.profile-dropdown-item');
            dropdownItems.forEach(item => {
                item.addEventListener('click', function(e) {
                    // Allow links to work normally
                    // Hide dropdown after click if it's not a link
                    if (!this.hasAttribute('href') || this.getAttribute('href') === '#') {
                        hideDropdownImmediately();
                    }
                });
            });
        }

        // Close profile dropdown when clicking outside
        document.addEventListener('click', function(e) {
            if (profileDropdownMenu && 
                !profileDropdownMenu.contains(e.target) && 
                e.target !== profileDropdownBtn &&
                !profileDropdownBtn.contains(e.target)) {
                hideDropdownImmediately();
            }
        });

        // Close dropdown when pressing Escape
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                if (profileDropdownMenu) {
                    hideDropdownImmediately();
                }
                if (window.innerWidth < 992 && sidebar.classList.contains('active')) {
                    sidebar.classList.remove('active');
                    sidebarOverlay.classList.remove('active');
                }
            }
        });

        // Handle window resize
        let resizeTimer;
        window.addEventListener('resize', function() {
            clearTimeout(resizeTimer);
            resizeTimer = setTimeout(function() {
                if (window.innerWidth >= 992) {
                    // Desktop: Remove mobile classes
                    sidebar.classList.remove('active');
                    sidebarOverlay.classList.remove('active');
                    
                    // Restore collapsed state from localStorage
                    const sidebarCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';
                    if (sidebarCollapsed) {
                        sidebar.classList.add('collapsed');
                    } else {
                        sidebar.classList.remove('collapsed');
                    }
                } else {
                    // Mobile: Remove collapsed class
                    sidebar.classList.remove('collapsed');
                }
            }, 250);
        });

        // Sync profile data with dropdown
        syncProfileData();
        
        // Update profile data periodically (every 5 minutes)
        setInterval(syncProfileData, 300000);
    });

    /**
     * Detect user role from page URL
     */
    function detectUserRole() {
        const path = window.location.pathname.toLowerCase();
        
        if (path.includes('/admin/')) {
            currentUserRole = 'admin';
        } else if (path.includes('/counselor/')) {
            currentUserRole = 'counselor';
        } else if (path.includes('/student/') || path.includes('/user/')) {
            currentUserRole = 'student';
        }

        // Fallback: check for data attribute on body
        if (!currentUserRole) {
            const bodyRole = document.body.getAttribute('data-user-role');
            if (bodyRole) {
                currentUserRole = bodyRole;
            }
        }

        SecureLogger.info('[Sidebar] Detected user role:', currentUserRole);
        return currentUserRole;
    }

    /**
     * Sync profile data between top bar and dropdown (universal for all roles)
     */
    function syncProfileData() {
        if (!currentUserRole) {
            console.error('[Sidebar] Cannot sync profile: role not detected');
            return;
        }

        const endpoint = ROLE_ENDPOINTS[currentUserRole];
        if (!endpoint) {
            console.error('[Sidebar] No endpoint configured for role:', currentUserRole);
            return;
        }

        const baseUrl = window.BASE_URL || '/';
        const url = baseUrl + endpoint;

        SecureLogger.info('[Sidebar] Syncing profile data from:', url);
        
        fetch(url, {
            method: 'GET',
            credentials: 'include',
            headers: {
                'Accept': 'application/json'
            }
        })
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            SecureLogger.info('[Sidebar] Profile data received:', data);
            
            if (data.success) {
                currentUserData = data.data || data;
                updateProfileElements(currentUserData);
            } else {
                console.error('[Sidebar] Profile load failed:', data.message);
                displayFallbackProfile();
            }
        })
        .catch(error => {
            console.error('[Sidebar] Error syncing profile data:', error);
            displayFallbackProfile();
        });
    }

    /**
     * Update all profile elements with user data
     */
    function updateProfileElements(userData) {
        // Update profile images (top bar and dropdown)
        updateProfileImage('profile-img-top', userData);
        updateProfileImage('profile-img-dropdown', userData);
        
        // Update user names (top bar and dropdown)
        updateUserName('uniNameTop', userData);
        updateUserName('uniNameDropdown', userData);
        
        // Update last login time in dropdown
        updateLastLogin('lastLoginDropdown', userData);
        
        SecureLogger.info('[Sidebar] Profile elements updated successfully');
    }

    /**
     * Update profile image element
     */
    function updateProfileImage(elementId, userData) {
        const imgElement = document.getElementById(elementId);
        if (!imgElement) return;

        const profilePicture = userData.profile_picture || userData.profilePicture;
        
        if (profilePicture) {
            let imageUrl = profilePicture;
            
            // If it's not already a full URL, make it absolute
            if (!/^https?:\/\//i.test(imageUrl)) {
                const baseUrl = window.BASE_URL || '/';
                imageUrl = imageUrl.startsWith('/') ? imageUrl : '/' + imageUrl;
                imageUrl = baseUrl.replace(/\/$/, '') + imageUrl;
            }
            
            imgElement.src = imageUrl;
            
            // Store in localStorage for quick access
            try {
                localStorage.setItem(`${currentUserRole}_profile_picture`, imageUrl);
            } catch (e) {
                console.warn('[Sidebar] Could not store profile picture in localStorage:', e);
            }
        } else {
            // Use default profile picture
            const baseUrl = window.BASE_URL || '/';
            imgElement.src = baseUrl + 'Photos/profile.png';
        }
    }

    /**
     * Update user name element with role-specific display logic
     */
    function updateUserName(elementId, userData) {
        const nameElement = document.getElementById(elementId);
        if (!nameElement) return;

        const displayName = getDisplayName(userData);
        nameElement.textContent = displayName;
        
        SecureLogger.info(`[Sidebar] Updated ${elementId} to: ${displayName}`);
    }

    /**
     * Get display name based on role and available data
     */
    function getDisplayName(userData) {
        if (!userData) return 'User';

        switch (currentUserRole) {
            case 'admin':
                return getAdminDisplayName(userData);
            case 'counselor':
                return getCounselorDisplayName(userData);
            case 'student':
                return getStudentDisplayName(userData);
            default:
                return userData.username || userData.user_id || 'User';
        }
    }

    /**
     * Get admin display name
     * Priority: username > user_id
     */
    function getAdminDisplayName(userData) {
        if (userData.username && userData.username.trim()) {
            return userData.username.trim();
        }
        
        return userData.user_id || 'Admin';
    }

    /**
     * Get counselor display name
     * Priority: full_name > name > username > user_id_display > user_id
     */
    function getCounselorDisplayName(userData) {
        // Check full_name first
        if (userData.full_name && userData.full_name.trim()) {
            return userData.full_name.trim();
        }
        
        // Check name
        if (userData.name && userData.name.trim()) {
            return userData.name.trim();
        }
        
        // Check username
        if (userData.username && userData.username.trim()) {
            return userData.username.trim();
        }
        
        // Fall back to user_id_display or user_id
        return userData.user_id_display || userData.user_id || 'Counselor';
    }

    /**
     * Get student display name
     * Priority: first_name + last_name > full_name > username > user_id
     */
    function getStudentDisplayName(userData) {
        // Check if we have both first and last name
        if (userData.first_name || userData.last_name) {
            const firstName = (userData.first_name || '').trim();
            const lastName = (userData.last_name || '').trim();
            
            if (firstName || lastName) {
                return `${firstName} ${lastName}`.trim();
            }
        }
        
        // Check full_name
        if (userData.full_name && userData.full_name.trim()) {
            return userData.full_name.trim();
        }
        
        // Check username
        if (userData.username && userData.username.trim()) {
            return userData.username.trim();
        }
        
        // Fall back to user_id
        return userData.user_id || 'Student';
    }

    /**
     * Update last login element
     */
    function updateLastLogin(elementId, userData) {
        const lastLoginElement = document.getElementById(elementId);
        if (!lastLoginElement) return;

        const lastLogin = userData.last_login || userData.lastLogin;
        
        if (lastLogin) {
            const formattedTime = formatDateTime(lastLogin);
            lastLoginElement.textContent = 'Last login: ' + formattedTime;
        } else {
            lastLoginElement.textContent = 'Last login: Never';
        }
    }

    /**
     * Format date and time
     */
    function formatDateTime(dateTimeStr) {
        if (!dateTimeStr) return 'Never';
        
        try {
            const date = new Date(dateTimeStr);
            
            // Check if date is valid
            if (isNaN(date.getTime())) {
                return 'Invalid date';
            }
            
            return date.toLocaleString('en-US', {
                year: 'numeric',
                month: 'long',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                hour12: true
            });
        } catch (e) {
            console.error('[Sidebar] Error formatting date:', e);
            return 'Invalid date';
        }
    }

    /**
     * Display fallback profile when data loading fails
     */
    function displayFallbackProfile() {
        // Update profile images to default
        const profileImgTop = document.getElementById('profile-img-top');
        const profileImgDropdown = document.getElementById('profile-img-dropdown');
        const baseUrl = window.BASE_URL || '/';
        const defaultImage = baseUrl + 'Photos/profile.png';
        
        if (profileImgTop) {
            profileImgTop.src = defaultImage;
        }
        
        if (profileImgDropdown) {
            profileImgDropdown.src = defaultImage;
        }

        // Update names to role name
        const roleName = currentUserRole ? 
            currentUserRole.charAt(0).toUpperCase() + currentUserRole.slice(1) : 
            'User';
        
        const userNameTop = document.getElementById('uniNameTop');
        const userNameDropdown = document.getElementById('uniNameDropdown');
        
        if (userNameTop) {
            userNameTop.textContent = roleName;
        }
        
        if (userNameDropdown) {
            userNameDropdown.textContent = roleName;
        }

        // Update last login
        const lastLoginDropdown = document.getElementById('lastLoginDropdown');
        if (lastLoginDropdown) {
            lastLoginDropdown.textContent = 'Last login: Unknown';
        }
        
        SecureLogger.info('[Sidebar] Displayed fallback profile for:', roleName);
    }

    /**
     * Public API for manual profile refresh
     */
    window.reloadSidebarProfile = function() {
        SecureLogger.info('[Sidebar] Manual profile reload requested');
        syncProfileData();
    };

    /**
     * Logout confirmation (called from profile dropdown)
     */
    if (typeof window.confirmLogout !== 'function') {
        window.confirmLogout = function() {
            if (confirm('Are you sure you want to log out?')) {
                window.location.href = (window.BASE_URL || '/') + 'auth/logout';
            }
        };
    }

    // Expose utility functions
    window.UniversalSidebar = {
        getCurrentUserData: function() { return currentUserData; },
        getCurrentUserRole: function() { return currentUserRole; },
        reloadProfile: syncProfileData,
        formatDateTime: formatDateTime
    };

})();