// ==================================================================
// FINAL FIX FOR COUNSELOR MESSAGES PAGE
// This file should REPLACE your entire counselor_messages.js
// ==================================================================

// Global variables
let currentUserId = null;
let messageUpdateInterval = null;
const API_BASE_URL = window.BASE_URL || '/';
let isSearching = false;
let searchTimeout = null;
let lastMessageTimestamp = null;
let lastActiveConversation = null;
let lastGlobalMessageTimestamp = null;
let autoSelectUserId = null;

// Debug logging
SecureLogger.info('Counselor Message JS file loaded');

// Small helper to normalize image URLs
function resolveImageUrl(path) {
    try {
        if (!path) return (window.BASE_URL || '/') + 'Photos/profile.png';
        const trimmed = String(path).trim();
        if (/^https?:\/\//i.test(trimmed)) return trimmed;
        if (trimmed.startsWith('/')) return (window.BASE_URL || '/') + trimmed.replace(/^\/+/, '');
        return (window.BASE_URL || '/') + trimmed;
    } catch (_) {
        return (window.BASE_URL || '/') + 'Photos/profile.png';
    }
}

// Initialize mobile sidebar functionality - COMPLETELY REWRITTEN
function initializeMobileSidebar() {
    const mobileSidebarToggle = document.getElementById('mobileSidebarToggle');
    const conversationsSidebar = document.getElementById('conversationsSidebar');
    const mobileSidebarOverlay = document.getElementById('mobileSidebarOverlay');
    const mainSidebar = document.getElementById('uniSidebar');
    const mainSidebarOverlay = document.getElementById('sidebarOverlay');
    
    if (!mobileSidebarToggle || !conversationsSidebar || !mobileSidebarOverlay) {
        SecureLogger.info('Conversations sidebar elements not found');
        return;
    }
    
    SecureLogger.info('Initializing mobile conversations sidebar');
    
    // Function to close conversations sidebar
    function closeConversationsSidebar() {
        conversationsSidebar.classList.remove('active');
        mobileSidebarOverlay.classList.remove('active');
        mobileSidebarToggle.classList.remove('hidden');
        document.body.classList.remove('conversations-sidebar-open');
        SecureLogger.info('Conversations sidebar closed');
    }
    
    // Function to open conversations sidebar
    function openConversationsSidebar() {
        // Only open if main sidebar is NOT active
        if (mainSidebar && mainSidebar.classList.contains('active')) {
            SecureLogger.info('Cannot open conversations sidebar - main sidebar is active');
            return;
        }
        conversationsSidebar.classList.add('active');
        mobileSidebarOverlay.classList.add('active');
        mobileSidebarToggle.classList.add('hidden');
        document.body.classList.add('conversations-sidebar-open');
        SecureLogger.info('Conversations sidebar opened');
    }
    
    // Toggle conversations sidebar - Use mousedown for faster response
    mobileSidebarToggle.addEventListener('mousedown', function(e) {
        e.stopPropagation();
        e.preventDefault();
        
        SecureLogger.info('Mobile sidebar toggle clicked');
        
        // Check if main sidebar is open
        if (mainSidebar && mainSidebar.classList.contains('active')) {
            SecureLogger.info('Main sidebar is active, ignoring conversations toggle');
            return;
        }
        
        if (conversationsSidebar.classList.contains('active')) {
            closeConversationsSidebar();
        } else {
            openConversationsSidebar();
        }
    });
    
    // Close conversations sidebar when overlay is clicked
    mobileSidebarOverlay.addEventListener('click', function(e) {
        e.stopPropagation();
        e.preventDefault();
        SecureLogger.info('Conversations overlay clicked');
        closeConversationsSidebar();
    });
    
    // Close conversations sidebar when a conversation is selected (mobile only)
    conversationsSidebar.addEventListener('click', function(e) {
        const conversationItem = e.target.closest('.conversation-item');
        if (conversationItem && window.innerWidth <= 768) {
            SecureLogger.info('Conversation item clicked, will close sidebar after selection');
            // Let the click through first, then close
            setTimeout(() => {
                closeConversationsSidebar();
            }, 100);
        }
    });
    
    // Monitor main sidebar state - close conversations sidebar when main opens
    if (mainSidebar) {
        const observer = new MutationObserver(function(mutations) {
            mutations.forEach(function(mutation) {
                if (mutation.attributeName === 'class') {
                    if (mainSidebar.classList.contains('active')) {
                        SecureLogger.info('Main sidebar opened, closing conversations sidebar');
                        closeConversationsSidebar();
                    }
                }
            });
        });
        
        observer.observe(mainSidebar, {
            attributes: true,
            attributeFilter: ['class']
        });
    }
    
    // Also listen to main sidebar overlay to close conversations sidebar
    if (mainSidebarOverlay) {
        mainSidebarOverlay.addEventListener('click', function() {
            if (conversationsSidebar.classList.contains('active')) {
                closeConversationsSidebar();
            }
        });
    }
    
    // Ensure conversations sidebar is closed on initial load (mobile only)
    if (window.innerWidth <= 768) {
        closeConversationsSidebar();
    }
    
    // Handle window resize for conversations sidebar
    let conversationsResizeTimer;
    window.addEventListener('resize', function() {
        clearTimeout(conversationsResizeTimer);
        conversationsResizeTimer = setTimeout(function() {
            if (window.innerWidth > 768) {
                // Desktop: ensure conversations sidebar is visible and reset
                conversationsSidebar.classList.remove('active');
                mobileSidebarOverlay.classList.remove('active');
                mobileSidebarToggle.classList.add('hidden');
                document.body.classList.remove('conversations-sidebar-open');
            } else {
                // Mobile: ensure proper state
                if (!conversationsSidebar.classList.contains('active')) {
                    mobileSidebarToggle.classList.remove('hidden');
                }
            }
        }, 250);
    });
    
    SecureLogger.info('Mobile conversations sidebar initialized successfully');
}

// Initialize the application
document.addEventListener('DOMContentLoaded', async function() {
    SecureLogger.info('DOM Content Loaded');
    try {
        const isLoggedIn = await checkSession();
        if (isLoggedIn) {
            SecureLogger.info('Counselor is logged in, initializing...');
            
            // Wait for sidebar.js to initialize, then initialize conversations sidebar
            setTimeout(() => {
                initializeMobileSidebar();
            }, 500);
            
            // Initialize message input first
            await initializeMessageInput();
            
            // Get the user ID from either URL parameter, localStorage, or highlighted conversation
            const urlParams = new URLSearchParams(window.location.search);
            const userIdFromUrl = urlParams.get('user');
            const userIdFromStorage = localStorage.getItem('selectedConversation');
            const highlightedUserId = localStorage.getItem('highlightConversation');
            const selectedUserId = userIdFromUrl || userIdFromStorage || highlightedUserId;
            
            SecureLogger.info('Selected user ID from URL:', userIdFromUrl);
            SecureLogger.info('Selected user ID from storage:', userIdFromStorage);
            SecureLogger.info('Highlighted user ID:', highlightedUserId);
            
            // Set the global autoSelectUserId
            autoSelectUserId = selectedUserId;
            SecureLogger.info('autoSelectUserId at DOMContentLoaded:', autoSelectUserId);
            
            // Load conversations
            await loadConversations();
            
            // Remove the stored conversation IDs
            localStorage.removeItem('selectedConversation');
            localStorage.removeItem('highlightConversation');
            
            // Remove the URL parameter without refreshing
            if (userIdFromUrl) {
                window.history.replaceState({}, document.title, window.location.pathname);
            }
        } else {
            console.error('Counselor is not logged in');
            window.location.href = (window.BASE_URL || '/') + 'auth/logout';
        }
    } catch (error) {
        console.error('Error during initialization:', error);
        window.location.href = (window.BASE_URL || '/') + 'auth/logout';
    }

    // Add event delegation for sidebar conversation selection
    const userList = document.querySelector('.conversations-list');
    if (userList) {
        userList.addEventListener('click', function(e) {
            const card = e.target.closest('.conversation-item');
            if (card && card.dataset.id) {
                SecureLogger.info('Conversation card clicked:', card.dataset.id);
                selectConversation(card.dataset.id);
            }
        });
    }
    
    // Enable sidebar search
    initializeSearch();

    // Remove dashboard highlight flag when messages.php is opened
    localStorage.removeItem('dashboardMessageHighlight');

    // Auto-select conversation if coming from dashboard
    const selectedUserId = localStorage.getItem('selectedConversation');
    if (selectedUserId) {
        const interval = setInterval(() => {
            const card = document.querySelector(`.conversation-item[data-id='${selectedUserId}']`);
            if (card) {
                if (typeof selectConversation === 'function') {
                    selectConversation(selectedUserId);
                } else {
                    card.click();
                }
                localStorage.removeItem('selectedConversation');
                clearInterval(interval);
            }
        }, 100);
    }
});

// Check session status
async function checkSession() {
    SecureLogger.info('Checking session...');
    try {
        const response = await fetch((window.BASE_URL || '/') + 'counselor/session/check', {
            method: 'GET',
            credentials: 'include',
            headers: {
                'Accept': 'application/json',
                'Cache-Control': 'no-cache'
            }
        });

        if (!response.ok) {
            throw new Error('Network response was not ok');
        }

        const data = await response.json();
        SecureLogger.info('Session check result:', data);

        if (!data.loggedin || !data.user_id || data.role !== 'counselor') {
            console.error('Session invalid:', data);
            return false;
        }

        return true;
    } catch (error) {
        console.error('Session check failed:', error);
        return false;
    }
}

function initializeSearch() {
    const searchInput = document.querySelector('.search-input');
    if (!searchInput) return;
    
    searchInput.addEventListener('input', function() {
        const searchTerm = this.value.toLowerCase();
        const cards = document.querySelectorAll('.conversation-item');
        
        isSearching = !!searchTerm;
        if (searchTimeout) clearTimeout(searchTimeout);
        
        if (isSearching) {
            if (messageUpdateInterval) clearInterval(messageUpdateInterval);
            searchTimeout = setTimeout(() => {
                isSearching = false;
                startMessagePolling();
            }, 10000);
        }
        
        cards.forEach(card => {
            const name = card.querySelector('.conversation-name')?.textContent.toLowerCase() || '';
            const lastMessage = card.querySelector('.conversation-last-message')?.textContent.toLowerCase() || '';
            if (name.includes(searchTerm) || lastMessage.includes(searchTerm)) {
                card.style.display = 'flex';
            } else {
                card.style.display = 'none';
            }
        });
    });
}

// Initialize message input
async function initializeMessageInput() {
    SecureLogger.info('Initializing message input...');
    const messageInput = document.getElementById('message-input');
    const sendButton = document.getElementById('send-button');

    if (!messageInput || !sendButton) {
        console.error('Message input or send button not found');
        return;
    }

    messageInput.disabled = true;
    messageInput.placeholder = 'Select a conversation to reply...';
    sendButton.disabled = true;
    
    initializeChatHeader();

    sendButton.addEventListener('click', sendMessage);
    messageInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });

    messageInput.addEventListener('input', function() {
        this.style.height = 'auto';
        this.style.height = (this.scrollHeight) + 'px';
    });

    SecureLogger.info('Message input initialized');
}

