function resolveImageUrl(path) {
  if (!path) return (window.BASE_URL || "/") + "Photos/profile.png";
  const trimmed = String(path).trim();
  if (/^https?:\/\//i.test(trimmed)) return trimmed;
  if (trimmed.startsWith("/")) return trimmed;
  return (window.BASE_URL || "/") + trimmed;
}

// Calculate online status based on last_activity, last_login, and logout_time
function calculateOnlineStatus(lastActivity, lastLogin, logoutTime) {
  // Get all available times
  const activityTime = lastActivity ? new Date(lastActivity) : null;
  const loginTime = lastLogin ? new Date(lastLogin) : null;
  const logoutTimeDate = logoutTime ? new Date(logoutTime) : null;

  // Check if logout_time equals last_activity (exact match)
  if (
    logoutTimeDate &&
    activityTime &&
    logoutTimeDate.getTime() === activityTime.getTime()
  ) {
    return {
      status: "offline",
      text: "Offline",
      class: "status-offline",
    };
  }

  // Find the most recent time between last_activity and last_login
  let mostRecentTime = null;

  if (activityTime && loginTime) {
    // Use the more recent of the two
    mostRecentTime = activityTime > loginTime ? activityTime : loginTime;
  } else if (activityTime) {
    mostRecentTime = activityTime;
  } else if (loginTime) {
    mostRecentTime = loginTime;
  }

  if (!mostRecentTime) {
    return {
      status: "offline",
      text: "Offline",
      class: "status-offline",
    };
  }

  const now = new Date();
  const diffInMinutes = Math.floor((now - mostRecentTime) / (1000 * 60));

  if (diffInMinutes <= 5) {
    return {
      status: "online",
      text: "Online",
      class: "status-online",
    };
  } else if (diffInMinutes <= 60) {
    return {
      status: "active",
      text: `Last active ${diffInMinutes}m ago`,
      class: "status-active-recent",
    };
  } else {
    return {
      status: "offline",
      text: "Offline",
      class: "status-offline",
    };
  }
}
document.addEventListener("DOMContentLoaded", function () {
  // Initialize lastMessageId and isTyping
  let lastMessageId = 0;
  let isTyping = false;

  // Get references to all necessary elements
  const header = document.querySelector("header");
  const homeLink = document.querySelector("nav ul li:first-child a");
  const appointmentBtn = document.getElementById("appointmentBtn");
  const appointmentForm = document.getElementById("appointmentForm");
  const cancelAppointmentBtn = document.getElementById("cancelAppointmentBtn");
  const welcomeSection = document.querySelector(".content-panel h3");
  const welcomeQuote = document.querySelector(".content-panel p");
  const openChatBtn = document.getElementById("openChatBtn");
  const chatPopup = document.getElementById("chatPopup");
  const closeChat = document.getElementById("closeChat");
  const main = document.querySelector("main");
  const notificationIcon = document.getElementById("notificationIcon");
  const notificationsDropdown = document.getElementById(
    "notificationsDropdown"
  );
  const notificationBadge = document.getElementById("notificationBadge");
  const profileAvatar = document.querySelector(".profile-avatar");
  const navbarDrawerToggler = document.getElementById("navbarDrawerToggler");
  const navbarDrawer = document.getElementById("navbarDrawer");
  const navbarDrawerClose = document.getElementById("navbarDrawerClose");
  const navbarOverlay = document.getElementById("navbarOverlay");

  // Make header sticky on scroll
  if (header) {
    window.addEventListener("scroll", function () {
      if (window.scrollY > 0) {
        header.classList.add("sticky-header");
      } else {
        header.classList.remove("sticky-header");
      }
    });
  }

  // Remove the placeholder div code completely, as it's causing the jumping

  // Initially hide the appointment form
  if (appointmentForm) {
    appointmentForm.style.display = "none";
  }

  // Initially hide the chat popup
  if (chatPopup) {
    chatPopup.style.display = "none";
  }

  // Click animations for chat and notifications
  const openChatBtnEl = document.getElementById("openChatBtn");
  if (openChatBtnEl) {
    openChatBtnEl.addEventListener("click", function () {
      openChatBtnEl.classList.remove("chat-click");
      void openChatBtnEl.offsetWidth;
      openChatBtnEl.classList.add("chat-click");
    });
  }
  if (notificationIcon) {
    notificationIcon.addEventListener("click", function (e) {
      notificationIcon.classList.remove("bell-click");
      void notificationIcon.offsetWidth;
      notificationIcon.classList.add("bell-click");
    });
  }

  // Home link - make it functional to navigate to user_dashboard.html
  if (homeLink) {
    homeLink.addEventListener("click", function (e) {
      // Check if we're already on the dashboard page
      if (
        window.location.pathname.includes("user_dashboard.html") ||
        window.location.pathname.endsWith("/") ||
        window.location.pathname === ""
      ) {
        // If we're on dashboard, just reset the view
        e.preventDefault();

        // Reset dashboard view
        if (appointmentForm) appointmentForm.style.display = "none";
        if (welcomeSection) welcomeSection.style.display = "block";
        if (welcomeQuote) welcomeQuote.style.display = "block";
        if (chatPopup) chatPopup.style.display = "none";

        // Scroll to top
        window.scrollTo(0, 0);
      }
    });
  }

  // Appointment button - show form and hide welcome
  if (appointmentBtn) {
    appointmentBtn.addEventListener("click", function () {
      if (appointmentForm) {
        appointmentForm.style.display = "block";

        // Hide welcome section
        if (welcomeSection) welcomeSection.style.display = "none";
        if (welcomeQuote) welcomeQuote.style.display = "none";

        // Scroll to appointment form
        appointmentForm.scrollIntoView({ behavior: "smooth" });
      }
    });
  }

  // Cancel button - hide form and show welcome
  if (cancelAppointmentBtn) {
    cancelAppointmentBtn.addEventListener("click", function () {
      if (appointmentForm) {
        appointmentForm.style.display = "none";

        // Show welcome section again
        if (welcomeSection) welcomeSection.style.display = "block";
        if (welcomeQuote) welcomeQuote.style.display = "block";
      }
    });
  }

  // Chat functionality
  let messageUpdateInterval = null;
  let userId = null; // Will store the user's ID
  let selectedStudentId = null; // Will store the selected student ID
  let selectedStudentName = null; // Will store the selected student name

  // Student selection modal elements
  const studentSelectionModal = document.getElementById(
    "studentSelectionModal"
  );
  const closeStudentSelection = document.getElementById(
    "closeStudentSelection"
  );
  const studentSearchInput = document.getElementById("studentSearchInput");
  const studentList = document.getElementById("studentList");
  const messagesCard = document.getElementById("messagesCard");

  // Notification handling
  function initializeNotifications() {
    const notificationIcon = document.getElementById("notificationIcon");
    const notificationsDropdown = document.getElementById(
      "notificationsDropdown"
    );
    const notificationBadge = document.getElementById("notificationBadge");

    if (notificationIcon && notificationsDropdown) {
      notificationsDropdown.style.display = "none";

      notificationIcon.addEventListener("click", function (e) {
        e.stopPropagation();
        if (
          notificationsDropdown.style.display === "none" ||
          !notificationsDropdown.style.display
        ) {
          const iconRect = notificationIcon.getBoundingClientRect();
          const dropdownWidth = Math.min(320, window.innerWidth - 20);
          let right = window.innerWidth - iconRect.right;
          if (right + dropdownWidth > window.innerWidth) {
            right = 10;
          }
          notificationsDropdown.style.top =
            Math.min(
              iconRect.bottom + window.scrollY + 10,
              window.scrollY +
                window.innerHeight -
                notificationsDropdown.offsetHeight -
                10
            ) + "px";
          notificationsDropdown.style.right = right + "px";
          notificationsDropdown.style.display = "block";
          loadNotifications();
        } else {
          notificationsDropdown.style.display = "none";
        }
      });

      document.addEventListener("click", function (e) {
        if (
          notificationsDropdown.style.display === "block" &&
          !notificationsDropdown.contains(e.target) &&
          e.target !== notificationIcon
        ) {
          notificationsDropdown.style.display = "none";
        }
      });

      notificationsDropdown.addEventListener("click", function (e) {
        e.stopPropagation();
      });

      window.addEventListener("resize", function () {
        if (notificationsDropdown.style.display === "block") {
          const iconRect = notificationIcon.getBoundingClientRect();
          const dropdownWidth = Math.min(320, window.innerWidth - 20);
          let right = window.innerWidth - iconRect.right;
          if (right + dropdownWidth > window.innerWidth) {
            right = 10;
          }
          notificationsDropdown.style.right = right + "px";
          notificationsDropdown.style.width = dropdownWidth + "px";
        }
      });
    }
  }

  function updateNotificationCounter(count) {
    const notificationBadge = document.getElementById("notificationBadge");
    if (notificationBadge) {
      if (count > 0) {
        notificationBadge.textContent = count;
        notificationBadge.style.display = "inline-block";
        notificationBadge.classList.remove("hidden");
      } else {
        notificationBadge.textContent = "";
        notificationBadge.style.display = "none";
        notificationBadge.classList.add("hidden");
      }
    }
  }

  function fetchNotificationCount() {
    // Align the badge count with the currently displayable items from the same source
    fetch(window.BASE_URL + "counselor/notifications")
      .then((response) => response.json())
      .then((data) => {
        if (data.status === "success") {
          const notifications = Array.isArray(data.notifications)
            ? data.notifications
            : [];
          updateNotificationCounter(notifications.length);
        }
      })
      .catch((error) => {
        console.error("Error fetching notification count:", error);
      });
  }

  function loadNotifications() {
    fetch(window.BASE_URL + "counselor/notifications")
      .then((response) => response.json())
      .then((data) => {
        if (data.status === "success") {
          const notifications = Array.isArray(data.notifications)
            ? data.notifications
            : [];
          // Apply client-side expiration filtering
          const filteredNotifications =
            filterExpiredNotifications(notifications);
          renderNotifications(filteredNotifications);
          updateNotificationCounter(filteredNotifications.length);
        } else {
          showEmptyNotifications("Failed to load notifications");
        }
      })
      .catch((error) => {
        showEmptyNotifications("Unable to connect to server");
      });
  }

  // Filter out expired notifications on the client side
  function filterExpiredNotifications(notifications) {
    const now = new Date();
    return notifications.filter((notification) => {
      // Check if event has passed
      if (notification.type === "event" && notification.event_date) {
        const eventDate = new Date(notification.event_date);
        return eventDate > now;
      }
      // Check if appointment has passed (keep for 7 days after appointment date)
      if (
        notification.type === "appointment" &&
        notification.appointment_date
      ) {
        const appointmentDate = new Date(notification.appointment_date);
        const sevenDaysAfter = new Date(
          appointmentDate.getTime() + 7 * 24 * 60 * 60 * 1000
        );
        return sevenDaysAfter > now;
      }
      // Keep all other notification types (announcements, messages)
      return true;
    });
  }

  function renderNotifications(notifications = []) {
    const notificationsContainer = document.querySelector(
      ".notifications-list"
    );
    if (!notificationsContainer) return;
    if (!notifications || notifications.length === 0) {
      showEmptyNotifications("No notifications");
      return;
    }
    notificationsContainer.innerHTML = "";
    notifications.forEach((notification) => {
      if (!notification) return;
      const notificationItem = document.createElement("div");
      notificationItem.className = "notification-item";
      if (!notification.is_read) {
        notificationItem.classList.add("unread");
      }
      const notifDate = new Date(notification.created_at);
      const formattedDate =
        notifDate.toLocaleDateString() + " " + notifDate.toLocaleTimeString();
      // Show mark as read button for all notification types if not already read
      // For events and announcements, check if they're already marked as read
      let showMarkReadBtn = false;
      if (notification.is_read === 0 || notification.is_read === false || notification.is_read === '0') {
        showMarkReadBtn = true;
      } else if (notification.type === 'event' || notification.type === 'announcement') {
        // Events and announcements don't have is_read in the notification object
        // They're considered unread if they appear in the list
        showMarkReadBtn = true;
      }
      
      const markReadBtn = showMarkReadBtn ? `
                <button class="btn btn-sm btn-outline-primary mark-read-btn" data-notification-id="${notification.id || ''}" data-type="${notification.type || ''}" data-related-id="${notification.related_id || ''}" title="Mark as read">
                    <i class="fas fa-check"></i>
                </button>
            ` : '';
      
      notificationItem.innerHTML = `
                <div class="notification-header">
                    <h4>${notification.title || "Notification"}</h4>
                    <div class="notification-actions">
                        <span class="notification-time">${formattedDate}</span>
                        ${markReadBtn}
                    </div>
                </div>
                <p>${notification.message || ""}</p>
            `;
      
      // Add click handler for mark as read button
      const markReadButton = notificationItem.querySelector('.mark-read-btn');
      if (markReadButton) {
        markReadButton.addEventListener('click', function(e) {
          e.stopPropagation();
          e.preventDefault();
          const notificationId = markReadButton.dataset.notificationId || notification.id || null;
          const notificationType = markReadButton.dataset.type || notification.type || null;
          const relatedId = markReadButton.dataset.relatedId || notification.related_id || null;
          
          markNotificationAsRead(notificationId, notificationType, relatedId);
          notificationItem.classList.remove('unread');
          notification.is_read = 1;
          markReadButton.remove();
          fetchNotificationCount();
          loadNotifications(); // Reload to update the list
        });
      }
      
      notificationItem.addEventListener("click", function () {
        // Hide notifications dropdown first
        const notificationsDropdown = document.getElementById(
          "notificationsDropdown"
        );
        if (notificationsDropdown) {
          notificationsDropdown.style.display = "none";
        }

        if (!notification.is_read) {
          markNotificationAsRead(notification.id);
          notificationItem.classList.remove("unread");
          notification.is_read = true;
          fetchNotificationCount();
        }
        // Handle navigation based on notification type
        if (notification.type === "appointment") {
          // Reuse student modal behavior for appointment details; fetch counselor appointments too
          showCounselorAppointmentDetailsModal(notification.related_id);
        } else if (
          notification.type === "event" ||
          notification.type === "announcement"
        ) {
          window.location.href = window.BASE_URL + "counselor/announcements";
        } else if (notification.type === "message") {
          // Open chat popup
          const openChatBtn = document.getElementById("openChatBtn");
          if (openChatBtn) openChatBtn.click();
        }
      });
      notificationsContainer.appendChild(notificationItem);
    });
  }

  // Counselor Appointment Details Modal (mirrors student modal but adds a Go To Appointments button)
  function showCounselorAppointmentDetailsModal(appointmentId) {
    const notificationsDropdown = document.getElementById(
      "notificationsDropdown"
    );
    if (
      notificationsDropdown &&
      notificationsDropdown.style.display === "block"
    ) {
      notificationsDropdown.style.display = "none";
    }
    fetch(window.BASE_URL + "counselor/appointments/getAppointments")
      .then((response) => response.json())
      .then((data) => {
        const body = document.getElementById("appointmentDetailsBody");
        if (!body) return;
        if (data && data.appointments) {
          const appointment = (data.appointments || []).find(
            (app) => String(app.id) === String(appointmentId)
          );
          if (appointment) {
            const getStatusBadge = (status) => {
              const statusLower = String(status || "").toLowerCase();
              let badgeClass = "bg-secondary";
              if (statusLower === "rejected") badgeClass = "bg-danger";
              else if (statusLower === "pending") badgeClass = "bg-warning";
              else if (statusLower === "completed") badgeClass = "bg-primary";
              else if (statusLower === "approved") badgeClass = "bg-success";
              else if (statusLower === "cancelled") badgeClass = "bg-secondary";
              return `<span class="badge ${badgeClass}">${status}</span>`;
            };
            body.innerHTML = `
                        <strong>Date:</strong> ${appointment.preferred_date}<br>
                        <strong>Time:</strong> ${appointment.preferred_time}<br>
                        <strong>Status:</strong> ${getStatusBadge(
                          appointment.status
                        )}<br>
                        <strong>Student:</strong> ${
                          appointment.student_name || appointment.username || appointment.student_id
                        }<br>
                        <strong>Method:</strong> ${
                          appointment.method_type || "N/A"
                        }<br>
                        <strong>Purpose:</strong> ${
                          appointment.purpose || "N/A"
                        }<br>
                        <strong>Description:</strong> ${
                          appointment.description || ""
                        }<br>
                    `;
            const modalEl = document.getElementById("appointmentDetailsModal");
            if (modalEl) {
              const footer = modalEl.querySelector(".modal-footer");
              if (
                footer &&
                !footer.querySelector("#goToCounselorAppointments")
              ) {
                const btn = document.createElement("a");
                btn.id = "goToCounselorAppointments";
                btn.className = "btn btn-primary";
                btn.href = (window.BASE_URL || "/") + "counselor/appointments";
                btn.textContent = "Go to Appointments";
                footer.appendChild(btn);
              }
              const modal = new bootstrap.Modal(modalEl);
              modal.show();
            }
          } else {
            body.innerHTML = "Appointment not found.";
          }
        } else {
          if (body) body.innerHTML = "Failed to load appointment details.";
        }
      })
      .catch(() => {
        const body = document.getElementById("appointmentDetailsBody");
        if (body) body.innerHTML = "Error loading appointment details.";
      });
  }

  function markNotificationAsRead(notificationId, notificationType, relatedId) {
    const payload = {};
    if (notificationId) {
      payload.notification_id = notificationId;
    } else if (notificationType && relatedId) {
      payload.type = notificationType;
      payload.related_id = relatedId;
    } else {
      console.error('Invalid parameters for markNotificationAsRead');
      return;
    }
    
    fetch(window.BASE_URL + "counselor/notifications/mark-read", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.status !== "success") {
          console.error("Error marking notification as read:", data.message);
        }
      })
      .catch((error) => {
        console.error("Error marking notification as read:", error);
      });
  }
  
  // Add mark all as read functionality
const markAllReadBtn = document.getElementById('markAllReadBtn');
if (markAllReadBtn) {
    markAllReadBtn.addEventListener('click', function(e) {
        e.stopPropagation();
        e.preventDefault();
        
        // Get all notifications currently displayed in the modal
        const notificationsList = document.querySelector('.notifications-list');
        if (!notificationsList) return;
        
        const notificationItems = notificationsList.querySelectorAll('.notification-item');
        
        // Collect all notifications that need to be marked as read
        const notificationsToMark = [];
        
        notificationItems.forEach(item => {
            const markReadBtn = item.querySelector('.mark-read-btn');
            if (markReadBtn) {
                const notificationId = markReadBtn.dataset.notificationId || null;
                const notificationType = markReadBtn.dataset.type || null;
                const relatedId = markReadBtn.dataset.relatedId || null;
                
                if (notificationId || (notificationType && relatedId)) {
                    notificationsToMark.push({
                        notification_id: notificationId,
                        type: notificationType,
                        related_id: relatedId
                    });
                }
            }
        });
        
        // If no notifications to mark, just return
        if (notificationsToMark.length === 0) {
            return;
        }
        
        // Mark all notifications as read using the bulk endpoint
        fetch(window.BASE_URL + 'counselor/notifications/mark-read', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ mark_all: true })
        })
        .then(response => response.json())
        .then(data => {
            if (data.status === 'success') {
                // Now mark each individual notification based on its type
                const markPromises = notificationsToMark.map(notif => {
                    const payload = {};
                    
                    // Handle different notification types
                    if (notif.notification_id) {
                        payload.notification_id = notif.notification_id;
                    } else if (notif.type && notif.related_id) {
                        payload.type = notif.type;
                        payload.related_id = notif.related_id;
                    } else {
                        return Promise.resolve();
                    }
                    
                    return fetch(window.BASE_URL + 'counselor/notifications/mark-read', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(payload)
                    });
                });
                
                // Wait for all individual marks to complete
                return Promise.all(markPromises);
            } else {
                console.error('Error marking all notifications as read:', data.message);
                throw new Error(data.message);
            }
        })
        .then(() => {
            // Remove all mark-as-read buttons and unread classes
            notificationItems.forEach(item => {
                item.classList.remove('unread');
                const markReadBtn = item.querySelector('.mark-read-btn');
                if (markReadBtn) {
                    markReadBtn.remove();
                }
            });
            
            // Reload notifications to get fresh data
            loadNotifications();
            fetchNotificationCount();
        })
        .catch(error => {
            console.error('Error marking all notifications as read:', error);
        });
    });
}

  function showEmptyNotifications(message) {
    const notificationsContainer = document.querySelector(
      ".notifications-list"
    );
    if (notificationsContainer) {
      notificationsContainer.innerHTML = `<div class="empty-notifications"><p>${message}</p></div>`;
    }
  }

  // Real-time polling for notifications
  function startNotificationPolling() {
    fetchNotificationCount();
    setInterval(() => {
      fetchNotificationCount();
      loadNotifications();
    }, 10000); // every 10 seconds
  }

  // Modify fetchUserIdAndInitialize to also initialize notifications
  function fetchUserIdAndInitialize() {
    fetch(window.BASE_URL + "counselor/profile/get")
      .then((response) => response.json())
      .then((data) => {
        if (data.success && data.user_id) {
          userId = data.user_id;
          initializeChat();
          initializeNotifications();
          startNotificationPolling();
          // Update profile picture on dashboard
          const img = document.getElementById("profile-img");
          if (img) {
            const src = resolveImageUrl(data.profile_picture);
            img.src = src;
            try {
              localStorage.setItem("counselor_profile_picture", src);
            } catch (e) {}
          }

          // Update the user ID in the welcome message only if no display name exists
          const userIdSpan = document.querySelector(".text-primary i");
          const userDisplaySpan = document.getElementById("user-id-display");
          if (userIdSpan && !userDisplaySpan) {
            // Only update if there's no hidden user-id-display element (meaning no name was found)
            userIdSpan.textContent = data.user_id;
          }
        } else {
          console.error("Failed to get user ID");
        }
      })
      .catch((error) => {
        console.error("Error fetching user profile:", error);
      });
  }

  // Add this to counselor_dashboard.js
