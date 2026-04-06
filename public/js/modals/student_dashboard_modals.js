// Modal utility functions for user dashboard
function hideActiveModals(excludedId) {
    document.querySelectorAll('.modal.show').forEach((activeModal) => {
        if (!activeModal.id || activeModal.id === excludedId) {
            return;
        }

        const activeInstance = bootstrap.Modal.getInstance(activeModal);
        if (activeInstance) {
            activeInstance.hide();
        }
    });
}

function openConfirmationModal(message, onConfirm = null, options = {}) {
    const messageElement = document.getElementById('confirmationMessageContent');
    const modalElement = document.getElementById('confirmationModal');

    if (!messageElement || !modalElement) {
        console.error('Confirmation modal elements not found');
        if (typeof window.confirm === 'function' && window.confirm(message) && typeof onConfirm === 'function') {
            onConfirm();
        }
        return;
    }

    const settings = {
        autoClose: typeof options.autoClose === 'boolean' ? options.autoClose : true,
        confirmButtonText: options.confirmButtonText || null,
        confirmButtonClass: options.confirmButtonClass || null,
        focusConfirm: options.focusConfirm !== false,
        onShow: typeof options.onShow === 'function' ? options.onShow : null,
        onClose: typeof options.onClose === 'function' ? options.onClose : null,
    };

    messageElement.textContent = message;
    hideActiveModals(modalElement.id);

    const modalInstance = bootstrap.Modal.getOrCreateInstance(modalElement);
    const confirmBtn = document.getElementById('confirmationConfirmBtn');

    if (!confirmBtn) {
        console.error('Confirmation button not found');
        return;
    }

    const newConfirmBtn = confirmBtn.cloneNode(true);
    const defaultConfirmText = confirmBtn.innerHTML;
    const defaultConfirmClass = confirmBtn.className;

    confirmBtn.parentNode.replaceChild(newConfirmBtn, confirmBtn);

    const appliedConfirmText = settings.confirmButtonText || defaultConfirmText;
    const appliedConfirmClass = settings.confirmButtonClass || defaultConfirmClass;

    newConfirmBtn.innerHTML = appliedConfirmText;
    newConfirmBtn.className = appliedConfirmClass;

    const context = {
        modalElement,
        modalInstance,
        confirmButton: newConfirmBtn,
        close: () => modalInstance.hide(),
        setLoading: (loadingText = 'Processing...') => {
            newConfirmBtn.disabled = true;
            newConfirmBtn.innerHTML = `
                <span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>${loadingText}
            `;
        },
        reset: () => {
            newConfirmBtn.disabled = false;
            newConfirmBtn.innerHTML = appliedConfirmText;
            newConfirmBtn.className = appliedConfirmClass;
        },
    };

    newConfirmBtn.onclick = function () {
        if (typeof onConfirm === 'function') {
            if (settings.autoClose) {
                modalInstance.hide();
                onConfirm(context);
            } else {
                onConfirm(context);
            }
        } else if (settings.autoClose) {
            modalInstance.hide();
        }
    };

    modalElement.addEventListener(
        'shown.bs.modal',
        () => {
            if (settings.focusConfirm) {
                newConfirmBtn.focus();
            }

            if (settings.onShow) {
                settings.onShow(context);
            }
        },
        { once: true }
    );

    if (settings.onClose) {
        const handleHidden = () => {
            settings.onClose(context);
            modalElement.removeEventListener('hidden.bs.modal', handleHidden);
        };

        modalElement.addEventListener('hidden.bs.modal', handleHidden);
    }

    modalInstance.show();
}

function openAlertModal(message, type = 'info', options = {}) {
    const messageElement = document.getElementById('alertMessageContent');
    const modalElement = document.getElementById('alertModal');
    const alertIcon = document.getElementById('alertIcon');
    const alertLabel = document.getElementById('alertModalLabel');

    if (!messageElement || !modalElement || !alertIcon || !alertLabel) {
        console.error('Alert modal elements not found');
        window.alert(message);
        return;
    }

    const settings = {
        title: options.title || null,
        keepActiveModals: options.keepActiveModals === true,
    };

    messageElement.textContent = message;
    if (!settings.keepActiveModals) {
        hideActiveModals(modalElement.id);
    }

    const modalInstance = bootstrap.Modal.getOrCreateInstance(modalElement);
    const iconElement = alertIcon.querySelector('i');

    if (iconElement) {
        switch (type) {
            case 'success':
                iconElement.className = 'fas fa-check-circle text-success';
                alertLabel.textContent = settings.title || 'Success';
                break;
            case 'error':
            case 'danger':
                iconElement.className = 'fas fa-exclamation-circle text-danger';
                alertLabel.textContent = settings.title || 'Error';
                break;
            case 'warning':
                iconElement.className = 'fas fa-exclamation-triangle text-warning';
                alertLabel.textContent = settings.title || 'Warning';
                break;
            default:
                iconElement.className = 'fas fa-info-circle text-primary';
                alertLabel.textContent = settings.title || 'Information';
        }
    }

    modalInstance.show();
}

function openNoticeModal(message, type = 'info') {
    const modalElement = document.getElementById('noticeModal');
    const messageElement = document.getElementById('noticeMessageContent');
    const noticeIcon = document.getElementById('noticeIcon');
    const noticeLabel = document.getElementById('noticeModalLabel');

    if (!modalElement || !messageElement || !noticeIcon || !noticeLabel) {
        console.error('Notice modal elements not found');
        window.alert(message);
        return;
    }

    messageElement.textContent = message;
    hideActiveModals(modalElement.id);

    const modalInstance = bootstrap.Modal.getOrCreateInstance(modalElement);
    const iconElement = noticeIcon.querySelector('i');

    if (iconElement) {
        switch (type) {
            case 'success':
                iconElement.className = 'fas fa-check-circle text-success';
                noticeLabel.textContent = 'Success';
                break;
            case 'error':
                iconElement.className = 'fas fa-exclamation-circle text-danger';
                noticeLabel.textContent = 'Error';
                break;
            case 'warning':
                iconElement.className = 'fas fa-exclamation-triangle text-warning';
                noticeLabel.textContent = 'Warning';
                break;
            default:
                iconElement.className = 'fas fa-bell text-warning';
                noticeLabel.textContent = 'Notice';
        }
    }

    modalInstance.show();
}

// Global functions for backward compatibility
window.openConfirmationModal = openConfirmationModal;
window.openAlertModal = openAlertModal;
window.openNoticeModal = openNoticeModal;