function initializeChatHeader() {
    const chatHeader = document.querySelector('.chat-user-info');
    if (chatHeader) {
        const userNameElement = chatHeader.querySelector('.user-name');
        const userStatusElement = chatHeader.querySelector('.user-status');
        const headerAvatar = chatHeader.querySelector('.user-avatar');
        
        if (userNameElement) userNameElement.textContent = 'Messages';
        if (userStatusElement) {
            userStatusElement.textContent = 'Select a conversation to start messaging';
            userStatusElement.className = 'user-status';
        }
        if (headerAvatar) {
            headerAvatar.innerHTML = '<i class="fas fa-user"></i>';
        }
    }
}

async function startMessagePolling() {
    SecureLogger.info('Starting message polling...');
    if (messageUpdateInterval) clearInterval(messageUpdateInterval);
    messageUpdateInterval = setInterval(async () => {
        if (!isSearching && currentUserId) {
            await loadMessages(currentUserId);
        }
        updateStatusIndicators();
    }, 1500);
}

function updateStatusIndicators() {
    const conversationItems = document.querySelectorAll('.conversation-item');
    conversationItems.forEach(item => {
        const lastActivity = item.dataset.lastActivity;
        const lastLogin = item.dataset.lastLogin;
        const statusElement = item.querySelector('.conversation-status');
        if (statusElement && (lastActivity || lastLogin)) {
            const statusInfo = calculateOnlineStatus(lastActivity, lastLogin, item.dataset.logoutTime);
            statusElement.textContent = statusInfo.text;
            statusElement.className = `conversation-status ${statusInfo.class}`;
        }
    });
    
    if (currentUserId) {
        const activeCard = document.querySelector(`.conversation-item[data-id="${currentUserId}"]`);
        if (activeCard) {
            const userStatusElement = document.querySelector('.user-status');
            if (userStatusElement) {
                const lastActivity = activeCard.dataset.lastActivity;
                const lastLogin = activeCard.dataset.lastLogin;
                const statusInfo = calculateOnlineStatus(lastActivity, lastLogin, activeCard.dataset.logoutTime);
                userStatusElement.textContent = statusInfo.text;
                userStatusElement.className = `user-status ${statusInfo.class}`;
            }
        }
    }
}

