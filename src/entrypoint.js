import "./styles/main.sass";

import { themeChange } from "theme-change";
themeChange();

document.addEventListener("DOMContentLoaded", () => {
  // Toggle search field input visibility
  document.getElementById("search-toggle").addEventListener("click", () => {
    const searchField = document.getElementById("search-field");
    const searchButton = document.getElementById("search-toggle");
    const isVisible = searchField.classList.contains("search-visible");

    if (isVisible) {
      // Hide the search input field
      searchField.classList.remove("search-visible");
      searchField.classList.add("search-hidden");
      // Change the search-toggle button's right side to rounded
      searchButton.classList.remove("!rounded-r-none");
      searchButton.classList.add("!rounded-r-full");
    } else {
      // Show the search input field
      searchField.classList.remove("search-hidden");
      searchField.classList.add("search-visible");
      // Change the search-toggle button's right side to square
      searchButton.classList.remove("!rounded-r-full");
      searchButton.classList.add("!rounded-r-none");
    }
  });
});
