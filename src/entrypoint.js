import "./styles/main.sass";

// Set listeners on data-set-theme attributes to change the theme
import { themeChange } from "theme-change";
themeChange();

document.addEventListener("DOMContentLoaded", () => {
  // Toggle search field input visibility
  document.getElementById("search-toggle").addEventListener("click", () => {
    const searchField = document.getElementById("search-field");
    const searchButton = document.getElementById("search-toggle");
    const isVisible = searchField.classList.toggle("search-visible");
    searchField.classList.toggle("search-hidden", !isVisible);
    searchButton.classList.toggle("!rounded-r-none", isVisible);
    searchButton.classList.toggle("!rounded-r-full", !isVisible);
    searchButton.setAttribute("aria-expanded", isVisible);
  });
});
