// Enhanced Resource Management JavaScript - Now uses shared preview module
let resources = [];
let categories = [];
let isEditMode = false;

document.addEventListener("DOMContentLoaded", function () {
  console.log("Resources Management Initialized");
  console.log("BASE_URL:", window.BASE_URL);

  loadCategories();
  loadResources();
  setupEventListeners();
});

function setupEventListeners() {
  // Add Resource Button
  const addBtn = document.getElementById("addResourceBtn");
  if (addBtn) {
    addBtn.addEventListener("click", function () {
      isEditMode = false;
      resetForm();
      document.getElementById("resourceModalLabel").textContent =
        "Add Resource";
      const modal = new bootstrap.Modal(
        document.getElementById("resourceModal")
      );
      modal.show();
    });
  }

  // Resource Type Toggle
  document.querySelectorAll('input[name="resource_type"]').forEach((radio) => {
    radio.addEventListener("change", function () {
      toggleResourceType(this.value);
    });
  });

  // Form Submit
  const form = document.getElementById("resourceForm");
  if (form) {
    form.addEventListener("submit", function (e) {
      e.preventDefault();
      saveResource();
    });
  }

  // Filters
  document
    .getElementById("searchInput")
    ?.addEventListener("input", applyFilters);
  document
    .getElementById("typeFilter")
    ?.addEventListener("change", applyFilters);
  document
    .getElementById("categoryFilter")
    ?.addEventListener("change", applyFilters);
  document
    .getElementById("visibilityFilter")
    ?.addEventListener("change", applyFilters);
  document
    .getElementById("statusFilter")
    ?.addEventListener("change", applyFilters);

  // Clear Filters
  document
    .getElementById("clearFiltersBtn")
    ?.addEventListener("click", clearFilters);
}

function toggleResourceType(type) {
  const fileSection = document.getElementById("fileSection");
  const linkSection = document.getElementById("linkSection");
  const fileInput = document.getElementById("file");
  const urlInput = document.getElementById("external_url");

  if (type === "file") {
    fileSection.style.display = "block";
    linkSection.style.display = "none";
    fileInput.required = !isEditMode;
    urlInput.required = false;
  } else {
    fileSection.style.display = "none";
    linkSection.style.display = "block";
    fileInput.required = false;
    urlInput.required = true;
  }
}

function loadCategories() {
  const url = (window.BASE_URL || "/") + "admin/resources/categories";
  console.log("Loading categories from:", url);

  fetch(url)
    .then((response) => {
      console.log("Categories response status:", response.status);
      return response.json();
    })
    .then((data) => {
      console.log("Categories data:", data);
      if (data.success) {
        categories = data.categories;
        populateCategoryFilters();
      } else {
        console.error("Failed to load categories:", data.message);
      }
    })
    .catch((error) => {
      console.error("Error loading categories:", error);
    });
}

function populateCategoryFilters() {
  const categoryFilter = document.getElementById("categoryFilter");
  const categoryList = document.getElementById("categoryList");

  if (!categoryFilter || !categoryList) {
    console.error("Category filter elements not found");
    return;
  }

  // Clear existing options (except first)
  while (categoryFilter.options.length > 1) {
    categoryFilter.remove(1);
  }

  // Clear datalist
  categoryList.innerHTML = "";

  // Populate filter dropdown
  categories.forEach((cat) => {
    const option = document.createElement("option");
    option.value = cat.category;
    option.textContent = cat.category;
    categoryFilter.appendChild(option);
  });

  // Populate datalist for input
  categories.forEach((cat) => {
    const option = document.createElement("option");
    option.value = cat.category;
    categoryList.appendChild(option);
  });
}

