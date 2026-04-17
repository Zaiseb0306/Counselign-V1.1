// Store appointments globally
let pendingAppointments = [];

// Load pending feedback appointments when page loads
document.addEventListener('DOMContentLoaded', function() {
    loadPendingFeedbackAppointments();
});

async function loadPendingFeedbackAppointments() {
    const loadingIndicator = document.getElementById('loadingIndicator');
    const appointmentsTableContainer = document.getElementById('appointmentsTableContainer');
    const appointmentsTableBody = document.getElementById('appointmentsTableBody');
    const emptyState = document.getElementById('emptyState');

    try {
        const requestUrl = `${window.BASE_URL || '/'}counselor/pending-feedback/get-appointments`;
        const response = await fetch(requestUrl, {
            method: 'GET',
            credentials: 'include',
            headers: {
                Accept: 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
            },
        });

        if (!response.ok) {
            throw new Error(`Request failed with status ${response.status}`);
        }

        const data = await response.json();

        // Hide loading indicator
        loadingIndicator.classList.add('d-none');
        appointmentsTableContainer.classList.remove('d-none');

        if (data.status === 'success' && data.appointments && data.appointments.length > 0) {
            emptyState.classList.add('d-none');
            // Store appointments globally
            pendingAppointments = data.appointments;
            renderAppointmentsTable(data.appointments);
        } else {
            emptyState.classList.remove('d-none');
            pendingAppointments = [];
        }
    } catch (error) {
        console.error('Error loading pending feedback appointments:', error);
        loadingIndicator.classList.add('d-none');
        appointmentsTableContainer.classList.remove('d-none');
        emptyState.classList.remove('d-none');
        pendingAppointments = [];
    }
}

function renderAppointmentsTable(appointments) {
    const tableBody = document.getElementById('appointmentsTableBody');
    tableBody.innerHTML = '';

    appointments.forEach(appointment => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${appointment.student_name || 'N/A'}</td>
            <td>${formatDate(appointment.appointed_date)}</td>
            <td>${formatTime(appointment.appointed_time)}</td>
            <td>${appointment.purpose || 'N/A'}</td>
            <td>${appointment.session || 'N/A'}</td>
            <td><span class="badge bg-warning text-dark">${appointment.status}</span></td>
            <td>${appointment.remarks ? '<button class="btn btn-sm btn-info" onclick="viewRemarks(' + appointment.id + ')"><i class="fas fa-eye"></i></button>' : 'N/A'}</td>
            <td>
                <button class="btn btn-sm btn-primary" onclick="viewAppointmentDetails(${appointment.id})">
                    <i class="fas fa-envelope"></i> Send Appointment Reminder
                </button>
            </td>
        `;
        tableBody.appendChild(row);
    });
}

function formatDate(dateString) {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    });
}

function formatTime(timeString) {
    if (!timeString) return 'N/A';
    // Format time as HH:MM AM/PM
    const [hours, minutes] = timeString.split(':');
    const hour = parseInt(hours);
    const ampm = hour >= 12 ? 'PM' : 'AM';
    const formattedHour = hour % 12 || 12;
    return `${formattedHour}:${minutes} ${ampm}`;
}

function viewRemarks(appointmentId) {
    console.log('viewRemarks called with appointmentId:', appointmentId, 'type:', typeof appointmentId);
    console.log('Global pendingAppointments:', pendingAppointments);
    console.log('Appointment IDs in array:', pendingAppointments.map(app => ({ id: app.id, type: typeof app.id })));
    
    // Find appointment data from the global appointments array
    const appointmentData = pendingAppointments.find(app => app.id == appointmentId);
    console.log('Found appointment data:', appointmentData);
    
    if (appointmentData) {
        document.getElementById('modalStudentName').textContent = appointmentData.student_name || 'N/A';
        document.getElementById('modalDate').textContent = formatDate(appointmentData.appointed_date) + ' at ' + formatTime(appointmentData.appointed_time);
        document.getElementById('modalRemarks').textContent = appointmentData.remarks || 'No remarks available';
        
        console.log('Modal element:', document.getElementById('viewRemarksModal'));
        const modal = new bootstrap.Modal(document.getElementById('viewRemarksModal'));
        console.log('Modal created:', modal);
        modal.show();
    } else {
        console.error('Appointment not found with ID:', appointmentId);
        alert('Appointment not found');
    }
}

async function fetchAppointmentDetails(appointmentId) {
    try {
        const requestUrl = `${window.BASE_URL || '/'}counselor/appointments/getAll`;
        const response = await fetch(requestUrl, {
            method: 'GET',
            credentials: 'include',
            headers: {
                Accept: 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
            },
        });

        if (!response.ok) {
            throw new Error(`Request failed with status ${response.status}`);
        }

        const data = await response.json();
        
        if (data.status === 'success' && data.appointments) {
            return data.appointments.filter(app => app.id === appointmentId);
        }
        return [];
    } catch (error) {
        console.error('Error fetching appointment details:', error);
        return [];
    }
}

async function viewAppointmentDetails(appointmentId) {
    console.log('viewAppointmentDetails called with appointmentId:', appointmentId);
    
    // Get the button that was clicked
    const button = event.target.closest('button');
    const originalText = button.innerHTML;
    
    // Add loading state
    button.disabled = true;
    button.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Sending...';
    
    try {
        // Send reminder email first
        const response = await fetch(`${window.BASE_URL || '/'}counselor/pending-feedback/send-reminder`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest',
            },
            body: `appointment_id=${appointmentId}`,
            credentials: 'include'
        });

        console.log('Response status:', response.status);
        
        const data = await response.json();
        console.log('Response data:', data);
        
        // Reset button state
        button.disabled = false;
        button.innerHTML = originalText;
        
        if (data.status === 'success') {
            // Show success modal
            const modal = new bootstrap.Modal(document.getElementById('emailSentModal'));
            modal.show();
        } else {
            console.error('Failed to send reminder email:', data.message);
            alert('Failed to send reminder email: ' + data.message);
        }
    } catch (error) {
        console.error('Error sending reminder email:', error);
        
        // Reset button state on error
        button.disabled = false;
        button.innerHTML = originalText;
        
        alert('Error sending reminder email: ' + error.message);
    }
}

function confirmLogout() {
    if (confirm('Are you sure you want to logout?')) {
        window.location.href = `${window.BASE_URL || '/'}auth/logout`;
    }
}
