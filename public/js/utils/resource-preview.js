/**
 * Shared Resource Preview Module
 * Handles preview functionality for all file types and links
 * Used by: resources_management.js, student_dashboard.js, counselor_dashboard.js
 */

// ========== YOUTUBE API ==========
let youtubePlayer = null;

function loadYouTubeAPI() {
  if (window.YT) return;
  const tag = document.createElement("script");
  tag.src = "https://www.youtube.com/iframe_api";
  const firstScriptTag = document.getElementsByTagName("script")[0];
  firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
}

window.onYouTubeIframeAPIReady = function () {
  console.log("YouTube IFrame API Ready");
};

// Load YouTube API on module load
loadYouTubeAPI();

// ========== ZOOM FUNCTIONALITY ==========
let currentPreviewZoom = 100;
let isPreviewDragging = false;
let previewStartX, previewStartY, previewScrollLeft, previewScrollTop;

function initPreviewZoom() {
  const wrapper = document.getElementById("previewZoomWrapper");
  const content = document.getElementById("previewContent");

  if (!wrapper || !content) return;

  wrapper.addEventListener(
    "wheel",
    function (e) {
      e.preventDefault();
      if (e.deltaY < 0) {
        zoomPreview("in");
      } else {
        zoomPreview("out");
      }
    },
    { passive: false }
  );

  wrapper.addEventListener("mousedown", startPreviewDragging);
  wrapper.addEventListener("mousemove", dragPreview);
  wrapper.addEventListener("mouseup", stopPreviewDragging);
  wrapper.addEventListener("mouseleave", stopPreviewDragging);

  wrapper.addEventListener("touchstart", handlePreviewTouchStart, {
    passive: false,
  });
  wrapper.addEventListener("touchmove", handlePreviewTouchMove, {
    passive: false,
  });
  wrapper.addEventListener("touchend", stopPreviewDragging);
}

function zoomPreview(direction) {
  const content = document.getElementById("previewContent");
  const zoomDisplay = document.querySelector(".zoom-level-display");
  const wrapper = document.getElementById("previewZoomWrapper");

  if (!content) return;

  if (direction === "in") {
    currentPreviewZoom = Math.min(currentPreviewZoom + 25, 400);
  } else if (direction === "out") {
    currentPreviewZoom = Math.max(currentPreviewZoom - 25, 25);
  }

  content.style.transform = `scale(${currentPreviewZoom / 100})`;
  content.style.transformOrigin = "top left";

  if (zoomDisplay) {
    zoomDisplay.textContent = `${currentPreviewZoom}%`;
  }

  if (wrapper) {
    wrapper.style.cursor = currentPreviewZoom > 100 ? "grab" : "default";
  }
}

function resetPreviewZoom() {
  currentPreviewZoom = 100;
  const content = document.getElementById("previewContent");
  const zoomDisplay = document.querySelector(".zoom-level-display");
  const wrapper = document.getElementById("previewZoomWrapper");

  if (content) {
    content.style.transform = "scale(1)";
  }
  if (zoomDisplay) {
    zoomDisplay.textContent = "100%";
  }
  if (wrapper) {
    wrapper.scrollLeft = 0;
    wrapper.scrollTop = 0;
    wrapper.style.cursor = "default";
  }
}

function startPreviewDragging(e) {
  if (currentPreviewZoom <= 100) return;

  isPreviewDragging = true;
  const wrapper = document.getElementById("previewZoomWrapper");
  if (wrapper) {
    wrapper.style.cursor = "grabbing";
    previewStartX = e.pageX - wrapper.offsetLeft;
    previewStartY = e.pageY - wrapper.offsetTop;
    previewScrollLeft = wrapper.scrollLeft;
    previewScrollTop = wrapper.scrollTop;
  }
}

function dragPreview(e) {
  if (!isPreviewDragging) return;
  e.preventDefault();

  const wrapper = document.getElementById("previewZoomWrapper");
  if (wrapper) {
    const x = e.pageX - wrapper.offsetLeft;
    const y = e.pageY - wrapper.offsetTop;
    const walkX = (x - previewStartX) * 2;
    const walkY = (y - previewStartY) * 2;

    wrapper.scrollLeft = previewScrollLeft - walkX;
    wrapper.scrollTop = previewScrollTop - walkY;
  }
}