function loadResources() {
  const filters = getFilterParams();
  const url =
    (window.BASE_URL || "/") +
    "admin/resources/get" +
    (filters ? "?" + filters : "");
  const listContainer = document.getElementById("resourcesList");

  console.log("Loading resources from:", url);

  if (listContainer) {
    listContainer.innerHTML = `
            <div class="text-center py-5">
                <div class="spinner-border text-primary" role="status" aria-hidden="true"></div>
                <p class="mt-2 text-muted">Loading resources...</p>
            </div>
        `;
  }

  fetch(url)
    .then((response) => {
      console.log("Resources response status:", response.status);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return response.json();
    })
    .then((data) => {
      console.log("Resources data:", data);
      if (data.success) {
        resources = data.resources || [];
        console.log("Loaded resources count:", resources.length);
        renderResources();
      } else {
        console.error("Failed to load resources:", data.message);
        showError(data.message || "Failed to load resources");
      }
    })
    .catch((error) => {
      console.error("Error loading resources:", error);
      showError("An error occurred while loading resources: " + error.message);
    });
}

function getFilterParams() {
  const params = new URLSearchParams();

  const search = document.getElementById("searchInput")?.value.trim();
  const type = document.getElementById("typeFilter")?.value;
  const category = document.getElementById("categoryFilter")?.value;
  const visibility = document.getElementById("visibilityFilter")?.value;
  const status = document.getElementById("statusFilter")?.value;

  if (search) params.append("search", search);
  if (type) params.append("resource_type", type);
  if (category) params.append("category", category);
  if (visibility) params.append("visibility", visibility);
  if (status !== "") params.append("is_active", status);

  return params.toString();
}

function applyFilters() {
  loadResources();
}

function clearFilters() {
  document.getElementById("searchInput").value = "";
  document.getElementById("typeFilter").value = "";
  document.getElementById("categoryFilter").value = "";
  document.getElementById("visibilityFilter").value = "";
  document.getElementById("statusFilter").value = "";
  loadResources();
}

function renderResources() {
  const container = document.getElementById("resourcesList");

  if (!container) {
    console.error("Resources list container not found");
    return;
  }

  if (!resources || resources.length === 0) {
    container.innerHTML = `
            <div class="empty-state">
                <i class="fas fa-folder-open"></i>
                <h4>No Resources Found</h4>
                <p>Start by adding your first resource</p>
            </div>
        `;
    return;
  }

  console.log("Rendering", resources.length, "resources");

  container.innerHTML = resources
    .map(
      (resource) => `
        <div class="resource-card" data-resource-id="${resource.id}">
            <div class="d-flex">
                <div class="resource-icon ${
                  resource.resource_type === "file" ? "file-icon" : "link-icon"
                }">
                    <i class="fas fa-${
                      resource.resource_type === "file" ? "file-alt" : "link"
                    }"></i>
                </div>
                <div class="flex-grow-1">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <div>
                            <h5 class="mb-1">${escapeHtml(resource.title)}</h5>
                            ${
                              resource.description
                                ? `<p class="text-muted mb-2">${escapeHtml(
                                    resource.description
                                  )}</p>`
                                : ""
                            }
                        </div>
                        <div class="text-end">
                            ${
                              resource.is_active == 1
                                ? '<span class="badge bg-success badge-status">Active</span>'
                                : '<span class="badge bg-secondary badge-status">Inactive</span>'
                            }
                        </div>
                    </div>
                    
                    <div class="d-flex flex-wrap gap-2 mb-2">
                        ${
                          resource.category
                            ? `<span class="badge bg-primary">${escapeHtml(
                                resource.category
                              )}</span>`
                            : ""
                        }
                        ${
                          resource.visibility !== "all"
                            ? `<span class="badge bg-info">${formatVisibility(
                                resource.visibility
                              )}</span>`
                            : ""
                        }
                        ${
                          resource.resource_type === "file" &&
                          resource.file_size_formatted
                            ? `<span class="badge bg-light text-dark">${resource.file_size_formatted}</span>`
                            : ""
                        }
                    </div>
                    
                    <div class="d-flex justify-content-between align-items-center">
                        <small class="text-muted">
                            <i class="fas fa-user me-1"></i>${escapeHtml(
                              resource.uploader_name || "Unknown"
                            )}
                            <i class="fas fa-calendar ms-3 me-1"></i>${
                              resource.created_at_formatted || "N/A"
                            }
                            ${
                              resource.view_count
                                ? `<i class="fas fa-eye ms-3 me-1"></i>${resource.view_count} views`
                                : ""
                            }
                            ${
                              resource.download_count
                                ? `<i class="fas fa-download ms-3 me-1"></i>${resource.download_count} downloads`
                                : ""
                            }
                        </small>
                        <div>
                            <button class="btn btn-sm btn-primary btn-action" onclick="previewResourceAdmin(${
                              resource.id
                            })" title="Preview">
                                <i class="fas fa-eye"></i>
                            </button>
                            ${
                              resource.resource_type === "file"
                                ? `<button class="btn btn-sm btn-success btn-action" onclick="downloadResource(${resource.id})" title="Download">
                                    <i class="fas fa-download"></i>
                                </button>`
                                : `<button class="btn btn-sm btn-info btn-action" onclick="window.ResourcePreview.openLink('${escapeHtml(
                                    resource.external_url || ""
                                  )}')" title="Open Link">
                                    <i class="fas fa-external-link-alt"></i>
                                </button>`
                            }
                            <button class="btn btn-sm btn-warning btn-action" onclick="editResource(${
                              resource.id
                            })" title="Edit">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button class="btn btn-sm btn-danger btn-action" onclick="confirmDeleteResource(${
                              resource.id
                            })" title="Delete">
                                <i class="fas fa-trash"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `
    )
    .join("");
}