function highlightConversation(userId) {
    const card = document.querySelector(`.conversation-item[data-id="${userId}"]`);
    if (card) {
        card.classList.add('highlight-new-message');
        setTimeout(() => {
            card.classList.remove('highlight-new-message');
        }, 2000);
    }
}

async function loadConversations() {
    try {
        const isLoggedIn = await checkSession();
        if (!isLoggedIn) {
            window.location.href = (window.BASE_URL || '/') + 'auth/logout';
            return;
        }

        const userList = document.querySelector('.conversations-list');
        if (!userList) return;

        if (!userList.querySelector('.conversation-item')) {
            userList.innerHTML = '<div class="loading-state"><i class="fas fa-spinner fa-spin"></i><span>Loading conversations...</span></div>';
        }

        const response = await fetch((window.BASE_URL || '/') + 'counselor/message/operations?action=get_conversations', {
            method: 'GET',
            credentials: 'include',
            headers: {
                'Accept': 'application/json',
                'Cache-Control': 'no-cache'
            }
        });

        if (!response.ok) {
            throw new Error('Failed to load conversations');
        }

        const data = await response.json();
        if (data.success) {
            if (Array.isArray(data.conversations) && data.conversations.length > 0) {
                const loading = userList.querySelector('.loading-state');
                if (loading) loading.remove();
                
                updateConversations(data.conversations);
                
                let newestConversation = null;
                let newestTimestamp = lastGlobalMessageTimestamp || 0;
                
                data.conversations.forEach(conv => {
                    if (conv.last_message_time) {
                        const msgTime = new Date(conv.last_message_time).getTime();
                        if (msgTime > newestTimestamp && parseInt(conv.unread_count) > 0) {
                            newestTimestamp = msgTime;
                            newestConversation = conv;
                        }
                    }
                });
                
                if (newestConversation && newestTimestamp > lastGlobalMessageTimestamp) {
                    SecureLogger.info('New message detected in conversation:', newestConversation.user_id);
                    lastGlobalMessageTimestamp = newestTimestamp;
                    
                    if (!currentUserId || newestConversation.user_id === currentUserId) {
                        selectConversation(newestConversation.user_id);
                    } else {
                        highlightConversation(newestConversation.user_id);
                    }
                }
            } else {
                throw new Error(data.message || 'Failed to load conversations');
            }
        }
    } catch (error) {
        console.error('Error:', error);
        const userList = document.querySelector('.conversations-list');
        if (userList && !userList.querySelector('.conversation-item')) {
            userList.innerHTML = `<div class="error-message">${error.message}</div>`;
        }
    }
}