// Place it after the fetchUserIdAndInitialize() function call

  // ========== DAILY QUOTES CAROUSEL ==========
  
  function loadDailyQuotesCarousel() {
    fetch(window.BASE_URL + 'counselor/quotes/approved-quotes')
      .then(response => response.json())
      .then(data => {
        if (data.success && data.quotes && data.quotes.length > 0) {
          displayQuotesCarousel(data.quotes);
        } else {
          displayEmptyQuotesCarousel();
        }
      })
      .catch(error => {
        console.error('Error loading quotes carousel:', error);
        displayEmptyQuotesCarousel();
      });
  }
  
  // Update this function in counselor_dashboard.js

function displayQuotesCarousel(quotes) {
  const carouselInner = document.getElementById('quotesCarouselInner');
  
  if (!carouselInner) return;
  
  carouselInner.innerHTML = '';
  
  quotes.forEach((quote, index) => {
    // Create carousel item
    const carouselItem = document.createElement('div');
    carouselItem.className = `carousel-item ${index === 0 ? 'active' : ''}`;
    
    const categoryIcon = getCategoryIcon(quote.category);
    
    // Truncate long quotes for compact display
    const maxLength = 120;
    let displayText = quote.quote_text;
    if (displayText.length > maxLength) {
      displayText = displayText.substring(0, maxLength) + '...';
    }
    
    carouselItem.innerHTML = `
      <div class="quote-carousel-card" title="${escapeHtml(quote.quote_text)}">
        <div class="quote-carousel-text">${escapeHtml(displayText)}</div>
        <div class="quote-carousel-author">${escapeHtml(quote.author_name)}</div>
        <div class="quote-carousel-meta">
          <span class="quote-category-badge">${categoryIcon} ${escapeHtml(quote.category)}</span>
        </div>
      </div>
    `;
    
    carouselInner.appendChild(carouselItem);
  });
  
  // Reinitialize carousel
  const carouselElement = document.getElementById('dailyQuotesCarousel');
  if (carouselElement && typeof bootstrap !== 'undefined') {
    // Dispose existing carousel if any
    const existingCarousel = bootstrap.Carousel.getInstance(carouselElement);
    if (existingCarousel) {
      existingCarousel.dispose();
    }
    
    // Create new carousel instance
    new bootstrap.Carousel(carouselElement, {
      interval: 8000,
      wrap: true,
      keyboard: true,
      pause: 'hover'
    });
  }
}

