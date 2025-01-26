import "./styles.sass";

const THEMES = {
  light: "fl",
  dark: "ad",
};

// Set listeners on data-set-theme attributes to change the theme
import { themeChange } from "theme-change";
themeChange();

//
// Theme "reset to system defaults", and "light"/"dark" data-theme-mode logic
//
function initializeThemeReset() {
  const themeReset = document.querySelector<HTMLSpanElement>("#theme-reset");
  const themeButtons = document.querySelectorAll<HTMLButtonElement>("[data-set-theme]");

  const updateThemeMode = () => {
    const theme = document.documentElement.getAttribute("data-theme");
    if (theme === THEMES.dark || theme === THEMES.light) {
      document.documentElement.setAttribute(
        "data-theme-mode",
        theme === THEMES.dark ? "dark" : "light",
      );
    } else {
      const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
      document.documentElement.setAttribute("data-theme-mode", prefersDark ? "dark" : "light");
    }
  };

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

  // Initialize on page load
  updateThemeMode();
  updateThemeResetButtonVisibility();

  // Add a listener for system preference changes
  const prefersDarkQuery = window.matchMedia("(prefers-color-scheme: dark)");
  prefersDarkQuery.addEventListener("change", () => {
    if (!document.documentElement.getAttribute("data-theme")) {
      updateThemeMode();
    }
  });

  // Monitor changes to the data-theme attribute
  const themeChangeObserver = new MutationObserver(() => {
    updateThemeMode();
    updateThemeResetButtonVisibility();
  });
  themeChangeObserver.observe(document.documentElement, {
    attributes: true,
    attributeFilter: ["data-theme"],
  });

  // Add click listener for the reset button
  if (themeReset) {
    themeReset.addEventListener("click", () => {
      document.documentElement.removeAttribute("data-theme");
      localStorage.removeItem("theme");

      themeButtons.forEach((button) => {
        button.classList.remove("btn-active");
      });

      updateThemeMode();
      updateThemeResetButtonVisibility();
    });
  } else {
    console.error("Could not find #theme-reset element.");
  }

  // Add listeners to theme buttons to toggle "btn-active" class
  themeButtons.forEach((button) => {
    button.addEventListener("click", () => {
      const newTheme = button.getAttribute("data-set-theme");
      if (newTheme) {
        document.documentElement.setAttribute("data-theme", newTheme);
        localStorage.setItem("theme", newTheme);
      }

      themeButtons.forEach((btn) => btn.classList.remove("btn-active"));
      button.classList.add("btn-active");

      updateThemeMode();
    });
  });
}

//
// Search field toggling logic
//
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
// Apply shadows to the right of code blocks when they overflow their container
//
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

//
// Create the nested list of internal page links for a 'Page Contents' container
//
function renderPageContents(): void {
  const tocContainer = document.querySelector("main nav .toc");
  if (!tocContainer) return;

  // Create the header for the navigation
  const tocHeader = document.createElement("h2");
  tocHeader.textContent = "In this page";
  tocContainer.appendChild(tocHeader);

  // Create the root list
  const tocList = document.createElement("ul");
  tocContainer.appendChild(tocList);

  // Stack to track the current list level
  const listStack: HTMLUListElement[] = [tocList];
  let currentLevel = 1;

  // Find all anchor-linked headings inside articles
  const headings = document.querySelectorAll<HTMLElement>(
    "article h1[id], article h2[id], article h3[id], article h4[id], article h5[id], article h6[id]",
  );

  headings.forEach((heading) => {
    const headingLevel = parseInt(heading.tagName.substring(1));

    // Adjust the stack to match the heading level
    while (headingLevel > currentLevel) {
      // Create intermediate sub-lists for skipped levels
      const newList = document.createElement("ul");
      const lastItem = listStack[listStack.length - 1].lastElementChild;

      if (lastItem) {
        lastItem.appendChild(newList);
        listStack.push(newList);
      } else {
        // If no previous item exists, append directly to the current list
        listStack[listStack.length - 1].appendChild(newList);
        listStack.push(newList);
      }
      currentLevel++;
    }

    while (headingLevel < currentLevel) {
      // Pop back to the parent list
      listStack.pop();
      currentLevel--;
    }

    // Add the heading to the current list
    const listItem = document.createElement("li");
    const link = document.createElement("a");

    // Get heading text without pilcrow
    link.href = `#${heading.id}`;
    link.textContent = heading.textContent?.replace("¶", "").trim() || "Untitled"; // Remove pilcrow
    listItem.appendChild(link);

    listStack[listStack.length - 1].appendChild(listItem);
  });
}

// function enableStickyTOC(): void {
//   const tocContainer = document.querySelector<HTMLElement>(".toc > div");
//   if (!tocContainer) return;

//   const parentContainer = tocContainer.parentElement;
//   if (!parentContainer) return;

//   const offsetTop = 16; // Equivalent to Tailwind's `top-4`
//   const marginRight = 16; // Equivalent to Tailwind's `-mr-4`

//   const initialTop = parentContainer.getBoundingClientRect().top + window.scrollY;
//   const parentStyles = getComputedStyle(parentContainer);

//   window.addEventListener("scroll", () => {
//     const currentScroll = window.scrollY;
//     const stickyStart = initialTop - offsetTop;

//     if (currentScroll >= stickyStart) {
//       tocContainer.classList.add("is-fixed");

//       tocContainer.style.position = "fixed";
//       tocContainer.style.top = `${offsetTop}px`;
//       tocContainer.style.maxHeight = `calc(100vh - ${offsetTop}px)`;
//       tocContainer.style.overflowY = "auto";

//       // Dynamically calculate width and right offset
//       const parentWidth = parentContainer.getBoundingClientRect().width;
//       tocContainer.style.width = `${parentWidth}px`;
//       tocContainer.style.padding = parentStyles.padding; // Preserve padding
//       tocContainer.style.right = `${marginRight}px`; // Apply negative right margin
//     } else {
//       tocContainer.classList.remove("is-fixed");

//       tocContainer.style.position = "relative";
//       tocContainer.style.top = "initial";
//       tocContainer.style.maxHeight = "initial";
//       tocContainer.style.overflowY = "initial";

//       // Reset dynamically applied styles
//       tocContainer.style.width = "initial";
//       tocContainer.style.padding = "initial";
//       tocContainer.style.right = "initial"; // Reset right offset
//     }
//   });
// }

//
// Main DOMContentLoaded Listener
//
document.addEventListener("DOMContentLoaded", () => {
  initializeThemeReset();
  initializeSearchFieldToggle();
  initializeCodeBlockOverflowWatchers();
  renderPageContents();
  // enableStickyTOC();
});
