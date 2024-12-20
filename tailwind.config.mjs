/** @type {import('tailwindcss').Config} */

import daisyui from "daisyui";
import typography from "@tailwindcss/typography";

export default {
  content: ["./src/*.sass", "./src/**/*.html", "./src/**/*.{js,jsx,ts,tsx}"],
  options: {
    safelist: ["size-5", "group-hover:opacity-100"],
  },
  plugins: [daisyui, typography],
  daisyui: {
    themes: [
      {
        ad: {
          primary: "#b6b8e6",
          secondary: "#99c9bc",
          accent: "#ffc293",
          neutral: "#3b5d6e",
          "base-100": "#1b303b",
          info: "#18bdcf",
          success: "#40b78e",
          warning: "#b6b14d",
          error: "#f38fa1",
          "--tw-theme-ring": "#b6b8e6",
        },
        fl: {
          primary: "#134f62",
          secondary: "#583c5b",
          accent: "#00b3a9",
          neutral: "#1f1008",
          "base-100": "#e9e5e4",
          info: "#71bcfe",
          success: "#7fbb70",
          warning: "#daba00",
          error: "#f57592",
          "--tw-theme-ring": "#134f62",
        },
      },
    ],
    logs: false,
  },
  theme: {
    extend: {
      colors: {
        "profile-ring": "var(--tw-theme-ring)",
      },
      maxWidth: {
        sm: "53rem",
        md: "53rem",
        lg: "62rem",
        xl: "72rem",
        "2xl": "86rem",
      },
      padding: {
        "safe-left": "env(safe-area-inset-left)",
        "safe-right": "env(safe-area-inset-right)",
      },
      margin: {
        "neg-safe-left": "calc(-1 * env(safe-area-inset-left))",
        "neg-safe-right": "calc(-1 * env(safe-area-inset-right))",
      },
    },
  },
  variants: {
    extend: {},
  },
};