function displayEmptyQuotesCarousel() {
  const carouselInner = document.getElementById('quotesCarouselInner');
  
  if (!carouselInner) return;
  
  carouselInner.innerHTML = `
    <div class="carousel-item active">
      <div class="quote-carousel-card">
        <div class="quote-empty-state">
          <i class="fas fa-quote-left"></i>
          <p class="mb-0">No quotes available yet.<br><small>Submit one to inspire students!</small></p>
        </div>
      </div>
    </div>
  `;
}
  
  
  // Load carousel on page load
  loadDailyQuotesCarousel();
  
  // Refresh carousel every 5 minutes
  setInterval(loadDailyQuotesCarousel, 5 * 60 * 1000);
  
  // ========== END DAILY QUOTES CAROUSEL ==========

  function initializeChat() {
    const messageForm = document.getElementById("messageForm");
    const messageInput = document.getElementById("messageInput");
    const messagesContainer = document.getElementById("messagesContainer");
    const chatPopup = document.getElementById("chatPopup");
    const openChatBtn = document.getElementById("openChatBtn");
    const closeChat = document.getElementById("closeChat");

    // Add console logs for debugging
    SecureLogger.info("Chat elements:", {
      messageForm,
      messageInput,
      messagesContainer,
      chatPopup,
      openChatBtn,
      closeChat,
    });

    if (openChatBtn && chatPopup) {
      openChatBtn.addEventListener("click", function (e) {
        e.preventDefault();
        e.stopPropagation();
        SecureLogger.info("Chat button clicked");
        chatPopup.style.display = "block";
        chatPopup.classList.add("visible");
        openChatBtn.classList.add("active"); // Add active class when chat is opened
        loadMessages();
        startMessagePolling();
      });
    }

    if (closeChat && chatPopup) {
      closeChat.addEventListener("click", function (e) {
        e.preventDefault();
        e.stopPropagation();
        chatPopup.classList.remove("visible");
        openChatBtn.classList.remove("active"); // Remove active class when chat is closed
        setTimeout(() => {
          chatPopup.style.display = "none";
        }, 300); // Match the transition duration
        stopMessagePolling();
      });
    }

    // Close chat when clicking outside
    document.addEventListener("click", function (e) {
      if (
        chatPopup &&
        chatPopup.style.display === "block" &&
        !chatPopup.contains(e.target) &&
        e.target !== openChatBtn
      ) {
        closeChat.click();
      }
    });

    // Prevent chat from closing when clicking inside
    if (chatPopup) {
      chatPopup.addEventListener("click", function (e) {
        e.stopPropagation();
      });
    }

    // Handle message submission
    if (messageForm) {
      messageForm.addEventListener("submit", function (e) {
        e.preventDefault();
        const message = messageInput.value.trim();
        if (message) {
          sendMessage(e);
        }
      });
    }

    // Handle enter key for sending message
    if (messageInput) {
      messageInput.addEventListener("keypress", function (e) {
        if (e.key === "Enter" && !e.shiftKey) {
          e.preventDefault();
          const message = messageInput.value.trim();
          if (message) {
            sendMessage(e);
          }
        }
      });
    }
  }

  function startMessagePolling() {
    loadMessages(); // Initial load
    messageUpdateInterval = setInterval(loadMessages, 5000); // Poll every 5 seconds
  }

  function stopMessagePolling() {
    if (messageUpdateInterval) {
      clearInterval(messageUpdateInterval);
      messageUpdateInterval = null;
    }
  }

  function loadMessages() {
    if (!userId) {
      console.error("User ID not available");
      return;
    }

    fetch(window.BASE_URL + "counselor/message/operations?action=get_messages")
      .then((response) => {
        if (!response.ok) {
          throw new Error("Network response was not ok");
        }
        return response.json();
      })
      .then((data) => {
        if (data.success) {
          displayMessages(data.messages || []);
        } else {
          console.error("Failed to load messages:", data.message);
          showSystemMessage("Unable to load messages. Please try again later.");
        }
      })
      .catch((error) => {
        console.error("Error:", error);
        showSystemMessage(
          "Error loading messages. Please check your connection."
        );
      });
  }

  function displayMessages(messages) {
    const container = document.getElementById("messagesContainer");
    if (!container) return;

    // If no messages, show welcome message
    if (!messages || messages.length === 0) {
      container.innerHTML = `
                <div class="system-message">
                    Welcome! Send a message to get started.
                </div>
            `;
      return;
    }

    // Sort messages by created_at
    messages.sort((a, b) => new Date(a.created_at) - new Date(b.created_at));

    // Track which messages are new
    const newMessages = messages.filter(
      (msg) => msg.message_id > lastMessageId
    );

    // Update lastMessageId
    if (messages.length > 0) {
      lastMessageId = Math.max(...messages.map((m) => m.message_id));
    }

    // Only update DOM if there are new messages
    if (newMessages.length > 0) {
      // Append new messages
      newMessages.forEach((message) => {
        const messageElement = createMessageElement(message);
        container.appendChild(messageElement);

        // Trigger fade-in animation
        requestAnimationFrame(() => {
          messageElement.style.opacity = "1";
          messageElement.style.transform = "translateY(0)";
        });
      });

      // Scroll to bottom smoothly
      scrollToBottom();
    }
  }

  function createMessageElement(message) {
    const div = document.createElement("div");
    div.className = `message-bubble ${
      message.sender_id === userId ? "sent" : "received"
    }`;
    div.style.opacity = "0";
    div.style.transform = "translateY(10px)";

    const messageText = document.createElement("div");
    messageText.className = "message-text";
    messageText.textContent = message.message_text;

    const timeDiv = document.createElement("div");
    timeDiv.className = "message-time";
    timeDiv.textContent = formatMessageTime(message.created_at);

    div.appendChild(messageText);
    div.appendChild(timeDiv);

    return div;
  }

  function formatMessageTime(timestamp) {
    const date = new Date(timestamp);
    const now = new Date();
    const diff = now - date;

    // If less than 24 hours ago, show time
    if (diff < 24 * 60 * 60 * 1000) {
      return date.toLocaleTimeString([], {
        hour: "2-digit",
        minute: "2-digit",
      });
    }
    // If this year, show date and time
    if (date.getFullYear() === now.getFullYear()) {
      return (
        date.toLocaleDateString([], { month: "short", day: "numeric" }) +
        " " +
        date.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })
      );
    }
    // If different year, show full date
    return date.toLocaleDateString([], {
      year: "numeric",
      month: "short",
      day: "numeric",
    });
  }

  function scrollToBottom() {
    const chatBody = document.querySelector(".chat-body");
    if (chatBody) {
      chatBody.scrollTop = chatBody.scrollHeight;
    }
  }

  function showTypingIndicator() {
    if (isTyping) return;

    const container = document.getElementById("messagesContainer");
    if (!container) return;

    isTyping = true;
    const indicator = document.createElement("div");
    indicator.className = "typing-indicator";
    indicator.id = "typingIndicator";
    indicator.innerHTML = `
            <span></span>
            <span></span>
            <span></span>
        `;

    container.appendChild(indicator);
    scrollToBottom();
  }

  function hideTypingIndicator() {
    const indicator = document.getElementById("typingIndicator");
    if (indicator) {
      indicator.remove();
    }
    isTyping = false;
  }

  function sendMessage(event) {
    event.preventDefault();

    if (!userId) {
      console.error("User ID not available");
      showSystemMessage("Unable to send message. Please try again.");
      return;
    }

    const messageInput = document.querySelector(".message-input");
    const message = messageInput.value.trim();

    if (!message) return;

    const sendButton = document.querySelector(".send-button");
    sendButton.disabled = true;

    showTypingIndicator();

    const formData = new FormData();
    formData.append("action", "send_message");
    formData.append("receiver_id", "admin123");
    formData.append("message", message);

    fetch(window.BASE_URL + "user/message/operations", {
      method: "POST",
      body: formData,
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error("Network response was not ok");
        }
        return response.json();
      })
      .then((data) => {
        if (data.success) {
          messageInput.value = "";
          loadMessages(); // Refresh messages
          // Show system message immediately
          showSystemMessage(
            "Message sent successfully. Please wait for a counselor to respond."
          );
        } else {
          console.error("Failed to send message:", data.message);
          showSystemMessage(
            data.message || "Failed to send message. Please try again."
          );
        }
      })
      .catch((error) => {
        console.error("Error sending message:", error);
        showSystemMessage(
          "An error occurred while sending the message. Please try again."
        );
      })
      .finally(() => {
        sendButton.disabled = false;
        hideTypingIndicator();
      });
  }

  function notifyAdmin(message) {
    // Send notification to admin page
    const notification = {
      type: "new_message",
      user_id: userId,
      message: message,
      timestamp: new Date().toISOString(),
    };

    // Store notification in database for admin
    fetch(window.BASE_URL + "admin/notify", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(notification),
    })
      .then((response) => response.json())
      .then((data) => {
        if (!data.success) {
          console.error("Failed to notify admin:", data.message);
        }
      })
      .catch((error) => {
        console.error("Error notifying admin:", error);
      });
  }

  function showSystemMessage(message) {
    const container = document.getElementById("messagesContainer");
    if (!container) return;

    const systemMessage = document.createElement("div");
    systemMessage.className = "system-message";
    systemMessage.textContent = message;

    container.appendChild(systemMessage);
    scrollToBottom();

    // Keep system message visible for 10 seconds before fading out
    setTimeout(() => {
      systemMessage.style.opacity = "0";
      setTimeout(() => {
        if (systemMessage.parentNode === container) {
          container.removeChild(systemMessage);
        }
      }, 300);
    }, 10000);
  }

  function showAppointmentDetailsModal(appointmentId) {
    // Hide notifications dropdown if open
    const notificationsDropdown = document.getElementById(
      "notificationsDropdown"
    );
    if (
      notificationsDropdown &&
      notificationsDropdown.style.display === "block"
    ) {
      notificationsDropdown.style.display = "none";
    }
    fetch(window.BASE_URL + "user/appointments/get-my-appointments")
      .then((response) => response.json())
      .then((data) => {
        if (data.success && data.appointments) {
          const appointment = data.appointments.find(
            (app) => app.id == appointmentId
          );
          if (appointment) {
            // Function to get status badge HTML
            const getStatusBadge = (status) => {
              const statusLower = status.toLowerCase();
              let badgeClass = "";
              switch (statusLower) {
                case "pending":
                  badgeClass = "bg-warning";
                  break;
                case "rejected":
                  badgeClass = "bg-danger";
                  break;
                case "completed":
                  badgeClass = "bg-primary";
                  break;
                case "approved":
                  badgeClass = "bg-success";
                  break;
                case "cancelled":
                  badgeClass = "bg-secondary";
                  break;
                default:
                  badgeClass = "bg-secondary";
              }
              return `<span class="badge ${badgeClass}">${status}</span>`;
            };

            document.getElementById("appointmentDetailsBody").innerHTML = `
                            <strong>Date:</strong> ${
                              appointment.preferred_date
                            }<br>
                            <strong>Time:</strong> ${
                              appointment.preferred_time
                            }<br>
                            <strong>Status:</strong> ${getStatusBadge(
                              appointment.status
                            )}<br>
                            <strong>Counselor Preference:</strong> ${
                              appointment.counselor_preference
                            }<br>
                            <strong>Consultation Type:</strong> ${
                              appointment.consultation_type || ""
                            }<br>
                            <strong>Description:</strong> ${
                              appointment.description || ""
                            }<br>
                            <strong>Reason:</strong> ${
                              appointment.reason || ""
                            }<br>

                            
                        `;
            // Show the modal (Bootstrap 5)
            const modal = new bootstrap.Modal(
              document.getElementById("appointmentDetailsModal")
            );
            modal.show();
          } else {
            document.getElementById("appointmentDetailsBody").innerHTML =
              "Appointment not found.";
          }
        } else {
          document.getElementById("appointmentDetailsBody").innerHTML =
            "Failed to load appointment details.";
        }
      })
      .catch(() => {
        document.getElementById("appointmentDetailsBody").innerHTML =
          "Error loading appointment details.";
      });
  }

  // Messages card click handler
  if (messagesCard) {
    messagesCard.addEventListener("click", function () {
      // Navigate to counselor messages page
      window.location.href = window.BASE_URL + "counselor/messages";
    });
  }

  // Auto-refresh notifications every 30 seconds
  let notificationRefreshInterval = null;

  function startNotificationAutoRefresh() {
    // Clear existing interval if any
    if (notificationRefreshInterval) {
      clearInterval(notificationRefreshInterval);
    }

    // Refresh notifications every 30 seconds
    notificationRefreshInterval = setInterval(() => {
      // Only refresh if notifications dropdown is open
      const notificationsDropdown = document.getElementById(
        "notificationsDropdown"
      );
      if (
        notificationsDropdown &&
        notificationsDropdown.style.display === "block"
      ) {
        loadNotifications();
      }
    }, 30000);
  }

  function stopNotificationAutoRefresh() {
    if (notificationRefreshInterval) {
      clearInterval(notificationRefreshInterval);
      notificationRefreshInterval = null;
    }
  }

  // Start the initialization process
  fetchUserIdAndInitialize();

  // Start auto-refresh for notifications
  startNotificationAutoRefresh();

  /**
   * Fetch and display recent pending appointments for the counselor
   * This function loads the 2 most recent pending appointments where
   * counselor_preference matches the logged-in counselor
   */
  function loadRecentPendingAppointments() {
    const container = document.getElementById("appointments-container");
    if (!container) {
      console.warn("Appointments container not found");
      return;
    }

    fetch(window.BASE_URL + "counselor/dashboard/recent-pending-appointments")
      .then((response) => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then((data) => {
        if (data.status === "success") {
          displayRecentAppointments(data.appointments || []);
        } else {
          console.error(
            "Failed to load appointments:",
            data.message || "Unknown error"
          );
          displayRecentAppointments([]);
        }
      })
      .catch((error) => {
        console.error("Error fetching appointments:", error);
        // Display empty state instead of breaking
        displayRecentAppointments([]);
      });
  }

  /**
   * Display recent appointments in the dashboard
   * @param {Array} appointments - Array of appointment objects
   */
  function displayRecentAppointments(appointments) {
    const container = document.getElementById("appointments-container");
    if (!container) return;

    // Find the appointments content area (the div with gap-3 class)
    const appointmentsContent = container.querySelector(
      ".d-flex.flex-column.gap-3"
    );
    if (!appointmentsContent) {
      console.warn("Appointments content area not found");
      return;
    }

    // Clear existing placeholder content
    appointmentsContent.innerHTML = "";

    if (!appointments || appointments.length === 0) {
      // Show "no appointments" message
      appointmentsContent.innerHTML = `
            <div class="p-3 bg-light rounded shadow-sm text-center">
                <p class="text-muted mb-0">No pending appointments at the moment</p>
            </div>
        `;
      return;
    }

    // Display each appointment
    appointments.forEach((appointment) => {
      const appointmentCard = document.createElement("div");
      appointmentCard.className = "p-3 bg-light rounded shadow-sm";

      // Format the date safely
      let formattedDate = "N/A";
      try {
        const appointmentDate = new Date(appointment.preferred_date);
        if (!isNaN(appointmentDate.getTime())) {
          formattedDate = appointmentDate.toLocaleDateString("en-US", {
            year: "numeric",
            month: "long",
            day: "numeric",
          });
        }
      } catch (e) {
        console.error("Error formatting date:", e);
      }

      appointmentCard.innerHTML = `
            <p class="text-body-secondary mb-1"><strong>Student:</strong> ${escapeHtml(
              appointment.student_name || appointment.username || appointment.student_id || "N/A"
            )}</p>
            <p class="text-body-secondary mb-1"><strong>Date:</strong> ${formattedDate}</p>
            <p class="text-body-secondary mb-1"><strong>Time:</strong> ${escapeHtml(
              appointment.preferred_time || "N/A"
            )}</p>
            <p class="text-body-secondary mb-1"><strong>Method:</strong> ${escapeHtml(
              appointment.method_type || "N/A"
            )}</p>
            <p class="text-body-secondary mb-0"><strong>Purpose:</strong> ${escapeHtml(
              appointment.purpose || "N/A"
            )}</p>
        `;

      appointmentsContent.appendChild(appointmentCard);
    });
  }

  // Load appointments when page loads
  loadRecentPendingAppointments();

  // Refresh appointments every 30 seconds
  setInterval(loadRecentPendingAppointments, 30000);

  /**
   * Fetch and display the latest 2 student conversations for the counselor
   * Populates the Messages card on the dashboard
   */
  function loadRecentMessages() {
    const card = document.getElementById("messagesCard");
    if (!card) return;

    fetch(
      (window.BASE_URL || "/") +
        "counselor/message/operations?action=get_dashboard_messages&limit=2",
      {
        method: "GET",
        credentials: "include",
        headers: { Accept: "application/json" },
      }
    )
      .then((r) => r.json())
      .then((data) => {
        if (data && data.success && Array.isArray(data.conversations)) {
          displayRecentMessages(data.conversations);
        } else {
          displayRecentMessages([]);
        }
      })
      .catch(() => displayRecentMessages([]));
  }

  function displayRecentMessages(conversations) {
    const card = document.getElementById("messagesCard");
    if (!card) return;

    const content = card.querySelector(".d-flex.flex-column");
    if (!content) return;

    content.innerHTML = "";

    if (!conversations || conversations.length === 0) {
      const empty = document.createElement("div");
      empty.className = "p-3 bg-light rounded shadow-sm text-center";
      empty.innerHTML =
        '<p class="text-muted mb-0">No recent student messages</p>';
      content.appendChild(empty);
      return;
    }

    conversations.slice(0, 2).forEach((conv) => {
      const lastTime = conv.last_message_time
        ? formatDashboardTime(conv.last_message_time)
        : "";
      const statusInfo = calculateOnlineStatus(
        conv.last_activity,
        conv.last_login,
        conv.logout_time
      );

      const preview = document.createElement("div");
      preview.className =
        "p-3 bg-light rounded shadow-sm d-flex align-items-start gap-2 dashboard-message-card";

      const avatar = document.createElement("img");
      avatar.alt = "Student avatar";
      avatar.className = "rounded-circle";
      avatar.style.width = "36px";
      avatar.style.height = "36px";
      avatar.style.objectFit = "cover";
      avatar.src = resolveImageUrl(
        conv.other_profile_picture || "Photos/profile.png"
      );

      const info = document.createElement("div");
      info.style.flex = "1";
      info.innerHTML = `
            <div class="d-flex align-items-center justify-content-between mb-1">
                <div class="d-flex align-items-start justify-content-left">
                    <strong class="text-body-secondary me-1">Student:</strong>
                    <span class="text-body-secondary">${escapeHtml(
                      conv.other_username || conv.other_user_id || ""
                    )}</span>
                </div>
                <span class="dashboard-status-indicator ${statusInfo.class}">${
        statusInfo.text
      }</span>
            </div>
            <p class="text-body-secondary mb-1"><strong>Last:</strong> ${escapeHtml(
              conv.last_message || ""
            )}</p>
            <p class="small text-secondary mb-0"><strong>Received on:</strong> ${lastTime}</p>
        `;

      preview.appendChild(avatar);
      preview.appendChild(info);
      content.appendChild(preview);
    });
  }

  /**
   * Formats a timestamp for dashboard display with dynamic relative time
   * @param {string|Date|number} ts - Timestamp to format
   * @returns {string} Formatted time string
   */
  function formatDashboardTime(ts) {
    if (!ts) return "";
    
    const messageDate = new Date(ts);
    if (Number.isNaN(messageDate.getTime())) return "";
    
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const messageDay = new Date(
      messageDate.getFullYear(),
      messageDate.getMonth(),
      messageDate.getDate()
    );
    
    // Format time in 12-hour format with AM/PM
    const hours = messageDate.getHours();
    const minutes = messageDate.getMinutes();
    const ampm = hours >= 12 ? "PM" : "AM";
    const displayHours = hours % 12 || 12;
    const displayMinutes = minutes.toString().padStart(2, "0");
    const timeString = `${displayHours}:${displayMinutes} ${ampm}`;
    
    // Calculate difference in days
    const diffInMs = today - messageDay;
    const diffInDays = Math.floor(diffInMs / (1000 * 60 * 60 * 24));
    
    // Today: show only time
    if (diffInDays === 0) {
      return timeString;
    }
    
    // Yesterday: "Yesterday at {time}"
    if (diffInDays === 1) {
      return `Yesterday at ${timeString}`;
    }
    
    // 1-6 days ago: "{n} days ago {time}"
    if (diffInDays >= 2 && diffInDays <= 6) {
      return `${diffInDays} days ago ${timeString}`;
    }
    
    // 1 week ago (7 days): "1 week ago {time}"
    if (diffInDays === 7) {
      return `1 week ago ${timeString}`;
    }
    
    // More than 1 week ago: "Nov 1, 9:30 PM" format
    const monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    const month = monthNames[messageDate.getMonth()];
    const day = messageDate.getDate();
    return `${month} ${day}, ${timeString}`;
  }

  function escapeHtml(text) {
    return String(text)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;");
  }

  // Load recent messages when page loads and refresh every 30s
  loadRecentMessages();
  setInterval(loadRecentMessages, 30000);

  // Drawer open/close behavior (always enabled)
  function openDrawer() {
    if (navbarDrawer) navbarDrawer.classList.add("show");
    if (navbarOverlay) navbarOverlay.classList.add("show");
    document.body.style.overflow = "hidden";
    if (navbarDrawerToggler) navbarDrawerToggler.classList.add("active");
  }

  function closeDrawer() {
    if (navbarDrawer) navbarDrawer.classList.remove("show");
    if (navbarOverlay) navbarOverlay.classList.remove("show");
    document.body.style.overflow = "";
    if (navbarDrawerToggler) navbarDrawerToggler.classList.remove("active");
  }

  if (navbarDrawerToggler) {
    navbarDrawerToggler.addEventListener("click", openDrawer);
  }
  if (navbarDrawerClose) {
    navbarDrawerClose.addEventListener("click", closeDrawer);
  }
  if (navbarOverlay) {
    navbarOverlay.addEventListener("click", closeDrawer);
  }

  // Logout from drawer
  const logoutFromDrawer = document.getElementById("logoutFromDrawer");
  if (logoutFromDrawer) {
    logoutFromDrawer.addEventListener("click", function (e) {
      e.preventDefault();
      closeDrawer();
      setTimeout(() => handleLogout(), 150);
    });
  }

  // One-shot click animation for drawer items
  document.querySelectorAll("#navbarDrawer .nav-link").forEach(function (link) {
    link.addEventListener("click", function () {
      link.classList.remove("drawer-item-click");
      void link.offsetWidth;
      link.classList.add("drawer-item-click");
    });
  });

  // Add this code at the end of the DOMContentLoaded function in counselor_dashboard.js
// Replace the previous quote submission code with this:

  // ========== DAILY QUOTE MODAL FEATURE ==========
  
  const openQuoteModalBtn = document.getElementById('openQuoteModalBtn');
  const quoteSubmissionModal = document.getElementById('quoteSubmissionModal');
  const myQuotesModal = document.getElementById('myQuotesModal');
  const quoteForm = document.getElementById('quoteSubmissionForm');
  const quoteTextArea = document.getElementById('quoteText');
  const charCount = document.getElementById('charCount');
  const submitQuoteBtn = document.getElementById('submitQuoteBtn');
  const viewMyQuotesBtn = document.getElementById('viewMyQuotesBtn');
  const openQuoteSubmissionFromMyQuotesBtn = document.getElementById('openQuoteSubmissionFromMyQuotes');
  const alertModalElement = document.getElementById('alertModal');
  
  let quoteModalReturnAction = null;
  
  function setQuoteModalReturnAction(action) {
    quoteModalReturnAction = action;
  }
  
  if (alertModalElement) {
    alertModalElement.addEventListener('hidden.bs.modal', () => {
      if (quoteModalReturnAction) {
        const action = quoteModalReturnAction;
        quoteModalReturnAction = null;
        action();
      }
    });
  }
  
  function showMyQuotesModalWithReload() {
    if (!myQuotesModal) return;
    const modalInstance = bootstrap.Modal.getOrCreateInstance(myQuotesModal);
    modalInstance.show();
    loadMyQuotes();
  }
  
  // Character counter for quote text
  if (quoteTextArea && charCount) {
    quoteTextArea.addEventListener('input', function() {
      const length = this.value.length;
      charCount.textContent = length;
      
      // Change color based on character count
      if (length > 450) {
        charCount.style.color = '#dc3545'; // Red
      } else if (length > 400) {
        charCount.style.color = '#ffc107'; // Yellow
      } else {
        charCount.style.color = '#060E57'; // Blue
      }
    });
  }
  
  // Open quote modal with animation
  if (openQuoteModalBtn) {
    openQuoteModalBtn.addEventListener('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      
      // Add click animation
      openQuoteModalBtn.classList.remove('quote-click');
      void openQuoteModalBtn.offsetWidth;
      openQuoteModalBtn.classList.add('quote-click');
      
      // Show My Quotes modal
      if (myQuotesModal) {
        const myQuotesModalInstance = bootstrap.Modal.getOrCreateInstance(myQuotesModal);
        myQuotesModalInstance.show();
        loadMyQuotes();
      }
    });
  }
  
  // Remove active state when modal is hidden
  if (quoteSubmissionModal) {
    quoteSubmissionModal.addEventListener('hidden.bs.modal', function() {
      if (openQuoteModalBtn) {
        openQuoteModalBtn.classList.remove('active');
      }
      
      // Reset form and edit state
      if (quoteForm) {
        quoteForm.reset();
        quoteForm.removeAttribute('data-edit-quote-id');
        quoteForm.removeAttribute('data-return-to-my-quotes');
        if (charCount) charCount.textContent = '0';
        
        // Restore submit button to original state
        const submitBtn = document.getElementById('submitQuoteBtn');
        if (submitBtn) {
          const originalText = submitBtn.getAttribute('data-original-text');
          if (originalText) {
            submitBtn.innerHTML = originalText;
            submitBtn.removeAttribute('data-original-text');
          } else {
            submitBtn.innerHTML = '<i class="fas fa-paper-plane me-2"></i>Submit Quote';
          }
          submitBtn.disabled = false;
        }
      }
      
      // Clear any alerts
      const alertContainer = document.getElementById('quoteAlertContainer');
      if (alertContainer) {
        alertContainer.innerHTML = '';
      }
    });
  }
  
  // Quote submission form handler
  if (quoteForm) {
    quoteForm.addEventListener('submit', function(e) {
      e.preventDefault();
      
      if (!submitQuoteBtn) return;
      
      // Store original button state
      const originalBtnText = submitQuoteBtn.innerHTML;
      const originalBtnDisabled = submitQuoteBtn.disabled;
      
      // Set loading state
      submitQuoteBtn.disabled = true;
      
      // Check if this is an edit operation
      const editQuoteId = quoteForm.getAttribute('data-edit-quote-id');
      const isEdit = editQuoteId !== null && editQuoteId !== '';
      const returnToMyQuotes = quoteForm.getAttribute('data-return-to-my-quotes') === 'true';
      
      // Update button to show loading state
      if (isEdit) {
        submitQuoteBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Updating...';
      } else {
        submitQuoteBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Submitting...';
      }
      
      let url = window.BASE_URL + 'counselor/quotes/submit';
      let method = 'POST';
      let requestBody;
      let headers = {};
      
      if (isEdit) {
        url = window.BASE_URL + 'counselor/quotes/update/' + editQuoteId;
        method = 'PUT';
        // For PUT requests, convert FormData to URLSearchParams for better compatibility
        const formData = new FormData(quoteForm);
        const params = new URLSearchParams();
        for (const [key, value] of formData.entries()) {
          params.append(key, value);
        }
        requestBody = params.toString();
        headers['Content-Type'] = 'application/x-www-form-urlencoded';
      } else {
        // For POST requests, use FormData as normal
        requestBody = new FormData(quoteForm);
      }
      
      fetch(url, {
        method: method,
        headers: headers,
        body: requestBody
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          // Show success message using alert modal (not in quoteSubmissionModal)
          const successMsg = isEdit ? (data.message || 'Quote updated successfully!') : (data.message || 'Quote submitted successfully!');
          
          if (typeof openAlertModal === 'function') {
            setQuoteModalReturnAction(() => {
              showMyQuotesModalWithReload();
            });
            openAlertModal(successMsg, 'success');
          } else {
            alert(successMsg);
            showMyQuotesModalWithReload();
          }
          
          // Reset form and clear edit flag
          quoteForm.reset();
          quoteForm.removeAttribute('data-edit-quote-id');
          quoteForm.removeAttribute('data-return-to-my-quotes');
          if (charCount) charCount.textContent = '0';
          
          // Restore submit button to original state
          const storedOriginalText = submitQuoteBtn.getAttribute('data-original-text');
          if (storedOriginalText) {
            submitQuoteBtn.innerHTML = storedOriginalText;
            submitQuoteBtn.removeAttribute('data-original-text');
          } else {
            submitQuoteBtn.innerHTML = '<i class="fas fa-paper-plane me-2"></i>Submit Quote';
          }
          submitQuoteBtn.disabled = false;
          
          // Close quote submission modal
          const modalInstance = bootstrap.Modal.getInstance(quoteSubmissionModal);
          if (modalInstance) {
            modalInstance.hide();
          }
          
          // (Return action already queued above)
        } else {
          let errorMsg = data.message || (isEdit ? 'Failed to update quote' : 'Failed to submit quote');
          if (data.errors) {
            const errorList = Array.isArray(data.errors) ? data.errors : Object.values(data.errors);
            errorMsg += '<br><small>' + errorList.join('<br>') + '</small>';
          }
          
          // Show error in alert modal (not in quoteSubmissionModal)
          if (typeof openAlertModal === 'function') {
            openAlertModal(errorMsg, 'danger');
          } else {
            alert(errorMsg);
          }
          
          // Restore button state on error
          const storedOriginalText = submitQuoteBtn.getAttribute('data-original-text');
          if (storedOriginalText) {
            submitQuoteBtn.innerHTML = storedOriginalText;
            submitQuoteBtn.removeAttribute('data-original-text');
          } else {
            submitQuoteBtn.innerHTML = originalBtnText;
          }
          submitQuoteBtn.disabled = false;
          
          // If this was an edit, return to myQuotesModal even on error
          if (returnToMyQuotes || isEdit) {
            // Keep the edit modal open so user can fix errors, but don't return to myQuotesModal yet
            // User can manually close and return
          }
        }
      })
      .catch(error => {
        console.error('Error ' + (isEdit ? 'updating' : 'submitting') + ' quote:', error);
        
        // Show error in alert modal
        if (typeof openAlertModal === 'function') {
          openAlertModal('An error occurred. Please try again.', 'danger');
        } else {
          alert('An error occurred. Please try again.');
        }
        
        // Restore button state on error
        const storedOriginalText = submitQuoteBtn.getAttribute('data-original-text');
        if (storedOriginalText) {
          submitQuoteBtn.innerHTML = storedOriginalText;
          submitQuoteBtn.removeAttribute('data-original-text');
        } else {
          submitQuoteBtn.innerHTML = originalBtnText;
        }
        submitQuoteBtn.disabled = false;
      });
    });
  }
  
  // View my quotes button handler
  if (viewMyQuotesBtn) {
    viewMyQuotesBtn.addEventListener('click', function() {
      // Hide submission modal
      const submissionModalInstance = bootstrap.Modal.getInstance(quoteSubmissionModal);
      if (submissionModalInstance) {
        submissionModalInstance.hide();
      }
      
      // Show my quotes modal
      const myQuotesModalInstance = new bootstrap.Modal(myQuotesModal);
      myQuotesModalInstance.show();
      
      // Load quotes
      loadMyQuotes();
    });
  }

  if (openQuoteSubmissionFromMyQuotesBtn) {
    openQuoteSubmissionFromMyQuotesBtn.addEventListener('click', () => {
      if (myQuotesModal) {
        const myQuotesModalInstance = bootstrap.Modal.getInstance(myQuotesModal);
        if (myQuotesModalInstance) {
          myQuotesModalInstance.hide();
        }
      }
      
      setTimeout(() => {
        if (quoteSubmissionModal) {
          const submissionModalInstance = bootstrap.Modal.getOrCreateInstance(quoteSubmissionModal);
          if (quoteForm) {
            quoteForm.reset();
            quoteForm.removeAttribute('data-edit-quote-id');
            quoteForm.removeAttribute('data-return-to-my-quotes');
            if (charCount) charCount.textContent = '0';
          }
          submissionModalInstance.show();
        }
      }, 200);
    });
  }
  
  // Load counselor's submitted quotes
  function loadMyQuotes() {
    const quotesList = document.getElementById('myQuotesList');
    if (!quotesList) return;
    
    quotesList.innerHTML = `
      <div class="text-center py-4">
        <i class="fas fa-spinner fa-spin fa-2x text-primary"></i>
        <p class="mt-2 text-muted">Loading your quotes...</p>
      </div>
    `;
    
    fetch(window.BASE_URL + 'counselor/quotes/my-quotes')
      .then(response => response.json())
      .then(data => {
        if (data.success && data.quotes && data.quotes.length > 0) {
          displayMyQuotes(data.quotes);
        } else {
          quotesList.innerHTML = `
            <div class="empty-quotes-state">
              <i class="fas fa-quote-left"></i>
              <h5 class="mt-3">No Quotes Submitted Yet</h5>
              <p class="text-muted">Share your first inspirational quote to get started!</p>
            </div>
          `;
        }
      })
      .catch(error => {
        console.error('Error loading quotes:', error);
        quotesList.innerHTML = `
          <div class="text-center py-4 text-danger">
            <i class="fas fa-exclamation-triangle fa-2x mb-3"></i>
            <p>Failed to load quotes. Please try again.</p>
          </div>
        `;
      });
  }
  
  // Display quotes with enhanced styling
  function displayMyQuotes(quotes) {
    const quotesList = document.getElementById('myQuotesList');
    if (!quotesList) return;
    
    quotesList.innerHTML = '';
    
    quotes.forEach(quote => {
      const statusClass = 'status-' + quote.status;
      const statusBadge = getQuoteStatusBadge(quote.status);
      const quoteCard = document.createElement('div');
      quoteCard.className = `quote-card ${statusClass}`;
      
      let rejectionReason = '';
      if (quote.status === 'rejected' && quote.rejection_reason) {
        rejectionReason = `
          <div class="rejection-alert mt-2">
            <strong><i class="fas fa-info-circle me-1"></i>Rejection Reason:</strong><br>
            ${escapeHtml(quote.rejection_reason)}
          </div>
        `;
      }
      
      let moderationInfo = '';
      if (quote.moderated_at) {
        const action = quote.status === 'approved' ? 'Approved' : 'Rejected';
        moderationInfo = `
          <small class="text-muted d-block mt-2">
            <i class="fas fa-user-check me-1"></i>
            ${action} on ${formatQuoteDate(quote.moderated_at)}
          </small>
        `;
      }
      
      const categoryIcon = getCategoryIcon(quote.category);
      
      // Action buttons based on status
      let actionButtons = '';
      if (quote.status === 'pending') {
        // Pending: Show both edit and delete
        actionButtons = `
          <div class="quote-actions mt-3 d-flex gap-2">
            <button class="btn btn-sm btn-primary edit-quote-btn" data-quote-id="${quote.id}" title="Edit Quote">
              <i class="fas fa-edit me-1"></i>Edit
            </button>
            <button class="btn btn-sm btn-danger delete-quote-btn" data-quote-id="${quote.id}" title="Delete Quote">
              <i class="fas fa-trash me-1"></i>Delete
            </button>
          </div>
        `;
      } else {
        // Approved or Rejected: Show only delete
        actionButtons = `
          <div class="quote-actions mt-3 d-flex gap-2">
            <button class="btn btn-sm btn-danger delete-quote-btn" data-quote-id="${quote.id}" title="Delete Quote">
              <i class="fas fa-trash me-1"></i>Delete
            </button>
          </div>
        `;
      }
      
      quoteCard.innerHTML = `
        <div class="d-flex justify-content-between align-items-start mb-2">
          <h6 class="author-name mb-0">
            <i class="fas fa-user me-2"></i>${escapeHtml(quote.author_name)}
          </h6>
          ${statusBadge}
        </div>
        
        <p class="quote-text mb-2">${escapeHtml(quote.quote_text)}</p>
        
        <div class="d-flex flex-wrap gap-2 align-items-center mt-3">
          <span class="badge bg-secondary">
            ${categoryIcon} ${escapeHtml(quote.category)}
          </span>
          ${quote.source ? `
            <span class="badge bg-info">
              <i class="fas fa-book me-1"></i>${escapeHtml(quote.source)}
            </span>
          ` : ''}
          <small class="text-muted ms-auto">
            <i class="fas fa-calendar me-1"></i>
            Submitted ${formatQuoteDate(quote.submitted_at)}
          </small>
        </div>
        
        ${moderationInfo}
        ${rejectionReason}
        ${actionButtons}
      `;
      
      quotesList.appendChild(quoteCard);
    });
    
    // Attach event listeners for edit and delete buttons
    attachQuoteActionListeners();
  }
  
  // Attach event listeners for quote actions
  function attachQuoteActionListeners() {
    // Edit buttons
    document.querySelectorAll('.edit-quote-btn').forEach(btn => {
      btn.addEventListener('click', function() {
        const quoteId = this.getAttribute('data-quote-id');
        editQuote(quoteId);
      });
    });
    
    // Delete buttons
    document.querySelectorAll('.delete-quote-btn').forEach(btn => {
      btn.addEventListener('click', function() {
        const quoteId = this.getAttribute('data-quote-id');
        deleteQuote(quoteId);
      });
    });
  }
  
  // Edit quote function
  function editQuote(quoteId) {
    // Close myQuotesModal immediately
    const myQuotesModal = document.getElementById('myQuotesModal');
    if (myQuotesModal) {
      const myQuotesModalInstance = bootstrap.Modal.getInstance(myQuotesModal);
      if (myQuotesModalInstance) {
        myQuotesModalInstance.hide();
      }
    }
    
    // Find the quote data from the current quotes list
    fetch(window.BASE_URL + 'counselor/quotes/my-quotes')
      .then(response => response.json())
      .then(data => {
        if (data.success && data.quotes) {
          const quote = data.quotes.find(q => q.id == quoteId);
          if (!quote) {
            showQuoteAlert('danger', 'Quote not found');
            // Reopen myQuotesModal if quote not found
            if (myQuotesModal) {
              const modalInstance = new bootstrap.Modal(myQuotesModal);
              modalInstance.show();
              loadMyQuotes();
            }
            return;
          }
          
          if (quote.status !== 'pending') {
            showQuoteAlert('warning', 'You can only edit pending quotes');
            // Reopen myQuotesModal if status is not pending
            if (myQuotesModal) {
              const modalInstance = new bootstrap.Modal(myQuotesModal);
              modalInstance.show();
              loadMyQuotes();
            }
            return;
          }
          
          // Populate the form with quote data
          document.getElementById('quoteText').value = quote.quote_text || '';
          document.getElementById('authorName').value = quote.author_name || '';
          document.getElementById('category').value = quote.category || '';
          document.getElementById('source').value = quote.source || '';
          document.getElementById('charCount').textContent = (quote.quote_text || '').length;
          
          // Store quote ID for update and reference to myQuotesModal
          const quoteForm = document.getElementById('quoteSubmissionForm');
          quoteForm.setAttribute('data-edit-quote-id', quoteId);
          quoteForm.setAttribute('data-return-to-my-quotes', 'true');
          
          // Change submit button text
          const submitBtn = document.getElementById('submitQuoteBtn');
          const originalText = submitBtn.innerHTML;
          submitBtn.innerHTML = '<i class="fas fa-save me-2"></i>Update Quote';
          submitBtn.setAttribute('data-original-text', originalText);
          
          // Open the edit modal
          const quoteSubmissionModal = document.getElementById('quoteSubmissionModal');
          const modal = new bootstrap.Modal(quoteSubmissionModal);
          modal.show();
        }
      })
      .catch(error => {
        console.error('Error loading quote:', error);
        showQuoteAlert('danger', 'Failed to load quote data');
        // Reopen myQuotesModal on error
        if (myQuotesModal) {
          const modalInstance = new bootstrap.Modal(myQuotesModal);
          modalInstance.show();
          loadMyQuotes();
        }
      });
  }
  
  // Delete quote function
  function deleteQuote(quoteId) {
    const myQuotesModal = document.getElementById('myQuotesModal');
    
    // Close myQuotesModal immediately before showing confirmation
    if (myQuotesModal) {
      const myQuotesModalInstance = bootstrap.Modal.getInstance(myQuotesModal);
      if (myQuotesModalInstance) {
        myQuotesModalInstance.hide();
      }
    }
    
    // Use the shared confirmation modal
    if (typeof openConfirmationModal === 'function') {
      openConfirmationModal(
        'Are you sure you want to delete this quote? This action cannot be undone.',
        function() {
          // User confirmed deletion - show loading state
          const deleteButtons = document.querySelectorAll(`.delete-quote-btn[data-quote-id="${quoteId}"]`);
          deleteButtons.forEach(btn => {
            const originalHtml = btn.innerHTML;
            btn.disabled = true;
            btn.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Deleting...';
            btn.setAttribute('data-original-html', originalHtml);
          });
          
          // Perform deletion
          fetch(window.BASE_URL + 'counselor/quotes/delete/' + quoteId, {
            method: 'DELETE',
            headers: {
              'Content-Type': 'application/json',
              'X-Requested-With': 'XMLHttpRequest'
            },
            credentials: 'include'
          })
          .then(response => response.json())
          .then(data => {
            // Restore button state
            deleteButtons.forEach(btn => {
              const originalHtml = btn.getAttribute('data-original-html');
              if (originalHtml) {
                btn.innerHTML = originalHtml;
                btn.removeAttribute('data-original-html');
              }
              btn.disabled = false;
            });
            
            if (data.success) {
              setQuoteModalReturnAction(() => {
                showMyQuotesModalWithReload();
              });
              
              // Show success message using alert modal (not in quoteSubmissionModal)
              if (typeof openAlertModal === 'function') {
                openAlertModal(data.message || 'Quote deleted successfully', 'success');
              } else {
                alert(data.message || 'Quote deleted successfully');
                showMyQuotesModalWithReload();
              }
            } else {
              setQuoteModalReturnAction(() => {
                showMyQuotesModalWithReload();
              });
              
              // Show error and reopen myQuotesModal
              if (typeof openAlertModal === 'function') {
                openAlertModal(data.message || 'Failed to delete quote', 'danger');
              } else {
                alert(data.message || 'Failed to delete quote');
                showMyQuotesModalWithReload();
              }
            }
          })
          .catch(error => {
            console.error('Error deleting quote:', error);
            
            // Show error and reopen myQuotesModal
            setQuoteModalReturnAction(() => {
              showMyQuotesModalWithReload();
            });
            
            if (typeof openAlertModal === 'function') {
              openAlertModal('An error occurred while deleting the quote', 'danger');
            } else {
              alert('An error occurred while deleting the quote');
              showMyQuotesModalWithReload();
            }
            
            // Restore button state on error
            deleteButtons.forEach(btn => {
              const originalHtml = btn.getAttribute('data-original-html');
              if (originalHtml) {
                btn.innerHTML = originalHtml;
                btn.removeAttribute('data-original-html');
              }
              btn.disabled = false;
            });
          });
        }
      );
    } else {
      // Fallback if modal function not available
      if (confirm('Are you sure you want to delete this quote? This action cannot be undone.')) {
        const deleteButtons = document.querySelectorAll(`.delete-quote-btn[data-quote-id="${quoteId}"]`);
        deleteButtons.forEach(btn => {
          const originalHtml = btn.innerHTML;
          btn.disabled = true;
          btn.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Deleting...';
          btn.setAttribute('data-original-html', originalHtml);
        });
        
        fetch(window.BASE_URL + 'counselor/quotes/delete/' + quoteId, {
          method: 'DELETE',
          headers: {
            'Content-Type': 'application/json',
            'X-Requested-With': 'XMLHttpRequest'
          },
          credentials: 'include'
        })
        .then(response => response.json())
        .then(data => {
          deleteButtons.forEach(btn => {
            const originalHtml = btn.getAttribute('data-original-html');
            if (originalHtml) {
              btn.innerHTML = originalHtml;
              btn.removeAttribute('data-original-html');
            }
            btn.disabled = false;
          });
          
          if (data.success) {
            if (typeof openAlertModal === 'function') {
              setQuoteModalReturnAction(() => {
                showMyQuotesModalWithReload();
              });
              openAlertModal(data.message || 'Quote deleted successfully', 'success');
            } else {
              alert(data.message || 'Quote deleted successfully');
              showMyQuotesModalWithReload();
            }
          } else {
            if (typeof openAlertModal === 'function') {
              setQuoteModalReturnAction(() => {
                showMyQuotesModalWithReload();
              });
              openAlertModal(data.message || 'Failed to delete quote', 'danger');
            } else {
              alert(data.message || 'Failed to delete quote');
              showMyQuotesModalWithReload();
            }
          }
        })
        .catch(error => {
          console.error('Error deleting quote:', error);
          
          // Show error and reopen myQuotesModal
          if (typeof openAlertModal === 'function') {
            setQuoteModalReturnAction(() => {
              showMyQuotesModalWithReload();
            });
            openAlertModal('An error occurred while deleting the quote', 'danger');
          } else {
            alert('An error occurred while deleting the quote');
            showMyQuotesModalWithReload();
          }
          
          deleteButtons.forEach(btn => {
            const originalHtml = btn.getAttribute('data-original-html');
            if (originalHtml) {
              btn.innerHTML = originalHtml;
              btn.removeAttribute('data-original-html');
            }
            btn.disabled = false;
          });
        });
      }
    }
  }
  
  // Get status badge HTML with icons
  function getQuoteStatusBadge(status) {
    const badges = {
      'pending': '<span class="badge bg-warning quote-status-badge"><i class="fas fa-clock me-1"></i>PENDING REVIEW</span>',
      'approved': '<span class="badge bg-success quote-status-badge"><i class="fas fa-check-circle me-1"></i>APPROVED</span>',
      'rejected': '<span class="badge bg-danger quote-status-badge"><i class="fas fa-times-circle me-1"></i>REJECTED</span>'
    };
    return badges[status] || '<span class="badge bg-secondary quote-status-badge">UNKNOWN</span>';
  }
  
  // Get category icon
  function getCategoryIcon(category) {
    const icons = {
      'Inspirational': '✨',
      'Motivational': '💪',
      'Wisdom': '🦉',
      'Life': '🌱',
      'Success': '🎯',
      'Education': '📚',
      'Perseverance': '🏔️',
      'Courage': '🦁',
      'Hope': '🌟',
      'Kindness': '💝'
    };
    return icons[category] || '📝';
  }
  
  // Replace this function in counselor_dashboard.js