function stopPreviewDragging() {
  isPreviewDragging = false;
  const wrapper = document.getElementById("previewZoomWrapper");
  if (wrapper && currentPreviewZoom > 100) {
    wrapper.style.cursor = "grab";
  }
}

function handlePreviewTouchStart(e) {
  if (currentPreviewZoom <= 100) return;

  const touch = e.touches[0];
  const wrapper = document.getElementById("previewZoomWrapper");

  if (wrapper) {
    isPreviewDragging = true;
    previewStartX = touch.pageX - wrapper.offsetLeft;
    previewStartY = touch.pageY - wrapper.offsetTop;
    previewScrollLeft = wrapper.scrollLeft;
    previewScrollTop = wrapper.scrollTop;
  }
}

function handlePreviewTouchMove(e) {
  if (!isPreviewDragging) return;
  e.preventDefault();

  const touch = e.touches[0];
  const wrapper = document.getElementById("previewZoomWrapper");

  if (wrapper) {
    const x = touch.pageX - wrapper.offsetLeft;
    const y = touch.pageY - wrapper.offsetTop;
    const walkX = (x - previewStartX) * 2;
    const walkY = (y - previewStartY) * 2;

    wrapper.scrollLeft = previewScrollLeft - walkX;
    wrapper.scrollTop = previewScrollTop - walkY;
  }
}

