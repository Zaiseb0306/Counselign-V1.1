// Load notification history when page loads
document.addEventListener('DOMContentLoaded', function() {
    loadNotificationHistory();
});

async function loadNotificationHistory() {
    const loadingIndicator = document.getElementById('loadingIndicator');
    const notificationsListContainer = document.getElementById('notificationsListContainer');
    const notificationsList = document.getElementById('notificationsList');
    const emptyState = document.getElementById('emptyState');

    try {
        const requestUrl = `${window.BASE_URL || '/'}student/notifications/get-history`;
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
        notificationsListContainer.classList.remove('d-none');

        if (data.status === 'success' && data.notifications && data.notifications.length > 0) {
            emptyState.classList.add('d-none');
            renderNotifications(data.notifications);
        } else {
            emptyState.classList.remove('d-none');
        }
    } catch (error) {
        console.error('Error loading notification history:', error);
        loadingIndicator.classList.add('d-none');
        notificationsListContainer.classList.remove('d-none');
        emptyState.classList.remove('d-none');
    }
}

function renderNotifications(notifications) {
    const notificationsList = document.getElementById('notificationsList');
    notificationsList.innerHTML = '';

    notifications.forEach(notification => {
        const notificationCard = document.createElement('div');
        notificationCard.className = 'card mb-3 shadow-sm';
        
        // Only show delete button if notification has an ID (from notifications table)
        // Events and announcements from notification_reads have null ID and cannot be deleted
        const deleteButton = notification.id ? 
            `<button class="btn btn-sm btn-outline-danger ms-3" onclick="deleteNotification(${notification.id})" title="Delete notification">
                <i class="fas fa-trash"></i>
            </button>` : '';
        
        notificationCard.innerHTML = `
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-start">
                    <div class="flex-grow-1">
                        <h5 class="card-title mb-2">
                            ${getNotificationIcon(notification.type)}
                            ${notification.title || 'Notification'}
                        </h5>
                        <p class="card-text mb-2">${notification.message || ''}</p>
                        <small class="text-muted">
                            <i class="fas fa-clock me-1"></i>
                            ${formatDate(notification.created_at)}
                        </small>
                    </div>
                    ${deleteButton}
                </div>
            </div>
        `;
        notificationsList.appendChild(notificationCard);
    });
}

function getNotificationIcon(type) {
    switch (type) {
        case 'message':
            return '<i class="fas fa-envelope text-primary me-2"></i>';
        case 'appointment':
            return '<i class="fas fa-calendar text-success me-2"></i>';
        case 'event':
            return '<i class="fas fa-calendar-alt text-warning me-2"></i>';
        case 'announcement':
            return '<i class="fas fa-bullhorn text-info me-2"></i>';
        default:
            return '<i class="fas fa-bell text-secondary me-2"></i>';
    }
}

function formatDate(dateString) {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

async function deleteNotification(notificationId) {
    if (!confirm('Are you sure you want to delete this notification?')) {
        return;
    }

    try {
        const requestUrl = `${window.BASE_URL || '/'}student/notifications/delete`;
        const response = await fetch(requestUrl, {
            method: 'POST',
            credentials: 'include',
            headers: {
                'Content-Type': 'application/json',
                Accept: 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
            },
            body: JSON.stringify({ notification_id: notificationId }),
        });

        const data = await response.json();

        if (data.status === 'success') {
            // Reload the notification history
            loadNotificationHistory();
        } else {
            alert('Failed to delete notification: ' + (data.message || 'Unknown error'));
        }
    } catch (error) {
        console.error('Error deleting notification:', error);
        alert('Failed to delete notification. Please try again.');
    }
}

function confirmLogout() {
    if (confirm('Are you sure you want to logout?')) {
        window.location.href = `${window.BASE_URL || '/'}auth/logout`;
    }
}