// Fix the date calculation bug

function formatQuoteDate(dateString) {
  if (!dateString) return 'N/A';
  
  try {
    // Parse the date string - ensure it's treated as Manila time
    const date = new Date(dateString);
    
    // Get current date in Manila timezone
    const now = new Date();
    const manilaOffset = 8 * 60; // Manila is UTC+8
    const localOffset = now.getTimezoneOffset(); // Local offset in minutes
    const offsetDiff = manilaOffset + localOffset;
    
    // Adjust current time to Manila timezone
    const manilaTime = new Date(now.getTime() + (offsetDiff * 60 * 1000));
    
    // Create date-only comparisons (without time)
    const dateOnly = new Date(date.getFullYear(), date.getMonth(), date.getDate());
    const todayOnly = new Date(manilaTime.getFullYear(), manilaTime.getMonth(), manilaTime.getDate());
    
    // Calculate difference in days
    const diffTime = todayOnly.getTime() - dateOnly.getTime();
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
    
    // Return appropriate string
    if (diffDays === 0) {
      return 'Today';
    } else if (diffDays === 1) {
      return 'Yesterday';
    } else if (diffDays > 1 && diffDays < 7) {
      return `${diffDays} days ago`;
    } else if (diffDays === 7) {
      return '1 week ago';
    } else if (diffDays > 7 && diffDays < 30) {
      const weeks = Math.floor(diffDays / 7);
      return `${weeks} ${weeks === 1 ? 'week' : 'weeks'} ago`;
    } else {
      // For older dates, show the actual date
      return date.toLocaleDateString('en-US', { 
        year: 'numeric', 
        month: 'short', 
        day: 'numeric' 
      });
    }
  } catch (error) {
    console.error('Error formatting date:', error);
    return dateString;
  }
}
  
  // Show alert message in modal
  function showQuoteAlert(type, message, autoClose = false) {
    const alertContainer = document.getElementById('quoteAlertContainer');
    if (!alertContainer) return;
    
    const iconMap = {
      'success': 'fa-check-circle',
      'danger': 'fa-exclamation-circle',
      'warning': 'fa-exclamation-triangle',
      'info': 'fa-info-circle'
    };
    
    const icon = iconMap[type] || 'fa-info-circle';
    
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show`;
    alertDiv.setAttribute('role', 'alert');
    alertDiv.innerHTML = `
      <i class="fas ${icon} me-2"></i>
      ${message}
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    alertContainer.innerHTML = '';
    alertContainer.appendChild(alertDiv);
    
    // Auto-dismiss success messages
    if (autoClose && type === 'success') {
      setTimeout(() => {
        alertDiv.remove();
      }, 5000);
    }
  }
  
  // Ensure escapeHtml function exists (reuse from earlier in the file or add it)
  if (typeof escapeHtml !== 'function') {
    function escapeHtml(text) {
      const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
      };
      return String(text).replace(/[&<>"']/g, m => map[m]);
    }
  }
  
  // ========== END DAILY QUOTE MODAL FEATURE ==========

  loadResources();
});

