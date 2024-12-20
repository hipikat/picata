import "./styles.sass";

// Set listeners on data-set-theme attributes to change the theme
import { themeChange } from "theme-change";
themeChange();

//
// Theme Reset Logic
function initializeThemeReset() {
  const themeReset = document.querySelector<HTMLSpanElement>("#theme-reset");
  const themeButtons = document.querySelectorAll<HTMLButtonElement>("[data-set-theme]");

  const updateThemeResetButtonVisibility = () => {
    if (themeReset) {
      const isThemeSet = document.documentElement.hasAttribute("data-theme");
      if (isThemeSet) {
        themeReset.classList.remove("hidden", "pointer-events-none");
      } else {
        themeReset.classList.add("hidden", "pointer-events-none");
      }
    }
  };

  // Set initial state for the #theme-reset button
  updateThemeResetButtonVisibility();

  // Monitor changes to the data-theme attribute on <html>
  const themeChangeObserver = new MutationObserver(updateThemeResetButtonVisibility);
  themeChangeObserver.observe(document.documentElement, {
    attributes: true,
    attributeFilter: ["data-theme"], // Only watch for changes to data-theme
  });

  // Add click listener for the reset button
  if (themeReset) {
    themeReset.addEventListener("click", () => {
      document.documentElement.removeAttribute("data-theme");
      localStorage.removeItem("theme");

      themeButtons.forEach((button) => {
        button.classList.remove("btn-active");
      });

      updateThemeResetButtonVisibility();
    });
  } else {
    console.error("Could not find #theme-reset element.");
  }

  // Add listeners to theme buttons to toggle "btn-active" class
  themeButtons.forEach((button) => {
    button.addEventListener("click", () => {
      themeButtons.forEach((btn) => btn.classList.remove("btn-active"));
      button.classList.add("btn-active");
    });
  });
}

//
// Search Field Toggle Logic
function initializeSearchFieldToggle() {
  const searchToggleButton = document.getElementById("search-toggle") as HTMLButtonElement | null;
  const searchField = document.getElementById("search-field") as HTMLElement | null;

  if (!searchToggleButton || !searchField) {
    console.error("Search toggle or search field elements not found.");
    return;
  }

  searchToggleButton.addEventListener("click", () => {
    const isVisible = searchField.classList.toggle("search-visible");
    searchField.classList.toggle("search-hidden", !isVisible);
    searchField.setAttribute("tabindex", isVisible ? "0" : "-1");
    searchToggleButton.classList.toggle("!rounded-r-none", isVisible);
    searchToggleButton.classList.toggle("!rounded-r-full", !isVisible);
    searchToggleButton.setAttribute("aria-expanded", isVisible.toString());
    if (isVisible) {
      searchField.focus();
    }
  });
}

//
// Apply shadows to the right of code blocks when they overflow their div
function initializeCodeBlockOverflowWatchers(): void {
  const pygmentsDivs: NodeListOf<HTMLDivElement> = document.querySelectorAll(".pygments");

  const applyOverflowClass = (div: HTMLDivElement) => {
    const pre = div.querySelector("pre");
    if (!pre) return;

    if (pre.scrollWidth > pre.clientWidth) {
      div.classList.add("shadow-fade-right");
    } else {
      div.classList.remove("shadow-fade-right");
    }
  };

  // Apply initial shadows
  pygmentsDivs.forEach(applyOverflowClass);

  // Add resize listener to recheck on window resize
  window.addEventListener("resize", () => {
    pygmentsDivs.forEach(applyOverflowClass);
  });
}

// Main DOMContentLoaded Listener
document.addEventListener("DOMContentLoaded", () => {
  initializeCodeBlockOverflowWatchers();
  initializeSearchFieldToggle();
  initializeThemeReset();
});

//
// Main DOMContentLoaded Listener
document.addEventListener("DOMContentLoaded", () => {
  initializeSearchFieldToggle();
  initializeThemeReset();
  initializeCodeBlockOverflowWatchers();
});
