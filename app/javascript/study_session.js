// T042 — Card flip interaction for the study session view
//
// Clicking "Show Answer" reveals the card back panel and rating buttons,
// then hides the "Show Answer" button section.
// Uses vanilla JS (with jQuery available via jquery-rails) so this works
// regardless of whether the page loads via Turbo or a full navigation.

document.addEventListener("DOMContentLoaded", () => {
  const showAnswerBtn = document.getElementById("show-answer-btn");
  if (!showAnswerBtn) return; // Only active on study session show page

  showAnswerBtn.addEventListener("click", () => {
    // Reveal card back
    const cardBack = document.getElementById("card-back");
    if (cardBack) {
      cardBack.style.display = "";
      cardBack.removeAttribute("hidden");
    }

    // Hide "Show Answer" section
    const showAnswerSection = document.getElementById("show-answer-section");
    if (showAnswerSection) {
      showAnswerSection.style.display = "none";
    }

    // Reveal rating buttons
    const ratingSection = document.getElementById("rating-section");
    if (ratingSection) {
      ratingSection.style.display = "";
      ratingSection.removeAttribute("hidden");

      // Move focus to the first rating button for keyboard accessibility
      const firstBtn = ratingSection.querySelector("button, input[type=submit]");
      if (firstBtn) firstBtn.focus();
    }
  });
});
