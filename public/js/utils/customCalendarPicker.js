/**
 * Custom Calendar Picker Component
 * 
 * A reusable calendar popup that integrates with date inputs and provides
 * availability checking based on counselor schedules and bookings.
 * 
 * Features:
 * - Popup calendar with UI matching student_announcements calendar
 * - Disables past dates and today (min date is tomorrow)
 * - Disables dates with no counselor availability
 * - Disables dates with all time slots booked
 * - Manual input still allowed through the date input field
 * 
 * @class CustomCalendarPicker
 */

class CustomCalendarPicker {
    /**
     * @param {Object} options Configuration options
     * @param {string} options.inputId ID of the date input element
     * @param {Function} options.onDateSelect Callback when date is selected (optional)
     * @param {string} options.userRole 'student' or 'counselor' (default: 'student')
     * @param {string} options.counselorId Specific counselor ID for filtering (optional)
     * @param {string} options.consultationType Consultation type for booking checks (optional)
     */
    constructor(options) {
        this.inputId = options.inputId;
        this.input = document.getElementById(this.inputId);
        this.onDateSelect = options.onDateSelect || null;
        this.userRole = options.userRole || 'student';
        this.counselorId = options.counselorId || null;
        this.consultationType = options.consultationType || null;
        
        if (!this.input) {
            console.error(`CustomCalendarPicker: Input element with ID "${this.inputId}" not found`);
            return;
        }

        this.currentDate = new Date();
        this.selectedDate = null;
        this.availabilityCache = {}; // Cache for availability data by date
        this.isOpen = false;
        
        this.init();
    }

    /**
     * Initialize the calendar picker
     */
    init() {
        this.createCalendarButton();
        this.createCalendarPopup();
        this.attachEventListeners();
        this.setTomorrowAsMinimum();
    }

    /**
     * Set tomorrow as the minimum date and default value
     */
    setTomorrowAsMinimum() {
        const tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        
        const year = tomorrow.getFullYear();
        const month = String(tomorrow.getMonth() + 1).padStart(2, '0');
        const day = String(tomorrow.getDate()).padStart(2, '0');
        const minDate = `${year}-${month}-${day}`;
        
        this.input.setAttribute('min', minDate);
        
        // Only set default value if input is empty
        if (!this.input.value) {
            this.input.value = minDate;
        }
    }

    /**
     * Create the calendar button next to the input
     */
    createCalendarButton() {
        // Check if button already exists
        if (this.input.nextElementSibling?.classList.contains('custom-calendar-btn')) {
            return;
        }

        // Wrap input in a container if not already wrapped
        let wrapper = this.input.parentElement;
        if (!wrapper.classList.contains('custom-calendar-input-wrapper')) {
            wrapper = document.createElement('div');
            wrapper.className = 'custom-calendar-input-wrapper';
            this.input.parentNode.insertBefore(wrapper, this.input);
            wrapper.appendChild(this.input);
        }

        const button = document.createElement('button');
        button.type = 'button';
        button.className = 'custom-calendar-btn';
        button.innerHTML = '<i class="fas fa-calendar-alt"></i>';
        button.setAttribute('aria-label', 'Open calendar');
        
        wrapper.appendChild(button);
        this.calendarButton = button;
    }

    /**
     * Create the calendar popup structure
     */
    createCalendarPopup() {
        // Remove existing popup if any
        const existing = document.getElementById(`custom-calendar-popup-${this.inputId}`);
        if (existing) {
            existing.remove();
        }

        const popup = document.createElement('div');
        popup.id = `custom-calendar-popup-${this.inputId}`;
        popup.className = 'custom-calendar-popup';
        popup.innerHTML = `
            <div class="custom-calendar-header">
                <button type="button" class="custom-calendar-nav-btn" data-nav="prev">
                    <i class="fas fa-chevron-left"></i>
                </button>
                <h4 class="custom-calendar-month"></h4>
                <button type="button" class="custom-calendar-nav-btn" data-nav="next">
                    <i class="fas fa-chevron-right"></i>
                </button>
            </div>
            <div class="custom-calendar-grid"></div>
        `;
        
        document.body.appendChild(popup);
        this.popup = popup;
        this.monthLabel = popup.querySelector('.custom-calendar-month');
        this.grid = popup.querySelector('.custom-calendar-grid');
    }