// CHANGED: Use shared preview module
function previewResourceAdmin(id) {
  if (window.ResourcePreview && typeof window.ResourcePreview.previewResource === 'function') {
    window.ResourcePreview.previewResource(id, resources);
  } else {
    console.error('ResourcePreview module not loaded');
    alert('Preview feature is not available. Please refresh the page.');
  }
}

function resetForm() {
  const form = document.getElementById("resourceForm");
  if (form) form.reset();

  document.getElementById("resourceId").value = "";
  document.getElementById("typeFile").checked = true;
  toggleResourceType("file");
  document.getElementById("currentFile").style.display = "none";
  document.getElementById("is_active").checked = true;
  document.getElementById("file").required = true;
}

function editResource(id) {
  console.log("Editing resource:", id);

  if (!resources || resources.length === 0) {
    openAlertModal(
      "Resources not loaded. Please refresh the page and try again.",
      "error"
    );
    return;
  }

  const resource = resources.find((r) => r.id == id);

  if (!resource) {
    console.error("Resource not found with ID:", id);
    openAlertModal(
      "Unable to locate the selected resource. Please refresh and try again.",
      "error"
    );
    return;
  }

  isEditMode = true;
  resetForm();

  document.getElementById("resourceModalLabel").textContent = "Edit Resource";
  document.getElementById("resourceId").value = resource.id;
  document.getElementById("title").value = resource.title || "";
  document.getElementById("description").value = resource.description || "";
  document.getElementById("category").value = resource.category || "";
  document.getElementById("tags").value = resource.tags || "";
  document.getElementById("visibility").value = resource.visibility || "all";
  document.getElementById("is_active").checked = resource.is_active == 1;

  if (resource.resource_type === "link") {
    document.getElementById("typeLink").checked = true;
    document.getElementById("external_url").value = resource.external_url || "";
    toggleResourceType("link");
  } else {
    document.getElementById("typeFile").checked = true;
    toggleResourceType("file");
    document.getElementById("file").required = false;
    if (resource.file_name) {
      document.getElementById("currentFile").style.display = "block";
      document.getElementById("currentFileName").textContent =
        resource.file_name;
    }
  }

  const modal = new bootstrap.Modal(document.getElementById("resourceModal"));
  modal.show();
}