function updateConversations(conversations) {
    const userList = document.querySelector('.conversations-list');
    if (!userList) return;

    if (!Array.isArray(conversations) || conversations.length === 0) {
        if (!userList.querySelector('.no-conversations')) {
            userList.innerHTML = `
            <div class="no-conversations">
                <i class="fas fa-comments"></i>
                <p>No conversations yet</p>
            </div>`;
        }
        return;
    }

    const existingCards = new Map();
    userList.querySelectorAll('.conversation-item').forEach(card => {
        existingCards.set(card.dataset.id, card);
    });

    conversations.forEach(conv => {
        const otherUserId = conv.other_user_id || conv.user_id;
        const otherUserName = conv.other_username || conv.name || 'Unknown';
        const otherAvatar = resolveImageUrl(conv.other_profile_picture || 'Photos/profile.png');
        const unreadCount = parseInt(conv.unread_count) || 0;
        const lastMessage = conv.last_message || 'No messages yet';
        const lastMessageTime = conv.last_message_time ? formatMessageTime(conv.last_message_time) : '';
        const lastMessageType = conv.last_message_type || 'received';
        
        let formattedLastMessage = lastMessage;
        if (lastMessageType === 'sent') {
            formattedLastMessage = `You: ${lastMessage}`;
        } else if (lastMessageType === 'received') {
            formattedLastMessage = `Sent a Message: ${lastMessage}`;
        }
        
        let truncatedLastMessage = formattedLastMessage;
        const maxPreviewLength = 20;
        if (truncatedLastMessage.length > maxPreviewLength) {
            truncatedLastMessage = truncatedLastMessage.substring(0, maxPreviewLength - 3) + '...';
        }
        
        const statusInfo = calculateOnlineStatus(conv.last_activity, conv.last_login, conv.logout_time);
        
        const cardHtml = `
            <div class="conversation-item ${otherUserId === currentUserId ? 'active' : ''}" 
                 data-id="${otherUserId}" data-last-activity="${conv.last_activity || ''}" data-last-login="${conv.last_login || ''}" data-logout-time="${conv.logout_time || ''}">
                <div class="conversation-avatar">
                    <img src="${otherAvatar}" alt="avatar" style="width:46px;height:46px;border-radius:50%;object-fit:cover;"/>
                </div>
                <div class="conversation-details">
                    <div class="conversation-name">${otherUserName}</div>
                    <div class="conversation-last-message">${truncatedLastMessage}</div>
                    <div class="conversation-status ${statusInfo.class}">${statusInfo.text}</div>
                </div>
                <div class="conversation-meta">
                    <div class="conversation-time">${lastMessageTime}</div>
                    ${unreadCount > 0 ? `<span class="unread-badge">${unreadCount}</span>` : ''}
                </div>
            </div>
        `;

        const existingCard = existingCards.get(String(otherUserId));
        if (existingCard) {
            const tempDiv = document.createElement('div');
            tempDiv.innerHTML = cardHtml;
            const newCard = tempDiv.firstElementChild;
            
            const existingName = existingCard.querySelector('.conversation-name');
            const existingMessage = existingCard.querySelector('.conversation-last-message');
            const existingTime = existingCard.querySelector('.conversation-time');
            const existingBadge = existingCard.querySelector('.unread-badge');
            const existingStatus = existingCard.querySelector('.conversation-status');
            
            const newName = newCard.querySelector('.conversation-name');
            const newMessage = newCard.querySelector('.conversation-last-message');
            const newTime = newCard.querySelector('.conversation-time');
            const newBadge = newCard.querySelector('.unread-badge');
            const newStatus = newCard.querySelector('.conversation-status');
            
            if (existingName && newName && existingName.textContent !== newName.textContent) {
                existingName.textContent = newName.textContent;
            }
            if (existingMessage && newMessage && existingMessage.textContent !== newMessage.textContent) {
                existingMessage.textContent = newMessage.textContent;
            }
            if (existingTime && newTime && existingTime.textContent !== newTime.textContent) {
                existingTime.textContent = newTime.textContent;
            }
            
            if (existingStatus && newStatus) {
                existingStatus.textContent = newStatus.textContent;
                existingStatus.className = newStatus.className;
            } else if (newStatus) {
                const conversationDetails = existingCard.querySelector('.conversation-details');
                if (conversationDetails) {
                    conversationDetails.appendChild(newStatus);
                }
            }
            
            if (existingBadge) {
                if (newBadge) {
                    existingBadge.textContent = newBadge.textContent;
                } else {
                    existingBadge.remove();
                }
            } else if (newBadge) {
                existingCard.querySelector('.conversation-meta').appendChild(newBadge);
            }
            
            if (otherUserId === currentUserId) {
                existingCard.classList.add('active');
            } else {
                existingCard.classList.remove('active');
            }
            
            existingCard.dataset.lastActivity = conv.last_activity || '';
            existingCard.dataset.lastLogin = conv.last_login || '';
            
            existingCards.delete(conv.user_id);
        } else {
            const tempDiv = document.createElement('div');
            tempDiv.innerHTML = cardHtml;
            userList.appendChild(tempDiv.firstElementChild);
        }
    });

    existingCards.forEach(card => card.remove());

    const highlightId = localStorage.getItem('highlightStudentCard');
    if (highlightId) {
        setTimeout(() => {
            const card = document.querySelector(`.conversation-item[data-id='${highlightId}']`);
            SecureLogger.info('Highlighting card for userId:', highlightId, 'Found:', !!card);
            if (card) {
                card.classList.add('highlight-student-card');
                setTimeout(() => card.classList.remove('highlight-student-card'), 2000);
            }
            localStorage.removeItem('highlightStudentCard');
        }, 300);
    }

    SecureLogger.info('autoSelectUserId at updateConversations:', autoSelectUserId);
    if (autoSelectUserId) {
        selectConversation(autoSelectUserId);
        autoSelectUserId = null;
    }
}