    /**
     * Attach event listeners
     */
    attachEventListeners() {
        // Calendar button click
        this.calendarButton.addEventListener('click', (e) => {
            e.preventDefault();
            e.stopPropagation();
            this.toggleCalendar();
        });

        // Navigation buttons
        this.popup.querySelectorAll('.custom-calendar-nav-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                e.stopPropagation();
                const direction = btn.dataset.nav;
                if (direction === 'prev') {
                    this.currentDate.setMonth(this.currentDate.getMonth() - 1);
                } else {
                    this.currentDate.setMonth(this.currentDate.getMonth() + 1);
                }
                this.renderCalendar();
            });
        });

        // Close calendar when clicking outside
        document.addEventListener('click', (e) => {
            if (this.isOpen && !this.popup.contains(e.target) && !this.calendarButton.contains(e.target)) {
                this.closeCalendar();
            }
        });

        // Manual input change
        this.input.addEventListener('change', () => {
            this.validateInputDate();
        });
    }

    /**
     * Toggle calendar visibility
     */
    toggleCalendar() {
        if (this.isOpen) {
            this.closeCalendar();
        } else {
            this.openCalendar();
        }
    }

    /**
     * Open calendar popup
     */
    async openCalendar() {
        this.isOpen = true;
        
        // Position popup near the input
        const inputRect = this.input.getBoundingClientRect();
        this.popup.style.top = `${inputRect.bottom + window.scrollY + 5}px`;
        this.popup.style.left = `${inputRect.left + window.scrollX}px`;
        
        this.popup.classList.add('active');
        
        // Set current date from input or use tomorrow
        if (this.input.value) {
            this.currentDate = new Date(this.input.value + 'T00:00:00');
        } else {
            this.currentDate = new Date();
            this.currentDate.setDate(this.currentDate.getDate() + 1);
        }
        
        await this.renderCalendar();
    }

    /**
     * Close calendar popup
     */
    closeCalendar() {
        this.isOpen = false;
        this.popup.classList.remove('active');
    }

    /**
     * Render calendar grid
     */
    async renderCalendar() {
        // Update month label
        const monthNames = [
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
        ];
        this.monthLabel.textContent = `${monthNames[this.currentDate.getMonth()]} ${this.currentDate.getFullYear()}`;

        // Clear grid
        this.grid.innerHTML = '';

        // Add day headers
        const dayHeaders = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        dayHeaders.forEach(day => {
            const header = document.createElement('div');
            header.className = 'custom-calendar-day-header';
            header.textContent = day;
            this.grid.appendChild(header);
        });

        // Calculate first day and number of days in month
        const firstDay = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth(), 1);
        const lastDay = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth() + 1, 0);
        const daysInMonth = lastDay.getDate();
        const startingDayOfWeek = firstDay.getDay();

        // Add empty cells before first day
        for (let i = 0; i < startingDayOfWeek; i++) {
            const emptyCell = document.createElement('div');
            emptyCell.className = 'custom-calendar-day other-month';
            this.grid.appendChild(emptyCell);
        }

        // Get today and tomorrow for comparison
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const tomorrow = new Date(today);
        tomorrow.setDate(tomorrow.getDate() + 1);

        // Start fetching availability in background (don't await to avoid blocking)
        this.fetchMonthAvailability(this.currentDate.getFullYear(), this.currentDate.getMonth()).catch(err => {
            console.warn('Failed to fetch availability:', err);
        });

        // Add days of month
        for (let day = 1; day <= daysInMonth; day++) {
            const dayDate = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth(), day);
            dayDate.setHours(0, 0, 0, 0);
            
            const dayCell = document.createElement('div');
            dayCell.className = 'custom-calendar-day';
            
            const dateNumber = document.createElement('span');
            dateNumber.className = 'date-number';
            dateNumber.textContent = day;
            dayCell.appendChild(dateNumber);

            // Check if date is in the past or today (disabled)
            if (dayDate < tomorrow) {
                dayCell.classList.add('disabled', 'past-date');
                dayCell.title = 'Cannot book appointments for past dates or today';
            } else {
                // Check availability for future dates
                const dateString = this.formatDate(dayDate);
                const availability = this.availabilityCache[dateString];

                if (availability) {
                    if (!availability.hasCounselors) {
                        // No counselors scheduled on this day
                        dayCell.classList.add('disabled', 'no-counselors');
                        dayCell.title = 'No counselors available on this date';
                    } else if (availability.fullyBooked) {
                        // All time slots are booked
                        dayCell.classList.add('disabled', 'fully-booked');
                        dayCell.title = 'All time slots are booked for this date';
                    } else {
                        // Available date
                        dayCell.classList.add('available');
                        dayCell.addEventListener('click', () => this.selectDate(dayDate));
                    }
                } else {
                    // Default to available if no data (optimistic approach)
                    dayCell.classList.add('available');
                    dayCell.addEventListener('click', () => this.selectDate(dayDate));
                }

                // Highlight selected date
                if (this.input.value) {
                    const selectedDate = new Date(this.input.value + 'T00:00:00');
                    if (this.isSameDate(dayDate, selectedDate)) {
                        dayCell.classList.add('selected');
                    }
                }

                // Highlight today
                if (this.isSameDate(dayDate, today)) {
                    dayCell.classList.add('today');
                }
            }

            this.grid.appendChild(dayCell);
        }
    }

    /**
     * Fetch availability data for the entire month
     */
    async fetchMonthAvailability(year, month) {
        const monthKey = `${year}-${month + 1}`;
        
        // Mark as being fetched to prevent duplicate requests
        if (this.availabilityCache[monthKey]) {
            return;
        }
        this.availabilityCache[monthKey] = 'fetching';

        try {
            // Calculate first and last day of month
            const firstDay = new Date(year, month, 1);
            const lastDay = new Date(year, month + 1, 0);
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            const tomorrow = new Date(today);
            tomorrow.setDate(tomorrow.getDate() + 1);

            // Create array of promises for parallel fetching
            const fetchPromises = [];
            
            for (let day = 1; day <= lastDay.getDate(); day++) {
                const date = new Date(year, month, day);
                date.setHours(0, 0, 0, 0);
                
                // Skip past dates (including today)
                if (date < tomorrow) {
                    continue;
                }
                
                const dateString = this.formatDate(date);
                
                // Skip if already cached
                if (this.availabilityCache[dateString] && this.availabilityCache[dateString] !== 'fetching') {
                    continue;
                }

                // Add to batch fetch
                fetchPromises.push(
                    this.checkDateAvailability(date).then(availability => {
                        this.availabilityCache[dateString] = availability;
                        this.updateDateCell(dateString, availability);
                    }).catch(err => {
                        console.warn(`Failed to check availability for ${dateString}:`, err);
                        // Default to available on error
                        this.availabilityCache[dateString] = { hasCounselors: true, fullyBooked: false };
                    })
                );
            }

            // Wait for all availability checks to complete
            await Promise.all(fetchPromises);
            this.availabilityCache[monthKey] = 'fetched';
            
        } catch (error) {
            console.error('Error fetching month availability:', error);
            this.availabilityCache[monthKey] = 'error';
        }
    }

    /**
     * Check if a specific date has availability
     * Supports both student and counselor roles
     */
    async checkDateAvailability(date) {
        const dateString = this.formatDate(date);
        const dayOfWeek = this.getDayOfWeek(date);

        try {
            // Counselor role - check their own availability
            if (this.userRole === 'counselor') {
                return await this.checkCounselorOwnAvailability(dateString, dayOfWeek);
            }

            // Student role - check counselor schedules
            // 1. Check if any counselors are scheduled for this day of week
            const schedulesRes = await fetch(
                (window.BASE_URL || '/') + 'student/get-counselor-schedules',
                {
                    method: 'GET',
                    credentials: 'include',
                    headers: { 'Accept': 'application/json' }
                }
            );

            if (!schedulesRes.ok) {
                return { hasCounselors: true, fullyBooked: false }; // Optimistic fallback
            }

            const schedulesData = await schedulesRes.json();
            const schedules = schedulesData?.schedules || {};
            const daySchedules = schedules[dayOfWeek] || [];

            if (daySchedules.length === 0) {
                return { hasCounselors: false, fullyBooked: false };
            }

            // 2. Check if ALL counselors have ALL their slots booked for this specific date
            // We need to check each counselor individually - only mark as fully booked if ALL counselors are fully booked
            
            // If filtering by specific counselor, check only that counselor
            if (this.counselorId && this.counselorId !== 'No preference') {
                const bookedRes = await fetch(
                    (window.BASE_URL || '/') + `student/appointments/booked-times?date=${dateString}` +
                    `&counselor_id=${this.counselorId}` +
                    (this.consultationType ? `&consultation_type=${this.consultationType}` : ''),
                    {
                        method: 'GET',
                        credentials: 'include',
                        headers: { 'Accept': 'application/json' }
                    }
                );

                if (!bookedRes.ok) {
                    return { hasCounselors: true, fullyBooked: false };
                }

                const bookedData = await bookedRes.json();
                const bookedSlots = bookedData?.booked || [];
                const availableSlots = this.generateTimeSlotsFromSchedules(daySchedules);
                const allBooked = availableSlots.length > 0 && availableSlots.every(slot => bookedSlots.includes(slot));

                return {
                    hasCounselors: true,
                    fullyBooked: allBooked,
                    availableSlots: availableSlots.length,
                    bookedSlots: bookedSlots.length
                };
            }

            // Check each counselor individually - only fully booked if ALL counselors are fully booked
            let allCounselorsFullyBooked = true;
            let totalAvailableSlots = 0;
            let totalBookedSlots = 0;

            // Group schedules by counselor_id to avoid counting duplicates
            const counselorSchedulesMap = new Map();
            daySchedules.forEach(schedule => {
                const counselorId = schedule.counselor_id;
                if (!counselorSchedulesMap.has(counselorId)) {
                    counselorSchedulesMap.set(counselorId, []);
                }
                counselorSchedulesMap.get(counselorId).push(schedule);
            });

            // Check each counselor's availability
            for (const [counselorId, counselorSchedules] of counselorSchedulesMap) {
                // Get booked times for this specific counselor
                const bookedRes = await fetch(
                    (window.BASE_URL || '/') + `student/appointments/booked-times?date=${dateString}` +
                    `&counselor_id=${counselorId}` +
                    (this.consultationType ? `&consultation_type=${this.consultationType}` : ''),
                    {
                        method: 'GET',
                        credentials: 'include',
                        headers: { 'Accept': 'application/json' }
                    }
                );

                if (!bookedRes.ok) {
                    // If we can't check, assume not fully booked (optimistic)
                    allCounselorsFullyBooked = false;
                    continue;
                }

                const bookedData = await bookedRes.json();
                const bookedSlots = bookedData?.booked || [];
                
                // Generate slots for this counselor
                const counselorSlots = this.generateTimeSlotsFromSchedules(counselorSchedules);
                totalAvailableSlots += counselorSlots.length;
                
                // Check if this counselor has any available slots
                const hasAvailableSlot = counselorSlots.some(slot => !bookedSlots.includes(slot));
                
                if (hasAvailableSlot) {
                    // At least one counselor has availability - date is NOT fully booked
                    allCounselorsFullyBooked = false;
                }
                
                // Count booked slots for this counselor
                const counselorBookedCount = counselorSlots.filter(slot => bookedSlots.includes(slot)).length;
                totalBookedSlots += counselorBookedCount;
            }

            return {
                hasCounselors: true,
                fullyBooked: allCounselorsFullyBooked,
                availableSlots: totalAvailableSlots,
                bookedSlots: totalBookedSlots
            };

        } catch (error) {
            console.error(`Error checking availability for ${dateString}:`, error);
            return { hasCounselors: true, fullyBooked: false }; // Optimistic fallback
        }
    }

    /**
     * Check counselor's own availability for a specific date
     * Used when userRole is 'counselor' to check their own schedule
     */
    async checkCounselorOwnAvailability(dateString, dayOfWeek) {
        try {
            // 1. Get counselor's own availability for this day of week
            const availabilityRes = await fetch(
                (window.BASE_URL || '/') + `counselor/follow-up/counselor-availability?date=${dateString}`,
                {
                    method: 'GET',
                    credentials: 'include',
                    headers: { 'Accept': 'application/json' }
                }
            );

            if (!availabilityRes.ok) {
                return { hasCounselors: true, fullyBooked: false }; // Optimistic fallback
            }

            const availabilityData = await availabilityRes.json();
            
            if (availabilityData.status !== 'success' || !availabilityData.time_slots || availabilityData.time_slots.length === 0) {
                // No schedule for this day
                return { hasCounselors: false, fullyBooked: false };
            }

            // 2. Get booked times for this counselor on this date
            const bookedRes = await fetch(
                (window.BASE_URL || '/') + `counselor/follow-up/booked-times?date=${dateString}`,
                {
                    method: 'GET',
                    credentials: 'include',
                    headers: { 'Accept': 'application/json' }
                }
            );

            if (!bookedRes.ok) {
                return { hasCounselors: true, fullyBooked: false }; // Optimistic fallback
            }

            const bookedData = await bookedRes.json();
            const bookedSlots = bookedData?.booked || [];

            // 3. Generate all possible 30-minute slots from counselor's time_scheduled
            const availableSlots = this.generateTimeSlotsFromCounselorTimeScheduled(availabilityData.time_slots);
            
            // 4. Check if all slots are booked
            const allBooked = availableSlots.length > 0 && availableSlots.every(slot => bookedSlots.includes(slot));

            return {
                hasCounselors: true,
                fullyBooked: allBooked,
                availableSlots: availableSlots.length,
                bookedSlots: bookedSlots.length
            };

        } catch (error) {
            console.error(`Error checking counselor own availability for ${dateString}:`, error);
            return { hasCounselors: true, fullyBooked: false }; // Optimistic fallback
        }
    }

    /**
     * Generate 30-minute time slots from counselor time_scheduled strings
     * Used for counselor role - time_slots is array of strings like "8:00 AM - 12:00 PM"
     */
    generateTimeSlotsFromCounselorTimeScheduled(timeSlots) {
        const slots = new Set();

        timeSlots.forEach(timeScheduled => {
            if (!timeScheduled) return;

            // Split multiple time ranges (e.g., "8:00 AM - 12:00 PM, 1:00 PM - 5:00 PM")
            const ranges = timeScheduled.split(',').map(r => r.trim());

            ranges.forEach(range => {
                if (range.includes('-')) {
                    const [start, end] = range.split('-').map(t => t.trim());
                    const startMinutes = this.parseTime12ToMinutes(start);
                    const endMinutes = this.parseTime12ToMinutes(end);

                    if (startMinutes !== null && endMinutes !== null && endMinutes > startMinutes) {
                        // Generate 30-minute slots
                        for (let t = startMinutes; t + 30 <= endMinutes; t += 30) {
                            const slotStart = this.formatMinutesTo12h(t);
                            const slotEnd = this.formatMinutesTo12h(t + 30);
                            slots.add(`${slotStart} - ${slotEnd}`);
                        }
                    }
                }
            });
        });

        return Array.from(slots).sort((a, b) => {
            const aStart = this.parseTime12ToMinutes(a.split('-')[0].trim());
            const bStart = this.parseTime12ToMinutes(b.split('-')[0].trim());
            return aStart - bStart;
        });
    }

    /**
     * Generate 30-minute time slots from counselor schedules
     */
    generateTimeSlotsFromSchedules(schedules) {
        const slots = new Set();

        schedules.forEach(schedule => {
            const timeScheduled = schedule.time_scheduled;
            if (!timeScheduled) return;

            // Split multiple time ranges (e.g., "8:00 AM - 12:00 PM, 1:00 PM - 5:00 PM")
            const ranges = timeScheduled.split(',').map(r => r.trim());

            ranges.forEach(range => {
                if (range.includes('-')) {
                    const [start, end] = range.split('-').map(t => t.trim());
                    const startMinutes = this.parseTime12ToMinutes(start);
                    const endMinutes = this.parseTime12ToMinutes(end);

                    if (startMinutes !== null && endMinutes !== null && endMinutes > startMinutes) {
                        // Generate 30-minute slots
                        for (let t = startMinutes; t + 30 <= endMinutes; t += 30) {
                            const slotStart = this.formatMinutesTo12h(t);
                            const slotEnd = this.formatMinutesTo12h(t + 30);
                            slots.add(`${slotStart} - ${slotEnd}`);
                        }
                    }
                }
            });
        });

        return Array.from(slots).sort((a, b) => {
            const aStart = this.parseTime12ToMinutes(a.split('-')[0].trim());
            const bStart = this.parseTime12ToMinutes(b.split('-')[0].trim());
            return aStart - bStart;
        });
    }

    /**
     * Parse 12-hour time to minutes since midnight
     */
    parseTime12ToMinutes(timeStr) {
        if (!timeStr) return null;
        const match = timeStr.trim().match(/^(\d{1,2}):(\d{2})\s*(AM|PM)$/i);
        if (!match) return null;

        let hour = parseInt(match[1], 10);
        const minute = parseInt(match[2], 10);
        const ampm = match[3].toUpperCase();

        if (hour === 12) hour = 0;
        if (ampm === 'PM') hour += 12;

        return hour * 60 + minute;
    }

    /**
     * Format minutes since midnight to 12-hour time
     */
    formatMinutesTo12h(totalMinutes) {
        const minutes = totalMinutes % 60;
        let hour24 = Math.floor(totalMinutes / 60) % 24;
        const ampm = hour24 >= 12 ? 'PM' : 'AM';
        let hour12 = hour24 % 12;
        if (hour12 === 0) hour12 = 12;
        const mm = String(minutes).padStart(2, '0');
        return `${hour12}:${mm} ${ampm}`;
    }

    /**
     * Get day of week from date
     */
    getDayOfWeek(date) {
        const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        return days[date.getDay()];
    }

    /**
     * Select a date from the calendar
     */
    selectDate(date) {
        const dateString = this.formatDate(date);
        this.input.value = dateString;
        
        // Trigger change event
        const event = new Event('change', { bubbles: true });
        this.input.dispatchEvent(event);

        // Call custom callback if provided
        if (this.onDateSelect) {
            this.onDateSelect(dateString);
        }

        this.closeCalendar();
    }

    /**
     * Validate manually entered date
     */
    validateInputDate() {
        if (!this.input.value) return;

        const inputDate = new Date(this.input.value + 'T00:00:00');
        const tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        tomorrow.setHours(0, 0, 0, 0);

        // Check if date is before tomorrow
        if (inputDate < tomorrow) {
            alert('Please select a date starting from tomorrow.');
            this.setTomorrowAsMinimum();
        }
    }

    /**
     * Format date to YYYY-MM-DD
     */
    formatDate(date) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }

    /**
     * Check if two dates are the same day
     */
    isSameDate(date1, date2) {
        return date1.getFullYear() === date2.getFullYear() &&
               date1.getMonth() === date2.getMonth() &&
               date1.getDate() === date2.getDate();
    }

    /**
     * Update counselor filter (for dynamic filtering)
     */
    updateCounselorId(counselorId) {
        this.counselorId = counselorId;
        this.availabilityCache = {}; // Clear cache
        if (this.isOpen) {
            this.renderCalendar();
        }
    }

    /**
     * Update consultation type filter (for dynamic filtering)
     */
    updateConsultationType(consultationType) {
        this.consultationType = consultationType;
        this.availabilityCache = {}; // Clear cache
        if (this.isOpen) {
            this.renderCalendar();
        }
    }

    /**
     * Update a specific date cell with availability info (called after async fetch)
     */
    updateDateCell(dateString, availability) {
        if (!this.grid || !this.isOpen) return;

        // Find the date cell in the current grid
        const cells = this.grid.querySelectorAll('.custom-calendar-day');
        cells.forEach(cell => {
            const dateNumber = cell.querySelector('.date-number');
            if (!dateNumber) return;

            const cellDay = parseInt(dateNumber.textContent, 10);
            if (!cellDay) return;

            const cellDate = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth(), cellDay);
            const cellDateString = this.formatDate(cellDate);

            if (cellDateString === dateString && !cell.classList.contains('past-date')) {
                // Remove previous availability classes
                cell.classList.remove('no-counselors', 'fully-booked', 'available');

                if (!availability.hasCounselors) {
                    cell.classList.add('disabled', 'no-counselors');
                    cell.title = 'No counselors available on this date';
                    cell.style.cursor = 'not-allowed';
                } else if (availability.fullyBooked) {
                    cell.classList.add('disabled', 'fully-booked');
                    cell.title = 'All time slots are booked for this date';
                    cell.style.cursor = 'not-allowed';
                } else {
                    cell.classList.add('available');
                    cell.style.cursor = 'pointer';
                }
            }
        });
    }

    /**
     * Destroy the calendar picker and clean up
     */
    destroy() {
        if (this.popup) {
            this.popup.remove();
        }
        if (this.calendarButton) {
            this.calendarButton.remove();
        }
    }
}

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = CustomCalendarPicker;
}
