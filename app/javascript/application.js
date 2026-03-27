// T004: Bootstrap 5 + jQuery setup — Constitution Principle III (UX consistency)
//
// jQuery is provided by jquery-rails via the asset pipeline.
// Bootstrap JS bundle (includes Popper) loaded via CDN in <head>.
// This file handles app-specific JS initialisation.

// Initialise Bootstrap Alert instances so that the data-bs-dismiss="alert"
// click handler is wired for every .alert-dismissible on the page.
// Must run on both DOMContentLoaded (initial load) and turbo:load
// (subsequent Turbo Drive navigations) — T074.
function initFlashAlerts() {
  document.querySelectorAll(".alert-dismissible").forEach((el) => {
    bootstrap.Alert.getOrCreateInstance(el);
  });
}

// Auto-dismiss flash alerts after 4 seconds
function autoDismissFlash() {
  setTimeout(() => {
    document.querySelectorAll(".flash-auto-dismiss").forEach((el) => {
      const alert = bootstrap.Alert.getOrCreateInstance(el);
      alert.close();
    });
  }, 4000);
}

function onPageLoad() {
  initFlashAlerts();
  autoDismissFlash();
}

document.addEventListener("DOMContentLoaded", onPageLoad);
document.addEventListener("turbo:load", onPageLoad);