function pausePolling() {
    if (messageUpdateInterval) clearInterval(messageUpdateInterval);
}

function resumePolling(delay = 1) {
    setTimeout(() => {
        startMessagePolling();
    }, delay);
}

function selectConversation(userId) {
    pausePolling();
    SecureLogger.info('Selecting conversation:', userId);
    if (!userId) return;
    
    lastActiveConversation = currentUserId;
    lastMessageTimestamp = null;
    
    const messagesContainer = document.getElementById('messages-container');
    if (messagesContainer) {
        messagesContainer.innerHTML = `
            <div class="empty-state" id="empty-state">
                <i class="fas fa-inbox"></i>
                <h5>Loading Messages...</h5>
                <p>Please wait while we load the conversation.</p>
            </div>
        `;
    }

    currentUserId = userId;

    document.querySelectorAll('.conversation-item').forEach(card => {
        card.classList.remove('active');
        if (String(card.getAttribute('data-id')) === String(userId)) {
            card.classList.add('active');
            card.classList.add('highlight-new-message');
            setTimeout(() => {
                card.classList.remove('highlight-new-message');
            }, 2000);
            card.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
    });

    const activeCard = document.querySelector(`.conversation-item[data-id="${userId}"]`);
    if (activeCard) {
        const userName = activeCard.querySelector('.conversation-name').textContent;
        const avatarImg = activeCard.querySelector('.conversation-avatar img')?.getAttribute('src');
        const chatHeader = document.querySelector('.chat-user-info');
        if (chatHeader) {
            const userNameElement = chatHeader.querySelector('.user-name');
            const userStatusElement = chatHeader.querySelector('.user-status');
            const headerAvatar = chatHeader.querySelector('.user-avatar');
            if (userNameElement) userNameElement.textContent = userName;
            if (userStatusElement) {
                const lastActivity = activeCard.dataset.lastActivity;
                const lastLogin = activeCard.dataset.lastLogin;
                const logoutTime = activeCard.dataset.logoutTime;
                const statusInfo = calculateOnlineStatus(lastActivity, lastLogin, logoutTime);
                userStatusElement.textContent = statusInfo.text;
                userStatusElement.className = `user-status ${statusInfo.class}`;
            }
            if (headerAvatar && avatarImg) {
                headerAvatar.innerHTML = `<img src="${avatarImg}" alt="avatar" style="width:50px;height:50px;border-radius:50%;object-fit:cover;"/>`;
            }
        }
    }

    const messageInput = document.getElementById('message-input');
    const sendButton = document.getElementById('send-button');

    if (messageInput) {
        messageInput.disabled = false;
        messageInput.placeholder = 'Type your message...';
        messageInput.focus();
    }
    if (sendButton) sendButton.disabled = false;

    loadMessages(userId).then(() => {
        markMessagesAsRead(userId);
        resumePolling();
    });
}

async function loadMessages(userId) {
    try {
        const isLoggedIn = await checkSession();
        if (!isLoggedIn) return;

        if (!userId) {
            console.error('No user ID provided for loading messages');
            return;
        }

        SecureLogger.info('Loading messages for user:', userId);

        const response = await fetch((window.BASE_URL || '/') + `counselor/message/operations?action=get_messages&user_id=${userId}`, {
            method: 'GET',
            credentials: 'include',
            headers: {
                'Accept': 'application/json'
            }
        });

        if (!response.ok) {
            throw new Error('Network response was not ok');
        }

        const data = await response.json();
        SecureLogger.info('Received messages data:', data);

        if (data.success && Array.isArray(data.messages)) {
            const conversationMessages = data.messages.filter(msg => {
                const isCurrentConversation = (msg.sender_id === userId || msg.receiver_id === userId);
                return isCurrentConversation;
            });
            
            if (conversationMessages.length > 0) {
                const latestMessage = conversationMessages[conversationMessages.length - 1];
                const messageTime = new Date(latestMessage.created_at).getTime();
                
                if (!lastMessageTimestamp || messageTime > lastMessageTimestamp) {
                    SecureLogger.info('Updating messages display with:', conversationMessages);
                    lastMessageTimestamp = messageTime;
                    displayMessages(conversationMessages);
                    markMessagesAsRead(userId);
                }
            } else {
                displayMessages([]);
            }
        } else {
            throw new Error(data.message || 'Failed to load messages');
        }
    } catch (error) {
        console.error('Error:', error);
        showErrorMessage(error.message);
    }
}

function displayMessages(messages) {
    const messagesContainer = document.getElementById('messages-container');
    const emptyState = document.getElementById('empty-state');
    
    if (!messagesContainer || !emptyState) return;
    
    SecureLogger.info('Displaying messages:', messages);
    
    if (!Array.isArray(messages) || messages.length === 0) {
        emptyState.style.display = 'flex';
        messagesContainer.innerHTML = `
            <div class="empty-state" id="empty-state">
                <i class="fas fa-inbox"></i>
                <h5>No Messages Yet</h5>
                <p>Start the conversation by sending a message.</p>
            </div>
        `;
        return;
    }

    emptyState.style.display = 'none';
    let html = '<div class="p-3">';
    
    messages.sort((a, b) => new Date(a.created_at) - new Date(b.created_at));
    
    messages.forEach(msg => {
        const isSent = msg.message_type === 'sent';
        const time = formatMessageTime(msg.created_at);
        
        html += `
            <div class="message ${isSent ? 'sent' : 'received'}">
                <div class="message-content">
                    <p class="message-text">${escapeHtml(msg.message_text || '')}</p>
                </div>
                <p class="message-time">${time}</p>
            </div>
        `;
    });

    html += '</div>';
    
    messagesContainer.innerHTML = html;
    
    setTimeout(() => {
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }, 100);
}

function markMessagesAsRead(userId) {
    if (!userId) return;
    
    fetch((window.BASE_URL || '/') + 'counselor/message/operations', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: `action=mark_read&user_id=${userId}`
    })
    .then(response => response.json())
    .then(data => {
        if (!data.success) {
            console.error('Failed to mark messages as read:', data.message);
        }
    })
    .catch(error => {
        console.error('Error marking messages as read:', error);
    });
}