function saveResource() {
  const formData = new FormData(document.getElementById("resourceForm"));
  const resourceId = document.getElementById("resourceId").value;
  const isActive = document.getElementById("is_active").checked ? 1 : 0;

  formData.set("is_active", isActive);

  const url = resourceId
    ? (window.BASE_URL || "/") + "admin/resources/update/" + resourceId
    : (window.BASE_URL || "/") + "admin/resources/create";

  const saveBtn = document.getElementById("saveResourceBtn");
  if (!saveBtn) return;

  const originalText = saveBtn.innerHTML;
  saveBtn.disabled = true;
  saveBtn.innerHTML =
    '<span class="spinner-border spinner-border-sm me-2"></span>Saving...';

  fetch(url, {
    method: "POST",
    body: formData,
  })
    .then((response) => response.json())
    .then((data) => {
      saveBtn.disabled = false;
      saveBtn.innerHTML = originalText;

      if (data.success) {
        openAlertModal(
          data.message || "Resource saved successfully",
          "success"
        );
        const modalEl = document.getElementById("resourceModal");
        const modalInstance = bootstrap.Modal.getInstance(modalEl);
        if (modalInstance) modalInstance.hide();

        loadResources();
        loadCategories();
      } else {
        openAlertModal(data.message || "Failed to save resource", "error", {
          keepActiveModals: true,
        });
      }
    })
    .catch((error) => {
      console.error("Error saving resource:", error);
      saveBtn.disabled = false;
      saveBtn.innerHTML = originalText;
      openAlertModal(
        "An error occurred while saving: " + error.message,
        "error",
        { keepActiveModals: true }
      );
    });
}

function confirmDeleteResource(id) {
  if (!resources || resources.length === 0) {
    openAlertModal(
      "Resources not loaded. Please refresh the page and try again.",
      "error"
    );
    return;
  }

  const resource = resources.find((r) => r.id == id);

  if (!resource) {
    console.error("Resource not found with ID:", id);
    openAlertModal(
      "Unable to locate the selected resource. Please refresh and try again.",
      "error"
    );
    return;
  }

  openConfirmationModal(
    `Are you sure you want to delete "${resource.title}"? This action cannot be undone.`,
    (context = {}) => {
      const { confirmButton, setLoading, reset, close } = context;

      if (typeof setLoading === "function") {
        setLoading("Deleting...");
      } else if (confirmButton) {
        const originalText = confirmButton.innerHTML;
        confirmButton.disabled = true;
        confirmButton.innerHTML = `
                    <span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>Deleting...
                `;
        confirmButton.dataset.originalText = originalText;
      }

      deleteResourceRequest(id)
        .then((data) => {
          if (typeof close === "function") {
            close();
          }

          openAlertModal(
            data.message || "Resource deleted successfully",
            "success"
          );
          loadResources();
        })
        .catch((error) => {
          if (typeof close === "function") {
            close();
          }

          const message =
            (error && error.data && error.data.message) ||
            error?.message ||
            "An error occurred while deleting the resource";
          openAlertModal(message, "error");
        })
        .finally(() => {
          if (typeof reset === "function") {
            reset();
          } else if (confirmButton) {
            confirmButton.disabled = false;
            confirmButton.innerHTML =
              confirmButton.dataset.originalText ||
              '<i class="fas fa-trash me-2"></i>Delete';
            delete confirmButton.dataset.originalText;
          }
        });
    },
    {
      confirmButtonText: '<i class="fas fa-trash me-2"></i>Delete Resource',
      confirmButtonClass: "btn btn-danger",
      autoClose: false,
    }
  );
}

function deleteResourceRequest(id) {
  const url = (window.BASE_URL || "/") + "admin/resources/delete/" + id;

  return fetch(url, {
    method: "DELETE",
  }).then(async (response) => {
    let data = {};

    try {
      data = await response.json();
    } catch (parseError) {
      console.error("Failed to parse delete response", parseError);
    }

    if (!response.ok || !data.success) {
      const error = new Error(data.message || "Failed to delete resource");
      error.data = data;
      throw error;
    }

    return data;
  });
}

function downloadResource(id) {
  window.location.href =
    (window.BASE_URL || "/") + "admin/resources/download/" + id;
}

function formatVisibility(visibility) {
  const map = {
    all: "All Users",
    students: "Students Only",
    counselors: "Counselors Only",
  };
  return map[visibility] || visibility;
}

function escapeHtml(text) {
  if (!text) return "";
  const div = document.createElement("div");
  div.textContent = text;
  return div.innerHTML;
}

function showError(message) {
  const container = document.getElementById("resourcesList");
  if (container) {
    container.innerHTML = `
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle me-2"></i>${escapeHtml(
                  message
                )}
            </div>
        `;
  }
}

// Make functions globally available
window.editResource = editResource;
window.confirmDeleteResource = confirmDeleteResource;
window.downloadResource = downloadResource;
window.previewResourceAdmin = previewResourceAdmin;