// Function to handle logout action
function handleLogout() {
  if (typeof window.confirmLogout === "function") {
    window.confirmLogout();
  } else {
    // Fallback (should rarely occur)
    if (confirm("Are you sure you want to log out?")) {
      window.location.href = (window.BASE_URL || "/") + "auth/logout";
    }
  }
}

// ========== RESOURCES ACCORDION SECTION ==========
// This should be added at the end of the DOMContentLoaded function in student_dashboard.js
// Replace the existing resources section (lines ~2000-2200) with this:

// Make functions globally accessible (compatibility layer)
window.previewResourceFile = function(resourceId, filePath, fileType) {
  const baseUrl = window.BASE_URL || '/';
  const fullPath = baseUrl + filePath;
  
  // For simple preview, just open in new tab
  // The advanced preview will use the shared module
  window.open(fullPath, '_blank');
};

window.trackResourceDownload = function(resourceId) {
  console.log('Resource downloaded:', resourceId);
};

window.trackResourceView = function(resourceId) {
  console.log('Resource viewed:', resourceId);
};

// Store resources data globally for preview module
let studentDashboardResources = [];

function loadResources() {
  const baseUrl = window.BASE_URL || '/';
  const url = baseUrl + 'counselor/resources/get';
  const container = document.getElementById('resourcesAccordionContent');

  if (!container) {
    return;
  }

  container.innerHTML = `
    <div class="text-center py-4">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Loading resources...</span>
      </div>
      <p class="mt-2 text-muted">Loading resources...</p>
    </div>
  `;

  fetch(url)
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return response.json();
    })
    .then(data => {
      if (data.success && data.resources && data.resources.length > 0) {
        studentDashboardResources = data.resources; // Store for preview module
        renderResourcesAccordion(data.resources);
      } else {
        container.innerHTML = `
          <div class="text-center py-5">
            <i class="fas fa-folder-open fa-3x text-muted mb-3"></i>
            <p class="text-muted">No resources available at this time.</p>
          </div>
        `;
      }
    })
    .catch(error => {
      console.error('Error loading resources:', error);
      container.innerHTML = `
        <div class="text-center py-5">
          <i class="fas fa-exclamation-triangle fa-3x text-warning mb-3"></i>
          <p class="text-danger">Failed to load resources. Please try again later.</p>
        </div>
      `;
    });
}