async function sendMessage() {
    pausePolling();
    try {
        const isLoggedIn = await checkSession();
        if (!isLoggedIn) {
            window.location.href = `${API_BASE_URL}/Landing_Page.html`;
            return;
        }
        if (!currentUserId) {
            showErrorMessage('Please select a conversation first');
            return;
        }
        const messageInput = document.getElementById('message-input');
        if (!messageInput || !messageInput.value.trim()) {
            showErrorMessage('Please enter a message');
            return;
        }
        const messageText = messageInput.value.trim();
        const sendButton = document.getElementById('send-button');
        messageInput.disabled = true;
        sendButton.disabled = true;

        const response = await fetch((window.BASE_URL || '/') + 'counselor/message/operations?action=send_message', {
            method: 'POST',
            credentials: 'include',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Accept': 'application/json'
            },
            body: `receiver_id=${currentUserId}&message=${encodeURIComponent(messageText)}`
        });

        if (!response.ok) {
            throw new Error('Network response was not ok');
        }

        const data = await response.json();
        if (data.success) {
            messageInput.value = '';
            messageInput.style.height = 'auto';

            const messagesContainer = document.getElementById('messages-container');
            const newMessageHtml = `
                <div class="d-flex justify-content-end mb-3">
                    <div class="message sent">
                        <div class="message-content bg-primary text-white rounded-3 p-2 px-3 shadow-sm">
                            <p class="mb-1">${escapeHtml(messageText)}</p>
                        </div>
                        <small class="text-white-50 message-time">Just now</small>
                    </div>
                </div>
            `;
            
            const emptyState = document.getElementById('empty-state');
            if (emptyState) {
                emptyState.style.display = 'none';
            }

            if (messagesContainer.innerHTML.includes('empty-state')) {
                messagesContainer.innerHTML = '<div class="p-3">' + newMessageHtml + '</div>';
            } else {
                const messageWrapper = messagesContainer.querySelector('.p-3');
                if (messageWrapper) {
                    messageWrapper.insertAdjacentHTML('beforeend', newMessageHtml);
                }
            }

            messagesContainer.scrollTop = messagesContainer.scrollHeight;
            loadConversations();
            resumePolling(1000);
        } else {
            throw new Error(data.message || 'Failed to send message');
        }
    } catch (error) {
        console.error('Error sending message:', error);
        showErrorMessage(error.message);
        resumePolling();
    } finally {
        const messageInput = document.getElementById('message-input');
        const sendButton = document.getElementById('send-button');
        if (messageInput) {
            messageInput.disabled = false;
            messageInput.focus();
        }
        if (sendButton) {
            sendButton.disabled = false;
        }
    }
}

