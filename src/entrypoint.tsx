import "./styles.sass";

// Set listeners on data-set-theme attributes to change the theme
import { themeChange } from "theme-change";
themeChange();

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

// Main DOMContentLoaded Listener
document.addEventListener("DOMContentLoaded", () => {
  initializeSearchFieldToggle();
  initializeThemeReset();
});

// // Ensure React's working
// import React from "react";
// import ReactDOM from "react-dom/client";

// // Import the HelloWorld component
// import HelloWorld from "./components/HelloWorld";

// document.addEventListener("DOMContentLoaded", () => {
//   const rootElement = document.getElementById("root");

//   if (rootElement) {
//     const root = ReactDOM.createRoot(rootElement);
//     root.render(<HelloWorld name="Piglet!!!!" />);
//   }
// });
