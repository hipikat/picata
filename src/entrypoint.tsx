import "./styles/main.sass";

// Set listeners on data-set-theme attributes to change the theme
import { themeChange } from "theme-change";
themeChange();

document.addEventListener("DOMContentLoaded", () => {
  // Toggle search field input visibility

  const searchToggleButton = document.getElementById("search-toggle") as HTMLButtonElement | null;
  const searchField = document.getElementById("search-field") as HTMLElement | null;
  if (!searchToggleButton || !searchField) {
    console.error("Search toggle or search field elements not found.");
    return;
  }

  searchToggleButton.addEventListener("click", () => {
    // Toggle visibility states
    const isVisible = searchField.classList.toggle("search-visible");
    searchField.classList.toggle("search-hidden", !isVisible);

    // Adjust button styles and accessibility attributes
    searchToggleButton.classList.toggle("!rounded-r-none", isVisible);
    searchToggleButton.classList.toggle("!rounded-r-full", !isVisible);
    searchToggleButton.setAttribute("aria-expanded", isVisible.toString());
  });
});


import React from "react";
import ReactDOM from "react-dom/client";
import "./styles/main.sass";

// Import the HelloWorld component
import HelloWorld from "./components/HelloWorld";

document.addEventListener("DOMContentLoaded", () => {
  const rootElement = document.getElementById("root");

  if (rootElement) {
    const root = ReactDOM.createRoot(rootElement);
    root.render(<HelloWorld name="Piglet" />);
  }
});
