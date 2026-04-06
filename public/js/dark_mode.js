/**
 * Dark Mode Manager - Modern Toggle Design
 * Handles theme switching with persistence and system preference detection
 */
(function() {
    'use strict';

    const THEME_KEY = 'counselign-theme-preference';
    const THEME_LIGHT = 'light';
    const THEME_DARK = 'dark';
    const THEME_AUTO = 'auto';

    class DarkModeManager {
        constructor() {
            this.currentTheme = null;
            this.systemPreference = null;
            this.init();
        }

        /**
         * Initialize dark mode functionality
         */
        init() {
            // Set up system preference detection
            this.detectSystemPreference();
            this.watchSystemPreference();

            // Load saved preference or use system preference
            this.loadThemePreference();

            // Create toggle button
            this.createToggleButton();

            // Apply initial theme
            this.applyTheme(this.currentTheme);
        }

        /**
         * Detect system color scheme preference
         */
        detectSystemPreference() {
            if (window.matchMedia) {
                this.systemPreference = window.matchMedia('(prefers-color-scheme: dark)').matches 
                    ? THEME_DARK 
                    : THEME_LIGHT;
            } else {
                this.systemPreference = THEME_LIGHT;
            }
        }

        /**
         * Watch for system preference changes
         */
        watchSystemPreference() {
            if (window.matchMedia) {
                const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
                
                // Modern browsers
                if (mediaQuery.addEventListener) {
                    mediaQuery.addEventListener('change', (e) => {
                        this.systemPreference = e.matches ? THEME_DARK : THEME_LIGHT;
                        
                        // If user hasn't set a manual preference, update theme
                        const savedPreference = localStorage.getItem(THEME_KEY);
                        if (!savedPreference || savedPreference === THEME_AUTO) {
                            this.applyTheme(this.systemPreference);
                        }
                    });
                }
                // Older browsers
                else if (mediaQuery.addListener) {
                    mediaQuery.addListener((e) => {
                        this.systemPreference = e.matches ? THEME_DARK : THEME_LIGHT;
                        
                        const savedPreference = localStorage.getItem(THEME_KEY);
                        if (!savedPreference || savedPreference === THEME_AUTO) {
                            this.applyTheme(this.systemPreference);
                        }
                    });
                }
            }
        }

        /**
         * Load theme preference from localStorage
         */
        loadThemePreference() {
            try {
                const savedTheme = localStorage.getItem(THEME_KEY);
                
                if (savedTheme && [THEME_LIGHT, THEME_DARK].includes(savedTheme)) {
                    this.currentTheme = savedTheme;
                } else {
                    // Use system preference if no saved preference or if set to auto
                    this.currentTheme = this.systemPreference;
                }
            } catch (error) {
                console.error('Error loading theme preference:', error);
                this.currentTheme = this.systemPreference;
            }
        }

        /**
         * Save theme preference to localStorage
         */
        saveThemePreference(theme) {
            try {
                localStorage.setItem(THEME_KEY, theme);
            } catch (error) {
                console.error('Error saving theme preference:', error);
            }
        }

        /**
         * Apply theme to document
         */
        applyTheme(theme) {
            this.currentTheme = theme;
            
            if (theme === THEME_DARK) {
                document.documentElement.setAttribute('data-theme', 'dark');
            } else {
                document.documentElement.setAttribute('data-theme', 'light');
            }

            // Update toggle button state
            this.updateToggleState();

            // Dispatch custom event for other scripts to listen to
            window.dispatchEvent(new CustomEvent('themechange', { 
                detail: { theme: this.currentTheme } 
            }));
        }

        /**
         * Toggle between light and dark themes
         */
        toggleTheme() {
            const newTheme = this.currentTheme === THEME_DARK ? THEME_LIGHT : THEME_DARK;
            
            // Add transition class for smooth animation
            const toggleSwitch = document.querySelector('.toggle-switch');
            if (toggleSwitch) {
                toggleSwitch.style.transition = 'all 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55)';
            }
            
            this.applyTheme(newTheme);
            this.saveThemePreference(newTheme);
        }

        /**
         * Create modern toggle button with sun/moon icons
         */
        createToggleButton() {
            const button = document.createElement('button');
            button.id = 'darkModeToggle';
            button.className = 'dark-mode-toggle';
            button.setAttribute('aria-label', 'Toggle dark mode');
            button.setAttribute('title', 'Toggle dark mode');
            
            // Create toggle switch with icons
            const toggleSwitch = document.createElement('div');
            toggleSwitch.className = 'toggle-switch';
            
            // Add moon icon element
            const moonIcon = document.createElement('span');
            moonIcon.className = 'moon-icon';
            moonIcon.textContent = '🌙';
            toggleSwitch.appendChild(moonIcon);
            
            button.appendChild(toggleSwitch);

            button.addEventListener('click', () => this.toggleTheme());

            // Add to body when DOM is ready
            if (document.body) {
                document.body.appendChild(button);
            } else {
                document.addEventListener('DOMContentLoaded', () => {
                    document.body.appendChild(button);
                });
            }
        }

        /**
         * Update toggle button state based on current theme
         */
        updateToggleState() {
            const button = document.getElementById('darkModeToggle');
            if (!button) return;

            if (this.currentTheme === THEME_DARK) {
                button.setAttribute('title', 'Switch to light mode');
                button.setAttribute('aria-label', 'Switch to light mode');
            } else {
                button.setAttribute('title', 'Switch to dark mode');
                button.setAttribute('aria-label', 'Switch to dark mode');
            }
        }

        /**
         * Get current theme
         */
        getCurrentTheme() {
            return this.currentTheme;
        }

        /**
         * Check if dark mode is active
         */
        isDarkMode() {
            return this.currentTheme === THEME_DARK;
        }

        /**
         * Set specific theme programmatically
         */
        setTheme(theme) {
            if ([THEME_LIGHT, THEME_DARK].includes(theme)) {
                this.applyTheme(theme);
                this.saveThemePreference(theme);
            }
        }
    }

    // Initialize dark mode manager
    const darkModeManager = new DarkModeManager();

    // Expose to window for global access
    window.DarkMode = {
        toggle: () => darkModeManager.toggleTheme(),
        setTheme: (theme) => darkModeManager.setTheme(theme),
        getCurrentTheme: () => darkModeManager.getCurrentTheme(),
        isDarkMode: () => darkModeManager.isDarkMode()
    };

    // Apply theme immediately to prevent flash
    const savedTheme = localStorage.getItem(THEME_KEY);
    const systemDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
    const initialTheme = savedTheme || (systemDark ? THEME_DARK : THEME_LIGHT);
    document.documentElement.setAttribute('data-theme', initialTheme === THEME_DARK ? 'dark' : 'light');

})();