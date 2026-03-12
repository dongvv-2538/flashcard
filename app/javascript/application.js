// T004: Bootstrap 5 + jQuery setup — Constitution Principle III (UX consistency)
//
// jQuery is provided by jquery-rails via the asset pipeline.
// Bootstrap JS bundle (includes Popper) loaded via CDN in layout.
// This file handles app-specific JS initialisation.

// Auto-dismiss flash alerts after 4 seconds
document.addEventListener("DOMContentLoaded", () => {
  setTimeout(() => {
    document.querySelectorAll(".flash-auto-dismiss").forEach((el) => {
      const alert = bootstrap.Alert.getOrCreateInstance(el);
      alert.close();
    });
  }, 4000);
});
