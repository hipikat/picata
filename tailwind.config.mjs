/** @type {import('tailwindcss').Config} */

import daisyui from "daisyui";

export default {
  content: ["./src/styles/main.sass", "./src/**/*.html", "./src/**/*.js"],
  plugins: [daisyui],
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
        },
      },
    ],
    logs: false,
  },
  theme: {
    extend: {
      colors: {
        "light-green-gray": "#e9f0e9", // Custom color
      },
    },
  },
  variants: {
    extend: {},
  },
};
