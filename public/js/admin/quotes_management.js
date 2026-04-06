// Admin Quotes Management JavaScript

document.addEventListener('DOMContentLoaded', function() {
    const openQuotesModalBtn = document.getElementById('openQuotesModalBtn');
    const quotesManagementModal = document.getElementById('quotesManagementModal');
    const rejectionReasonModal = document.getElementById('rejectionReasonModal');
    const confirmRejectionBtn = document.getElementById('confirmRejectionBtn');
    const rejectionReasonForm = document.getElementById('rejectionReasonForm');
    
    let currentRejectingQuoteId = null;
    
    // Open quotes modal (desktop and mobile buttons)
    const openQuotesModalBtnMobile = document.getElementById('openQuotesModalBtnMobile');
    
    function openQuotesModal() {
        if (quotesManagementModal) {
            const modal = new bootstrap.Modal(quotesManagementModal);
            modal.show();
            loadAllQuotes();
        }
    }
    
    if (openQuotesModalBtn && quotesManagementModal) {
        openQuotesModalBtn.addEventListener('click', openQuotesModal);
    }
    
    if (openQuotesModalBtnMobile && quotesManagementModal) {
        openQuotesModalBtnMobile.addEventListener('click', openQuotesModal);
    }
    
    // Load all quotes
    function loadAllQuotes() {
        fetch(window.BASE_URL + 'admin/quotes/all', {
            method: 'GET',
            credentials: 'include'
        })
        .then(response => response.json())
        .then(data => {
            if (data.success && data.quotes) {
                displayQuotesByStatus(data.quotes);
                updateQuoteCounts(data.quotes);
            } else {
                showError('Failed to load quotes');
            }
        })
        .catch(error => {
            console.error('Error loading quotes:', error);
            showError('An error occurred while loading quotes');
        });
    }
    
    // Display quotes by status
    function displayQuotesByStatus(quotes) {
        const pendingQuotes = quotes.filter(q => q.status === 'pending');
        const approvedQuotes = quotes.filter(q => q.status === 'approved');
        const rejectedQuotes = quotes.filter(q => q.status === 'rejected');
        
        displayQuotesList('pendingQuotesList', pendingQuotes, true);
        displayQuotesList('approvedQuotesList', approvedQuotes, false);
        displayQuotesList('rejectedQuotesList', rejectedQuotes, false);
    }
    
    // Display quotes list
    function displayQuotesList(containerId, quotes, showActions) {
        const container = document.getElementById(containerId);
        if (!container) return;
        
        if (quotes.length === 0) {
            container.innerHTML = `
                <div class="text-center py-4">
                    <i class="fas fa-inbox fa-2x text-muted mb-3"></i>
                    <p class="text-muted">No quotes found</p>
                </div>
            `;
            return;
        }
        
        container.innerHTML = '';
        
        quotes.forEach(quote => {
            const quoteCard = createQuoteCard(quote, showActions);
            container.appendChild(quoteCard);
        });
    }
    
    // Create quote card
    function createQuoteCard(quote, showActions) {
        const card = document.createElement('div');
        card.className = 'card mb-3';
        
        const statusClass = {
            'pending': 'border-warning',
            'approved': 'border-success',
            'rejected': 'border-danger'
        }[quote.status] || 'border-secondary';
        
        card.classList.add(statusClass);
        
        const categoryIcon = getCategoryIcon(quote.category);
        const statusBadge = getStatusBadge(quote.status);
        
        let actionsHtml = '';
        if (showActions && quote.status === 'pending') {
            actionsHtml = `
                <div class="d-flex gap-2 mt-3">
                    <button class="btn btn-sm btn-success approve-quote-btn" data-quote-id="${quote.id}" type="button">
                        <i class="fas fa-check me-1"></i>Approve
                    </button>
                    <button class="btn btn-sm btn-danger reject-quote-btn" data-quote-id="${quote.id}" type="button">
                        <i class="fas fa-times me-1"></i>Reject
                    </button>
                </div>
            `;
        }
        
        let rejectionReasonHtml = '';
        if (quote.status === 'rejected' && quote.rejection_reason) {
            rejectionReasonHtml = `
                <div class="alert alert-danger mt-2 mb-0">
                    <strong><i class="fas fa-info-circle me-1"></i>Rejection Reason:</strong><br>
                    ${escapeHtml(quote.rejection_reason)}
                </div>
            `;
        }
        
        let moderationInfo = '';
        if (quote.moderated_at && quote.moderator_username) {
            const action = quote.status === 'approved' ? 'Approved' : 'Rejected';
            moderationInfo = `
                <small class="text-muted d-block mt-2">
                    <i class="fas fa-user-check me-1"></i>
                    ${action} by ${escapeHtml(quote.moderator_username)} on ${formatDate(quote.moderated_at)}
                </small>
            `;
        }
        
        card.innerHTML = `
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-start mb-2">
                    <h6 class="card-title mb-0">
                        <i class="fas fa-user me-2"></i>${escapeHtml(quote.author_name)}
                    </h6>
                    ${statusBadge}
                </div>
                
                <p class="card-text">${escapeHtml(quote.quote_text)}</p>
                
                <div class="d-flex flex-wrap gap-2 align-items-center">
                    <span class="badge bg-secondary">
                        ${categoryIcon} ${escapeHtml(quote.category)}
                    </span>
                    ${quote.source ? `
                        <span class="badge bg-info">
                            <i class="fas fa-book me-1"></i>${escapeHtml(quote.source)}
                        </span>
                    ` : ''}
                    <small class="text-muted ms-auto">
                        <i class="fas fa-user-tie me-1"></i>Submitted by ${escapeHtml(quote.submitted_by_name || quote.submitted_by_id)}
                    </small>
                </div>
                
                <small class="text-muted d-block mt-2">
                    <i class="fas fa-calendar me-1"></i>
                    Submitted ${formatDate(quote.submitted_at)}
                </small>
                
                ${moderationInfo}
                ${rejectionReasonHtml}
                ${actionsHtml}
            </div>
        `;
        
        // Attach event listeners for action buttons
        if (showActions && quote.status === 'pending') {
            const approveBtn = card.querySelector('.approve-quote-btn');
            const rejectBtn = card.querySelector('.reject-quote-btn');
            
            if (approveBtn) {
                approveBtn.addEventListener('click', function() {
                    approveQuote(quote.id);
                });
            }
            
            if (rejectBtn) {
                rejectBtn.addEventListener('click', function() {
                    openRejectionModal(quote.id);
                });
            }
        }
        
        return card;
    }
    
    // Approve quote
    function approveQuote(quoteId) {
        // Find the approve button and store original state
        const approveButtons = document.querySelectorAll(`.approve-quote-btn[data-quote-id="${quoteId}"]`);
        let buttonStates = [];
        
        approveButtons.forEach(btn => {
            buttonStates.push({
                element: btn,
                originalHtml: btn.innerHTML,
                originalDisabled: btn.disabled
            });
        });
        
        // Show confirmation modal
        if (typeof openConfirmationModal === 'function') {
            openConfirmationModal('Are you sure you want to approve this quote?', () => {
                // Set loading state on all matching buttons
                buttonStates.forEach(state => {
                    state.element.disabled = true;
                    state.element.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Approving...';
                });
                
                doApproveQuote(quoteId, buttonStates);
            });
        } else {
            if (confirm('Are you sure you want to approve this quote?')) {
                // Set loading state
                buttonStates.forEach(state => {
                    state.element.disabled = true;
                    state.element.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Approving...';
                });
                
                doApproveQuote(quoteId, buttonStates);
            }
        }
    }

    function doApproveQuote(quoteId, buttonStates) {
        fetch(window.BASE_URL + 'admin/quotes/approve/' + quoteId, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-Requested-With': 'XMLHttpRequest'
            },
            credentials: 'include'
        })
            .then(response => response.json())
            .then(data => {
                // Restore button states
                if (buttonStates && buttonStates.length > 0) {
                    buttonStates.forEach(state => {
                        state.element.disabled = state.originalDisabled;
                        state.element.innerHTML = state.originalHtml;
                    });
                }
                
                if (data.success) {
                    showSuccess(data.message || 'Quote approved successfully');
                    loadAllQuotes();
                } else {
                    showError(data.message || 'Failed to approve quote');
                }
            })
            .catch(error => {
                console.error('Error approving quote:', error);
                
                // Restore button states on error
                if (buttonStates && buttonStates.length > 0) {
                    buttonStates.forEach(state => {
                        state.element.disabled = state.originalDisabled;
                        state.element.innerHTML = state.originalHtml;
                    });
                }
                
                showError('An error occurred while approving the quote');
            });
    }
    
    // Open rejection modal
    function openRejectionModal(quoteId) {
        currentRejectingQuoteId = quoteId;
        const modal = new bootstrap.Modal(rejectionReasonModal);
        modal.show();
        
        // Reset form
        if (rejectionReasonForm) {
            rejectionReasonForm.reset();
        }
    }
    
    // Confirm rejection
    if (confirmRejectionBtn) {
        confirmRejectionBtn.addEventListener('click', function() {
            if (!rejectionReasonForm || !rejectionReasonForm.checkValidity()) {
                rejectionReasonForm.reportValidity();
                return;
            }
            
            const reason = document.getElementById('rejectionReason').value.trim();
            if (!reason) {
                showError('Please provide a rejection reason');
                return;
            }
            
            if (!currentRejectingQuoteId) {
                showError('Quote ID not found');
                return;
            }
            
            // Store original button state and set loading state
            const originalBtnHtml = confirmRejectionBtn.innerHTML;
            const originalBtnDisabled = confirmRejectionBtn.disabled;
            
            confirmRejectionBtn.disabled = true;
            confirmRejectionBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Rejecting...';
            
            const formData = new FormData();
            formData.append('reason', reason);
            
            fetch(window.BASE_URL + 'admin/quotes/reject/' + currentRejectingQuoteId, {
                method: 'POST',
                body: formData,
                credentials: 'include'
            })
            .then(response => response.json())
            .then(data => {
                // Restore button state
                confirmRejectionBtn.disabled = originalBtnDisabled;
                confirmRejectionBtn.innerHTML = originalBtnHtml;
                
                if (data.success) {
                    const modalInstance = bootstrap.Modal.getInstance(rejectionReasonModal);
                    if (modalInstance) {
                        modalInstance.hide();
                    }
                    showSuccess(data.message || 'Quote rejected successfully');
                    currentRejectingQuoteId = null;
                    loadAllQuotes();
                } else {
                    showError(data.message || 'Failed to reject quote');
                }
            })
            .catch(error => {
                console.error('Error rejecting quote:', error);
                
                // Restore button state on error
                confirmRejectionBtn.disabled = originalBtnDisabled;
                confirmRejectionBtn.innerHTML = originalBtnHtml;
                
                showError('An error occurred while rejecting the quote');
            });
        });
    }
    
    // Update quote counts
    function updateQuoteCounts(quotes) {
        const pendingCount = quotes.filter(q => q.status === 'pending').length;
        const approvedCount = quotes.filter(q => q.status === 'approved').length;
        const rejectedCount = quotes.filter(q => q.status === 'rejected').length;
        
        const pendingBadge = document.getElementById('pending-count');
        const approvedBadge = document.getElementById('approved-count');
        const rejectedBadge = document.getElementById('rejected-count');
        
        if (pendingBadge) pendingBadge.textContent = pendingCount;
        if (approvedBadge) approvedBadge.textContent = approvedCount;
        if (rejectedBadge) rejectedBadge.textContent = rejectedCount;
    }
    
    // Get status badge
    function getStatusBadge(status) {
        const badges = {
            'pending': '<span class="badge bg-warning"><i class="fas fa-clock me-1"></i>Pending</span>',
            'approved': '<span class="badge bg-success"><i class="fas fa-check-circle me-1"></i>Approved</span>',
            'rejected': '<span class="badge bg-danger"><i class="fas fa-times-circle me-1"></i>Rejected</span>'
        };
        return badges[status] || '<span class="badge bg-secondary">Unknown</span>';
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
    
    // Format date
    function formatDate(dateString) {
        if (!dateString) return 'N/A';
        try {
            const date = new Date(dateString);
            return date.toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'short',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            });
        } catch (error) {
            return dateString;
        }
    }
    
    // Escape HTML
    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
    
    // Show success message
    function showSuccess(message) {
        if (typeof openAlertModal === 'function') {
            openAlertModal(message, 'success');
        } else {
            alert(message);
        }
    }
    
    // Show error message
    function showError(message) {
        if (typeof openAlertModal === 'function') {
            openAlertModal(message, 'danger');
        } else {
            alert(message);
        }
    }
});