function renderResourcesAccordion(resources) {
  const container = document.getElementById('resourcesAccordionContent');
  if (!container) {
    return;
  }

  if (resources.length === 0) {
    container.innerHTML = `
      <div class="text-center py-5">
        <i class="fas fa-folder-open fa-3x text-muted mb-3"></i>
        <p class="text-muted">No resources available at this time.</p>
      </div>
    `;
    return;
  }

  const baseUrl = window.BASE_URL || '/';
  let html = '';
  resources.forEach((resource, index) => {
    const collapseId = `resourceCollapse${resource.id}`;
    const isFirst = index === 0;
    
    const resourceTypeIcon = resource.resource_type === 'file' 
      ? '<i class="fas fa-file-alt text-primary"></i>' 
      : '<i class="fas fa-link text-info"></i>';
    
    const categoryBadge = resource.category 
      ? `<span class="badge bg-secondary ms-2">${escapeHtml(resource.category)}</span>` 
      : '';
    
    const description = resource.description 
      ? `<p class="text-muted mb-2">${escapeHtml(resource.description)}</p>` 
      : '';
    
    const tags = resource.tags 
      ? `<div class="mb-2"><small class="text-muted">Tags: ${escapeHtml(resource.tags)}</small></div>` 
      : '';

    let resourceContent = '';
    if (resource.resource_type === 'file') {
      const fileIcon = getFileIcon(resource.file_type);
      const fileSize = resource.file_size_formatted || 'Unknown size';
      
      // CHANGED: Use advanced preview for all file types
      const previewButton = `
        <button class="btn btn-sm btn-outline-primary me-2 preview-resource-advanced" 
               data-resource-id="${resource.id}">
          <i class="fas fa-eye me-1"></i>Preview
        </button>
      `;
      
      resourceContent = `
        <div class="resource-file-info p-3 bg-light rounded">
          <div class="d-flex align-items-center mb-2">
            ${fileIcon}
            <div class="ms-2">
              <strong>${escapeHtml(resource.file_name || 'File')}</strong>
              <small class="text-muted d-block">${fileSize}</small>
            </div>
          </div>
          <div class="d-flex gap-2">
            ${previewButton}
            <button class="btn btn-sm btn-primary download-resource-btn" 
                    data-resource-id="${resource.id}"
                    type="button">
              <i class="fas fa-download me-1"></i>Download
            </button>
          </div>
        </div>
      `;
    } else {
      // CHANGED: Use advanced preview for links too
      resourceContent = `
        <div class="resource-link-info p-3 bg-light rounded">
          <button class="btn btn-primary preview-resource-advanced" 
                  data-resource-id="${resource.id}">
            <i class="fas fa-external-link-alt me-1"></i>Open Link
          </button>
          <p class="mt-2 mb-0"><small class="text-muted">${escapeHtml(resource.external_url)}</small></p>
        </div>
      `;
    }

    html += `
      <div class="accordion-item">
        <h2 class="accordion-header" id="heading${resource.id}">
          <button class="accordion-button ${isFirst ? '' : 'collapsed'}" 
                  type="button" 
                  data-bs-toggle="collapse" 
                  data-bs-target="#${collapseId}" 
                  aria-expanded="${isFirst ? 'true' : 'false'}" 
                  aria-controls="${collapseId}">
            <div class="d-flex align-items-center w-100">
              ${resourceTypeIcon}
              <span class="ms-2 fw-bold">${escapeHtml(resource.title)}</span>
              ${categoryBadge}
              <small class="text-muted ms-auto me-3">${resource.created_at_formatted || ''}</small>
            </div>
          </button>
        </h2>
        <div id="${collapseId}" 
             class="accordion-collapse collapse ${isFirst ? 'show' : ''}" 
             aria-labelledby="heading${resource.id}" 
             data-bs-parent="#resourcesAccordion">
          <div class="accordion-body">
            ${description}
            ${tags}
            ${resourceContent}
            <div class="mt-3 pt-3 border-top">
              <small class="text-muted">
                <i class="fas fa-user me-1"></i>Posted by: ${escapeHtml(resource.uploader_name || 'Admin')}
              </small>
            </div>
          </div>
        </div>
      </div>
    `;
  });

  container.innerHTML = html;
}