function formatMessageTime(timestamp) {
    if (!timestamp) return '';
    
    const date = new Date(timestamp);
    const now = new Date();
    const diff = now - date;
    
    if (diff < 60000) {
        return 'Just now';
    }
    
    if (diff < 3600000) {
        const minutes = Math.floor(diff / 60000);
        return `${minutes}m ago`;
    }
    
    if (date.toDateString() === now.toDateString()) {
        return date.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
    }
    
    if (date.getFullYear() === now.getFullYear()) {
        return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    }
    
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
}

function showErrorMessage(message) {
    const errorDiv = document.createElement('div');
    errorDiv.className = 'error-message';
    errorDiv.textContent = message;
    
    document.body.appendChild(errorDiv);
    
    setTimeout(() => {
        errorDiv.remove();
    }, 3000);
}

function calculateOnlineStatus(lastActivity, lastLogin, logoutTime) {
    const activityTime = lastActivity ? new Date(lastActivity) : null;
    const loginTime = lastLogin ? new Date(lastLogin) : null;
    const logoutTimeDate = logoutTime ? new Date(logoutTime) : null;
    
    if (logoutTimeDate && activityTime && logoutTimeDate.getTime() === activityTime.getTime()) {
        return {
            status: 'offline',
            text: 'Offline',
            class: 'status-offline'
        };
    }
    
    let mostRecentTime = null;
    
    if (activityTime && loginTime) {
        mostRecentTime = activityTime > loginTime ? activityTime : loginTime;
    } else if (activityTime) {
        mostRecentTime = activityTime;
    } else if (loginTime) {
        mostRecentTime = loginTime;
    }
    
    if (!mostRecentTime) {
        return {
            status: 'offline',
            text: 'Offline',
            class: 'status-offline'
        };
    }

    const now = new Date();
    const diffInMinutes = Math.floor((now - mostRecentTime) / (1000 * 60));

    if (diffInMinutes <= 5) {
        return {
            status: 'online',
            text: 'Online',
            class: 'status-online'
        };
    } else if (diffInMinutes <= 60) {
        return {
            status: 'active',
            text: `Last active ${diffInMinutes}m ago`,
            class: 'status-active-recent'
        };
    } else {
        return {
            status: 'offline',
            text: 'Offline',
            class: 'status-offline'
        };
    }
}

function escapeHtml(text) {
    return String(text)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/\"/g, '&quot;')
        .replace(/'/g, '&#039;');
}