// ========== YOUTUBE UTILITIES ==========
function extractYouTubeID(url) {
  if (!url) return null;

  const patterns = [
    /(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\n?#]+)/,
    /^([a-zA-Z0-9_-]{11})$/,
  ];

  for (const pattern of patterns) {
    const match = url.match(pattern);
    if (match && match[1]) {
      return match[1];
    }
  }

  return null;
}

function isYouTubeURL(url) {
  if (!url) return false;
  return /(?:youtube\.com|youtu\.be)/.test(url);
}

function previewYouTube(videoId, resource) {
  const modalBody = document.getElementById("previewModalBody");

  modalBody.innerHTML = `
    <div class="youtube-preview-container" style="background: #000; padding: 2rem; border-radius: 8px; min-height: 500px;">
      <div id="youtubePlayer" style="max-width: 100%; margin: 0 auto;"></div>
    </div>
  `;

  setTimeout(() => {
    if (window.YT && window.YT.Player) {
      createYouTubePlayer(videoId);
    } else {
      document.getElementById("youtubePlayer").innerHTML = `
        <iframe width="100%" height="500" 
          src="https://www.youtube.com/embed/${videoId}?autoplay=0&rel=0&modestbranding=1" 
          frameborder="0" 
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
          allowfullscreen
          style="border-radius: 8px;">
        </iframe>
      `;
    }
  }, 100);
}

function createYouTubePlayer(videoId) {
  if (youtubePlayer) {
    youtubePlayer.destroy();
  }

  youtubePlayer = new YT.Player("youtubePlayer", {
    height: "500",
    width: "100%",
    videoId: videoId,
    playerVars: {
      autoplay: 0,
      rel: 0,
      modestbranding: 1,
      controls: 1,
    },
    events: {
      onReady: onPlayerReady,
      onError: onPlayerError,
    },
  });
}

function onPlayerReady(event) {
  console.log("YouTube player ready");
}

function onPlayerError(event) {
  console.error("YouTube player error:", event.data);
  const modalBody = document.getElementById("previewModalBody");
  modalBody.innerHTML = `
    <div class="text-center py-5">
      <i class="fab fa-youtube fa-4x text-danger mb-3"></i>
      <h5>Unable to Load Video</h5>
      <p class="text-danger">This video may be unavailable or restricted.</p>
    </div>
  `;
}

function showLinkPreview(url, resource) {
  const modalBody = document.getElementById("previewModalBody");

  modalBody.innerHTML = `
    <div class="text-center py-5">
      <i class="fas fa-external-link-alt fa-4x text-primary mb-3"></i>
      <h5>External Link</h5>
      <p class="text-muted">${escapeHtml(url)}</p>
      <div class="mt-4">
        <button class="btn btn-primary" onclick="window.ResourcePreview.openLink('${escapeHtml(url)}')">
          <i class="fas fa-external-link-alt me-2"></i>Open Link
        </button>
      </div>
    </div>
  `;
}

// ========== IMAGE PREVIEW ==========
function previewImageWithZoom(fileUrl, resource) {
  const modalBody = document.getElementById("previewModalBody");

  modalBody.innerHTML = `
    <div class="preview-zoom-container">
      <div class="preview-zoom-toolbar">
        <button class="btn btn-sm btn-secondary" onclick="window.ResourcePreview.zoomPreview('out')" title="Zoom Out">
          <i class="fas fa-search-minus"></i>
        </button>
        <button class="btn btn-sm btn-secondary" onclick="window.ResourcePreview.resetPreviewZoom()" title="Reset Zoom">
          <i class="fas fa-compress"></i>
        </button>
        <button class="btn btn-sm btn-secondary" onclick="window.ResourcePreview.zoomPreview('in')" title="Zoom In">
          <i class="fas fa-search-plus"></i>
        </button>
        <span class="zoom-level-display ms-3">100%</span>
        <button class="btn btn-sm btn-primary ms-auto" onclick="window.ResourcePreview.downloadResource(${resource.id})">
          <i class="fas fa-download me-2"></i>Download Original
        </button>
      </div>
      <div class="preview-zoom-wrapper" id="previewZoomWrapper">
        <img src="${fileUrl}" 
             id="previewContent" 
             class="preview-content-image" 
             alt="${escapeHtml(resource.title)}"
             style="max-width: 100%; height: auto; display: block; margin: 0 auto;">
      </div>
    </div>
  `;
  initPreviewZoom();
}

// ========== VIDEO PREVIEW ==========
function previewVideo(fileUrl, fileName, fileType, resource) {
  const modalBody = document.getElementById("previewModalBody");

  let mimeType = fileType;
  if (!mimeType || mimeType === "application/octet-stream") {
    if (fileName.endsWith(".mp4")) mimeType = "video/mp4";
    else if (fileName.endsWith(".webm")) mimeType = "video/webm";
    else if (fileName.endsWith(".ogg")) mimeType = "video/ogg";
    else if (fileName.endsWith(".mov")) mimeType = "video/mp4";
    else mimeType = "video/mp4";
  }

  modalBody.innerHTML = `
    <div class="video-preview-container" style="background: #1a1a1a; padding: 2rem; border-radius: 8px; min-height: 500px;">
      <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 450px;">
        <video id="previewVideo" 
               controls 
               preload="metadata" 
               style="width: 100%; max-width: 100%; max-height: 70vh; border-radius: 8px; box-shadow: 0 8px 24px rgba(0,0,0,0.4);"
               crossorigin="anonymous">
          <source src="${fileUrl}" type="${mimeType}">
          <source src="${fileUrl}">
          <p class="text-center text-white mt-3">Your browser does not support the video format. <a href="${fileUrl}" download class="text-info">Download the video</a> to view it.</p>
        </video>
        <div class="mt-3 text-center">
          <button class="btn btn-sm btn-outline-light" onclick="window.ResourcePreview.downloadResource(${resource.id})">
            <i class="fas fa-download me-2"></i>Download Video
          </button>
        </div>
      </div>
    </div>
  `;

  setTimeout(() => {
    const video = document.getElementById("previewVideo");
    if (video) {
      const container = video.parentElement;
      const loadingDiv = document.createElement("div");
      loadingDiv.id = "videoLoading";
      loadingDiv.className = "text-center text-white mb-3";
      loadingDiv.innerHTML = `
        <div class="spinner-border text-light" role="status">
          <span class="visually-hidden">Loading video...</span>
        </div>
        <p class="mt-2 mb-0">Loading video...</p>
      `;
      container.insertBefore(loadingDiv, video);
      video.style.display = "none";

      video.onloadedmetadata = function () {
        const loading = document.getElementById("videoLoading");
        if (loading) loading.remove();
        video.style.display = "block";
      };

      video.onloadeddata = function () {
        const loading = document.getElementById("videoLoading");
        if (loading) loading.remove();
        video.style.display = "block";
      };

      video.onerror = function (e) {
        console.error("Video error:", e);
        const errorMessages = {
          1: "Video loading was aborted",
          2: "A network error occurred while loading the video",
          3: "Video decoding failed - the format may not be supported",
          4: "Video format is not supported by your browser",
        };

        const errorCode = video.error ? video.error.code : 0;
        const errorMsg = errorMessages[errorCode] || "An unknown error occurred";

        modalBody.innerHTML = `
          <div class="text-center py-5">
            <i class="fas fa-video fa-4x text-danger mb-3"></i>
            <h5>Unable to Play Video</h5>
            <p class="text-muted">${escapeHtml(resource.file_name)}</p>
            <p class="text-danger">${errorMsg}</p>
            <div class="alert alert-warning mt-3 text-start" style="max-width: 600px; margin: 0 auto;">
              <strong>Troubleshooting:</strong>
              <ul class="mb-0 mt-2">
                <li>Try downloading the file to play it locally</li>
                <li>Check if the video file is corrupted</li>
                <li>Ensure the video is in MP4 (H.264) format for best compatibility</li>
                <li>Try opening in a different browser</li>
              </ul>
            </div>
            <div class="mt-4">
              <button class="btn btn-primary me-2" onclick="window.ResourcePreview.downloadResource(${resource.id})">
                <i class="fas fa-download me-2"></i>Download Video
              </button>
              <button class="btn btn-secondary" onclick="location.reload()">
                <i class="fas fa-sync me-2"></i>Refresh Page
              </button>
            </div>
          </div>
        `;
      };

      video.load();

      setTimeout(() => {
        if (video.readyState === 0) {
          video.onerror(new Event("timeout"));
        }
      }, 10000);
    }
  }, 100);
}

// ========== DOCX PREVIEW ==========
function previewDocxWithZoom(fileUrl, resource) {
  const modalBody = document.getElementById("previewModalBody");

  fetch(fileUrl)
    .then((response) => response.arrayBuffer())
    .then((arrayBuffer) => {
      if (typeof mammoth === "undefined") {
        throw new Error("Mammoth library not loaded");
      }
      return mammoth.convertToHtml({ arrayBuffer: arrayBuffer });
    })
    .then((result) => {
      modalBody.innerHTML = `
        <div class="preview-zoom-container">
          <div class="preview-zoom-toolbar">
            <button class="btn btn-sm btn-secondary" onclick="window.ResourcePreview.zoomPreview('out')" title="Zoom Out">
              <i class="fas fa-search-minus"></i>
            </button>
            <button class="btn btn-sm btn-secondary" onclick="window.ResourcePreview.resetPreviewZoom()" title="Reset Zoom">
              <i class="fas fa-compress"></i>
            </button>
            <button class="btn btn-sm btn-secondary" onclick="window.ResourcePreview.zoomPreview('in')" title="Zoom In">
              <i class="fas fa-search-plus"></i>
            </button>
            <span class="zoom-level-display ms-3">100%</span>
            <button class="btn btn-sm btn-primary ms-auto" onclick="window.ResourcePreview.downloadResource(${resource.id})">
              <i class="fas fa-download me-2"></i>Download Original
            </button>
          </div>
          <div class="preview-zoom-wrapper" id="previewZoomWrapper">
            <div id="previewContent" class="document-preview">
              ${result.value}
            </div>
          </div>
        </div>
      `;
      initPreviewZoom();

      if (result.messages.length > 0) {
        console.warn("Mammoth conversion warnings:", result.messages);
      }
    })
    .catch((error) => {
      console.error("Error previewing DOCX:", error);
      modalBody.innerHTML = `
        <div class="text-center py-5">
          <i class="fas fa-file-word fa-4x text-primary mb-3"></i>
          <h5>Unable to Preview Document</h5>
          <p class="text-muted">${escapeHtml(resource.file_name)}</p>
          <p class="text-danger">Preview failed: ${escapeHtml(error.message)}</p>
          <div class="mt-4">
            <button class="btn btn-primary" onclick="window.ResourcePreview.downloadResource(${resource.id})">
              <i class="fas fa-download me-2"></i>Download File
            </button>
          </div>
        </div>
      `;
    });
}

// ========== EXCEL PREVIEW ==========
function previewExcelWithZoom(fileUrl, resource) {
  const modalBody = document.getElementById("previewModalBody");

  fetch(fileUrl)
    .then((response) => response.arrayBuffer())
    .then((data) => {
      if (typeof XLSX === "undefined") {
        throw new Error("SheetJS library not loaded");
      }

      const workbook = XLSX.read(data, { type: "array" });

      let tabsHtml = '<ul class="nav nav-tabs mb-3" role="tablist">';
      let contentHtml = '<div class="tab-content">';

      workbook.SheetNames.forEach((sheetName, index) => {
        const isActive = index === 0 ? "active" : "";
        tabsHtml += `
          <li class="nav-item" role="presentation">
            <button class="nav-link ${isActive}" data-bs-toggle="tab" data-bs-target="#sheet-${index}" type="button">
              ${escapeHtml(sheetName)}
            </button>
          </li>
        `;

        const worksheet = workbook.Sheets[sheetName];
        const html = XLSX.utils.sheet_to_html(worksheet, {
          id: `sheet-${index}`,
        });

        contentHtml += `
          <div class="tab-pane fade ${isActive} show" id="sheet-${index}" role="tabpanel">
            <div class="excel-sheet-content">${html}</div>
          </div>
        `;
      });

      tabsHtml += "</ul>";
      contentHtml += "</div>";

      modalBody.innerHTML = `
        <div class="preview-zoom-container">
          <div class="preview-zoom-toolbar">
            <button class="btn btn-sm btn-secondary" onclick="window.ResourcePreview.zoomPreview('out')" title="Zoom Out">
              <i class="fas fa-search-minus"></i>
            </button>
            <button class="btn btn-sm btn-secondary" onclick="window.ResourcePreview.resetPreviewZoom()" title="Reset Zoom">
              <i class="fas fa-compress"></i>
            </button>
            <button class="btn btn-sm btn-secondary" onclick="window.ResourcePreview.zoomPreview('in')" title="Zoom In">
              <i class="fas fa-search-plus"></i>
            </button>
            <span class="zoom-level-display ms-3">100%</span>
            <button class="btn btn-sm btn-primary ms-auto" onclick="window.ResourcePreview.downloadResource(${resource.id})">
              <i class="fas fa-download me-2"></i>Download Original
            </button>
          </div>
          <div class="preview-zoom-wrapper" id="previewZoomWrapper">
            <div id="previewContent" class="excel-preview">
              ${workbook.SheetNames.length > 1 ? tabsHtml : ""}
              ${contentHtml}
            </div>
          </div>
        </div>
      `;
      initPreviewZoom();
    })
    .catch((error) => {
      console.error("Error previewing Excel:", error);
      modalBody.innerHTML = `
        <div class="text-center py-5">
          <i class="fas fa-file-excel fa-4x text-success mb-3"></i>
          <h5>Unable to Preview Spreadsheet</h5>
          <p class="text-muted">${escapeHtml(resource.file_name)}</p>
          <p class="text-danger">Preview failed: ${escapeHtml(error.message)}</p>
          <div class="mt-4">
            <button class="btn btn-primary" onclick="window.ResourcePreview.downloadResource(${resource.id})">
              <i class="fas fa-download me-2"></i>Download File
            </button>
          </div>
        </div>
      `;
    });
}

// ========== MAIN PREVIEW FUNCTION ==========
function previewResource(id, resources) {
  const resource = resources.find((r) => r.id == id);
  if (!resource) {
    if (typeof openAlertModal === 'function') {
      openAlertModal("Resource not found", "error");
    } else {
      alert("Resource not found");
    }
    return;
  }

  const modal = new bootstrap.Modal(document.getElementById("previewModal"));
  const modalBody = document.getElementById("previewModalBody");
  const modalTitle = document.getElementById("previewModalTitle");

  modalTitle.textContent = resource.title;

  modalBody.innerHTML = `
    <div class="text-center py-5">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Loading preview...</span>
      </div>
      <p class="mt-3 text-muted">Preparing preview...</p>
    </div>
  `;

  modal.show();

  // Handle External Links
  if (resource.resource_type === "link") {
    const url = resource.external_url;

    if (isYouTubeURL(url)) {
      const videoId = extractYouTubeID(url);
      if (videoId) {
        previewYouTube(videoId, resource);
      } else {
        showLinkPreview(url, resource);
      }
    } else {
      showLinkPreview(url, resource);
    }
    return;
  }

  // Handle File Resources
  const fileType = (resource.file_type || "").toLowerCase();
  const fileName = (resource.file_name || "").toLowerCase();
  const fileUrl = (window.BASE_URL || "/") + resource.file_path;

  // Image Preview
  if (fileType.includes("image") || /\.(jpg|jpeg|png|gif|bmp|webp)$/.test(fileName)) {
    previewImageWithZoom(fileUrl, resource);
  }
  // PDF Preview
  else if (fileType.includes("pdf") || fileName.endsWith(".pdf")) {
    modalBody.innerHTML = `
      <iframe src="${fileUrl}" width="100%" height="600px" style="border:none; border-radius: 8px;"></iframe>
    `;
  }
  // Video Preview
  else if (fileType.includes("video") || /\.(mp4|webm|ogg|mov)$/.test(fileName)) {
    previewVideo(fileUrl, fileName, fileType, resource);
  }
  // DOCX Preview
  else if (fileType.includes("wordprocessingml") || fileName.endsWith(".docx")) {
    previewDocxWithZoom(fileUrl, resource);
  }
  // Excel Preview
  else if (fileType.includes("spreadsheetml") || /\.(xlsx|xls)$/.test(fileName)) {
    previewExcelWithZoom(fileUrl, resource);
  }
  // PowerPoint Preview
  else if (fileType.includes("presentationml") || /\.(pptx|ppt)$/.test(fileName)) {
    const googleViewerUrl = `https://docs.google.com/gviewerembedded?url=${encodeURIComponent(fileUrl)}&embedded=true`;

    modalBody.innerHTML = `
      <div class="ppt-preview-container" style="min-height: 600px;">
        <div class="text-center py-3 mb-3">
          <div class="btn-group" role="group">
            <button type="button" class="btn btn-sm btn-outline-primary active" onclick="window.ResourcePreview.switchPPTViewer('google', '${escapeHtml(googleViewerUrl)}', '${escapeHtml(fileUrl)}', ${resource.id})">
              <i class="fas fa-eye me-1"></i>Google Viewer
            </button>
            <button type="button" class="btn btn-sm btn-outline-primary" onclick="window.ResourcePreview.switchPPTViewer('office', '${escapeHtml(googleViewerUrl)}', '${escapeHtml(fileUrl)}', ${resource.id})">
              <i class="fas fa-file-powerpoint me-1"></i>Office Online
            </button>
            <button type="button" class="btn btn-sm btn-outline-success" onclick="window.ResourcePreview.downloadResource(${resource.id})">
              <i class="fas fa-download me-1"></i>Download
            </button>
          </div>
        </div>
        <div id="pptViewerFrame">
          <iframe src="${googleViewerUrl}" 
                  width="100%" 
                  height="600px" 
                  style="border:none; border-radius: 8px; background: white;"
                  onload="window.ResourcePreview.handlePPTLoad()"
                  onerror="window.ResourcePreview.handlePPTError(${resource.id}, '${escapeHtml(resource.file_name)}')">
          </iframe>
        </div>
      </div>
    `;
  }
  // Unsupported
  else {
    modalBody.innerHTML = `
      <div class="text-center py-5">
        <i class="fas fa-file-alt fa-4x text-muted mb-3"></i>
        <h5>Preview not available</h5>
        <p class="text-muted">${escapeHtml(resource.file_name)}</p>
        <p class="text-muted">This file type cannot be previewed in the browser.</p>
        <button class="btn btn-primary mt-3" onclick="window.ResourcePreview.downloadResource(${resource.id})">
          <i class="fas fa-download me-2"></i>Download File
        </button>
      </div>
    `;
  }
}

// ========== HELPER FUNCTIONS ==========
function downloadResource(id) {
  // Determine the base URL path based on context
  let basePath = '';
  if (window.location.pathname.includes('/admin/')) {
    basePath = 'admin/resources/download/';
  } else if (window.location.pathname.includes('/counselor/')) {
    basePath = 'counselor/resources/download/';
  } else if (window.location.pathname.includes('/student/')) {
    basePath = 'student/resources/download/';
  } else {
    basePath = 'resources/download/';
  }
  
  window.location.href = (window.BASE_URL || "/") + basePath + id;
}

function openLink(url) {
  if (!url) {
    if (typeof openAlertModal === 'function') {
      openAlertModal("Invalid URL", "error");
    } else {
      alert("Invalid URL");
    }
    return;
  }
  window.open(url, "_blank", "noopener,noreferrer");
}

function switchPPTViewer(viewer, googleUrl, fileUrl, resourceId) {
  const frame = document.getElementById("pptViewerFrame");
  const buttons = document.querySelectorAll(".btn-group .btn-outline-primary");

  buttons.forEach((btn) => btn.classList.remove("active"));
  event.target.classList.add("active");

  if (viewer === "google") {
    frame.innerHTML = `
      <iframe src="${googleUrl}" 
              width="100%" 
              height="600px" 
              style="border:none; border-radius: 8px; background: white;">
      </iframe>
    `;
  } else if (viewer === "office") {
    const officeUrl = `https://view.officeapps.live.com/op/embed.aspx?src=${encodeURIComponent(fileUrl)}`;
    frame.innerHTML = `
      <iframe src="${officeUrl}" 
              width="100%" 
              height="600px" 
              style="border:none; border-radius: 8px; background: white;">
      </iframe>
    `;
  }
}

function handlePPTLoad() {
  console.log("PowerPoint viewer loaded successfully");
}

function handlePPTError(resourceId, fileName) {
  const frame = document.getElementById("pptViewerFrame");
  if (frame) {
    frame.innerHTML = `
      <div class="text-center py-5">
        <i class="fas fa-file-powerpoint fa-4x text-warning mb-3"></i>
        <h5>Preview Unavailable</h5>
        <p class="text-muted">${escapeHtml(fileName)}</p>
        <p class="text-muted">Unable to load preview. Please download the file to view it.</p>
        <div class="mt-4">
          <button class="btn btn-primary" onclick="window.ResourcePreview.downloadResource(${resourceId})">
            <i class="fas fa-download me-2"></i>Download File
          </button>
        </div>
      </div>
    `;
  }
}

function escapeHtml(text) {
  if (!text) return "";
  const div = document.createElement("div");
  div.textContent = text;
  return div.innerHTML;
}

// ========== CLEANUP ==========
function cleanupPreview() {
  currentPreviewZoom = 100;
  isPreviewDragging = false;

  if (youtubePlayer) {
    try {
      youtubePlayer.destroy();
      youtubePlayer = null;
    } catch (e) {
      console.log("YouTube player cleanup:", e);
    }
  }
}

// ========== EXPORT MODULE ==========
window.ResourcePreview = {
  previewResource,
  downloadResource,
  openLink,
  zoomPreview,
  resetPreviewZoom,
  switchPPTViewer,
  handlePPTLoad,
  handlePPTError,
  cleanupPreview
};

// Setup modal cleanup listener
document.addEventListener('DOMContentLoaded', function() {
  const previewModal = document.getElementById("previewModal");
  if (previewModal) {
    previewModal.addEventListener("hidden.bs.modal", cleanupPreview);
  }
});