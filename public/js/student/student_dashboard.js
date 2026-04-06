document.addEventListener("DOMContentLoaded", function () {
  // Initialize lastMessageId and isTyping
  let lastMessageId = 0;
  let isTyping = false;
  let lastConversationCounselorId = null; // Track which counselor's thread is rendered

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

  // Get references to all necessary elements
  const header = document.querySelector("header");
  const homeLink = document.querySelector("nav ul li:first-child a");
  const appointmentBtn = document.getElementById("appointmentBtn");
  const appointmentForm = document.getElementById("appointmentForm");
  const cancelAppointmentBtn = document.getElementById("cancelAppointmentBtn");
  const welcomeSection = document.querySelector(".content-panel h3");
  const welcomeQuote = document.querySelector(".content-panel p");
  const openChatBtn = document.getElementById("openChatBtn");
  const chatPopup = null; // Chat popup removed
  const closeChat = null; // Chat popup removed
  const main = document.querySelector("main");
  const notificationIcon = document.getElementById("notificationIcon");
  const notificationsDropdown = document.getElementById(
    "notificationsDropdown"
  );
  const notificationBadge = document.getElementById("notificationBadge");
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

  // Chat popup removed; redirect messages icon to messages page

  // Click animations for chat and notifications
  const openChatBtnEl = document.getElementById("openChatBtn");
  if (openChatBtnEl) {
    openChatBtnEl.addEventListener("click", function (e) {
      e.preventDefault();
      window.location.href = (window.BASE_URL || "/") + "student/messages";
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
  let selectedCounselorId = null; // Will store the selected counselor ID
  let selectedCounselorName = null; // Will store the selected counselor name

  // Counselor selection modal elements
  // Removed counselor selection UI (moved to dedicated Messages page)

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
          // Ensure fully visible horizontally
          if (right + dropdownWidth > window.innerWidth) {
            right = 10; // fallback padding from right edge
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

      // Reposition on resize/scroll to keep it on screen
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

      notificationsDropdown.addEventListener("click", function (e) {
        e.stopPropagation();
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

  function updateMessageCounter(count) {
    const messageBadge = document.getElementById("messageBadge");
    if (messageBadge) {
      const numCount = parseInt(count) || 0;
      if (numCount > 0) {
        messageBadge.textContent = numCount;
        messageBadge.style.display = "inline-block";
        messageBadge.classList.remove("hidden");
      } else {
        messageBadge.textContent = "";
        messageBadge.style.display = "none";
        messageBadge.classList.add("hidden");
      }
    }
  }

  function fetchNotificationCount() {
    // Use the same source and filtering as the list (exclude ALL message notifications)
    fetch(window.BASE_URL + "student/notifications")
      .then((response) => response.json())
      .then((data) => {
        if (data.status === "success") {
          const raw = Array.isArray(data.notifications)
            ? data.notifications
            : [];
          const displayable = raw.filter((n) => !(n && n.type === "message"));
          updateNotificationCounter(displayable.length);
        } else {
          console.error("Error fetching notification count:", data.message);
        }
      })
      .catch((error) => {
        console.error("Error fetching notification count:", error);
      });
  }

  function fetchMessageCount() {
    fetch(
      window.BASE_URL + "student/message/operations?action=get_unread_count"
    )
      .then((response) => response.json())
      .then((data) => {
        if (data.success) {
          const count = parseInt(data.unread_count) || 0;
          updateMessageCounter(count);
        } else {
          console.error("Error fetching message count:", data.message);
        }
      })
      .catch((error) => {
        console.error("Error fetching message count:", error);
      });
  }

  function loadNotifications() {
    fetch(window.BASE_URL + "student/notifications")
      .then((response) => response.json())
      .then((data) => {
        if (data.status === "success") {
          const raw = Array.isArray(data.notifications)
            ? data.notifications
            : [];
          // Exclude ALL message notifications from display per requirement
          const displayable = raw.filter((n) => !(n && n.type === "message"));
          // Apply additional client-side expiration filtering
          const filteredNotifications = filterExpiredNotifications(displayable);
          if (filteredNotifications.length === 0) {
            showEmptyNotifications("No notifications");
          } else {
            renderNotifications(filteredNotifications);
          }
          updateNotificationCounter(filteredNotifications.length);
        } else {
          showEmptyNotifications("Failed to load notifications");
          openAlertModal(
            "Failed to load notifications. Please try again later.",
            "error"
          );
        }
      })
      .catch((error) => {
        showEmptyNotifications("Unable to connect to server");
        openAlertModal(
          "Unable to connect to server. Please check your connection.",
          "error"
        );
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

  // Replace the renderNotifications function in student_dashboard.js (around line 245)

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

    notifications
      // Exclude ALL message notifications from display per requirement
      .filter((n) => !(n && n.type === "message"))
      .forEach((notification) => {
        if (!notification) return;

        const notificationItem = document.createElement("div");
        notificationItem.className = "notification-item";
        if (!notification.is_read) {
          notificationItem.classList.add("unread");
        }

        const notifDate = new Date(notification.created_at);
        const formattedDate =
          notifDate.toLocaleDateString() + " " + notifDate.toLocaleTimeString();

        // Use title directly from backend (already formatted with counselor name)
        const displayTitle = notification.title || "Notification";

        // Show mark as read button for all notification types if not already read
        // For events and announcements, check if they're already marked as read
        let showMarkReadBtn = false;
        if (
          notification.is_read === 0 ||
          notification.is_read === false ||
          notification.is_read === "0"
        ) {
          showMarkReadBtn = true;
        } else if (
          notification.type === "event" ||
          notification.type === "announcement"
        ) {
          // Events and announcements don't have is_read in the notification object
          // They're considered unread if they appear in the list
          showMarkReadBtn = true;
        }

        const markReadBtn = showMarkReadBtn
          ? `
                <button class="btn btn-sm btn-outline-primary mark-read-btn" data-notification-id="${
                  notification.id || ""
                }" data-type="${notification.type || ""}" data-related-id="${
              notification.related_id || ""
            }" title="Mark as read">
                    <i class="fas fa-check"></i>
                </button>
            `
          : "";

        notificationItem.innerHTML = `
                <div class="notification-header">
                    <h4>${displayTitle}</h4>
                    <div class="notification-actions">
                        <span class="notification-time">${formattedDate}</span>
                        ${markReadBtn}
                    </div>
                </div>
                <p>${notification.message || ""}</p>
            `;

        // Store counselor data as data attributes for message notifications
        if (notification.type === "message" && notification.counselor_id) {
          notificationItem.dataset.counselorId = notification.counselor_id;
          notificationItem.dataset.counselorName =
            notification.counselor_name || "Counselor";
        }

        // Add click handler for mark as read button
        const markReadButton = notificationItem.querySelector(".mark-read-btn");
        if (markReadButton) {
          markReadButton.addEventListener("click", function (e) {
            e.stopPropagation();
            e.preventDefault();
            const notificationId =
              markReadButton.dataset.notificationId || notification.id || null;
            const notificationType =
              markReadButton.dataset.type || notification.type || null;
            const relatedId =
              markReadButton.dataset.relatedId ||
              notification.related_id ||
              null;

            markNotificationAsRead(notificationId, notificationType, relatedId);
            notificationItem.classList.remove("unread");
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

          // Mark as read
          if (!notification.is_read) {
            markNotificationAsRead(notification.id);
            notificationItem.classList.remove("unread");
            notification.is_read = true;
            fetchNotificationCount();
          }

          // Handle navigation based on notification type
          if (notification.type === "appointment") {
            showAppointmentDetailsModal(notification.related_id);
          } else if (
            notification.type === "event" ||
            notification.type === "announcement"
          ) {
            window.location.href = window.BASE_URL + "student/announcements";
          } else if (notification.type === "message") {
            // Open chat with the specific counselor
            const counselorId =
              notification.counselor_id || notificationItem.dataset.counselorId;
            const counselorName =
              notification.counselor_name ||
              notificationItem.dataset.counselorName ||
              "Counselor";

            if (counselorId) {
              // Use the selectCounselor function to open chat with this counselor
              selectCounselor(counselorId, counselorName);
            } else {
              // Fallback: just open chat
              const openChatBtn = document.getElementById("openChatBtn");
              if (openChatBtn) openChatBtn.click();
            }
          }
        });

        notificationsContainer.appendChild(notificationItem);
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
      console.error("Invalid parameters for markNotificationAsRead");
      return;
    }

    fetch(window.BASE_URL + "student/notifications/mark-read", {
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
  const markAllReadBtn = document.getElementById("markAllReadBtn");
  if (markAllReadBtn) {
    markAllReadBtn.addEventListener("click", function (e) {
      e.stopPropagation();
      e.preventDefault();

      // Get all notifications currently displayed in the modal
      const notificationsList = document.querySelector(".notifications-list");
      if (!notificationsList) return;

      const notificationItems =
        notificationsList.querySelectorAll(".notification-item");

      // Collect all notifications that need to be marked as read
      const notificationsToMark = [];

      notificationItems.forEach((item) => {
        const markReadBtn = item.querySelector(".mark-read-btn");
        if (markReadBtn) {
          const notificationId = markReadBtn.dataset.notificationId || null;
          const notificationType = markReadBtn.dataset.type || null;
          const relatedId = markReadBtn.dataset.relatedId || null;

          if (notificationId || (notificationType && relatedId)) {
            notificationsToMark.push({
              notification_id: notificationId,
              type: notificationType,
              related_id: relatedId,
            });
          }
        }
      });

      // If no notifications to mark, just return
      if (notificationsToMark.length === 0) {
        return;
      }

      // Mark all notifications as read using the bulk endpoint
      fetch(window.BASE_URL + "student/notifications/mark-read", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ mark_all: true }),
      })
        .then((response) => response.json())
        .then((data) => {
          if (data.status === "success") {
            // Now mark each individual notification based on its type
            const markPromises = notificationsToMark.map((notif) => {
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

              return fetch(
                window.BASE_URL + "student/notifications/mark-read",
                {
                  method: "POST",
                  headers: { "Content-Type": "application/json" },
                  body: JSON.stringify(payload),
                }
              );
            });

            // Wait for all individual marks to complete
            return Promise.all(markPromises);
          } else {
            console.error(
              "Error marking all notifications as read:",
              data.message
            );
            throw new Error(data.message);
          }
        })
        .then(() => {
          // Remove all mark-as-read buttons and unread classes
          notificationItems.forEach((item) => {
            item.classList.remove("unread");
            const markReadBtn = item.querySelector(".mark-read-btn");
            if (markReadBtn) {
              markReadBtn.remove();
            }
          });

          // Reload notifications to get fresh data
          loadNotifications();
          fetchNotificationCount();
        })
        .catch((error) => {
          console.error("Error marking all notifications as read:", error);
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

  // Real-time polling for notifications and messages
  function startNotificationPolling() {
    fetchNotificationCount();
    fetchMessageCount();
    setInterval(() => {
      fetchNotificationCount();
      fetchMessageCount();
      loadNotifications();
    }, 10000); // every 10 seconds
  }

  // Function to load and display student profile picture
  function loadStudentProfilePicture() {
    SecureLogger.info("Loading student profile picture...");
    fetch(window.BASE_URL + "student/dashboard/get-profile-data", {
      method: "GET",
      credentials: "include",
    })
      .then((response) => {
        SecureLogger.info("Profile picture response status:", response.status);
        return response.text().then((text) => {
          SecureLogger.info("Raw profile picture response:", text);
          try {
            return JSON.parse(text);
          } catch (e) {
            console.error("JSON parse error:", e);
            throw new Error("Invalid JSON response");
          }
        });
      })
      .then((data) => {
        SecureLogger.info("Parsed profile picture data:", data);
        if (data.success) {
          const studentData = data.data;
          SecureLogger.info("Student data:", studentData);

          // Update profile picture
          const profileImg = document.getElementById("profile-img");
          if (profileImg && studentData.profile_picture) {
            SecureLogger.info(
              "Updating student profile picture:",
              studentData.profile_picture
            );
            profileImg.src = studentData.profile_picture;
          }
        } else {
          console.error(
            "Failed to load student profile picture:",
            data.message
          );
        }
      })
      .catch((error) => {
        console.error("Error loading student profile picture:", error);
      });
  }

  // Modify fetchUserIdAndInitialize to also initialize notifications and profile picture
  function fetchUserIdAndInitialize() {
    fetch(window.BASE_URL + "student/profile/get")
      .then((response) => response.json())
      .then((data) => {
        if (data.success && data.user_id) {
          userId = data.user_id;
          initializeNotifications();
          startNotificationPolling();

          // Load student profile picture
          loadStudentProfilePicture();

          // Update the user ID in the welcome message only if no display name exists
          const userIdSpan = document.querySelector(".text-primary i");
          const userDisplaySpan = document.getElementById("user-id-display");
          if (userIdSpan && !userDisplaySpan) {
            // Only update if there's no hidden user-id-display element (meaning no name was found)
            userIdSpan.textContent = data.user_id;
          }
        } else {
          console.error("Failed to get user ID");
          openAlertModal(
            "Failed to load user profile. Please refresh the page.",
            "error"
          );
        }
      })
      .catch((error) => {
        console.error("Error fetching user profile:", error);
        openAlertModal(
          "Error loading user profile. Please check your connection.",
          "error"
        );
      });
  }

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
        // Open chat popup only; do not open counselor selection here
        chatPopup.style.display = "block";
        chatPopup.classList.add("visible");
        openChatBtn.classList.add("active");
        // Load conversation only if a counselor has been selected
        if (selectedCounselorId) {
          loadMessagesWithCounselor();
          startMessagePolling();
        }
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

  function loadMessagesWithCounselor() {
    if (!userId || !selectedCounselorId) {
      console.error("User ID or Counselor ID not available");
      return;
    }

    fetch(
      window.BASE_URL +
        `student/message/operations?action=get_messages&user_id=${selectedCounselorId}`
    )
      .then((response) => {
        if (!response.ok) {
          throw new Error("Network response was not ok");
        }
        return response.json();
      })
      .then((data) => {
        if (data.success) {
          // Defensive filter to ensure only conversation with selected counselor is shown
          const allMessages = Array.isArray(data.messages) ? data.messages : [];
          const filtered = allMessages.filter((m) => {
            if (!m) return false;
            // Accept only messages where one side is the selected counselor AND the other side is the logged-in student
            const involvesSelectedCounselor =
              m.sender_id === selectedCounselorId ||
              m.receiver_id === selectedCounselorId;
            const involvesStudent =
              m.sender_id === userId || m.receiver_id === userId;
            return involvesSelectedCounselor && involvesStudent;
          });
          displayMessages(filtered);
        } else {
          console.error("Failed to load messages:", data.message);
          openAlertModal(
            "Unable to load messages. Please try again later.",
            "error"
          );
        }
      })
      .catch((error) => {
        console.error("Error:", error);
        openAlertModal(
          "Error loading messages. Please check your connection.",
          "error"
        );
      });
  }

  function loadMessages() {
    // Legacy function - now redirects to counselor-specific loading
    loadMessagesWithCounselor();
  }

  function displayMessages(messages) {
    const container = document.getElementById("messagesContainer");
    if (!container) return;

    // Always render a clean view for the currently selected counselor
    container.innerHTML = "";

    if (!messages || messages.length === 0) {
      container.innerHTML = `
                <div class="system-message">
                    Welcome! Send a message to get started.
                </div>
            `;
      return;
    }

    // Sort by timestamp ASC and render all
    messages.sort((a, b) => new Date(a.created_at) - new Date(b.created_at));
    lastMessageId = Math.max(...messages.map((m) => m.message_id || 0));

    const fragment = document.createDocumentFragment();
    messages.forEach((message) => {
      const messageElement = createMessageElement(message);
      fragment.appendChild(messageElement);
    });
    container.appendChild(fragment);
    scrollToBottom();
  }

  function createMessageElement(message) {
    const div = document.createElement("div");
    div.className = `message-bubble ${
      message.sender_id === userId ? "sent" : "received"
    }`;
    // Render fully visible with no animations

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
      openAlertModal("Unable to send message. Please try again.", "error");
      return;
    }

    if (!selectedCounselorId) {
      console.error("No counselor selected");
      openAlertModal("Please select a counselor first.", "error");
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
    formData.append("receiver_id", selectedCounselorId);
    formData.append("message", message);

    fetch(window.BASE_URL + "student/message/operations", {
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
          loadMessagesWithCounselor(); // Refresh messages
          // No modal or system banner on success; keep UX quiet
        } else {
          console.error("Failed to send message:", data.message);
          openAlertModal(
            data.message || "Failed to send message. Please try again.",
            "error"
          );
        }
      })
      .catch((error) => {
        console.error("Error sending message:", error);
        openAlertModal(
          "An error occurred while sending the message. Please try again.",
          "error"
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

    // Do not open modals on send success; keep chat unobtrusive

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
    fetch(window.BASE_URL + "student/appointments/get-my-appointments")
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
                            <strong>Purpose:</strong> ${
                              appointment.purpose || "N/A"
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
            openAlertModal("Appointment not found.", "warning");
          }
        } else {
          document.getElementById("appointmentDetailsBody").innerHTML =
            "Failed to load appointment details.";
          openAlertModal("Failed to load appointment details.", "error");
        }
      })
      .catch(() => {
        document.getElementById("appointmentDetailsBody").innerHTML =
          "Error loading appointment details.";
        openAlertModal("Error loading appointment details.", "error");
      });
  }

  // Removed counselor selection modal and logic (moved to student/messages)

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

  // PDS Reminder Popup functionality
  function initializePdsReminder() {
    const pdsReminderModal = document.getElementById("pdsReminderModal");
    const closePdsReminder = document.getElementById("closePdsReminder");
    const dismissPdsReminder = document.getElementById("dismissPdsReminder");
    const timerProgress = document.getElementById("timerProgress");
    const timerCountdown = document.getElementById("timerCountdown");

    if (!pdsReminderModal) return;

    let timerInterval = null;
    let timeLeft = 20;

    // Check if this is the initial login (not a page navigation)
    function shouldShowPdsReminder() {
      // Use session storage to track if reminder has been shown in this session
      const reminderShownKey = "pdsReminderShown";
      const hasShownReminder = sessionStorage.getItem(reminderShownKey);

      // Debug logging to help troubleshoot
      SecureLogger.info("PDS Reminder Debug:", {
        hasShownReminder: hasShownReminder,
        referrer: document.referrer,
        currentPath: window.location.pathname,
      });

      // If reminder hasn't been shown in this session, show it
      if (!hasShownReminder) {
        SecureLogger.info("PDS Reminder: Showing (first time in session)");
        return true;
      }

      // Check referrer for additional context
      const referrer = document.referrer;

      // If coming from login page or auth pages, show reminder again
      if (
        referrer &&
        (referrer.includes("/auth") ||
          referrer.includes("/login") ||
          referrer.includes("/signup"))
      ) {
        SecureLogger.info("PDS Reminder: Showing (from auth pages)");
        return true;
      }

      // If coming from landing page (root), show reminder again
      if (
        referrer &&
        referrer.includes("/") &&
        referrer.endsWith("/") &&
        !referrer.includes("/student/")
      ) {
        SecureLogger.info("PDS Reminder: Showing (from landing page)");
        return true;
      }

      // If coming from other pages within the app, don't show
      SecureLogger.info("PDS Reminder: Not showing (already shown in session)");
      return false;
    }

    // Function to update timer
    function updateTimer() {
      timeLeft--;
      const progressPercentage = (timeLeft / 20) * 100;

      if (timerProgress) {
        timerProgress.style.width = progressPercentage + "%";
      }

      if (timerCountdown) {
        timerCountdown.textContent = timeLeft;
      }

      if (timeLeft <= 0) {
        closePdsReminderModal();
      }
    }

    // Function to close modal
    function closePdsReminderModal() {
      if (timerInterval) {
        clearInterval(timerInterval);
        timerInterval = null;
      }

      // Mark reminder as shown in session storage
      sessionStorage.setItem("pdsReminderShown", "true");
      SecureLogger.info("PDS Reminder: Marked as shown in session");

      const modal = bootstrap.Modal.getInstance(pdsReminderModal);
      if (modal) {
        modal.hide();
      }
    }

    // Function to show modal
    function showPdsReminderModal() {
      SecureLogger.info("PDS Reminder: Attempting to show modal");

      // Reset timer
      timeLeft = 20;
      if (timerProgress) {
        timerProgress.style.width = "100%";
      }
      if (timerCountdown) {
        timerCountdown.textContent = "20";
      }

      // Show modal
      const modal = new bootstrap.Modal(pdsReminderModal, {
        backdrop: false,
        keyboard: false,
      });
      modal.show();
      SecureLogger.info("PDS Reminder: Modal shown successfully");

      // Start timer
      timerInterval = setInterval(updateTimer, 1000);
    }

    // Event listeners
    if (closePdsReminder) {
      closePdsReminder.addEventListener("click", closePdsReminderModal);
    }

    if (dismissPdsReminder) {
      dismissPdsReminder.addEventListener("click", closePdsReminderModal);
    }

    // Only show modal if this is an initial login
    SecureLogger.info("PDS Reminder: Checking if should show reminder");
    if (shouldShowPdsReminder()) {
      SecureLogger.info("PDS Reminder: Will show modal in 1 second");
      // Show modal after a short delay to ensure page is fully loaded
      setTimeout(showPdsReminderModal, 1000);
    } else {
      SecureLogger.info("PDS Reminder: Not showing modal");
    }
  }

  // Initialize PDS reminder when DOM is loaded
  initializePdsReminder();

  // Make sure the function is defined globally if using onclick attribute
  window.redirectToProfilePage = function () {
    const redirectPath = "student/profile";
    window.location.href =
      redirectPath.startsWith("http") || redirectPath.startsWith("/")
        ? redirectPath
        : window.BASE_URL + redirectPath;
  };

  // Drawer open/close behavior (always enabled)
  function openDrawer() {
    if (navbarDrawer) navbarDrawer.classList.add("show");
    if (navbarOverlay) navbarOverlay.classList.add("show");
    document.body.style.overflow = "hidden";
    if (navbarDrawerToggler) navbarDrawerToggler.classList.add("active");
  }

  if (navbarDrawerToggler) {
    navbarDrawerToggler.addEventListener("click", openDrawer);
  }

  function closeDrawer() {
    if (navbarDrawer) navbarDrawer.classList.remove("show");
    if (navbarOverlay) navbarOverlay.classList.remove("show");
    document.body.style.overflow = "";
    if (navbarDrawerToggler) navbarDrawerToggler.classList.remove("active");
  }

  if (navbarDrawerClose) {
    navbarDrawerClose.addEventListener("click", closeDrawer);
  }

  if (navbarOverlay) {
    navbarOverlay.addEventListener("click", closeDrawer);
  }

  // One-shot click animation for drawer items
  document.querySelectorAll("#navbarDrawer .nav-link").forEach(function (link) {
    link.addEventListener("click", function () {
      link.classList.remove("drawer-item-click");
      void link.offsetWidth;
      link.classList.add("drawer-item-click");
    });
  });

  // ========== EVENTS & QUOTES SHOWCASE ==========
  let eventsCarouselTimer = null;
  let quoteRotationIntervals = [];
  let quoteRotationTimeouts = [];

  function loadEventsCarousel() {
    fetch((window.BASE_URL || "/") + "student/events/all")
      .then((response) => {
        if (!response.ok) {
          throw new Error("Network response was not ok");
        }
        return response.json();
      })
      .then((data) => {
        if (data.status === "success" && Array.isArray(data.events)) {
          const upcomingEvents = (data.events || [])
            .filter((event) => isUpcomingEvent(event))
            .sort((a, b) => {
              const dateA = new Date(a.date);
              const dateB = new Date(b.date);
              return dateA - dateB;
            });
          renderEventsCarousel(upcomingEvents);
        } else {
          renderEventsCarousel([]);
        }
      })
      .catch((error) => {
        console.error("Error loading events carousel:", error);
        renderEventsCarousel([]);
      });
  }

  function isUpcomingEvent(event) {
    if (!event || !event.date) {
      return false;
    }
    const today = new Date();
    const midnight = new Date(
      today.getFullYear(),
      today.getMonth(),
      today.getDate()
    );
    const eventDate = new Date(event.date);
    return eventDate >= midnight;
  }

  function renderEventsCarousel(events) {
    const track = document.getElementById("eventsCarouselTrack");
    const dotsContainer = document.getElementById("eventsCarouselDots");
    const prevBtn = document.getElementById("eventsCarouselPrev");
    const nextBtn = document.getElementById("eventsCarouselNext");
    const controls = document.getElementById("eventsCarouselControls");
    const emptyState = document.getElementById("eventsCarouselEmpty");

    if (
      !track ||
      !dotsContainer ||
      !prevBtn ||
      !nextBtn ||
      !controls ||
      !emptyState
    ) {
      return;
    }

    track.innerHTML = "";
    dotsContainer.innerHTML = "";
    clearEventsCarouselTimer();

    if (!events || events.length === 0) {
      controls.setAttribute("hidden", "hidden");
      emptyState.removeAttribute("hidden");
      return;
    }

    emptyState.setAttribute("hidden", "hidden");
    controls.removeAttribute("hidden");

    events.forEach((event, index) => {
      track.appendChild(buildEventSlide(event));

      const dot = document.createElement("span");
      dot.className = `dot ${index === 0 ? "active" : ""}`;
      dot.dataset.slide = String(index);
      dotsContainer.appendChild(dot);
    });

    let currentSlide = 0;
    const totalSlides = events.length;
    const dots = dotsContainer.querySelectorAll(".dot");

    function updateCarousel() {
      track.style.transform = `translateX(-${currentSlide * 100}%)`;
      dots.forEach((dot, index) => {
        dot.classList.toggle("active", index === currentSlide);
      });
    }

    function showNextSlide() {
      currentSlide = (currentSlide + 1) % totalSlides;
      updateCarousel();
    }

    function showPreviousSlide() {
      currentSlide = (currentSlide - 1 + totalSlides) % totalSlides;
      updateCarousel();
    }

    prevBtn.onclick = showPreviousSlide;
    nextBtn.onclick = showNextSlide;

    dots.forEach((dot) => {
      dot.addEventListener("click", (event) => {
        const target = event.target;
        if (
          !(target instanceof HTMLElement) ||
          typeof target.dataset.slide === "undefined"
        ) {
          return;
        }
        const parsedIndex = Number.parseInt(target.dataset.slide, 10);
        if (!Number.isNaN(parsedIndex)) {
          currentSlide = parsedIndex;
          updateCarousel();
        }
      });
    });

    eventsCarouselTimer = window.setInterval(showNextSlide, 6000);
    updateCarousel();
  }

  function clearEventsCarouselTimer() {
    if (eventsCarouselTimer) {
      clearInterval(eventsCarouselTimer);
      eventsCarouselTimer = null;
    }
  }

  function buildEventSlide(event) {
    const slide = document.createElement("div");
    slide.className = "carousel-slide";

    const badgeLabel = getEventBadgeLabel(event);
    const eventDateLabel = formatEventDate(event.date);
    const eventTimeLabel = formatEventTime(event.time);
    const eventLocationLabel = event.location ? `📍 ${event.location}` : "";

    const metaItems = [
      eventDateLabel ? `📅 ${eventDateLabel}` : "",
      eventTimeLabel ? `🕐 ${eventTimeLabel}` : "",
      eventLocationLabel,
    ].filter(Boolean);

    // CHANGED: New structure with header container
    slide.innerHTML = `
        <div class="carousel-slide-header">
            <span class="event-badge">${escapeHtml(badgeLabel)}</span>
            <h4 class="event-title">${escapeHtml(
              event.title || "Upcoming Event"
            )}</h4>
            <div class="event-meta">
                ${metaItems
                  .map(
                    (item) =>
                      `<span class="event-meta-item">${escapeHtml(item)}</span>`
                  )
                  .join("")}
            </div>
        </div>
        <p class="event-description">${escapeHtml(
          event.description || "Stay tuned for more details about this event."
        )}</p>
    `;

    return slide;
  }

  function getEventBadgeLabel(event) {
    if (!event) {
      return "Event";
    }
    const possibleFields = [
      event.type,
      event.event_type,
      event.category,
      event.event_category,
      event.tag,
    ].filter((value) => typeof value === "string" && value.trim().length > 0);

    if (possibleFields.length === 0) {
      return "Event";
    }

    return possibleFields[0];
  }

  function formatEventDate(dateString) {
    if (!dateString) {
      return "";
    }
    const date = new Date(dateString);
    if (Number.isNaN(date.getTime())) {
      return "";
    }
    return date.toLocaleDateString(undefined, {
      weekday: "long",
      month: "short",
      day: "numeric",
      year: "numeric",
    });
  }

  function formatEventTime(timeString) {
    if (!timeString) {
      return "";
    }
    const time = new Date(`1970-01-01T${timeString}`);
    if (Number.isNaN(time.getTime())) {
      return "";
    }
    return time.toLocaleTimeString(undefined, {
      hour: "2-digit",
      minute: "2-digit",
    });
  }

  function loadQuotesShowcase() {
    fetch((window.BASE_URL || "/") + "student/quotes/approved-quotes")
      .then((response) => response.json())
      .then((data) => {
        if (
          data.success &&
          Array.isArray(data.quotes) &&
          data.quotes.length > 0
        ) {
          initializeQuoteCards(data.quotes);
        } else {
          initializeQuoteCards(null);
        }
      })
      .catch((error) => {
        console.error("Error loading quotes showcase:", error);
        initializeQuoteCards(null);
      });
  }

  // Find this function in student_dashboard.js (around line 1110)
  // Replace the entire initializeQuoteCards function with this version:

  function initializeQuoteCards(quotes) {
    const container = document.getElementById("quoteCards");
    if (!container) {
      return;
    }

    const cards = container.querySelectorAll(".quote-card");
    if (!cards.length) {
      return;
    }

    clearQuoteRotations();

    const groups = distributeQuotesAcrossCards(quotes, cards.length);
    const rotationDelay = 15000; // CHANGED from 6000 to 10000 (10 seconds)
    const indices = new Array(cards.length).fill(0);

    function updateCard(cardIndex, immediate) {
      const card = cards[cardIndex];
      const quoteGroup = groups[cardIndex];
      if (!card || !quoteGroup || quoteGroup.length === 0) {
        return;
      }

      const applyQuote = () => {
        const quote = quoteGroup[indices[cardIndex]];
        const iconElement = card.querySelector(".quote-icon");
        const textElement = card.querySelector(".quote-text");
        const authorElement = card.querySelector(".quote-author");

        const icon = quote.icon || getCategoryIcon(quote.category) || "📝";
        if (iconElement) {
          iconElement.textContent = icon;
        }
        if (textElement) {
          textElement.textContent =
            quote.quote_text ||
            quote.text ||
            "Stay strong and keep moving forward.";
        }

        if (authorElement) {
          const author = quote.author_name || quote.author || "";
          authorElement.textContent = author ? `— ${author}` : "";
        }

        indices[cardIndex] = (indices[cardIndex] + 1) % quoteGroup.length;
      };

      if (immediate) {
        applyQuote();
        card.classList.remove("hidden");
        return;
      }

      // Fade out with smooth transition
      card.classList.add("hidden");
      const hideTimeout = window.setTimeout(() => {
        applyQuote();
        const showTimeout = window.setTimeout(() => {
          card.classList.remove("hidden");
        }, 60); // Small delay for smooth transition
        quoteRotationTimeouts.push(showTimeout);
      }, 500); // Wait for fade out to complete (matches CSS transition)

      quoteRotationTimeouts.push(hideTimeout);
    }

    // Initialize all cards with their first quotes immediately
    cards.forEach((_, index) => updateCard(index, true));

    // Start rotation with staggered timing for visual interest
    cards.forEach((_, index) => {
      // Stagger the start time: card 0 starts first, card 1 after 3.33s, card 2 after 6.66s
      const initialDelay = rotationDelay + index * 3333; // CHANGED from 1800 to 3333 (10000/3)
      const timeoutId = window.setTimeout(() => {
        updateCard(index, false);
        // Then continue rotating every 10 seconds
        const intervalId = window.setInterval(
          () => updateCard(index, false),
          rotationDelay
        );
        quoteRotationIntervals.push(intervalId);
      }, initialDelay);
      quoteRotationTimeouts.push(timeoutId);
    });
  }

  function distributeQuotesAcrossCards(quotes, cardCount) {
    const fallbackGroups = getFallbackQuoteGroups();

    if (!Array.isArray(quotes) || quotes.length === 0) {
      return fallbackGroups;
    }

    const groups = Array.from({ length: cardCount }, () => []);

    quotes.forEach((quote, index) => {
      const targetIndex = index % cardCount;
      groups[targetIndex].push({
        quote_text: quote.quote_text || "",
        author_name: quote.author_name || "",
        category: quote.category || "",
        icon: getCategoryIcon(quote.category),
      });
    });

    return groups.map((group, index) => {
      if (group.length === 0) {
        return fallbackGroups[index % fallbackGroups.length];
      }
      return group;
    });
  }

  function getFallbackQuoteGroups() {
    return [
      [
        {
          quote_text:
            "Growth begins at the end of your comfort zone. Every step you take towards healing matters.",
          author_name: "Daily Inspiration",
          icon: "🌱",
        },
        {
          quote_text:
            "Be patient with yourself. Growth is not linear, and every small step forward counts.",
          author_name: "Wellness Guide",
          icon: "🌱",
        },
      ],
      [
        {
          quote_text:
            "You are stronger than you think. Seeking support shows courage and self-awareness.",
          author_name: "Counseling Wisdom",
          icon: "💪",
        },
        {
          quote_text:
            "Sometimes the bravest thing you can do is share how you truly feel.",
          author_name: "Courage Corner",
          icon: "💪",
        },
      ],
      [
        {
          quote_text:
            "Take your journey one day at a time. Celebrate every small victory.",
          author_name: "Mindful Living",
          icon: "🌟",
        },
        {
          quote_text:
            "Healing is not a destination but a journey. Honor where you are right now.",
          author_name: "Wellness Path",
          icon: "🌟",
        },
      ],
    ];
  }

  function clearQuoteRotations() {
    quoteRotationIntervals.forEach((intervalId) => clearInterval(intervalId));
    quoteRotationTimeouts.forEach((timeoutId) => clearTimeout(timeoutId));
    quoteRotationIntervals = [];
    quoteRotationTimeouts = [];
  }

  // Initial load and scheduled refresh
  loadEventsCarousel();
  loadQuotesShowcase();

  setInterval(loadEventsCarousel, 10 * 60 * 1000);
  setInterval(loadQuotesShowcase, 5 * 60 * 1000);

  // ========== END EVENTS & QUOTES SHOWCASE ==========

  // Get category icon
  function getCategoryIcon(category) {
    const icons = {
      Inspirational: "✨",
      Motivational: "💪",
      Wisdom: "🦉",
      Life: "🌱",
      Success: "🎯",
      Education: "📚",
      Perseverance: "🏔️",
      Courage: "🦁",
      Hope: "🌟",
      Kindness: "💝",
    };
    return icons[category] || "📝";
  }

  function escapeHtml(text) {
    return String(text)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;");
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
  const url = baseUrl + 'student/resources/get';
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
    downloadStudentResource(resourceId);
    return;
  }
});

// Download function for student resources
function downloadStudentResource(id) {
  const baseUrl = window.BASE_URL || '/';
  window.location.href = baseUrl + 'student/resources/download/' + id;
}

// Load resources on page load
loadResources();
// ========== END RESOURCES ACCORDION ==========
});