function getFileIcon(fileType) {
  if (!fileType) return '<i class="fas fa-file text-secondary fa-2x"></i>';
  
  const type = fileType.toLowerCase();
  if (type.includes('pdf')) return '<i class="fas fa-file-pdf text-danger fa-2x"></i>';
  if (type.includes('word') || type.includes('doc')) return '<i class="fas fa-file-word text-primary fa-2x"></i>';
  if (type.includes('excel') || type.includes('sheet')) return '<i class="fas fa-file-excel text-success fa-2x"></i>';
  if (type.includes('image')) return '<i class="fas fa-file-image text-info fa-2x"></i>';
  if (type.includes('video')) return '<i class="fas fa-file-video text-warning fa-2x"></i>';
  if (type.includes('zip') || type.includes('rar')) return '<i class="fas fa-file-archive text-secondary fa-2x"></i>';
  return '<i class="fas fa-file text-secondary fa-2x"></i>';
}

function escapeHtml(text) {
  return String(text)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

// CHANGED: Use advanced preview from shared module
document.addEventListener('click', function(e) {
  const previewBtn = e.target.closest('.preview-resource-advanced');
  if (previewBtn) {
    e.preventDefault();
    const resourceId = parseInt(previewBtn.getAttribute('data-resource-id'));
    
    // Use the shared preview module
    if (window.ResourcePreview && typeof window.ResourcePreview.previewResource === 'function') {
      window.ResourcePreview.previewResource(resourceId, studentDashboardResources);
    } else {
      console.error('ResourcePreview module not loaded');
      alert('Preview feature is not available. Please refresh the page.');
    }
    return;
  }

  const downloadBtn = e.target.closest('.download-resource-btn');
  if (downloadBtn) {
    e.preventDefault();
    const resourceId = parseInt(downloadBtn.getAttribute('data-resource-id'));
    downloadCounselorResource(resourceId);
    return;
  }
});

// Download function for counselor resources
function downloadCounselorResource(id) {
  const baseUrl = window.BASE_URL || '/';
  window.location.href = baseUrl + 'counselor/resources/download/' + id;
}

// Load resources on page load


// ========== END RESOURCES ACCORDION ==========



